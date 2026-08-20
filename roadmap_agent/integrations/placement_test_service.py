from config.firebase import db


class PlacementTestService:

    async def get_result(
        self,
        user_id: str
    ):
        doc = (
            db
            .collection("users")
            .document(user_id)
            .get()
        )

        if not doc.exists:
            return None

        data = doc.to_dict()

        if data.get("placementTestCompleted") != True:
            return None

        return {
            "score": data.get(
                "placementTestScore",
                0
            ),
            "total": data.get(
                "placementTestTotal",
                0
            ),

            "level": data.get(
                "placementTestLevel",
                "Unknown"
            ),
            "completed": data.get(
                "placementTestCompleted",
                False
            ),
            "completedAt": data.get(
                "placementTestCompletedAt"
            )
        }