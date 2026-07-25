from config.settings import MINUTES_PER_WORD, OVERLOAD_THRESHOLD, OVERLOAD_REDUCTION
from integrations.firestore_service import FirestoreService
from integrations.gemini_service import select_and_explain
from tools.candidate_pool import build_candidate_pool
from schemas.suggestion_schema import (
    SuggestionRequest,
    SuggestionResponse,
    SuggestedWord,
    SessionMeta,
)


def _compute_session_capacity(session_duration_min: int, words_studied_today: int) -> int:
    max_words = max(1, session_duration_min // MINUTES_PER_WORD)
    if words_studied_today > OVERLOAD_THRESHOLD:
        max_words = max(1, round(max_words * OVERLOAD_REDUCTION))
    return max_words


def _build_capacity_note(session_duration_min: int, max_words: int, requested_top_n: int) -> str | None:
    """Chỉ trả về note khi capacity thực tế bị giới hạn thấp hơn số user yêu cầu."""
    if max_words >= requested_top_n:
        return None
    return (
        f"Với {session_duration_min} phút, mình chỉ gợi ý được tối đa "
        f"{max_words} từ để bạn học kịp."
    )


class SuggestionController:
    def __init__(self):
        self.firestore = FirestoreService()

    def run(self, request: SuggestionRequest) -> SuggestionResponse:
        user_id = request.userId
        ctx = request.context
        current_set_id = ctx.currentSetId if ctx else None
        streak_at_risk = bool(ctx.streakAtRisk) if ctx else False

        # ── Step 2: fetch + merge FSRS stats with Flashcard content ─────────
        merged_cards, user_sets = self.firestore.get_full_cards_for_user(user_id)
        profile = self.firestore.get_user_profile(user_id)
        words_studied_today = self.firestore.get_words_studied_today(user_id)

        # ── Step 3: eligibility pool (mechanical, not scored) ───────────────
        candidates = build_candidate_pool(merged_cards, user_sets, current_set_id)

        # ── Step 4: hard capacity constraint ────────────────────────────────
        max_words = _compute_session_capacity(request.sessionDuration, words_studied_today)

        user_context = {
            "englishLevel": profile.get("englishLevel", "intermediate"),
            "targetGoal": profile.get("targetGoal", ""),
            "streak": profile.get("streak", 0),
        }
        session_ctx = {
            "currentSetId": current_set_id,
            "streakAtRisk": streak_at_risk,
            "max_words": max_words,
            "words_studied_today": words_studied_today,
        }

        # ── Step 5: Gemini selects, ranks, tags, explains ───────────────────
        decisions = select_and_explain(candidates, user_context, session_ctx, request.topN)

        # ── Step 6: assemble response ────────────────────────────────────────
        candidates_by_id = {c["cardId"]: c for c in candidates}
        suggested_words = []
        for d in decisions:
            c = candidates_by_id[d["cardId"]]
            suggested_words.append(
                SuggestedWord(
                    cardId=c["cardId"],
                    setId=c["setId"],
                    word=c["word"],
                    meaning=c["meaning"],
                    phonetic=c.get("phonetic"),
                    priority_score=d["priority_score"],
                    reason=d["reason"],
                    tag=d["tag"],
                    due_days_ago=c["days_overdue"] or None,
                )
            )

        due_count = sum(1 for w in suggested_words if w.tag in ("overdue", "due_today"))
        new_count = sum(1 for w in suggested_words if w.tag == "new_word")
        review_count = len(suggested_words) - due_count - new_count

        meta = SessionMeta(
            total_suggested=len(suggested_words),
            due_count=due_count,
            new_count=new_count,
            review_count=review_count,
            estimated_duration_min=request.sessionDuration,
            note=_build_capacity_note(request.sessionDuration, max_words, request.topN),
        )

        return SuggestionResponse(suggested_words=suggested_words, session_meta=meta)