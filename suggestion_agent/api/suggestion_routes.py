from fastapi import APIRouter, HTTPException
from schemas.suggestion_schema import SuggestionRequest, SuggestionResponse
from agents.suggestion_controller import SuggestionController

router = APIRouter()
controller = SuggestionController()


@router.post("/suggest-vocabulary", response_model=SuggestionResponse)
def suggest_vocabulary(request: SuggestionRequest):
    """
    Main endpoint — Flutter calls this with userId, sessionDuration, topN.

    Example body:
    {
        "userId": "0MgjLq2qTHPnjFmj6SOXnFMFkhz2",
        "sessionDuration": 20,
        "topN": 10,
        "context": {
            "currentSetId": "abc123",
            "streakAtRisk": false
        }
    }
    """
    try:
        result = controller.run(request)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/suggest-vocabulary/health")
def health():
    return {"status": "ok", "agent": "VocabularySuggestionAgent", "selection_engine": "gemini-driven"}