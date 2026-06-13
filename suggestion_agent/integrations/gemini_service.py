import json
import math
import re
import time
from datetime import datetime, timezone
from google import genai
from google.genai import types
from config.settings import GEMINI_API_KEY

_client = genai.Client(api_key=GEMINI_API_KEY)


# ── FSRS helpers ──────────────────────────────────────────────────────────────

def _to_aware_dt(val) -> datetime | None:
    if val is None:
        return None
    if isinstance(val, datetime):
        return val if val.tzinfo else val.replace(tzinfo=timezone.utc)
    if hasattr(val, 'seconds'):                          # Firestore Timestamp object
        try:
            return datetime.fromtimestamp(val.seconds, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    if isinstance(val, (int, float)):
        ts = val
        # Detect milliseconds (> year 3000 if treated as seconds)
        if ts > 32503680000:
            ts = ts / 1000
        try:
            return datetime.fromtimestamp(ts, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    return None


def _days_since(dt_val) -> float | None:
    dt = _to_aware_dt(dt_val)
    if dt is None:
        return None
    return max(0.0, (datetime.now(timezone.utc) - dt).total_seconds() / 86400)


def _forgetting_pct(stability: float, days_elapsed: float) -> int:
    """Estimated % chance the learner has FORGOTTEN the word (100 - retrievability)."""
    if stability <= 0 or days_elapsed <= 0:
        return 0
    r = math.pow(1 + 0.9 / 0.1 * days_elapsed / stability, -0.5)
    return max(0, min(100, round((1 - r) * 100)))


def _extract_partial_json(raw: str) -> list[dict]:
    """Recover complete JSON objects from a truncated array string."""
    pattern = re.compile(
        r'\{\s*"cardId"\s*:\s*"([^"]+)"\s*,\s*"reason"\s*:\s*"((?:[^"\\]|\\.)*)"\s*\}'
    )
    return [{"cardId": m.group(1), "reason": m.group(2)} for m in pattern.finditer(raw)]


# ── Main ──────────────────────────────────────────────────────────────────────

def generate_suggestion_reasons(
    user_context: dict,
    candidate_words: list[dict],
) -> dict[str, str]:
    if not candidate_words:
        return {}

    # ── Build per-word coaching brief ─────────────────────────────────────────
    word_blocks = []
    for i, w in enumerate(candidate_words, 1):
        card_id      = w.get("cardId", "")
        word         = w.get("word", "")
        meaning      = w.get("meaning", "")
        example      = w.get("example", "")
        topic        = w.get("topic", "")
        tag          = w.get("tag", "")
        lapses       = int(w.get("lapses", 0))
        reps         = int(w.get("reps", 0))
        stability    = float(w.get("stability", 0))
        difficulty   = float(w.get("difficulty", 5.0))
        state        = w.get("state", "new")
        due_days_ago = w.get("due_days_ago")
        last_review  = w.get("last_review")

        days_since_review = _days_since(last_review)
        forgotten_pct = _forgetting_pct(stability, days_since_review) if stability > 0 and days_since_review else 0

        # ── Translate FSRS data into user-facing language ──────────────────

        # 1. Study history
        if state == "new":
            study_history = "Never studied before — brand new word."
        elif reps == 1:
            study_history = "Studied only once so far."
        else:
            days_str = f"{round(days_since_review)} day(s) ago" if days_since_review else "recently"
            study_history = f"Studied {reps} times total, last reviewed {days_str}."

        # 2. Risk of skipping today
        if tag == "overdue":
            if forgotten_pct >= 70:
                danger = f"HIGH FORGET RISK ({forgotten_pct}%) — {due_days_ago} day(s) overdue, memory is rapidly fading."
            elif forgotten_pct >= 40:
                danger = f"{due_days_ago} day(s) overdue — ~{forgotten_pct}% chance of forgetting, needs urgent review."
            else:
                danger = f"{due_days_ago} day(s) overdue — review soon to avoid having to relearn from scratch."
        elif tag == "due_today":
            if forgotten_pct >= 30:
                danger = f"Due today — memory weakening (~{forgotten_pct}% forget risk). This is the algorithmically optimal review window."
            else:
                danger = "Due today — reviewing right now maximises long-term retention efficiency."
        elif tag == "new_word":
            danger = "New word — studying today starts the spaced repetition clock."
        else:
            danger = "Coming up for review — catch it before the memory fades."

        # 3. Lapse history
        if lapses == 0 and reps > 0:
            lapse_story = f"Never forgotten across {reps} review(s) — a personal record worth protecting."
        elif lapses == 1:
            lapse_story = "Forgotten once before — has a weak spot that today's review can fix."
        elif lapses == 2:
            lapse_story = "Forgotten twice — this word keeps slipping, needs deliberate attention."
        elif lapses >= 3:
            lapse_story = f"Forgotten {lapses} times — one of the hardest words in the deck, but also the one that needs review most."
        else:
            lapse_story = ""

        # 4. Actual difficulty
        if difficulty >= 8.5:
            diff_story = f"Very high difficulty ({difficulty:.1f}/10) — among the top hardest words."
        elif difficulty >= 7.0:
            diff_story = f"Hard word ({difficulty:.1f}/10) — requires more repetitions than average."
        elif difficulty >= 5.0:
            diff_story = f"Moderate difficulty ({difficulty:.1f}/10)."
        else:
            diff_story = f"Relatively easy ({difficulty:.1f}/10) — a quick confidence win."

        block = f"""=== WORD {i} ===
cardId: {card_id}
Word: "{word}" — {meaning}
Set: {topic}
Study history: {study_history}
Today: {danger}"""
        if lapse_story:
            block += f"\nLapse history: {lapse_story}"
        block += f"\nDifficulty: {diff_story}"
        if example:
            block += f'\nExample sentence: "{example}"'

        word_blocks.append(block)

    # ── User context ──────────────────────────────────────────────────────────
    english_level  = user_context.get("englishLevel", "intermediate")
    interests      = user_context.get("interests", "general")
    streak         = user_context.get("streak", 0)
    streak_at_risk = user_context.get("streakAtRisk", False)
    target_goal    = user_context.get("targetGoal", "")

    if streak_at_risk:
        streak_ctx = f"STREAK ALERT: The learner has a {streak}-day streak but hasn't studied today. Weave streak urgency naturally into at least 2 reasons."
    elif streak >= 14:
        streak_ctx = f"Strong {streak}-day streak — briefly acknowledge momentum in 1-2 reasons where it fits naturally."
    elif streak >= 3:
        streak_ctx = f"Building a {streak}-day streak — keep the momentum going."
    else:
        streak_ctx = ""

    goal_ctx = f"Goal: {target_goal}." if target_goal else ""

    prompt = f"""You are a sharp, caring language coach writing personalised micro-motivations for a Vietnamese learner's flashcard app.

LEARNER PROFILE:
- English level: {english_level}
- Interests: {interests}
- Current streak: {streak} days
- {goal_ctx}
{streak_ctx}

YOUR JOB:
For each word below, write ONE reason (2-3 sentences, max 60 words) that convinces the learner to review THIS specific word TODAY.

QUALITY STANDARDS — every reason MUST:
✅ Reference the learner's ACTUAL data (times forgotten, days overdue, forgetting risk %, sessions invested) — translate it into human language, not raw stats
✅ State a CONCRETE CONSEQUENCE of skipping today ("you'll have to relearn from scratch", "X sessions of effort wasted")
✅ Connect to the learner's interests ({interests}) or goal when it fits naturally
✅ Open with a UNIQUE phrase — no two reasons can start the same way
✅ Tone: direct, warm, honest — like a trusted study partner, not a marketing copy

STRICTLY FORBIDDEN:
❌ "Today is the perfect...", "Let's", "It's time to", "Your memory of X is at its peak"
❌ Repeating the same sentence structure across reasons
❌ Generic reasons that could apply to any word
❌ Exposing raw technical numbers ("difficulty = 7.2", "stability = 3.4")

{chr(10).join(word_blocks)}

Return ONLY a valid JSON array — no markdown, no explanation, nothing else:
[{{"cardId": "...", "reason": "..."}}, ...]
Exactly {len(candidate_words)} items, using the EXACT cardId values shown above.
"""

    last_error = None
    for attempt in range(3):
        try:
            response = _client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.95,
                    max_output_tokens=8192,
                    response_mime_type="application/json",
                ),
            )

            raw = response.text.strip()
            raw = re.sub(r"^```json\s*|^```\s*|```$", "", raw, flags=re.MULTILINE).strip()
            print(f"[GeminiService] Response {len(raw)} chars (attempt {attempt+1})")

            try:
                items = json.loads(raw)
            except json.JSONDecodeError:
                print("[GeminiService] Truncated — attempting partial extraction...")
                items = _extract_partial_json(raw)
                if not items:
                    raise

            result = {item["cardId"]: item["reason"] for item in items if "cardId" in item}

            # Fill any missing cardIds with rule-based fallback
            for cw in candidate_words:
                if cw["cardId"] not in result:
                    result[cw["cardId"]] = _fallback_reason(cw)

            return result

        except Exception as e:
            last_error = e
            msg = str(e)
            print(f"[GeminiService] Attempt {attempt+1} failed: {msg}")
            if "503" in msg or "UNAVAILABLE" in msg or "overloaded" in msg.lower():
                time.sleep(1.5 * (attempt + 1))
                continue
            break

    print("[GeminiService] All attempts failed — using rule-based fallback.")
    return {w["cardId"]: _fallback_reason(w) for w in candidate_words}


