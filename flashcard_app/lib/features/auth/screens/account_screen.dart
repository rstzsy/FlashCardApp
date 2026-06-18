import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../widgets/account_header.dart';
import '../widgets/overview_section.dart';
import '../widgets/study_heatmap_section.dart';
import '../widgets/month_badge.dart';
import '../widgets/achievement_section.dart';
import '../widgets/harvested_plants_section.dart';
import '../widgets/saved_posts_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return _ProfileContent(data: data);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ProfileContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(data: data),

              const SizedBox(height: 10),
              const SavedPostsSection(),

              // const SizedBox(height: 40),
              const SizedBox(height: 10),

              OverviewSection(data: data),

              const SizedBox(height: 25),
              const StudyHeatmapSection(),

              const SizedBox(height: 25),
              const MonthlyBadgeSection(),

              const SizedBox(height: 25),
              AchievementSection(streak: data['streak'] ?? 0),

              const SizedBox(height: 40),
              const SizedBox(height: 25),
              const HarvestedPlantsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
