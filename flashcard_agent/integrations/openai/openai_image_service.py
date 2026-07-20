import os
import uuid
from openai import OpenAI

class OpenAIImageService:

    def __init__(self):

        self.client = OpenAI(
            api_key=os.getenv(
                "OPENAI_API_KEY"
            )
        )

    async def generate_flashcard_image(
        self,
        word,
        meaning
    ):

        try:

            prompt = f"""
            Minimal educational flashcard illustration.

            Main object:
            {word}

            Meaning:
            {meaning}

            Style:
            flat vector illustration,
            colorful,
            minimal,
            clean,
            centered object,
            white background,
            educational flashcard icon,
            no text,
            child-friendly,
            high quality
            """

            result = self.client.images.generate(
                model="gpt-image-1-mini",
                prompt=prompt,
                size="1024x1024"
            )

            image_base64 = result.data[0].b64_json

            import base64

            image_data = base64.b64decode(
                image_base64
            )

            os.makedirs(
                "temp/images",
                exist_ok=True
            )

            file_path = (
                f"temp/images/"
                f"{uuid.uuid4()}.png"
            )

            with open(file_path, "wb") as f:
                f.write(image_data)

            print(
                f"Generated image: {file_path}"
            )

            return file_path

        except Exception as e:

            print(
                "OPENAI IMAGE ERROR:"
            )

            print(e)

            return None