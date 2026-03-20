import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/groupModel.dart';
import '../widgets/group_card.dart';
import 'add_group_screen.dart';

class GroupListPage extends StatelessWidget {
  GroupListPage({super.key});

  final List<GroupModel> groups = [
    GroupModel(
      name: "English Learners",
      image: "assets/component/book.png",
      memberCount: 12,
    ),
    GroupModel(
      name: "IELTS Fighter",
      image: "assets/component/book.png",
      memberCount: 8,
    ),
    GroupModel(
      name: "Ket, Pet",
      image: "assets/component/book.png",
      memberCount: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,

      // header
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
                MaterialPageRoute(builder: (context) => const AddGroupPage()),
              );
            },
          ),
        ],
      ),

      // body
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GroupCard(group: groups[index]);
        },
      ),
    );
  }
}
