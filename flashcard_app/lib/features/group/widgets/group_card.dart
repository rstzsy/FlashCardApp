import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/groupModel.dart';
import '../screens/group_dashboard_screen.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary,
        
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // group name
          CircleAvatar(radius: 28, backgroundImage: AssetImage(group.image)),

          const SizedBox(width: 16),

          // group info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${group.memberCount} members",
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 12, 43, 83)),
                ),
              ],
            ),
          ),

          // arrow
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupDashboard()),
              );
            },
          ),
        ],
      ),
    );
  }
}
