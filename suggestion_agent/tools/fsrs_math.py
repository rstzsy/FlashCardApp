from datetime import datetime, timezone


def to_aware_dt(val) -> datetime | None:
    """Normalise any Firestore-ish value (Timestamp, epoch s/ms, datetime) to aware UTC."""
    if val is None:
        return None
    if isinstance(val, datetime):
        return val if val.tzinfo else val.replace(tzinfo=timezone.utc)
    if hasattr(val, "seconds"):  # Firestore Timestamp object
        try:
            return datetime.fromtimestamp(val.seconds, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    if isinstance(val, (int, float)):
        ts = val
        if ts > 32503680000:  # looks like milliseconds (> year 3000 as seconds)
            ts = ts / 1000
        try:
            return datetime.fromtimestamp(ts, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    return None


def days_since(dt_val) -> float | None:
    dt = to_aware_dt(dt_val)
    if dt is None:
        return None
    return max(0.0, (datetime.now(timezone.utc) - dt).total_seconds() / 86400)


def days_until(dt_val) -> float | None:
    """Positive = in the future, negative = overdue by that many days."""
    dt = to_aware_dt(dt_val)
    if dt is None:
        return None
    return (dt - datetime.now(timezone.utc)).total_seconds() / 86400


def forgetting_pct(stability: float, days_elapsed: float | None) -> int:
    """
    FSRS forgetting-curve estimate: % chance the learner has FORGOTTEN the
    word right now (100 - retrievability), using the standard FSRS decay
    with default fitted parameters (0.9 target retention baseline).
    This is deterministic science, not a priority opinion — safe to keep
    in Python and hand to the AI as a fact, not a decision.
    """
    if not stability or stability <= 0 or not days_elapsed or days_elapsed <= 0:
        return 0
    r = (1 + 0.9 / 0.1 * days_elapsed / stability) ** -0.5
    return max(0, min(100, round((1 - r) * 100)))