import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/flashcardModel.dart';
import '../models/flashcard_fsrs_data.dart';
import '../services/flashcard_study_service.dart';
import '../services/fsrs_service.dart';

class FlashcardStudyController {
  final FlashcardStudyService _service = FlashcardStudyService();
  final FsrsService _fsrs = FsrsService();

  /// Load flashcards + FSRS progress, sort theo priority
  Future<List<FlashcardModel>> getFlashcardsBySetId(String setId) async {
    try {
      final rawList = await _service.fetchFlashcardsBySetId(setId);

      final flashcards = rawList.map((data) {
        return FlashcardModel(
          id: data['id'] ?? '',
          day: 1,
          level: "Custom",
          imageUrl: data["imageUrl"] ?? data["ImageUrl"] ?? "",
          word: data["word"] ?? data["Word"] ?? "",
          meaning: data["meaning"] ?? data["Meaning"] ?? "",
          phonetic: data["phonetic"] ?? data["Phonetic"] ?? "",
          example: data["example"] ?? data["Example"] ?? "",
        );
      }).toList();

      // Load FSRS data nếu user đã đăng nhập
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || flashcards.isEmpty) return flashcards;

      final cardIds = flashcards.map((c) => c.id).where((id) => id.isNotEmpty).toList();
      final fsrsMap = await _fsrs.loadSetProgress(
        userId: uid,
        setId: setId,
        cardIds: cardIds,
      );

      // Gắn FSRS data vào từng thẻ
      final withFsrs = flashcards.map((card) {
        return card.copyWith(fsrsData: fsrsMap[card.id]);
      }).toList();

      // Sort theo FSRS priority:
      // 1. Thẻ new
      // 2. Thẻ overdue nhiều nhất
      // 3. Thẻ chưa đến hạn
      withFsrs.sort((a, b) {
        final pa = a.fsrsData?.priority ?? -1;
        final pb = b.fsrsData?.priority ?? -1;
        return pa.compareTo(pb); // ascending: priority nhỏ hơn = lên đầu
      });

      return withFsrs;
    } catch (e) {
      print("Controller Error: $e");
      return [];
    }
  }

  /// Rate một thẻ và trả về FSRS data đã cập nhật
  Future<FlashcardFsrsData?> rateCard({
    required FlashcardModel card,
    required FsrsRating rating,
    required String setId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final current = card.fsrsData ??
        FlashcardFsrsData.newCard(
          cardId: card.id,
          setId: setId,
          userId: uid,
        );

    return await _fsrs.rateCard(current: current, rating: rating);
  }
}