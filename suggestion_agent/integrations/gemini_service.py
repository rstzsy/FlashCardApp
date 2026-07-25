import json
import re
import time
from google import genai
from google.genai import types
from config.settings import (
    GEMINI_API_KEY,
    GEMINI_MODEL,
    OVERLOAD_THRESHOLD,
    WEIGHT_SRS,
    WEIGHT_LAPSE,
    WEIGHT_DIFFICULTY,
    WEIGHT_TOPIC,
)

_client = genai.Client(api_key=GEMINI_API_KEY)

VALID_TAGS = {"overdue", "due_today", "new_word", "difficult", "review"}


# ── Prompt construction ──────────────────────────────────────────────────────

def _word_block(i: int, c: dict) -> str:
    lines = [
        f'=== ỨNG VIÊN {i} ===',
        f'cardId: {c["cardId"]}',
        f'Từ: "{c["word"]}" — {c["meaning"]}',
        f'Chủ đề: {c["topic"]} (thẻ được đánh dấu yêu thích: {c["is_favourite_card"]}, chủ đề đang học dở: {c["is_in_progress_set"]})',
        f'Trạng thái FSRS: {c["state"]} | reps={c["reps"]} | lapses={c["lapses"]} | difficulty={c["difficulty"]:.1f}/10',
    ]
    if c["state"] != "new":
        if c["days_overdue"] > 0:
            lines.append(f'Quá hạn {c["days_overdue"]} ngày | Nguy cơ đã quên: ~{c["forgetting_pct"]}%')
        elif c["is_due_today"]:
            lines.append(f'Đến hạn hôm nay | Nguy cơ đã quên: ~{c["forgetting_pct"]}%')
        elif c["is_upcoming"]:
            lines.append(f'Sắp đến hạn (trong vài ngày tới) | Nguy cơ đã quên: ~{c["forgetting_pct"]}%')
        if c["days_since_review"] is not None:
            lines.append(f'Lần ôn gần nhất: {round(c["days_since_review"])} ngày trước')
    else:
        lines.append("Từ mới — chưa học lần nào.")
    if c["is_chronically_hard"]:
        lines.append(f'⚠ Đã quên {c["lapses"]} lần — thuộc nhóm từ khó nhớ nhất của user.')
    if c.get("example"):
        lines.append(f'Ví dụ: "{c["example"]}"')
    return "\n".join(lines)


