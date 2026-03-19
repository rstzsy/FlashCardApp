import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/collection_list.dart';
import '../widgets/header_section.dart';
import '../widgets/member_list.dart';

class GroupDashboard extends StatelessWidget {
  const GroupDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      //bottomNavigationBar: const BottomBar(),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(),

            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "This is a group for learning vocabulary, sharing knowledge, and creating your own flashcard sets.",
                style: TextStyle(height: 1.5),
              ),
            ),

            MemberList(),

            SizedBox(height: 20),

            CollectionList(),

            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}