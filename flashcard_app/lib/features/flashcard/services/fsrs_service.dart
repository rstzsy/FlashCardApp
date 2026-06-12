// services/fsrs_service.dart
// Thuật toán FSRS-4.5 implementation + Firestore persistence

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard_fsrs_data.dart';

/// Rating của user sau khi xem thẻ
enum FsrsRating {
  again, // 1 — Quên hoàn toàn
  hard,  // 2 — Nhớ nhưng khó
  good,  // 3 — Nhớ đúng
  easy,  // 4 — Quá dễ
}

extension FsrsRatingValue on FsrsRating {
  int get value {
    switch (this) {
      case FsrsRating.again: return 1;
      case FsrsRating.hard:  return 2;
      case FsrsRating.good:  return 3;
      case FsrsRating.easy:  return 4;
    }
  }
}

class FsrsService {
  final _db = FirebaseFirestore.instance;

  // ─── FSRS-4.5 Parameters (default) ───────────────────────────────────────
  static const List<double> _w = [
    0.4072, 1.1829, 3.1262, 15.4722, 7.2102,
    0.5316, 1.0651, 0.0589, 1.5330,  0.1544,
    1.0070, 1.9395, 0.1100, 0.2900,  2.2700,
    0.1400, 2.9898, 0.5100, 0.4150,
  ];
  static const double _requestRetention = 0.9; // 90% target retention
  static const double _decay = -0.5;
  static const double _factor = 0.9 / 0.1; // = 9 (tính từ decay)

  // ─── Firestore Collection ─────────────────────────────────────────────────
  // Path: fsrs_progress/{userId}/cards/{cardId}
  CollectionReference _userCards(String userId) => _db
      .collection('fsrs_progress')
      .doc(userId)
      .collection('cards');

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Load FSRS data cho toàn bộ thẻ trong set
  Future<Map<String, FlashcardFsrsData>> loadSetProgress({
    required String userId,
    required String setId,
    required List<String> cardIds,
  }) async {
    final result = <String, FlashcardFsrsData>{};

    // Batch query tất cả cards trong set
    final snap = await _userCards(userId)
        .where('setId', isEqualTo: setId)
        .get();

    for (final doc in snap.docs) {
      final data = FlashcardFsrsData.fromMap(doc.data() as Map<String, dynamic>);
      result[data.cardId] = data;
    }

    // Thẻ chưa có record → tạo mới in-memory (state: 'new')
    for (final id in cardIds) {
      result.putIfAbsent(
        id,
        () => FlashcardFsrsData.newCard(
          cardId: id,
          setId: setId,
          userId: userId,
        ),
      );
    }

    return result;
  }

  /// Tính lịch mới sau khi user rate, rồi lưu Firestore
  Future<FlashcardFsrsData> rateCard({
    required FlashcardFsrsData current,
    required FsrsRating rating,
  }) async {
    final updated = _schedule(current, rating);

    // Lưu lên Firestore
    await _userCards(current.userId)
        .doc('${current.setId}_${current.cardId}')
        .set(updated.toMap());

    return updated;
  }

  // ─── FSRS Algorithm ───────────────────────────────────────────────────────

  FlashcardFsrsData _schedule(FlashcardFsrsData card, FsrsRating rating) {
    final now = DateTime.now();
    final r = rating.value; // 1-4

    if (card.state == 'new') {
      return _scheduleNew(card, r, now);
    } else if (card.state == 'learning' || card.state == 'relearning') {
      return _scheduleLearning(card, r, now);
    } else {
      return _scheduleReview(card, r, now);
    }
  }

  /// Thẻ mới — lần đầu học
  FlashcardFsrsData _scheduleNew(
      FlashcardFsrsData card, int r, DateTime now) {
    double s = _initialStability(r);
    double d = _initialDifficulty(r);

    switch (r) {
      case 1: // Again
        return card.copyWith(
          stability: s,
          difficulty: d,
          reps: 1,
          lapses: card.lapses + 1,
          state: 'learning',
          due: now.add(const Duration(minutes: 1)),
          lastReview: now,
        );
      case 2: // Hard
        return card.copyWith(
          stability: s,
          difficulty: d,
          reps: 1,
          state: 'learning',
          due: now.add(const Duration(minutes: 5)),
          lastReview: now,
        );
      case 3: // Good
        return card.copyWith(
          stability: s,
          difficulty: d,
          reps: 1,
          state: 'learning',
          due: now.add(const Duration(minutes: 10)),
          lastReview: now,
        );
      default: // Easy (4)
        final interval = _nextInterval(s);
        return card.copyWith(
          stability: s,
          difficulty: d,
          reps: 1,
          state: 'review',
          due: now.add(Duration(days: max(interval, 4))),
          lastReview: now,
        );
    }
  }

