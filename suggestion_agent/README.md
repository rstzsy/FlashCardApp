# Vocabulary Suggestion Agent

FastAPI project độc lập để test chức năng **AI Gợi Ý Từ Vựng** dựa trên FSRS-4.5 data.

## Cấu trúc project

```
suggestion_agent/
├── main.py                          
├── requirements.txt
├── .env.example                    
├── firebase-service-account.json        
│
├── agents/
│   └── suggestion_controller.py    
│
├── api/
│   └── suggestion_routes.py        
├── config/
│   ├── firebase.py                  # Firebase Admin SDK init
│   └── settings.py                  # Weights, thresholds, env vars
│
├── integrations/
│   ├── firestore_service.py         # Batch data collector từ Firestore
│   └── gemini_service.py            # Gemini 2.5 Flash — sinh lý do gợi ý
│
├── schemas/
│   └── suggestion_schema.py         # Pydantic models request/response
│
└── tools/
    └── priority_scorer.py           # Pure Python — tính Priority Score
```

## Setup

### 1. Cài dependencies

```bash
cd suggestion_agent
pip install -r requirements.txt
```

### 2. Cấu hình environment

```bash
cp .env.example .env
# Điền GEMINI_API_KEY và đường dẫn firebase credentials
```

### 3. Firebase credentials

- Vào Firebase Console → Project Settings → Service accounts
- Bấm "Generate new private key" → tải về
- Đặt tên file là `firebase_credentials.json` và để vào thư mục gốc project

### 4. Chạy server

```bash
uvicorn main:app --reload --port 8001
```

## Test API

### Swagger UI
Mở browser: `http://localhost:8001/docs`

### cURL

```bash
curl -X POST http://localhost:8001/api/v1/suggest-vocabulary \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "0MgjLq2qTHPnjFmj6SOXnFMFkhz2",
    "sessionDuration": 20,
    "topN": 10,
    "context": {
      "streakAtRisk": false
    }
  }'
```

### Response mẫu

```json
{
  "suggested_words": [
    {
      "cardId": "card_abc123",
      "setId": "set_xyz",
      "word": "itinerary",
      "meaning": "lịch trình chuyến đi",
      "phonetic": "/aɪˈtɪnəreri/",
      "priority_score": 0.87,
      "reason": "Bạn đã quên từ này 4 lần rồi — hôm nay là thời điểm hoàn hảo để ghi nhớ chắc chắn hơn!",
      "tag": "overdue",
      "due_days_ago": 3
    }
  ],
  "session_meta": {
    "total_suggested": 10,
    "due_count": 6,
    "new_count": 2,
    "review_count": 2,
    "estimated_duration_min": 20
  }
}
```

## Logic Priority Score (tóm tắt)

```
Priority = (0.45 × SRS_Score) + (0.25 × Lapse_Score)
         + (0.20 × Difficulty_Score) + (0.10 × Topic_Score)
```

| Tag         | SRS_Score | Condition              |
|-------------|-----------|------------------------|
| overdue     | 1.00      | due > 3 ngày trước     |
| overdue     | 0.85      | due < hôm nay          |
| due_today   | 0.70      | due == hôm nay         |
| new_word    | 0.50      | state = new            |
| review      | 0.10      | due > hôm nay          |

## So sánh với Roadmap Agent

| Tiêu chí        | Roadmap Agent      | Suggestion Agent       |
|-----------------|--------------------|------------------------|
| Dùng Tavily     | ✅ Có              | ❌ Không cần           |
| Dùng Gemini     | Sinh lộ trình      | Chỉ sinh lý do         |
| Cá nhân hoá     | Trung bình         | Cao nhất (FSRS/card)   |
| Output          | Excel roadmap      | JSON list từ + lý do   |
| AI ra quyết định| Có                 | ❌ Python quyết định   |
