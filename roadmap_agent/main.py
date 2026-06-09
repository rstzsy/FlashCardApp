from fastapi import FastAPI

from api.roadmap_routes import (
    router
)

app = FastAPI()

app.include_router(router)