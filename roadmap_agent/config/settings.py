from dotenv import load_dotenv
import os

load_dotenv()

class Settings:

    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

    TAVILY_API_KEY = os.getenv("TAVILY_API_KEY")

# Suggestion agent weights (doc section 3.1)
WEIGHT_SRS = 0.45
WEIGHT_LAPSE = 0.25
WEIGHT_DIFFICULTY = 0.20
WEIGHT_TOPIC = 0.10

# Session limits
MINUTES_PER_WORD = 2
MIN_DUE_RATIO = 0.30
MAX_NEW_RATIO = 0.20
OVERLOAD_THRESHOLD = 30
CACHE_TTL_SECONDS = 600