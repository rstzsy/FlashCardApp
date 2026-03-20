import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/userModel.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  static const _primary = AppColors.primary;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(user.avatar),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: user.isSelected ? _primary : Colors.transparent,
                border: Border.all(
                  color: user.isSelected ? _primary : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: user.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}