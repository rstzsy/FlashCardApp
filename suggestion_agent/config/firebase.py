import firebase_admin
from firebase_admin import credentials, firestore

_initialized = False


def get_firestore_client():
    global _initialized
    if not _initialized:
        cred = credentials.Certificate("firebase-service-account.json")
        firebase_admin.initialize_app(cred)
        _initialized = True
    return firestore.client()
