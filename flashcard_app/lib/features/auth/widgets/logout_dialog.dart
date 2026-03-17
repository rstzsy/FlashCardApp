import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../routes/app_routes.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: AppColors.mainColor.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => LogoutDialog(onConfirm: onConfirm),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Image.asset(
              'assets/character/worry.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              'Leaving so soon?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.highlightColor,
              ),
            ),

            const SizedBox(height: 8),

            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 132, 211, 247),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Sign out
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Đóng dialog trước
                      Navigator.pop(context);
                      // Gọi callback (xử lý logout: clear token, v.v.)
                      onConfirm();
                      // Chuyển về IntroHomeScreen, xóa toàn bộ stack
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.introHomeScreen,
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFCEBEB),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color(0xFFF7C1C1),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE24B4A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}