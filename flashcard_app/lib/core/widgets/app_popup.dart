import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class AppPopup {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = Colors.green,
    String buttonText = "OK",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: AppColors.mainColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  icon,
                  size: 60,
                  color: iconColor,
                ),

                const SizedBox(height: 15),

                // title popup
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.highlightColor
                  ),
                ),

                const SizedBox(height: 10),

                // message popup
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.highlightColor,
                  ),
                ),

                const SizedBox(height: 25),

                // butotn popup
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}