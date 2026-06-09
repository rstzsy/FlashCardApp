from firebase_admin import credentials
from firebase_admin import firestore
import firebase_admin

cred = credentials.Certificate(
    "firebase-service-account.json"
)

firebase_admin.initialize_app(cred, {
    'storageBucket': 'mofu-8984b.firebasestorage.app'
})


db = firestore.client()