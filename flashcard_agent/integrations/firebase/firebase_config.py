import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

cred = credentials.Certificate(
    "firebase-service-account.json"
)

firebase_admin.initialize_app(cred, {
    'storageBucket': 'mofu-8984b.firebasestorage.app'
})

firestore_db = firestore.client()
storage_bucket = storage.bucket()