from schemas.learning_metrics import LearningMetrics


class AnalyticsTool:

    def build_metrics(
        self,
        user,
        profile,
        flashcards,
        sessions,
        games
    ):

        total_words = sum(
            x.get(
                "WordsStudied",
                0
            )
            for x in sessions
        )

        avg_accuracy = 0

        if games:
            avg_accuracy = (
                sum(
                    x.get(
                        "Accuracy",
                        0
                    )
                    for x in games
                )
                / len(games)
            )

        return LearningMetrics(
            level=user.get("level", 1),
            stars=user.get("stars", 0),
            streak=user.get("streak", 0),
            english_level=profile.get("englishLevel"),
            interests=[profile.get("interests")],
            average_accuracy=avg_accuracy,
            words_learned=total_words,
            flashcard_set_count=len(flashcards),
            weak_topics=[]
        )