from integrations.tavily.tavily_service import TavilyService

class TavilySearchTool:

    def __init__(self):
        self.service = TavilyService()

    async def search_topic(self, topic: str):

        query = f"""
        important vocabulary about {topic}
        with meaning and examples
        """

        return await self.service.search(query)