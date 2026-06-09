from pydantic import BaseModel

class LearningMetrics(BaseModel):

    level: int
    stars: int
    streak: int
    english_level: str
    interests: list[str]
    average_accuracy: float
    words_learned: int
    flashcard_set_count: int
    weak_topics: list[str]