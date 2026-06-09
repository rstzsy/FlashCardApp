import json
import re

class RoadmapParser:

    def parse(self, response):

        if not response:
            raise Exception(
                "Gemini returned empty response"
            )

        response = response.strip()

        response = response.replace(
            "```json",
            ""
        )

        response = response.replace(
            "```",
            ""
        )

        match = re.search(
            r"\{.*\}",
            response,
            re.DOTALL
        )

        if not match:
            raise Exception(
                f"Cannot find JSON in Gemini response:\n{response}"
            )

        json_text = match.group(0)

        return json.loads(json_text)