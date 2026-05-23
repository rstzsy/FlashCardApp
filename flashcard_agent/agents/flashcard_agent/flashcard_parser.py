import json

class FlashcardParser:

    def parse(self, text: str):

        cleaned = text.replace("```json", "")
        cleaned = cleaned.replace("```", "")

        return json.loads(cleaned)
    
class FlashcardValidator:

    def validate(self, cards):

        valid_cards = []

        for card in cards:

            if (
                card.get("word")
                and card.get("meaning")
            ):
                valid_cards.append(card)

        return valid_cards