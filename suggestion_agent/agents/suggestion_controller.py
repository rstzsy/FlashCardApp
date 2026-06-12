from datetime import datetime, timezone
from config.settings import (
    MINUTES_PER_WORD, MIN_DUE_RATIO, MAX_NEW_RATIO,
    OVERLOAD_THRESHOLD,
)
from integrations.firestore_service import FirestoreService
from integrations.gemini_service import generate_suggestion_reasons
from tools.priority_scorer import compute_priority
from schemas.suggestion_schema import (
    SuggestionRequest, SuggestionResponse, SuggestedWord, SessionMeta,
)


class SuggestionController:
    def __init__(self):
        self.db = FirestoreService()

    def run(self, request: SuggestionRequest) -> SuggestionResponse:
        user_id = request.userId
        session_duration = request.sessionDuration
        top_n = request.topN
        ctx = request.context

        streak_at_risk = ctx.streakAtRisk if ctx else False
        priority_set_id = ctx.currentSetId if ctx else None

        # ── Step 2: Collect data ─────────────────────────────────────────────
        user_profile = self.db.get_user_profile(user_id)
        user_profile_ext = self.db.get_user_profile_extended(user_id)
        fsrs_records = self.db.get_fsrs_cards(user_id)         # [{cardId, setId, ...}]
        user_sets = self.db.get_user_sets(user_id)             # [{SetId, Title, ...}]
        game_results = self.db.get_game_results(user_id)
        words_today = self.db.get_words_studied_today(user_id)

        set_ids = [s.get("SetId", "") for s in user_sets]

        # Pass user_sets to avoid a second Firestore query inside get_all_cards_for_user
        card_lookup = self.db.get_all_cards_for_user(user_id, set_ids, user_sets=user_sets)

        # Determine favourite & in-progress sets from game accuracy
        favourite_set_ids, in_progress_set_ids = self._classify_sets(
            user_sets, game_results, priority_set_id
        )

        # ── Step 3: Compute Priority Score ───────────────────────────────────
        scored: list[dict] = []

        fsrs_by_card: dict[str, dict] = {
            r.get("cardId", ""): r for r in fsrs_records if r.get("cardId")
        }

        for card_id, card_data in card_lookup.items():
            set_id = card_data.get("SetId", "")
            fsrs = fsrs_by_card.get(card_id, {"state": "new"})
            score, tag, due_days_ago = compute_priority(
                fsrs, set_id, favourite_set_ids, in_progress_set_ids, streak_at_risk
            )
            scored.append({
                "cardId": card_id,
                "setId": set_id,
                "word": card_data.get("Word", ""),
                "meaning": card_data.get("Meaning", ""),
                "phonetic": card_data.get("Phonetic"),
                "priority_score": score,
                "tag": tag,
                "due_days_ago": due_days_ago,
                # FSRS fields for Gemini prompt
                "lapses": fsrs.get("lapses", 0),
                "difficulty": fsrs.get("difficulty", 5.0),
                "state": fsrs.get("state", "new"),
                # Rich context for Gemini reasons
                "example": card_data.get("Example", ""),
                "topic": card_data.get("topic", ""),   # injected by FirestoreService
            })

        # ── Step 4: Smart filter & rank ──────────────────────────────────────
        max_words = max(1, session_duration // MINUTES_PER_WORD)

        # Reduce if already over-studied today
        if words_today > OVERLOAD_THRESHOLD:
            max_words = max(1, max_words // 2)

        # Cap at topN
        max_words = min(max_words, top_n)

        selected = self._smart_select(scored, max_words)

        # ── Step 5: Gemini reasons ───────────────────────────────────────────
        user_ctx_for_gemini = {
            "englishLevel": user_profile_ext.get(
                "englishLevel", user_profile.get("level", "beginner")
            ),
            "interests":    user_profile_ext.get("interests", "general"),
            "streak":       user_profile.get("streak", 0),
            "targetGoal":   user_profile_ext.get("targetGoal", ""),   # e.g. "IELTS 6.5"
            "streakAtRisk": streak_at_risk,
        }
        reasons = generate_suggestion_reasons(user_ctx_for_gemini, selected)

        # ── Step 6: Build response ───────────────────────────────────────────
        suggested_words = []
        due_count = new_count = review_count = 0

        for item in selected:
            tag = item["tag"]
            if tag in ("overdue", "due_today"):
                due_count += 1
            elif tag == "new_word":
                new_count += 1
            else:
                review_count += 1

            suggested_words.append(SuggestedWord(
                cardId=item["cardId"],
                setId=item["setId"],
                word=item["word"],
                meaning=item["meaning"],
                phonetic=item.get("phonetic"),
                priority_score=item["priority_score"],
                reason=reasons.get(item["cardId"], "Review this word today!"),
                tag=tag,
                due_days_ago=item.get("due_days_ago"),
            ))

        meta = SessionMeta(
            total_suggested=len(suggested_words),
            due_count=due_count,
            new_count=new_count,
            review_count=review_count,
            estimated_duration_min=len(suggested_words) * MINUTES_PER_WORD,
        )

        return SuggestionResponse(suggested_words=suggested_words, session_meta=meta)

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _classify_sets(
        self,
        user_sets: list[dict],
        game_results: list[dict],
        priority_set_id: str | None,
    ) -> tuple[list[str], list[str]]:
        """
        favourite : sets with avg accuracy ≥ 80 % or the currently active set.
        in_progress: sets with 40–80 % accuracy.
        """
        accuracy_by_set: dict[str, list[float]] = {}
        for r in game_results:
            sid = r.get("SetId", "")
            acc = float(r.get("Accuracy", 0))
            accuracy_by_set.setdefault(sid, []).append(acc)

        avg_acc = {sid: sum(v) / len(v) for sid, v in accuracy_by_set.items()}

        favourite, in_progress = [], []
        for s in user_sets:
            sid = s.get("SetId", "")
            acc = avg_acc.get(sid, 0)
            if sid == priority_set_id or acc >= 80:
                favourite.append(sid)
            elif 40 <= acc < 80:
                in_progress.append(sid)

        return favourite, in_progress

    def _smart_select(self, scored: list[dict], max_words: int) -> list[dict]:
        """
        Section-4 filtering logic:
          - ≥ 30 % must be due / overdue
          - ≤ 20 % new words
          - remainder filled by highest priority_score
        """
        due_pool  = [s for s in scored if s["tag"] in ("overdue", "due_today")]
        new_pool  = [s for s in scored if s["tag"] == "new_word"]
        rest_pool = [s for s in scored if s["tag"] not in ("overdue", "due_today", "new_word")]

        for pool in (due_pool, new_pool, rest_pool):
            pool.sort(key=lambda x: x["priority_score"], reverse=True)

        min_due = max(1, int(max_words * MIN_DUE_RATIO))
        max_new = max(0, int(max_words * MAX_NEW_RATIO))

        selected: list[dict] = []

        # 1. Guarantee due / overdue slots
        selected.extend(due_pool[:min_due])

        # 2. Fill new-word slots
        remaining = max_words - len(selected)
        new_slots = min(max_new, remaining)
        selected.extend(new_pool[:new_slots])

        # 3. Fill remainder with highest-priority leftovers
        remaining = max_words - len(selected)
        leftover = due_pool[min_due:] + new_pool[new_slots:] + rest_pool
        leftover.sort(key=lambda x: x["priority_score"], reverse=True)
        selected.extend(leftover[:remaining])

        # 4. Safety net — fill any remaining gap from the full pool
        if len(selected) < max_words:
            selected_ids = {s["cardId"] for s in selected}
            all_unused = [s for s in scored if s["cardId"] not in selected_ids]
            all_unused.sort(key=lambda x: x["priority_score"], reverse=True)
            selected.extend(all_unused[: max_words - len(selected)])

        return selected[:max_words]