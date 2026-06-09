from pydantic import BaseModel

class GenerateFlashcardSchema(BaseModel):
    userId: str
    topic: str
    totalCards: int = 10
    language: str = "English"
    difficulty: str = "Easy"