def _fallback_reason(word: dict) -> str:
    tag         = word.get("tag", "")
    lapses      = int(word.get("lapses", 0))
    reps        = int(word.get("reps", 0))
    w           = word.get("word", "this word")
    meaning     = word.get("meaning", "")
    topic       = word.get("topic", "")
    stability   = float(word.get("stability", 0))
    last_review = word.get("last_review")

    days_since  = _days_since(last_review)
    forgotten   = _forgetting_pct(stability, days_since) if stability > 0 and days_since else 0
    topic_ctx   = f" ({topic})" if topic else ""
    meaning_ctx = f' — "{meaning}"' if meaning else ""

    if tag == "overdue":
        lapse_note = f" Forgotten {lapses} times before." if lapses >= 2 else ""
        mem_note   = f" Forget risk: ~{forgotten}%." if forgotten > 30 else ""
        return f"\"{w}\"{topic_ctx}{meaning_ctx} is overdue.{mem_note}{lapse_note} Review now to avoid relearning from scratch."

    if tag == "due_today":
        mem_note = f" Memory is at ~{forgotten}% risk — today is the optimal moment." if forgotten > 20 else " Today is the optimal SRS window."
        return f"\"{w}\"{meaning_ctx}{topic_ctx} is due today.{mem_note}"

    if tag == "new_word":
        return f"First encounter with \"{w}\"{meaning_ctx}{topic_ctx}. Starting today activates the spaced repetition cycle — the sooner you begin, the faster it sticks."

    if tag == "difficult":
        lapse_note = f" Forgotten {lapses} times already." if lapses > 0 else ""
        return f"\"{w}\"{topic_ctx} is one of your hardest words{meaning_ctx}.{lapse_note} Regular review is the only way to tame it."

    reps_note = f" You've invested {reps} sessions into it" if reps > 0 else ""
    return f"Keep \"{w}\"{topic_ctx} solid with a quick review today.{reps_note} — don't let that effort go to waste."