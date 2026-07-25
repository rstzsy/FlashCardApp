from datetime import datetime, timezone
from google.cloud.firestore_v1.base_query import FieldFilter
from config.firebase import get_firestore_client


def _now() -> datetime:
    return datetime.now(timezone.utc)


class FirestoreService:
    def __init__(self):
        self.db = get_firestore_client()

    # ── FSRS ─────────────────────────────────────────────────────────────────

    def get_fsrs_cards(self, user_id: str) -> list[dict]:
        docs = (
            self.db.collection("fsrs_progress")
            .document(user_id)
            .collection("cards")
            .stream()
        )
        return [doc.to_dict() for doc in docs]

    # ── Flashcard Sets ────────────────────────────────────────────────────────

    def get_user_sets(self, user_id: str) -> list[dict]:
        docs = (
            self.db.collection("FlashcardSets")
            .where(filter=FieldFilter("UserId", "==", user_id))
            .stream()
        )
        return [doc.to_dict() for doc in docs]

    def get_cards_for_set(self, set_id: str) -> list[dict]:
        docs = (
            self.db.collection("Flashcards")
            .where(filter=FieldFilter("SetId", "==", set_id))
            .stream()
        )
        return [doc.to_dict() for doc in docs]

    def get_all_cards_for_user(
        self,
        user_id: str,
        set_ids: list[str],
        user_sets: list[dict] | None = None,
    ) -> dict[str, dict]:
        """
        Returns {cardId: card_data} with an extra 'topic' field
        pulled from the parent set's Title.

        Pass `user_sets` to avoid a redundant Firestore query when the
        caller already fetched them; otherwise they are fetched here.
        """
        sets = user_sets if user_sets is not None else self.get_user_sets(user_id)

        # Build setId → title map (one pass, no extra query)
        set_title_map: dict[str, str] = {
            s.get("SetId", ""): s.get("Title", "")
            for s in sets
            if s.get("SetId")
        }

        result: dict[str, dict] = {}
        for set_id in set_ids:
            topic = set_title_map.get(set_id, "")
            for card in self.get_cards_for_set(set_id):
                card_id = card.get("CardId") or card.get("cardId", "")
                if card_id:
                    card["topic"] = topic   # inject topic for Gemini context
                    result[card_id] = card
        return result

    # ── Merged cards (FSRS stats + Flashcard content) ────────────────────────

    def get_full_cards_for_user(
        self, user_id: str
    ) -> tuple[list[dict], list[dict]]:
        """
        Merges FSRS scheduling data (fsrs_progress/{userId}/cards/{setId}_{cardId})
        with Flashcard content (Word, Meaning, Example, IsFavorite...) into one
        dict per card, keyed by the real cardId field (NOT doc.id, since doc.id
        is '{setId}_{cardId}' per fsrs_service.dart).

        Returns (merged_cards, user_sets) — user_sets is returned alongside
        so the caller (candidate_pool.py) doesn't need a second query.
        """
        user_sets = self.get_user_sets(user_id)
        set_ids = [s.get("SetId") for s in user_sets if s.get("SetId")]

        # cardId -> flashcard content (+ 'topic' injected from set title)
        content_by_id = self.get_all_cards_for_user(user_id, set_ids, user_sets=user_sets)

        # cardId -> FSRS scheduling stats
        fsrs_docs = (
            self.db.collection("fsrs_progress")
            .document(user_id)
            .collection("cards")
            .stream()
        )

        merged: dict[str, dict] = {}
        for doc in fsrs_docs:
            data = doc.to_dict() or {}
            card_id = data.get("cardId")
            if not card_id:
                continue  # malformed doc, skip rather than guess
            content = content_by_id.get(card_id, {})

            merged[card_id] = {
                "cardId": card_id,
                "SetId": content.get("SetId") or data.get("setId", ""),
                "setId": content.get("SetId") or data.get("setId", ""),
                "Word": content.get("Word", ""),
                "Meaning": content.get("Meaning", ""),
                "Phonetic": content.get("Phonetic"),
                "Example": content.get("Example", ""),
                "IsFavorite": content.get("IsFavorite", False),
                "topic": content.get("topic", ""),
                # FSRS fields — field names confirmed from fsrs_service.dart
                "state": data.get("state", "new"),
                "stability": data.get("stability", 0),
                "difficulty": data.get("difficulty", 5.0),
                "lapses": data.get("lapses", 0),
                "reps": data.get("reps", 0),
                "due": data.get("due"),
                "lastReview": data.get("lastReview"),
            }

        # Cards that exist in Flashcards but have NO fsrs doc yet = 'new'
        for card_id, content in content_by_id.items():
            if card_id in merged:
                continue
            merged[card_id] = {
                "cardId": card_id,
                "SetId": content.get("SetId", ""),
                "setId": content.get("SetId", ""),
                "Word": content.get("Word", ""),
                "Meaning": content.get("Meaning", ""),
                "Phonetic": content.get("Phonetic"),
                "Example": content.get("Example", ""),
                "IsFavorite": content.get("IsFavorite", False),
                "topic": content.get("topic", ""),
                "state": "new",
                "stability": 0,
                "difficulty": 5.0,
                "lapses": 0,
                "reps": 0,
                "due": None,
                "lastReview": None,
            }

        return list(merged.values()), user_sets

    # ── Study Sessions ────────────────────────────────────────────────────────

    def get_study_sessions(self, user_id: str) -> list[dict]:
        docs = (
            self.db.collection("StudySessions")
            .where(filter=FieldFilter("UserId", "==", user_id))
            .stream()
        )
        return [doc.to_dict() for doc in docs]

    def get_words_studied_today(self, user_id: str) -> int:
        today_str = _now().strftime("%Y-%m-%d")
        sessions = self.get_study_sessions(user_id)
        total = 0
        for s in sessions:
            studied_at = s.get("StudiedAt")
            if studied_at is None:
                continue
            if hasattr(studied_at, "strftime"):
                day = studied_at.strftime("%Y-%m-%d")
            else:
                day = str(studied_at)[:10]
            if day == today_str:
                total += int(s.get("WordsStudied", 0))
        return total

    # ── Game Results ──────────────────────────────────────────────────────────

    def get_game_results(self, user_id: str) -> list[dict]:
        docs = (
            self.db.collection("GameResults")
            .where(filter=FieldFilter("UserId", "==", user_id))
            .stream()
        )
        return [doc.to_dict() for doc in docs]

    # ── User Profile ──────────────────────────────────────────────────────────

    def get_user_profile(self, user_id: str) -> dict:
        doc = self.db.collection("users").document(user_id).get()
        return doc.to_dict() or {}

    def get_user_profile_extended(self, user_id: str) -> dict:
        doc = self.db.collection("userProfiles").document(user_id).get()
        return doc.to_dict() or {}