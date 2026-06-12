from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.suggestion_routes import router as suggestion_router

app = FastAPI(
    title="Vocabulary Suggestion Agent",
    description="AI-powered vocabulary suggestion using FSRS-4.5 data from Firestore",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(suggestion_router, prefix="/api/v1")


@app.get("/")
def health_check():
    return {"status": "ok", "service": "Vocabulary Suggestion Agent"}
