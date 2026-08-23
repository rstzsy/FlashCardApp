import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import '../widgets/collection_list.dart';
import '../widgets/header_section.dart';
import '../widgets/member_list.dart';

class GroupDashboard extends StatelessWidget {
  final GroupModel group;

  const GroupDashboard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(group: group),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                group.description,
                style: const TextStyle(height: 1.5),
              ),
            ),

            MemberList(group: group),

            const SizedBox(height: 20),

            CollectionList(group: group),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}