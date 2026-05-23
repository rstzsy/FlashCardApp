import os

from uuid import uuid4

from firebase_admin import firestore
from firebase_admin import storage

from integrations.firebase.firebase_config import \
    firestore_db


class FirestoreTool:

    async def upload_image(
        self,
        image_path,
        set_id,
        card_id
    ):

        try:

            bucket = storage.bucket()

            blob = bucket.blob(
                f"flashcards/{set_id}/{card_id}.png"
            )

            blob.upload_from_filename(
                image_path
            )

            blob.make_public()

            return blob.public_url

        except Exception as e:

            print("UPLOAD IMAGE ERROR")
            print(e)

            return None

    async def save_flashcard_set(
        self,
        user_id,
        title,
        cards,
        difficulty,
        language
    ):

        set_id = str(uuid4())

        firestore_db.collection(
            "FlashcardSets"
        ).document(set_id).set({

            "SetId": set_id,

            "UserId": user_id,

            "Title": title,

            "Subtitle":
            f"AI Generated - {title}",

            "Icon": "58873",

            "ColorHex": "#f2dcbe",

            "TotalCards": len(cards),

            "Difficulty": difficulty,

            "Language": language,

            "IsPublic": False,

            "IsGeneratedByAI": True,

            "CreatedAt":
            firestore.SERVER_TIMESTAMP,

            "UpdatedAt":
            firestore.SERVER_TIMESTAMP,
        })

        for card in cards:

            card_id = str(uuid4())

            image_url = None

            if card.get("image_path"):

                if os.path.exists(
                    card["image_path"]
                ):

                    image_url = await \
                        self.upload_image(

                            card["image_path"],

                            set_id,

                            card_id
                        )

            firestore_db.collection(
                "Flashcards"
            ).document(card_id).set({

                "CardId": card_id,

                "SetId": set_id,

                "Word": card["word"],

                "Meaning": card["meaning"],

                "Phonetic":
                card.get("phonetic"),

                "Example":
                card.get("example"),

                "ImageUrl":
                image_url,

                "Tags": [],

                "IsFavorite": False,

                "CreatedAt":
                firestore.SERVER_TIMESTAMP,

                "UpdatedAt":
                firestore.SERVER_TIMESTAMP,
            })

        return set_id