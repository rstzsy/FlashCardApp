from integrations.firebase.firebase_config import storage_bucket

class StorageTool:

    async def upload_card_image(
        self,
        local_path,
        set_id,
        card_id
    ):

        remote_path = f"flashcards/{set_id}/{card_id}.jpg"

        blob = storage_bucket.blob(
            remote_path
        )

        blob.upload_from_filename(
            local_path
        )

        blob.make_public()

        return blob.public_url