def _build_prompt(candidates: list[dict], user_context: dict, session_ctx: dict) -> str:
    blocks = "\n\n".join(_word_block(i, c) for i, c in enumerate(candidates, 1))

    streak = user_context.get("streak", 0)
    streak_at_risk = session_ctx.get("streakAtRisk", False)
    level = user_context.get("englishLevel", "intermediate")
    goal = user_context.get("targetGoal", "")
    current_set_id = session_ctx.get("currentSetId")
    max_words = session_ctx["max_words"]
    words_studied_today = session_ctx.get("words_studied_today", 0)
    has_any_fsrs_history = any(c["state"] != "new" for c in candidates)

    guidance = []
    if not has_any_fsrs_history:
        guidance.append(
            "Đây là user MỚI, chưa có lịch sử FSRS thật (toàn bộ thẻ đều 'new'). "
            "Hãy chọn 5-10 từ thuộc chủ đề user quan tâm/đã tạo gần đây nhất, sắp xếp có hệ thống."
        )
    if streak_at_risk:
        guidance.append(
            f"Streak {streak} ngày đang có nguy cơ đứt (chưa học hôm nay). Ưu tiên xen kẽ vài từ QUEN THUỘC/dễ "
            "(không chỉ từ khó) để user hoàn thành phiên nhanh, không nản — nhưng đừng bỏ qua từ có nguy cơ quên cao."
        )
    if words_studied_today > OVERLOAD_THRESHOLD:
        guidance.append(
            f"User đã học {words_studied_today} từ hôm nay rồi — có dấu hiệu quá tải. "
            "Chỉ chọn những từ THỰC SỰ cấp thiết (quá hạn nặng, nguy cơ quên cao), bỏ bớt từ mới."
        )
    if max_words < 5:
        guidance.append(
            "Thời gian phiên học rất ngắn — chỉ chọn từ quá hạn/đến hạn hôm nay, KHÔNG thêm từ mới."
        )
    if not any(c["days_overdue"] > 0 or c["is_due_today"] for c in candidates):
        guidance.append(
            "Không có từ nào quá hạn hoặc đến hạn hôm nay — đây là dấu hiệu TỐT. "
            "Hãy khen ngợi ngắn trong lý do, và gợi ý từ mới thuộc chủ đề đang học dở hoặc liên quan mục tiêu."
        )
    if current_set_id:
        guidance.append(f"User đang học bộ thẻ '{current_set_id}' — ưu tiên nhẹ cho từ trong bộ này nếu phù hợp.")

    guidance_block = "\n".join(f"- {g}" for g in guidance) if guidance else "- Không có tình huống đặc biệt."

    return f"""Bạn là một AI chuyên gia về khoa học ghi nhớ (spaced repetition, đường cong quên Ebbinghaus, FSRS).
Nhiệm vụ của bạn KHÔNG phải áp một công thức cố định — hãy PHÂN TÍCH dữ liệu từng từ bên dưới và tự quyết định
từ nào nên đưa vào phiên học hôm nay, xếp thứ tự ưu tiên, gắn nhãn, và viết lý do thuyết phục.

HỒ SƠ NGƯỜI HỌC:
- Trình độ: {level}
- Mục tiêu: {goal or "chưa đặt mục tiêu cụ thể"}
- Streak hiện tại: {streak} ngày

BỐI CẢNH PHIÊN HỌC HÔM NAY:
- Sức chứa tối đa của phiên: {max_words} từ (đây là giới hạn CỨNG do thời gian, không được vượt quá)
- Đã học hôm nay: {words_studied_today} từ
{guidance_block}

NGUYÊN TẮC PHÂN TÍCH (tự suy luận, không phải công thức cộng điểm cứng):
- Nguy cơ quên càng cao (forgetting % cao, quá hạn càng lâu so với stability) → càng cấp thiết
- Từ hay bị quên (lapses cao) cần được ưu tiên đưa vào đều đặn hơn, không để "rơi" khỏi vòng ôn tập
- Từ mới nên được rải đều, không dồn hết vào 1 phiên, và không được lấn át từ cần ôn gấp
- Sự phù hợp chủ đề/mục tiêu là yếu tố cộng thêm, không phải yếu tố quyết định chính
- Đảm bảo trong danh sách cuối cùng có sự cân bằng hợp lý giữa "quá hạn/đến hạn" và "từ mới" — không cứng nhắc theo tỷ lệ % nào, hãy dùng phán đoán

DANH SÁCH ỨNG VIÊN:
{blocks}

YÊU CẦU LÝ DO (mỗi từ, 2-3 câu, tối đa 60 từ):
✅ Dựa vào dữ liệu THẬT của từ đó (số lần quên, số ngày quá hạn, % nguy cơ quên...) — diễn giải bằng ngôn ngữ con người, không phô số liệu kỹ thuật
✅ Nêu hậu quả cụ thể nếu bỏ qua hôm nay
✅ Câu mở đầu mỗi lý do phải khác nhau, không lặp cấu trúc
❌ Không dùng "Hôm nay là thời điểm hoàn hảo...", "Hãy...", không lộ số liệu thô kiểu "difficulty=7.2"

Trả về DUY NHẤT một JSON array, không markdown, không giải thích thêm, tối đa {max_words} phần tử,
đã được BẠN xếp theo thứ tự ưu tiên giảm dần (phần tử đầu = nên học đầu tiên):
[{{"cardId": "...", "priority_score": 0.0-1.0, "tag": "overdue|due_today|new_word|difficult|review", "reason": "..."}}]

priority_score là đánh giá CHỦ QUAN của bạn (mức độ cấp thiết, 0-1), không phải kết quả một công thức có sẵn.
Chỉ dùng cardId có trong danh sách ứng viên ở trên.
"""


# ── Parsing / validation ─────────────────────────────────────────────────────

def _extract_partial_json(raw: str) -> list[dict]:
    pattern = re.compile(
        r'\{\s*"cardId"\s*:\s*"([^"]+)"\s*,\s*"priority_score"\s*:\s*([\d.]+)\s*,\s*"tag"\s*:\s*"([^"]+)"\s*,\s*"reason"\s*:\s*"((?:[^"\\]|\\.)*)"\s*\}'
    )
    return [
        {"cardId": m.group(1), "priority_score": float(m.group(2)), "tag": m.group(3), "reason": m.group(4)}
        for m in pattern.finditer(raw)
    ]


def _validate_and_clip(items: list[dict], candidates_by_id: dict, top_n: int, max_words: int) -> list[dict]:
    """Hard safety rails only: real cardId, valid tag, no dupes, respect the request's limits."""
    limit = min(top_n, max_words)
    seen = set()
    clean = []
    for item in items:
        cid = item.get("cardId")
        if not cid or cid not in candidates_by_id or cid in seen:
            continue
        tag = item.get("tag") if item.get("tag") in VALID_TAGS else _infer_tag(candidates_by_id[cid])
        score = item.get("priority_score", 0.5)
        try:
            score = max(0.0, min(1.0, float(score)))
        except (TypeError, ValueError):
            score = 0.5
        clean.append({
            "cardId": cid,
            "priority_score": round(score, 4),
            "tag": tag,
            "reason": item.get("reason", "").strip() or _fallback_reason(candidates_by_id[cid]),
        })
        seen.add(cid)
        if len(clean) >= limit:
            break
    return clean


