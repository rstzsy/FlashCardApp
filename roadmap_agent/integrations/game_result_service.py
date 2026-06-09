from config.firebase import db

class GameResultService:

    async def get_results(
        self,
        user_id
    ):

        docs = (
            db.collection("GameResults")
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