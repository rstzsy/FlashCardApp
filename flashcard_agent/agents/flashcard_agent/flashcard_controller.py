import os

from integrations.gemini.gemini_service import \
    GeminiService

from integrations.openai.openai_image_service import \
    OpenAIImageService

from tools.tavily_search_tool import \
    TavilySearchTool

from tools.firestore_tool import \
    FirestoreTool

from agents.flashcard_agent.flashcard_parser import \
    FlashcardParser, FlashcardValidator

from integrations.openai.openai_image_service import \
    OpenAIImageService

class FlashcardController:

    def __init__(self):

        self.gemini = GeminiService()

        self.image_service = OpenAIImageService()

        self.tavily = TavilySearchTool()

        self.firestore = FirestoreTool()

        self.parser = FlashcardParser()

        self.validator = FlashcardValidator()

    async def generate(self, req):

        try:

            print("-----agent start------")

            # research topic

            print("Researching topic...")

            research = await self.tavily.search_topic(
                req.topic
            )

            # build prompt

            prompt = f"""
            Create {req.totalCards} flashcards.

            Topic:
            {req.topic}

            Difficulty:
            {req.difficulty}

            Language:
            {req.language}

            Research:
            {research}

            Return ONLY valid JSON array.

            Format:
            [
                {{
                    "word": "...",
                    "meaning": "...",
                    "phonetic": "...",
                    "example": "..."
                }}
            ]
            """

            # generate text
            print("Generating flashcards with Gemini...")

            response = await self.gemini.generate(
                prompt
            )

            print("---- agent response ----")
            print(response)

            # parse json
            cards = self.parser.parse(
                response
            )

            # validate information
            valid_cards = self.validator.validate(
                cards
            )

            print(
                f"Valid cards: {len(valid_cards)}"
            )

            # generate image
            print("Generating images...")

            for card in valid_cards:

                card["image_path"] = None

                try:

                    image_path = await self.image_service \
                        .generate_flashcard_image(
                            card["word"],
                            card["meaning"]
                        )

                    if image_path:

                        card["image_path"] = image_path

                        print(
                            f"Generated image for: {card['word']}"
                        )

                    else:

                        print(
                            f"No image generated for: {card['word']}"
                        )

                except Exception as image_error:

                    print(
                        f"IMAGE GENERATION FAILED: {card['word']}"
                    )

                    print(image_error)

                    card["image_path"] = None

            # save firestore
            print("Saving to Firestore...")

            set_id = await self.firestore.save_flashcard_set(
                req.userId,
                req.topic,
                valid_cards,
                req.difficulty,
                req.language
            )

            print(
                f"Saved FlashcardSet: {set_id}"
            )

            # clean temp images
            print("Cleaning temp images...")

            for card in valid_cards:

                try:

                    if card.get("image_path"):

                        if os.path.exists(
                            card["image_path"]
                        ):

                            os.remove(
                                card["image_path"]
                            )

                            print(
                                f"Deleted temp image: {card['image_path']}"
                            )

                except Exception as cleanup_error:

                    print(
                        "TEMP IMAGE CLEANUP ERROR:"
                    )

                    print(cleanup_error)

            # response
            print("----flashcard generation completed----")

            return {

                "success": True,

                "setId": set_id,

                "totalCards": len(valid_cards),

                "cards": valid_cards
            }

        except Exception as e:

            print("----flashcard generation failed----")

            print(e)

            return {

                "success": False,

                "error": str(e)
            }