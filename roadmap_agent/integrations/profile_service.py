from config.firebase import db

class ProfileService:

    async def get_profile(
        self,
        user_id
    ):

        docs = (
            db.collection("userProfiles")
            .where(
                "userId",
                "==",
                user_id
            )
            .limit(1)
            .stream()
        )

        for doc in docs:
            return doc.to_dict()

        return None