  /// Thẻ đang trong giai đoạn học/relearning (interval ngắn)
  FlashcardFsrsData _scheduleLearning(
      FlashcardFsrsData card, int r, DateTime now) {
    if (r == 1) {
      // Again → quay lại learning
      return card.copyWith(
        lapses: card.lapses + 1,
        reps: card.reps + 1,
        state: 'learning',
        due: now.add(const Duration(minutes: 1)),
        lastReview: now,
      );
    }

    double s = _shortTermStability(card.stability, r);
    final interval = r >= 3
        ? _nextInterval(s)
        : (r == 2 ? 1 : 0); // Hard=1 day, Easy=interval

    return card.copyWith(
      stability: s,
      reps: card.reps + 1,
      state: interval >= 1 ? 'review' : 'learning',
      due: interval >= 1
          ? now.add(Duration(days: interval))
          : now.add(const Duration(minutes: 10)),
      lastReview: now,
    );
  }

  /// Thẻ đã qua giai đoạn review
  FlashcardFsrsData _scheduleReview(
      FlashcardFsrsData card, int r, DateTime now) {
    final elapsed = card.lastReview != null
        ? now.difference(card.lastReview!).inDays.toDouble()
        : 1.0;

    final retrievability = _forgettingCurve(elapsed, card.stability);
    double newS;
    double newD = _nextDifficulty(card.difficulty, r);

    if (r == 1) {
      // Again → relearning
      newS = _forgettingStability(card.stability);
      return card.copyWith(
        stability: newS,
        difficulty: newD,
        reps: card.reps + 1,
        lapses: card.lapses + 1,
        state: 'relearning',
        due: now.add(const Duration(minutes: 10)),
        lastReview: now,
      );
    }

    newS = _recallStability(card.stability, retrievability, newD, r);
    final interval = _nextInterval(newS);

    return card.copyWith(
      stability: newS,
      difficulty: newD,
      reps: card.reps + 1,
      state: 'review',
      due: now.add(Duration(days: max(interval, 1))),
      lastReview: now,
    );
  }

  // ─── FSRS Math Functions ──────────────────────────────────────────────────

  double _initialStability(int r) => max(_w[r - 1], 0.1);

  double _initialDifficulty(int r) {
    return max(1, min(10, _w[4] - exp(_w[5] * (r - 1)) + 1));
  }

  double _forgettingCurve(double t, double s) {
    return pow(1 + _factor * t / s, _decay).toDouble();
  }

  int _nextInterval(double s) {
    final interval = s * log(_requestRetention) / log(0.9);
    return max(1, interval.round());
  }

  double _nextDifficulty(double d, int r) {
    final delta = _w[6] * (3 - r + 1) * (1 - (r - 1) / 3);
    final raw = d - delta;
    // Mean-reversion towards D0 (rating=2 baseline)
    return max(1, min(10, _w[7] * _initialDifficulty(2) + (1 - _w[7]) * raw));
  }

  double _recallStability(double s, double r, double d, int rating) {
    final hardPenalty = rating == 2 ? _w[15] : 1.0;
    final easyBonus = rating == 4 ? _w[16] : 1.0;
    return s *
        (exp(_w[8]) *
            (11 - d) *
            pow(s, -_w[9]) *
            (exp((1 - r) * _w[10]) - 1) *
            hardPenalty *
            easyBonus +
            1);
  }

  double _forgettingStability(double s) {
    return max(_w[11] * pow(s, -_w[12]) * (exp((1 - 0) * _w[13]) - 1), 0.1);
  }

  double _shortTermStability(double s, int r) {
    return s * exp(_w[17] * (r - 3 + _w[18]));
  }
}