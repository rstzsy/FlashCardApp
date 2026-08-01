# Mofu – AI-Powered English Vocabulary Learning Application

Mofu is an AI-powered English vocabulary learning mobile application designed to help learners acquire, review, and retain vocabulary effectively. The application combines flashcard-based learning, the Free Spaced Repetition Scheduler (FSRS), Artificial Intelligence, gamification, and collaborative learning to provide a personalized and engaging learning experience.

The system is developed using **Flutter** for cross-platform mobile development, **FastAPI** for AI backend services, and **Firebase** for authentication, cloud database management, and data synchronization.

---

# Table of Contents

1. Overview
2. Features
3. System Architecture
4. Technologies
5. Project Structure
6. Prerequisites
7. Installation
8. Running the Project
9. AI Services
10. Firebase Configuration
11. Environment Variables
12. Troubleshooting
13. Future Improvements

---

# Overview

Mofu is an intelligent English vocabulary learning application that integrates Artificial Intelligence and adaptive learning technologies to improve long-term vocabulary retention.

The application provides:

- Flashcard-based vocabulary learning
- AI-generated flashcards
- AI vocabulary recommendations
- Personalized learning roadmaps
- Adaptive review scheduling using FSRS
- Learning statistics
- Gamification
- Collaborative learning
- Community blog

---

# Features

## Authentication

- Google Sign-In
- Firebase Authentication
- User profile management

---

## Flashcard Learning

- Create flashcards manually
- AI-generated flashcards
- Organize flashcards into collections
- Vocabulary review
- Adaptive review scheduling (FSRS)

---

## AI-assisted Learning

### Flashcard Generation Agent

Automatically generates flashcards from user-selected topics.

### Vocabulary Suggestion Agent

Recommends vocabulary based on users' learning history and review performance.

### Learning Roadmap Agent

Creates personalized learning roadmaps according to users' goals and learning progress.

---

## Adaptive Learning

- Free Spaced Repetition Scheduler (FSRS)
- Personalized review intervals
- Memory-based scheduling

---

## Gamification

- Word Garden
- Harvest System
- Flower Shop
- Achievement Badges
- Monthly Badges
- Mini Games
- Study Heatmap
- Learning Statistics
- XP and Streak Tracking

---

## Collaborative Learning

- Create learning groups
- Invite members
- Shared flashcard collections
- Group Leaderboard

---

## Community Blog

- Create blog posts
- Like posts
- Comment
- Bookmark
- Role-based management

---

# System Architecture

The application consists of three major components.

### Mobile Application

- Flutter
- Provider State Management
- Firebase SDK
- HTTP Client

↓

### AI Backend Services

FastAPI REST APIs

- Flashcard Generation Agent
- Vocabulary Suggestion Agent
- Learning Roadmap Agent

↓

### Cloud Services

Firebase

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions

---

# Technologies

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform Mobile Application |
| Dart | Programming Language |
| FastAPI | AI Backend Services |
| Firebase Authentication | Google Sign-In Authentication |
| Cloud Firestore | Cloud Database |
| Firebase Storage | Image Storage |
| Cloud Functions | Backend Automation |
| Google Gemini | Large Language Model |
| FSRS | Adaptive Review Algorithm |
| Provider | State Management |
| HTTP | API Communication |

---

# Project Structure

```
FlashCardApp
│
├── Untitled
│   │
│   ├── flashcard_app/
│   │   ├── android/
│   │   ├── ios/
│   │   ├── lib/
│   │   ├── assets/
│   │   ├── pubspec.yaml
│   │   └── ...
│   │
│   ├── flashcard_agent/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── ...
│   │
│   ├── roadmap_agent/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── ...
│   │
│   └── suggestion_agent/
│       ├── main.py
│       ├── requirements.txt
│       └── ...
│
├── .gitignore
└── firebase-debug.log
```

---

# Prerequisites

Before running the project, make sure the following software is installed.

- Flutter SDK (3.7 or later)
- Dart SDK
- Python 3.11+
- Firebase CLI
- Android Studio or VS Code
- Xcode (for iOS development)
- Google Firebase Project

---

# Installation

## Clone Repository

```bash
git clone https://github.com/rstzsy/FlashCardApp.git

cd FlashCardApp
```

---

## Install Flutter Dependencies

```bash
cd Untitled/flashcard_app

flutter pub get
```

---

## Install Python Dependencies

### Flashcard Agent

```bash
cd ../flashcard_agent

pip install -r requirements.txt
```

### Learning Roadmap Agent

```bash
cd ../roadmap_agent

pip install -r requirements.txt
```

### Vocabulary Suggestion Agent

```bash
cd ../suggestion_agent

pip install -r requirements.txt
```

---

# Running the Project

## Start Flashcard Generation Agent

```bash
cd Untitled/flashcard_agent

python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Start Learning Roadmap Agent

```bash
cd Untitled/roadmap_agent

python3 -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

---

## Start Vocabulary Suggestion Agent

```bash
cd Untitled/suggestion_agent

python3 -m uvicorn main:app --host 0.0.0.0 --port 8002 --reload
```

---

## Run Flutter Application

```bash
cd Untitled/flashcard_app

flutter run
```

For iOS Simulator

```bash
open -a Simulator

flutter run
```

---

# AI Services

| Service | Port | Description |
|----------|------|-------------|
| Flashcard Generation Agent | 8000 | Generate flashcards from learning topics |
| Learning Roadmap Agent | 8001 | Generate personalized vocabulary learning roadmaps |
| Vocabulary Suggestion Agent | 8002 | Recommend vocabulary based on users' learning history and review performance |

---

# Firebase Configuration

The application integrates the following Firebase services:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions

To configure Firebase, run:

```bash
flutterfire configure
```

Ensure the following configuration files are added correctly:

### Android

```
android/app/google-services.json
```

### iOS

```
ios/Runner/GoogleService-Info.plist
```

---

# Environment Variables

Each AI service requires a `.env` file containing the Gemini API key.

Example:

```env
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

---

# Troubleshooting

### Flutter cannot connect to AI services

Ensure all FastAPI servers are running.

Required ports:

```
8000
8001
8002
```

---

### AI features do not work

- Verify the Gemini API key.
- Check whether the API quota has been exceeded.
- Ensure all AI services are running successfully.

---

### Firebase Authentication Error

Run:

```bash
flutterfire configure
```

Verify that:

- Google Sign-In is enabled in Firebase Authentication.
- `google-services.json` and `GoogleService-Info.plist` are correctly configured.

---

### iOS Simulator Issues

Restart the simulator.

```bash
xcrun simctl shutdown all

open -a Simulator
```

---

### Flutter Dependencies Error

Run:

```bash
flutter clean

flutter pub get
```

---

# Future Improvements

- Support multiple languages.
- Integrate speech recognition for pronunciation assessment.
- Deploy AI services to cloud infrastructure.
- Add offline learning support.
- Introduce additional AI agents for grammar correction and conversational learning.
- Expand gamification with seasonal events, leaderboards, and collaborative challenges.

---

# Authors

**Nguyen Thuy Khanh** **Nguyen Tran Mai Thanh**

Faculty of Information Technology

Ton Duc Thang University

---

# License

This project is developed for academic and research purposes as part of a graduation thesis at Ton Duc Thang University.
