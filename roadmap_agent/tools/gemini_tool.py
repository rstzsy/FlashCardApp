from google import genai
from config.settings import Settings

class GeminiTool:

    def __init__(self):

        self.client = genai.Client(
            api_key=
            Settings.GEMINI_API_KEY
        )

    async def generate(
        self,
        prompt
    ):

        result = (
            self.client.models
            .generate_content(
                model=
                "gemini-2.5-flash",
                contents=prompt
            )
        )

        return result.text