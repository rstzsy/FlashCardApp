import os
from firebase_admin import storage
from uuid import uuid4


class StorageTool:

    def upload_file(
        self,
        file_path: str,
        destination: str = None
    ):

        try:

            bucket = storage.bucket()

            if destination is None:
                destination = (
                    f"roadmaps/{uuid4()}.xlsx"
                )

            blob = bucket.blob(
                destination
            )

            blob.upload_from_filename(
                file_path
            )

            blob.make_public()

            public_url = blob.public_url

            if os.path.isfile(file_path):
                os.remove(file_path)

            return public_url

        except Exception as ex:

            print(
                "UPLOAD ERROR:",
                str(ex)
            )

            raise ex