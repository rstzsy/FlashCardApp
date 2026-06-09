from config.firebase import db

class UserService:

    async def get_user(
        self,
        user_id
    ):

        doc = (
            db.collection("users")
            .document(user_id)
            .get()
        )

        return doc.to_dict()