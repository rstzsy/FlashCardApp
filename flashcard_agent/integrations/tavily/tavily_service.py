import os
from tavily import TavilyClient
from dotenv import load_dotenv

load_dotenv()

class TavilyService:

    def __init__(self):
        self.client = TavilyClient(
            api_key=os.getenv("TAVILY_API_KEY")
        )

    async def search(self, query: str):

        enhanced_query = f"""
        English vocabulary about: {query}

        Include:
        - definitions
        - examples
        - meanings
        - IELTS vocabulary
        - related vocabulary
        """

        result = self.client.search(

            query=enhanced_query,

            search_depth="advanced",

            max_results=5,

            include_domains=[
                "dictionary.cambridge.org"
            ]
        )

        return result