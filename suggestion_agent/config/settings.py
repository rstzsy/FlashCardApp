import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = "gemini-2.5-flash"

# ── Session limits (hard physical constraints, not priority judgement) ──────
MINUTES_PER_WORD = 2
OVERLOAD_THRESHOLD = 30          # words already studied today → trigger burnout guard
OVERLOAD_REDUCTION = 0.5         # cut capacity in half when overloaded
CACHE_TTL_SECONDS = 600

# ── Candidate pool sizing (token-budget guard only, NOT a ranking step) ──────
NEW_WORD_POOL_CAP = 40             # max "new" cards shown to the AI as options
UPCOMING_DUE_WINDOW_DAYS = 3        # also show cards due within N days (gives AI review options)
CHRONIC_LAPSE_THRESHOLD = 3         # always surface chronically-forgotten cards regardless of due date
MAX_CANDIDATE_POOL = 150            # if pool still bigger than this, lightly pre-trim (see tools/candidate_pool.py)

# ── DEPRECATED — kept only for the deterministic fallback ────────────────────
# Word selection is no longer driven by this fixed weighted formula
# (Priority = W1*SRS + W2*Lapse + W3*Difficulty + W4*Topic) — Gemini now
# analyses the raw FSRS data directly and decides selection/ranking itself.
# These constants are only read by the fallback sorter in gemini_service.py,
# used when Gemini is unreachable so the endpoint never fails outright.
WEIGHT_SRS = 0.45
WEIGHT_LAPSE = 0.25
WEIGHT_DIFFICULTY = 0.20
WEIGHT_TOPIC = 0.10
MIN_DUE_RATIO = 0.30
MAX_NEW_RATIO = 0.20