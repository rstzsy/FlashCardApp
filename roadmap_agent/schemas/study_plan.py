from pydantic import BaseModel

class StudyPlan(BaseModel):

    daily_word_target: int
    study_days_per_week: int
    daily_study_minutes: int
    suggested_level: str
    estimated_weeks: int
    recommendation: str