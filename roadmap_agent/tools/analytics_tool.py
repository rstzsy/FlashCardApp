from schemas.learning_metrics import LearningMetrics
from tools.fsrs_analytic_tool import FSRSAnalyticsTool


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

        # FSRS analystics
        fsrs_result = (
            FSRSAnalyticsTool()
            .analyze(
                flashcards
            )
        )

        overdue_cards = fsrs_result.get(
            "overdue_cards",
            0
        )

        forgotten_cards = fsrs_result.get(
            "forgotten_cards",
            0
        )

        difficult_cards = fsrs_result.get(
            "difficult_cards",
            0
        )

        recommended_topics = fsrs_result.get(
            "recommended_topics",
            []
        )

        return LearningMetrics(

            level=user.get(
                "level",
                1
            ),

            stars=user.get(
                "stars",
                0
            ),

            streak=user.get(
                "streak",
                0
            ),

            english_level=profile.get(
                "englishLevel"
            ),

            interests=[
                profile.get(
                    "interests"
                )
            ],

            average_accuracy=avg_accuracy,

            words_learned=total_words,

            flashcard_set_count=len(
                flashcards
            ),

            weak_topics=[],

            overdue_cards=overdue_cards,

            forgotten_cards=forgotten_cards,

            difficult_cards=difficult_cards,

            favorite_sets=0,

            recommended_topics=recommended_topics
        )