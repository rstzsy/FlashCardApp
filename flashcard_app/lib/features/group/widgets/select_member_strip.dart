import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../models/userModel.dart';

class SelectedMemberStrip extends StatelessWidget {
  final List<UserModel> selectedUsers;
  final ValueChanged<UserModel> onRemove;

  const SelectedMemberStrip({
    super.key,
    required this.selectedUsers,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedUsers.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 96,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: selectedUsers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final user = selectedUsers[index];
          return GestureDetector(
            onTap: () => onRemove(user),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage(user.avatar),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.highlightColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 56,
                  child: Text(
                    user.name.split(' ').first,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color.fromARGB(248, 12, 43, 83)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}