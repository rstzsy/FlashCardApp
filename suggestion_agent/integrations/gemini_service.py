import json
import re
import time
from google import genai
from google.genai import types
from config.settings import GEMINI_API_KEY

_client = genai.Client(api_key=GEMINI_API_KEY)


def generate_suggestion_reasons(
    user_context: dict,
    candidate_words: list[dict],
) -> dict[str, str]:
    """
    Returns {cardId: reason_string} for each candidate word.
    Falls back to rule-based reasons on any error.
    """
    if not candidate_words:
        return {}

    # ── Build rich word descriptors ───────────────────────────────────────────
    word_lines = []
    for i, w in enumerate(candidate_words, 1):
        lapses       = w.get("lapses", 0)
        due_days_ago = w.get("due_days_ago")        # None = not yet due / new
        difficulty   = w.get("difficulty", 5.0)
        state        = w.get("state", "new")
        tag          = w.get("tag", "")
        meaning      = w.get("meaning", "")         # Vietnamese meaning
        example      = w.get("example", "")         # example sentence
        topic        = w.get("topic", "")           # set title, e.g. "Travel"

        # Translate raw data into human-readable narrative hooks
        situation_parts = []

        if tag == "overdue" and due_days_ago:
            situation_parts.append(f"overdue by {due_days_ago} day(s)")
        elif tag == "due_today":
            situation_parts.append("due for review today — perfect timing")
        elif tag == "new_word":
            situation_parts.append("brand new — never studied before")

        if lapses >= 5:
            situation_parts.append("forgotten 5+ times — a persistently tricky word")
        elif lapses >= 3:
            situation_parts.append(f"forgotten {lapses} times before")
        elif lapses == 0 and state != "new":
            situation_parts.append("no lapses yet — a strong track record to maintain")

        if difficulty >= 7.5:
            situation_parts.append("high difficulty — advanced-level vocabulary")
        elif difficulty <= 3.0:
            situation_parts.append("easy word — a quick confidence win")

        situation = "; ".join(situation_parts) if situation_parts else "scheduled review"

        line = f'{i}. "{w["word"]}"'
        if meaning:
            line += f' ({meaning})'
        if topic:
            line += f' [set: {topic}]'
        line += f'\n   Situation: {situation}'
        if example:
            line += f'\n   Example sentence: "{example}"'

        word_lines.append(line)

    # ── User context ──────────────────────────────────────────────────────────
    english_level  = user_context.get("englishLevel", "intermediate")
    target_goal    = user_context.get("targetGoal", "")       # e.g. "IELTS 6.5"
    interests      = user_context.get("interests", "general")
    streak         = user_context.get("streak", 0)
    streak_at_risk = user_context.get("streakAtRisk", False)

    streak_note = ""
    if streak_at_risk:
        streak_note = (
            f"⚠️ The learner's {streak}-day streak is at risk today — "
            f"be extra encouraging and keep the tone light."
        )
    elif streak >= 7:
        streak_note = (
            f"🔥 The learner has a strong {streak}-day streak — "
            f"briefly acknowledge their momentum where it feels natural."
        )

    goal_note = f"Goal: {target_goal}" if target_goal else "No specific exam goal set."

    # ── Prompt ────────────────────────────────────────────────────────────────
    prompt = f"""You are a warm, insightful language coach helping a Vietnamese learner build English vocabulary through spaced repetition.

Your task: for each word below, write ONE compelling reason (2–3 sentences) explaining why the learner should study it TODAY.

TONE RULES — follow these strictly:
- Write like a human coach, not a data report
- Reference the word's real-life meaning or usage to make it feel relevant
- When lapses are high, acknowledge the struggle empathetically — never critically
- When the word is new, spark genuine curiosity
- When the word is easy or has no lapses, frame it as a quick confidence win
- NEVER expose raw numbers like "lapses = 4" or "difficulty = 7.2" — translate them into human language instead
- End with a short motivational nudge when it fits naturally
- Keep each reason concise but meaningful — quality over length

LEARNER PROFILE:
- English level: {english_level}
- {goal_note}
- Interests: {interests}
- Current streak: {streak} days
{streak_note}

WORDS TO EXPLAIN:
{chr(10).join(word_lines)}

Return ONLY valid JSON — no markdown, no backticks, no explanations, no extra text:
[{{"cardId": "...", "reason": "..."}}, ...]

The cardId values in order are:
{json.dumps([w["cardId"] for w in candidate_words])}
"""

    last_error = None
    for attempt in range(3):
        try:
            response = _client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.85,
                    max_output_tokens=4096,
                    response_mime_type="application/json",
                ),
            )

            candidate = response.candidates[0] if response.candidates else None
            if candidate and getattr(candidate, "finish_reason", None) == "MAX_TOKENS":
                print("[GeminiService] Warning: response truncated due to max_output_tokens")

            raw = response.text.strip()
            raw = re.sub(r"^```json\s*|^```\s*|```$", "", raw, flags=re.MULTILINE).strip()

            try:
                items = json.loads(raw)
            except json.JSONDecodeError as je:
                print(f"[GeminiService] JSON parse failed: {je}")
                print(f"[GeminiService] Raw response was:\n{raw}")
                raise

            return {item["cardId"]: item["reason"] for item in items if "cardId" in item}

        except Exception as e:
            last_error = e
            msg = str(e)
            print(f"[GeminiService] Attempt {attempt + 1} failed: {msg}")
            if "503" in msg or "UNAVAILABLE" in msg or "overloaded" in msg.lower():
                time.sleep(1.5 * (attempt + 1))  # backoff then retry
                continue
            break  # non-retryable error (parse, auth, etc.) -> fallback directly

    print(f"[GeminiService] All attempts failed, using fallback. Last error: {last_error}")
    return {w["cardId"]: _fallback_reason(w) for w in candidate_words}


def _fallback_reason(word: dict) -> str:
    """
    Rule-based fallback — uses meaning and lapses for richer copy
    without exposing raw numbers.
    """
    tag     = word.get("tag", "")
    lapses  = word.get("lapses", 0)
    w       = word.get("word", "this word")
    meaning = word.get("meaning", "")
    suffix  = f' ("{meaning}")' if meaning else ""

    if tag == "overdue":
        if lapses >= 3:
            return (
                f"You've had a tough time with \"{w}\"{suffix} before — "
                f"and it's been waiting patiently in your queue. "
                f"Today is the right moment to finally make it stick."
            )
        return (
            f"\"{w}\"{suffix} has been sitting in your review queue. "
            f"A quick session now keeps it fresh and saves you a full relearn later."
        )

    if tag == "due_today":
        return (
            f"Your memory of \"{w}\"{suffix} is at its peak review point today. "
            f"Revisiting it now is the most efficient move for long-term retention — "
            f"it only takes a moment."
        )

    if tag == "new_word":
        return (
            f"\"{w}\"{suffix} is brand new territory for you! "
            f"Every fluent speaker started exactly here — one new word at a time. "
            f"Let's add this one to your permanent vocabulary today."
        )

    if tag == "difficult":
        return (
            f"\"{w}\"{suffix} is one of the trickier words in your set. "
            f"The more you revisit it, the less intimidating it becomes — "
            f"consistency is what turns difficult into effortless."
        )

    return (
        f"Keeping \"{w}\"{suffix} active in your memory takes just a moment today. "
        f"Skip it now and you risk having to relearn it from scratch — not worth it!"
    )