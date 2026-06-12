from datetime import datetime, timezone
from config.settings import (
    WEIGHT_SRS, WEIGHT_LAPSE, WEIGHT_DIFFICULTY, WEIGHT_TOPIC,
)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _to_datetime(val) -> datetime | None:
    if val is None:
        return None

    if isinstance(val, datetime):
        return val.replace(tzinfo=timezone.utc) if val.tzinfo is None else val

    # Firestore Timestamp object
    if hasattr(val, "seconds"):
        return datetime.fromtimestamp(val.seconds, tz=timezone.utc)

    # Unix timestamp (seconds or milliseconds)
    if isinstance(val, (int, float)):
        if val > 1e11:          # milliseconds → seconds
            val /= 1000
        return datetime.fromtimestamp(val, tz=timezone.utc)

    return None


# ── Component scores ──────────────────────────────────────────────────────────

def srs_score(fsrs: dict) -> tuple[float, str, int | None]:
    """
    Returns (score, tag, due_days_ago).
    due_days_ago is None when the card is not yet due.
    """
    state   = fsrs.get("state", "new")
    due_raw = fsrs.get("due")
    due     = _to_datetime(due_raw)
    today   = _now()

    if state == "new" or due is None:
        return 0.50, "new_word", None

    days_overdue = (today - due).days

    if days_overdue > 3:
        score = 1.00
    elif days_overdue > 0:
        score = 0.85
    elif days_overdue == 0:
        score = 0.70
    else:
        score = 0.10

    if days_overdue > 0:
        tag = "overdue"
    elif days_overdue == 0:
        tag = "due_today"
    else:
        tag = "review"

    due_days_ago = days_overdue if days_overdue >= 0 else None
    return score, tag, due_days_ago


def lapse_score(fsrs: dict) -> float:
    lapses = int(fsrs.get("lapses", 0))
    if lapses == 0:
        return 0.0
    if lapses <= 2:
        return 0.3
    if lapses <= 4:
        return 0.6
    return 1.0


def difficulty_score(fsrs: dict) -> float:
    d = float(fsrs.get("difficulty", 5.0))
    d = max(1.0, min(10.0, d))
    return (d - 1) / 9


def topic_score(
    set_id: str,
    favourite_set_ids: list[str],
    in_progress_set_ids: list[str],
) -> float:
    if set_id in favourite_set_ids:
        return 1.0
    if set_id in in_progress_set_ids:
        return 0.7
    return 0.1


# ── Main entry point ──────────────────────────────────────────────────────────

def compute_priority(
    fsrs: dict,
    set_id: str,
    favourite_set_ids: list[str],
    in_progress_set_ids: list[str],
    streak_at_risk: bool = False,
) -> tuple[float, str, int | None]:
    """
    Returns (priority_score, tag, due_days_ago).
    """
    s, tag, due_days_ago = srs_score(fsrs)
    l = lapse_score(fsrs)
    d = difficulty_score(fsrs)
    t = topic_score(set_id, favourite_set_ids, in_progress_set_ids)

    # Boost favourite-set topic score when streak is at risk
    # → surfaces familiar, easier words to help user keep their streak
    if streak_at_risk and set_id in favourite_set_ids:
        t = min(1.0, t + 0.2)

    # Promote difficult cards that aren't already flagged as overdue/due
    if float(fsrs.get("difficulty", 0)) >= 7.0 and tag not in ("overdue", "due_today"):
        tag = "difficult"

    score = (
        (WEIGHT_SRS        * s)
        + (WEIGHT_LAPSE    * l)
        + (WEIGHT_DIFFICULTY * d)
        + (WEIGHT_TOPIC    * t)
    )
    return round(score, 4), tag, due_days_ago