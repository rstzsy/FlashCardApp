import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class AddMemberButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onPressed;

  static const _primary = AppColors.primary;

  const AddMemberButton({
    super.key,
    required this.selectedCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: AnimatedOpacity(
          opacity: selectedCount == 0 ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: selectedCount == 0 ? 0 : 4,
                shadowColor: _primary.withOpacity(0.4),
              ),
              child: Text(
                selectedCount == 0
                    ? "Add Member"
                    : "Add $selectedCount members",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}