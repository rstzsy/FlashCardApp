import 'package:flutter/material.dart';
import '../../../models/flashcard_form_model.dart';
import '../services/flashcard_update_service.dart';

class FlashcardUpdateController {
  final service = FlashcardUpdateService();

  String? setId;
  TextEditingController? titleCtrl;
  TextEditingController? subtitleCtrl;
  Function(List<FlashcardFormModel>)? onCardsLoaded;
  Function(IconData, Color)? onMetaLoaded;

  //load data
  Future<void> loadData({
    required String setId,
    required TextEditingController titleCtrl,
    required TextEditingController subtitleCtrl,
    required Function(List<FlashcardFormModel>) onCardsLoaded,
    required Function(IconData, Color) onMetaLoaded,
  }) async {
    this.setId = setId;
    this.titleCtrl = titleCtrl;
    this.subtitleCtrl = subtitleCtrl;
    this.onCardsLoaded = onCardsLoaded;
    this.onMetaLoaded = onMetaLoaded;

    try {
      //get set
      final set = await service.getFlashcardSet(setId);

      titleCtrl.text = set['Title'] ?? "";
      subtitleCtrl.text = set['Subtitle'] ?? "";

      final icon = IconData(
        int.parse(set['Icon'].toString()),
        fontFamily: 'MaterialIcons',
      );
      final color = Color(
        int.parse(set['ColorHex'].toString().replaceFirst('#', '0xff')),
      );

      onMetaLoaded(icon, color);

      // get cards
      final cardsData = await service.getFlashcards(setId);

      final cards =
          cardsData.map((c) {
            return FlashcardFormModel.fromMap(c);
          }).toList();

      onCardsLoaded(cards);
    } catch (e) {
      debugPrint("Load Update Data Error: $e");
    }
  }

  Future<void> reload() async {
    if (setId == null || titleCtrl == null || subtitleCtrl == null || onCardsLoaded == null || onMetaLoaded == null) return;
    await loadData(
      setId: setId!,
      titleCtrl: titleCtrl!,
      subtitleCtrl: subtitleCtrl!,
      onCardsLoaded: onCardsLoaded!,
      onMetaLoaded: onMetaLoaded!,
    );
  }

  //update
  Future<void> update({
    required String setId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<FlashcardFormModel> cards,
  }) async {
    try {
      // update set
      await service.updateFlashcardSet(
        setId: setId,
        title: title,
        subtitle: subtitle,
        icon: icon.codePoint.toString(),
        colorHex: '#${color.value.toRadixString(16).substring(2)}',
      );

      // update cards
      await service.updateFlashcards(setId: setId, cards: cards);

      // Reload data to update UI immediately
      await reload();

      debugPrint("Update success");
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }
}