def _infer_tag(c: dict) -> str:
    if c["days_overdue"] > 0:
        return "overdue"
    if c["is_due_today"]:
        return "due_today"
    if c["state"] == "new":
        return "new_word"
    if c["difficulty"] >= 7.0:
        return "difficult"
    return "review"


def _fallback_reason(c: dict) -> str:
    w, meaning, topic = c["word"], c["meaning"], c["topic"]
    if c["days_overdue"] > 0:
        return f'"{w}" ({meaning}) đã quá hạn {c["days_overdue"]} ngày, nguy cơ quên ~{c["forgetting_pct"]}%. Ôn ngay để tránh học lại từ đầu.'
    if c["is_due_today"]:
        return f'"{w}" ({meaning}) đến hạn ôn hôm nay — đây là thời điểm SRS tối ưu để ghi nhớ lâu dài.'
    if c["state"] == "new":
        return f'Từ mới "{w}" ({meaning}) thuộc chủ đề {topic}. Bắt đầu hôm nay để khởi động chu trình ghi nhớ.'
    if c["is_chronically_hard"]:
        return f'"{w}" ({meaning}) đã bị quên {c["lapses"]} lần — cần ôn đều đặn để thoát khỏi vòng lặp quên.'
    return f'"{w}" ({meaning}) sắp đến hạn — ôn sớm giúp củng cố trí nhớ trước khi nó bắt đầu phai.'


# ── Deterministic fallback ranking (only used if Gemini is unreachable) ─────

def _fallback_ranking(candidates: list[dict], top_n: int, max_words: int) -> list[dict]:
    def score(c):
        srs = 1.0 if c["days_overdue"] > 3 else 0.85 if c["days_overdue"] > 0 else 0.70 if c["is_due_today"] else 0.50 if c["state"] == "new" else 0.10
        lapse = 0.0 if c["lapses"] == 0 else 0.3 if c["lapses"] <= 2 else 0.6 if c["lapses"] <= 4 else 1.0
        diff = (max(1.0, min(10.0, c["difficulty"])) - 1) / 9
        topic = 1.0 if c["is_favourite_card"] else 0.7 if c["is_in_progress_set"] else 0.1
        return WEIGHT_SRS * srs + WEIGHT_LAPSE * lapse + WEIGHT_DIFFICULTY * diff + WEIGHT_TOPIC * topic

    ranked = sorted(candidates, key=score, reverse=True)[: min(top_n, max_words)]
    return [
        {
            "cardId": c["cardId"],
            "priority_score": round(score(c), 4),
            "tag": _infer_tag(c),
            "reason": _fallback_reason(c),
        }
        for c in ranked
    ]


# ── Main entry point ──────────────────────────────────────────────────────────

def select_and_explain(
    candidates: list[dict],
    user_context: dict,
    session_ctx: dict,
    top_n: int,
) -> list[dict]:
    """
    Returns an ordered list of dicts: {cardId, priority_score, tag, reason}.
    Selection, ranking, tagging and reasoning are all Gemini's output — the
    only Python-side enforcement is _validate_and_clip's safety rails.
    """
    if not candidates:
        return []

    candidates_by_id = {c["cardId"]: c for c in candidates}
    max_words = session_ctx["max_words"]
    prompt = _build_prompt(candidates, user_context, session_ctx)

    for attempt in range(3):
        try:
            response = _client.models.generate_content(
                model=GEMINI_MODEL,
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.7,
                    max_output_tokens=8192,
                    response_mime_type="application/json",
                ),
            )
            raw = response.text.strip()
            raw = re.sub(r"^```json\s*|^```\s*|```$", "", raw, flags=re.MULTILINE).strip()

            try:
                items = json.loads(raw)
            except json.JSONDecodeError:
                items = _extract_partial_json(raw)
                if not items:
                    raise

            result = _validate_and_clip(items, candidates_by_id, top_n, max_words)
            if result:
                return result
            break  # AI returned nothing usable — fall through to fallback

        except Exception as e:
            msg = str(e)
            print(f"[GeminiService] Attempt {attempt+1} failed: {msg}")
            if "503" in msg or "UNAVAILABLE" in msg or "overloaded" in msg.lower():
                time.sleep(1.5 * (attempt + 1))
                continue
            break

    print("[GeminiService] Gemini unavailable — using deterministic fallback ranking.")
    return _fallback_ranking(candidates, top_n, max_words)