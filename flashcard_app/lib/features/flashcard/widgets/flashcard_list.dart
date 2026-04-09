import 'package:flutter/material.dart';
import '../../../models/flashcard_form_model.dart';
import 'flashcard_item.dart';

class FlashcardList extends StatelessWidget {
  final List<FlashcardFormModel> cards;
  final Function(int) onDelete;
  final Function(int) onPickImage;

  const FlashcardList({
    super.key,
    required this.cards,
    required this.onDelete,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return FlashcardItem(
          index: index + 1,
          card: cards[index],
          onPickImage: () => onPickImage(index),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}