from fastapi import APIRouter

from agents.roadmap_agent.roadmap_controller import RoadmapAgent


router = APIRouter(
    prefix="/roadmap",
    tags=["Roadmap"]
)

agent = RoadmapAgent()

@router.post("/generate")
async def generate(user_id: str):
    return await agent.generate(user_id)