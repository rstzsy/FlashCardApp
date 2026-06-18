import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../widgets/account_header.dart';
import '../widgets/overview_section.dart';
import '../widgets/month_badge.dart';
import '../widgets/achievement_section.dart';

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

              OverviewSection(data: data),

              const SizedBox(height: 25),
              const MonthlyBadgeSection(),

              const SizedBox(height: 25),
              AchievementSection(streak: data['streak'] ?? 0),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
