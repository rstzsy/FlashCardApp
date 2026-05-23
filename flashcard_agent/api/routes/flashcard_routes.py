from fastapi import APIRouter

from schemas.generate_flashcard_schema import \
    GenerateFlashcardSchema

from agents.flashcard_agent.flashcard_controller import \
    FlashcardController

router = APIRouter()

@router.post("/ai/generate-flashcards")
async def generate_flashcards(
    req: GenerateFlashcardSchema
):

    controller = FlashcardController()

    return await controller.generate(req)