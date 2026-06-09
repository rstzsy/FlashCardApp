from fastapi import APIRouter

from agents.roadmap_controller import RoadmapAgent


router = APIRouter(
    prefix="/roadmap",
    tags=["Roadmap"]
)

agent = RoadmapAgent()

@router.post(
    "/generate/{user_id}"
)
async def generate(
    UserId: str
):
    return await agent.generate(
        UserId
    )