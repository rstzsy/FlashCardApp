import os
import time
import uuid

from google import genai
from dotenv import load_dotenv


load_dotenv()


class GeminiService:

    def __init__(self):

        self.client = genai.Client(
            api_key=os.getenv("GEMINI_API_KEY")
        )

    async def generate(
        self,
        prompt
    ):

        for attempt in range(3):

            try:

                response = self.client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=prompt
                )

                return response.text

            except Exception as e:

                print(f"Gemini retry {attempt+1}: {e}")

                time.sleep(3)

        raise Exception(
            "Gemini text generation failed"
        )

    # async def generate_image(
    #     self,
    #     prompt
    # ):

    #     for attempt in range(3):

    #         try:

    #             response = self.client.models.generate_content(
    #                 model="gemini-2.5-flash-image",
    #                 contents=prompt
    #             )

    #             image_bytes = response.candidates[0] \
    #                 .content.parts[0] \
    #                 .inline_data.data

    #             os.makedirs(
    #                 "temp/images",
    #                 exist_ok=True
    #             )

    #             file_name = f"{uuid.uuid4()}.png"

    #             local_path = f"temp/images/{file_name}"

    #             with open(local_path, "wb") as f:

    #                 f.write(image_bytes)

    #             return local_path

    #         except Exception as e:

    #             print(f"Image retry {attempt+1}: {e}")

    #             time.sleep(5)

    #     raise Exception(
    #         "Gemini image generation failed"
    #     )