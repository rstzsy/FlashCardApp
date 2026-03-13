import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../widgets/account_header.dart';
import '../widgets/overview_section.dart';
import '../widgets/month_badge.dart';
import '../widgets/achievement_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              ProfileHeader(),
              SizedBox(height: 10),

              OverviewSection(),

              SizedBox(height: 25),

              MonthlyBadgeSection(),

              SizedBox(height: 25),

              AchievementSection(),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}