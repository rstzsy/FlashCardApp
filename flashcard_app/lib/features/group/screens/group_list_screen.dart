import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../models/groupModel.dart';
import '../widgets/group_card.dart';
import 'add_group_screen.dart';
import 'group_dashboard_screen.dart';

class GroupListPage extends StatelessWidget {
  GroupListPage({super.key});

  final List<GroupModel> groups = [
    GroupModel(
      name: "English Learners",
      image: "assets/component/book_watermark.png",
      memberCount: 12,
      description: "Learn English together every day.",
      bgColor: const Color(0xFFDFF2EB),
    ),
    GroupModel(
      name: "IELTS Fighter",
      image: "assets/component/book_watermark.png",
      memberCount: 8,
      description: "Prepare for IELTS and target 7.0+.",
      bgColor: const Color(0xFFFFF3DC),
    ),
    GroupModel(
      name: "KET & PET",
      image: "assets/component/book_watermark.png",
      memberCount: 15,
      description: "Practice for Cambridge KET and PET exams.",
      bgColor: const Color(0xFFEDE7FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Group List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.highlightColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.highlightColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddGroupPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GroupCard(
            group: groups[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GroupDashboard(),
                ),
              );
            },
          ),
        );
      },
    ),
    );
  }
}