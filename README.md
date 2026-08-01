# Mofu – AI-Powered English Vocabulary Learning Application

Mofu is an AI-powered mobile application designed to help learners acquire, review, and retain English vocabulary more effectively. The application combines flashcard-based learning, the Free Spaced Repetition Scheduler (FSRS), Artificial Intelligence, gamification, and collaborative learning to provide a personalized and engaging learning experience.

The application is developed using Flutter for cross-platform mobile development, FastAPI for AI backend services, and Firebase for cloud-based authentication and data management.

---

## Table of Contents

1. Overview
2. Features
3. System Architecture
4. Technologies
5. Prerequisites
6. Installation
7. Running the Project
8. Project Structure
9. AI Services
10. Firebase Configuration
11. Environment Variables
12. Troubleshooting
13. Future Improvements

---

# Overview

Mofu provides an intelligent vocabulary learning environment by integrating Artificial Intelligence with adaptive review scheduling.

The application supports:

- Flashcard-based vocabulary learning
- AI-generated flashcards
- AI vocabulary recommendations
- Personalized study roadmaps
- FSRS adaptive review scheduling
- Learning statistics
- Gamification
- Collaborative learning
- Community blog

---

# Features

## Authentication

- Google Sign-In
- Firebase Authentication
- User profile

---

## Flashcard Learning

- Create flashcards manually
- AI-generated flashcards
- Organize flashcards into collections
- Import and manage vocabulary sets
- Flashcard review

---

## AI-assisted Learning

### Flashcard Generation Agent

Automatically generates flashcards from a given topic.

### Vocabulary Suggestion Agent

Recommends vocabulary based on learning history and review performance.

### Learning Roadmap Agent

Creates personalized vocabulary learning roadmaps according to user goals.

---

## Adaptive Learning

- FSRS (Free Spaced Repetition Scheduler)
- Adaptive review intervals
- Personalized review scheduling

---

## Gamification

- Word Garden
- Harvest System
- Flower Shop
- Achievement Badges
- Monthly Badges
- Mini Games
- Learning Statistics
- Study Heatmap
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

The system consists of three major components:

## Mobile Application

- Flutter
- Provider State Management
- Firebase SDK
- HTTP Client

↓

## Backend AI Services

FastAPI REST APIs

- Flashcard Agent
- Vocabulary Suggestion Agent
- Learning Roadmap Agent

↓

## Cloud Services

Firebase

- Authentication
- Cloud Firestore
- Cloud Storage
- Cloud Functions

---

# Technologies

| Technology | Purpose |
|------------|---------|
| Flutter | Mobile Application |
| Dart | Programming Language |
| FastAPI | AI Backend Services |
| Firebase Authentication | User Authentication |
| Cloud Firestore | Database |
| Firebase Storage | File Storage |
| Google Gemini | Large Language Model |
| FSRS | Adaptive Review Scheduling |
| Provider | State Management |

---

# Prerequisites

Before running the project, install:

- Flutter SDK 3.7+
- Dart SDK
- Python 3.11+
- Firebase CLI
- Xcode (for iOS)
- Android Studio (for Android)
- Google Cloud Firebase Project

---

# Installation

## Clone Repository

```bash
git clone https://github.com/rstzsy/FlashCardApp.git

cd flashcardApp
```

---

## Install Flutter Packages

```bash
flutter pub get
```

---

## Install Python Dependencies

Flashcard Agent

```bash
cd Untitled/flashcard_agent

pip install -r requirements.txt
```

Roadmap Agent

```bash
cd ../roadmap_agent

pip install -r requirements.txt
```

Suggestion Agent

```bash
cd ../suggestion_agent

pip install -r requirements.txt
```

---

# Running the Project

## Start Flashcard Agent

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
flutter pub get

flutter run
```

For iOS Simulator

```bash
open -a Simulator

flutter run
```

---

# Project Structure

```
flashcardApp

│

├── lib/

│   ├── core/

│   ├── features/

│   ├── models/

│   ├── services/

│   ├── routes/

│   └── widgets/

│

├── assets/

│

├── Untitled/

│   ├── flashcard_agent/

│   ├── roadmap_agent/

│   └── suggestion_agent/

│

└── functions/
```

---

# AI Services

## Flashcard Agent

Port:

```
8000
```

Function

- Generate flashcards
- Create definitions
- Generate examples

---

## Learning Roadmap Agent

Port

```
8001
```

Function

- Analyze user goals
- Generate personalized study roadmap

---

## Vocabulary Suggestion Agent

Port

```
8002
```

Function

- Recommend vocabulary
- Analyze learning history
- Prioritize difficult words

---

# Firebase Configuration

Firebase services used in this project:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions

---

# Environment Variables

Create a `.env` file for each AI service.

Example

```env
GEMINI_API_KEY=YOUR_API_KEY
```

Flutter Firebase configuration should be generated using

```bash
flutterfire configure
```

---

# Troubleshooting

## AI service cannot connect

Check whether all FastAPI servers are running.

Ports

```
8000
8001
8002
```

---

## Flutter cannot connect to backend

Verify the backend IP address configured in

```
lib/core/config/env.dart
```

Ensure the simulator/device and backend are on the same network.

---

## Firebase Authentication Error

Run

```bash
flutterfire configure
```

Ensure the correct

- GoogleService-Info.plist

or

- google-services.json

is included.

---

## iOS Simulator Issues

Restart Simulator

```bash
xcrun simctl shutdown all

open -a Simulator
```

---

# Future Improvements

- Support additional languages.
- Integrate offline learning mode.
- Add speech recognition for pronunciation assessment.
- Deploy AI services to cloud infrastructure.
- Introduce additional AI Agents for grammar correction and conversational learning.
- Expand gamification with seasonal events and competitive challenges.
