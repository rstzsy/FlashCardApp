from typing import Any, Dict, List
from tools.priority_score import compute_priority


class FSRSAnalyticsTool:

    def analyze(
        self,
        cards,
        favourite_set_ids=None,
        in_progress_set_ids=None,
        streak_at_risk=False
    ):
        favourite_set_ids = favourite_set_ids or []
        in_progress_set_ids = in_progress_set_ids or []

        overdue_cards = 0
        forgotten_cards = 0
        difficult_cards: List[Dict[str, Any]] = []
        recommended_topics = []
        favorite_sets = set()
        priorities = []

        # cal card priority + tags + set-level learned stats
        learned_by_set: Dict[str, int] = {}   # number of cards learned per setId
        total_by_set:   Dict[str, int] = {}   # total cards per setId

        for card in cards:
            fsrs   = card.get("FSRS") or {}
            set_id = card.get("SetId", "")

            score, tag, due_days_ago = compute_priority(
                fsrs=fsrs,
                set_id=set_id,
                favourite_set_ids=favourite_set_ids,
                in_progress_set_ids=in_progress_set_ids,
                streak_at_risk=streak_at_risk
            )

            priorities.append((score, card))

            # tag analystic
            if tag == "overdue":
                overdue_cards += 1

            if tag == "difficult":
                difficult_cards.append({
                    "cardId":   card.get("CardId") or card.get("cardId"),
                    "setId":    set_id,
                    "word":     card.get("Word", ""),
                    "meaning":  card.get("Meaning", ""),
                    "score":    score,
                    "lapses":   fsrs.get("lapses", 0),
                    "reps":     fsrs.get("reps", 0),
                    "state":    fsrs.get("state", "new"),
                })

            if fsrs.get("lapses", 0) >= 3:
                forgotten_cards += 1

            # favorite set
            if set_id in favourite_set_ids:
                favorite_sets.add(set_id)

            # cal learned cards per set
            # Align with SuggestionController: card "studied" when state != "new"
            # or are reviewed at least 1 time (reps > 0)
            total_by_set[set_id] = total_by_set.get(set_id, 0) + 1

            state = fsrs.get("state", "new")
            reps  = fsrs.get("reps", 0)
            if state != "new" or reps > 0:
                learned_by_set[set_id] = learned_by_set.get(set_id, 0) + 1

        # priority sort
        priorities.sort(reverse=True, key=lambda x: x[0])

        for _, card in priorities[:20]:
            topic = card.get("Topic")
            if topic and topic not in recommended_topics:
                recommended_topics.append(topic)

        #  construct learned_sets (list to FE/AI used) 
        learned_sets: List[Dict[str, Any]] = [
            {
                "setId":        sid,
                "learned":      learned_by_set.get(sid, 0),
                "total":        total,
                "progress_pct": round(
                    learned_by_set.get(sid, 0) / total * 100, 1
                ) if total else 0.0,
            }
            for sid, total in total_by_set.items()
        ]

        return {
            "overdue_cards":       overdue_cards,
            "forgotten_cards":     forgotten_cards,
            "difficult_cards":     difficult_cards[:20],
            "favorite_sets":       len(favorite_sets),
            "recommended_topics":  recommended_topics,
            "learned_sets":        learned_sets,          # per-set breakdown
            "total_learned_cards": sum(learned_by_set.values()),  # total across all sets
        }