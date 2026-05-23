from fastapi import FastAPI
from api.routes.flashcard_routes import router

app = FastAPI()

app.include_router(router)