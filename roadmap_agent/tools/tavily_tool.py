from tavily import TavilyClient
from config.settings import Settings

class TavilyTool:

    def __init__(self):

        self.client = TavilyClient(
            api_key=
            Settings.TAVILY_API_KEY
        )

    def search_context(
        self,
        interests
    ):

        query = f"""
        Learning roadmap for
        {','.join(interests)}
        vocabulary learners
        """

        return self.client.search(
            query=query,
            max_results=5
        )