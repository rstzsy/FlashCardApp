from config.firebase import db

class FlashcardItemService:

    async def get_by_user(
        self,
        user_id
    ):

        sets = db.collection(
            "FlashcardSets"
        ).where(
            "UserId",
            "==",
            user_id
        ).stream()

        set_ids = [
            x.to_dict()["SetId"]
            for x in sets
        ]

        cards = []

        for set_id in set_ids:

            docs = db.collection(
                "Flashcards"
            ).where(
                "SetId",
                "==",
                set_id
            ).stream()

            cards.extend(
                [
                    d.to_dict()
                    for d in docs
                ]
            )

        return cards