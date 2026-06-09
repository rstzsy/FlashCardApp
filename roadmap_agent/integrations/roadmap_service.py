from uuid import uuid4
from datetime import datetime

from config.firebase import db


class RoadmapService:

   async def save_roadmap(
        self,
        roadmap_data: dict
    ):

        roadmap_id = str(uuid4())

        roadmap_data.update({
            "RoadmapId": roadmap_id,
            "CreatedAt": datetime.utcnow(),
            "UpdatedAt": datetime.utcnow()
        })

        db.collection(
            "userRoadmaps"
        ).document(
            roadmap_id
        ).set(
            roadmap_data
        )

        return roadmap_id