import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String avatar;

  const MemberCard(this.name, this.avatar, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(avatar),
            backgroundColor: Colors.white
          ),
          const SizedBox(height: 6),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: const Color.fromARGB(225, 19, 64, 122))),
        ],
      ),
    );
  }
}
