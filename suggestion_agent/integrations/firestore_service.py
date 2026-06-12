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