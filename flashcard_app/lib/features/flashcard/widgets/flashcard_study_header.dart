import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

import 'delete_flashcard_dialog.dart'; 
import '../controllers/flashcard_delete_controller.dart';
import '../screens/flashcard_update_screen.dart';

class FlashcardStudyHeader extends StatelessWidget {
  final String setId;
  final String? setName;
  final VoidCallback? onReload;
  final deleteController = FlashcardDeleteController();

  FlashcardStudyHeader({
    super.key,
    required this.setId,
    this.setName,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              setName ?? "Study Flashcards",
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
              ),
            ),
          ),

          // edit
          _circleButton(
            icon: Icons.edit,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateFlashcardScreen(setId: setId),
                ),
              );

              if (result == true && onReload != null) {
                onReload!();
              }
            },
          ),

          // delete
          _circleButton(
            icon: Icons.delete,
            onPressed: () {
              DeleteFlashcardDialog.show(
                context,
                onConfirm: () async {
                  final success = await deleteController.deleteSet(setId);
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pop(context, "deleted");
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      margin: const EdgeInsets.all(6),
      child: IconButton(
        icon: Icon(icon, color: AppColors.highlightColor),
        onPressed: onPressed,
      ),
    );
  }
}