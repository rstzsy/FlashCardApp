import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

import '../../../core/widgets/app_popup_cancel.dart';
import '../controllers/flashcard_delete_controller.dart';
import '../screens/flashcard_update_screen.dart';

class FlashcardStudyHeader extends StatelessWidget {
  final String setId;
  final VoidCallback? onReload; // callback
  final deleteController = FlashcardDeleteController();

  FlashcardStudyHeader({super.key, required this.setId, this.onReload});

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

          const Spacer(),

          const Text(
            "Study Flashcards",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.highlightColor,
            ),
          ),

          const Spacer(),

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

              // reload after update
              if (result == true && onReload != null) {
                onReload!();
              }
            },
          ),

          // delete
          _circleButton(
            icon: Icons.delete,
            onPressed: () {
              AppPopupCancel.show(
                context: context,
                title: "Confirm Delete",
                message: "Are you sure you want to delete this set?",
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                buttonText: "Delete",
                showCancelButton: true,
                cancelButtonText: "Cancel",
                onPressed: () async {
                  final success = await deleteController.deleteSet(setId);
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pop(context, "deleted");
                  }
                },
                onCancelPressed: () => Navigator.pop(context),
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
