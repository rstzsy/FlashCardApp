from datetime import datetime

from agents.roadmap_agent.roadmap_parser import RoadmapParser
from agents.roadmap_agent.roadmap_prompt import ROADMAP_PROMPT

from integrations.flashcard_item_service import FlashcardItemService
from integrations.flashcard_service import FlashcardService
from integrations.game_result_service import GameResultService
from integrations.profile_service import ProfileService
from integrations.study_session_service import StudySessionService
from integrations.user_service import UserService
from integrations.roadmap_service import RoadmapService

from tools.analytics_tool import AnalyticsTool
from tools.tavily_tool import TavilyTool
from tools.gemini_tool import GeminiTool
from tools.excel_generator import ExcelGenerator
from tools.storage_tool import StorageTool


class RoadmapAgent:

    async def generate(
        self,
        user_id: str
    ):

        try:

            # load data

            user = await UserService().get_user(
                user_id
            )

            if not user:
                raise Exception(
                    f"User {user_id} not found"
                )

            profile = await (
                ProfileService()
                .get_profile(user_id)
            )

            flashcards = await (
                FlashcardService()
                .get_sets(user_id)
            )

            flashcard_items = await (
                FlashcardItemService()
                .get_by_user(user_id)
            )

            sessions = await (
                StudySessionService()
                .get_sessions(user_id)
            )

            games = await (
                GameResultService()
                .get_results(user_id)
            )

            # analyze

            metrics = AnalyticsTool().build_metrics(
                user,
                profile,
                flashcard_items,
                sessions,
                games
            )

            # search context

            context = (
                TavilyTool()
                .search_context(
                    metrics.interests
                )
            )

            # prompt

            prompt = ROADMAP_PROMPT.format(
                metrics=metrics.model_dump_json(
                    indent=2
                ),
                context=context
            )

            # gemini

            result = await (
                GeminiTool()
                .generate(prompt)
            )

            print("-----gemini response-----")
            print(result)
            print("--------------------------")

            # parse format

            roadmap = (
                RoadmapParser()
                .parse(result)
            )

            # excel

            excel_path = (
                ExcelGenerator()
                .generate(
                    roadmap=roadmap,
                    user_info={
                        "userId": user_id,
                        "name": user.get(
                            "name",
                            "Unknown"
                        )
                    }
                )
            )

            print("-----excel-----")
            print(excel_path)
            print("----------------")

            # upload to storage

            storage_path = (
                f"roadmaps/"
                f"{user_id}/"
                f"{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.xlsx"
            )

            excel_url = (
                StorageTool()
                .upload_file(
                    file_path=excel_path,
                    destination=storage_path
                )
            )

            print("-----storage-----")
            print(excel_url)
            print("-----------------")

            # firestore save

            roadmap_id = (
                await RoadmapService()
                .save_roadmap(
                    {
                        "UserId": user_id,
                        "Roadmap": roadmap,
                        "ExcelUrl": excel_url,
                        "IsActive": True,
                        "CreatedAt": datetime.utcnow(),
                        "UpdatedAt": datetime.utcnow()
                    }
                )
            )

            print("-----roadmap saved-----")
            print(roadmap_id)
            print("-----------------------")

            # response

            return {
                "success": True,
                "roadmapId": roadmap_id,
                "excelUrl": excel_url,
                "excelPath": excel_path,
                "roadmap": roadmap,

                # NEW FIELDS
                "overdue_cards": getattr(metrics, "overdue_cards", 0),
                "forgotten_cards": getattr(metrics, "forgotten_cards", 0),
                "difficult_cards": getattr(metrics, "difficult_cards", []),
                "favorite_sets": getattr(metrics, "favorite_sets", 0),
                "recommended_topics": getattr(metrics, "recommended_topics", [])
            }

        except Exception as ex:

            print(
                "ROADMAP ERROR:",
                str(ex)
            )

            return {
                "success": False,
                "message": str(ex)
            }