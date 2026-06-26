from pydantic import BaseModel
from typing import Any
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

    # FSRS
    overdue_cards: int
    forgotten_cards: int
    difficult_cards: list[dict[str, Any]] 

    favorite_sets: int

    recommended_topics: list[str]