from config.firebase import db

class StudySessionService:

    async def get_sessions(
        self,
        user_id
    ):

        docs = (
            db.collection("StudySessions")
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