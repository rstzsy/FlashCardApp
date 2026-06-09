from config.firebase import db

class FlashcardService:

    async def get_sets(
        self,
        user_id
    ):

        docs = (
            db.collection("FlashcardSets")
            .where(
                "UserId",
                "==",
                user_id
            )
            .stream()
        )

        return [
            x.to_dict()
            for x in docs
        ]