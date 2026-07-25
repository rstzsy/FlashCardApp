"""
tools/candidate_pool.py

Replaces tools/priority_scorer.py.

This module does NOT compute a priority score and does NOT rank words —
that decision now happens inside integrations/gemini_service.py. This file
only does two purely mechanical jobs:

  1. Annotate each merged card (FSRS stats + Flashcard content) with
     objective facts (forgetting %, days overdue, favourite card, in-progress
     topic...) so Gemini doesn't have to parse dates/booleans itself.
  2. Trim the full card list down to a token-budget-friendly candidate
     pool WITHOUT deciding which words "matter more" — wide net of
     everything due/overdue/chronically-hard, plus a capped sample of new
     words. Only pre-trims further if that net is still too big for one
     Gemini call.

CONFIRMED SCHEMA (from real Firestore docs):
  - Flashcards: CardId, SetId, Word, Meaning, Phonetic, Example, Tags,
    IsFavorite (per-CARD, not per-set — note single "u", US spelling).
  - FlashcardSets: SetId, Title, Difficulty, TotalCards, UserId... — no
    stored progress/favourite field at the set level. "In-progress topic"
    is therefore DERIVED here: (# cards in that set already studied, i.e.
    FSRS state != 'new') / TotalCards, flagged in-progress when that ratio
    lands between 40-80%.
"""

from config.settings import (
    NEW_WORD_POOL_CAP,
    UPCOMING_DUE_WINDOW_DAYS,
    CHRONIC_LAPSE_THRESHOLD,
    MAX_CANDIDATE_POOL,
)
from tools.fsrs_math import days_since, days_until, forgetting_pct


def _compute_in_progress_set_ids(merged_cards: list[dict], user_sets: list[dict]) -> set:
    """A set is 'in progress' when 40-80% of its cards have already been studied at least once."""
    studied_count_by_set: dict[str, int] = {}
    for c in merged_cards:
        set_id = c.get("SetId") or c.get("setId", "")
        if c.get("state", "new") != "new":
            studied_count_by_set[set_id] = studied_count_by_set.get(set_id, 0) + 1

    in_progress = set()
    for s in user_sets:
        set_id = s.get("SetId")
        total = s.get("TotalCards", 0) or 0
        if not set_id or total <= 0:
            continue
        ratio = studied_count_by_set.get(set_id, 0) / total
        if 0.4 <= ratio <= 0.8:
            in_progress.add(set_id)
    return in_progress


def _annotate(card: dict, sets_by_id: dict, in_progress_set_ids: set) -> dict:
    stability = float(card.get("stability", 0) or 0)
    difficulty = float(card.get("difficulty", 5.0) or 5.0)
    state = card.get("state", "new")
    due = card.get("due")
    last_review = card.get("lastReview")
    set_id = card.get("SetId") or card.get("setId", "")

    days_to_due = days_until(due) if state != "new" else None
    # +/-1 day tolerance: due values are timestamps, not calendar-day
    # boundaries, so "due 30 seconds ago" shouldn't miss both buckets.
    is_overdue = days_to_due is not None and days_to_due < -1
    is_due_today = days_to_due is not None and -1 <= days_to_due < 1
    days_overdue = round(-days_to_due) if is_overdue else 0

    d_since_review = days_since(last_review)
    fpct = forgetting_pct(stability, d_since_review)

    set_meta = sets_by_id.get(set_id, {})
    word = card.get("Word") or card.get("word", "")
    meaning = card.get("Meaning") or card.get("meaning", "")
    phonetic = card.get("Phonetic") or card.get("phonetic")
    example = card.get("Example") or card.get("example", "")
    topic = card.get("topic") or set_meta.get("Title", "")

    return {
        "cardId": card.get("cardId", ""),
        "setId": set_id,
        "word": word,
        "meaning": meaning,
        "phonetic": phonetic,
        "example": example,
        "topic": topic,
        "state": state,
        "stability": stability,
        "difficulty": difficulty,
        "lapses": int(card.get("lapses", 0) or 0),
        "reps": int(card.get("reps", 0) or 0),
        "days_since_review": d_since_review,
        "days_overdue": days_overdue,
        "is_due_today": is_due_today,
        "is_upcoming": (days_to_due is not None and 0 < days_to_due <= UPCOMING_DUE_WINDOW_DAYS),
        "forgetting_pct": fpct,
        "is_favourite_card": bool(card.get("IsFavorite", False)),
        "is_in_progress_set": set_id in in_progress_set_ids,
        "is_chronically_hard": int(card.get("lapses", 0) or 0) >= CHRONIC_LAPSE_THRESHOLD,
    }


def build_candidate_pool(
    merged_cards: list[dict],
    user_sets: list[dict],
    current_set_id: str | None = None,
) -> list[dict]:
    sets_by_id = {s.get("SetId"): s for s in user_sets if s.get("SetId")}
    in_progress_set_ids = _compute_in_progress_set_ids(merged_cards, user_sets)

    annotated = [_annotate(c, sets_by_id, in_progress_set_ids) for c in merged_cards]

    # Wide net, eligibility-only (no ranking):
    always_include = [
        c for c in annotated
        if c["days_overdue"] > 0 or c["is_due_today"] or c["is_chronically_hard"] or c["is_upcoming"]
        or c["is_favourite_card"]
        or (current_set_id and c["setId"] == current_set_id)
    ]

    new_words = [c for c in annotated if c["state"] == "new"]
    # Light, non-priority ordering just to pick a diverse capped sample of new words:
    # cards in an in-progress topic first, so new-word suggestions naturally
    # cluster around what the learner is already engaged with.
    new_words.sort(key=lambda c: not c["is_in_progress_set"])
    new_words = new_words[:NEW_WORD_POOL_CAP]

    pool = {c["cardId"]: c for c in always_include}
    for c in new_words:
        pool.setdefault(c["cardId"], c)

    pool = list(pool.values())

    # Token-budget-only pre-trim (NOT the final ranking — Gemini re-ranks whatever
    # survives this). Only triggers on very large decks.
    if len(pool) > MAX_CANDIDATE_POOL:
        pool.sort(key=lambda c: (c["days_overdue"], c["forgetting_pct"], c["lapses"]), reverse=True)
        pool = pool[:MAX_CANDIDATE_POOL]

    return pool