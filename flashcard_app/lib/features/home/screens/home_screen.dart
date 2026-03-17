import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/feature_item.dart';
import '../widgets/recent_study_card.dart';
import '../widgets/collection_card.dart';
import '../widgets/performance_section.dart';
import '../widgets/promo_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Good Morning", style: TextStyle(color: AppColors.highlightColor)),
                            SizedBox(height: 5),
                            Text(
                              "Learner",
                              style: TextStyle(
                                fontSize: 28,
                                color: AppColors.highlightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/character/amaz.png'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: AppColors.highlightColor),
                          hintText: "Search here...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Statistic ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FeatureItem(
                        title: "Revisions\nThis Week",
                        description: "Lessons reviewed this week.",
                        imagePath: "assets/component/flash_card_home.png",
                      ),
                    ),
                    const DashedSeparator(),
                    Expanded(
                      child: FeatureItem(
                        title: "Total\nXP Earned",
                        description: "Watch your experience grow.",
                        imagePath: "assets/component/fire_home.png",
                      ),
                    ),
                    const DashedSeparator(),
                    Expanded(
                      child: FeatureItem(
                        title: "Your Tree\nStatus",
                        description: "Stay consistent to grow.",
                        imagePath: "assets/component/tree_home.png",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Promo Banner ──
              const PromoBanner(),

              const SizedBox(height: 25),

              // ── Performance ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: PerformanceSection(
                  streakDays: 5,
                  completedDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                ),
              ),

              const SizedBox(height: 25),

              // ── Recent Study ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Study",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          "See All",
                          style: TextStyle(fontSize: 13, color: AppColors.highlightColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RecentStudyCard(
                      title: "Unit 1 - Greetings",
                      description: "Start with basic greetings and everyday expressions.",
                      totalCards: 30,
                      learnedCards: 10,
                      imagePath: "assets/component/book_watermark.png",
                      bgColor: const Color(0xFFDCEDC8),
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    RecentStudyCard(
                      title: "Unit 2 - Family",
                      description: "Learn vocabulary about family members and relationships.",
                      totalCards: 30,
                      learnedCards: 18,
                      imagePath: "assets/component/book_watermark.png",
                      bgColor: const Color(0xFFB2EBF2),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ── Collections ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Collections",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 145,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20, right: 8),
                      clipBehavior: Clip.none,
                      children: const [
                        CollectionCard(
                          title: "Prepare!",
                          subtitle: "Exam preparation",
                          setsCount: 2,
                          color: Color(0xFF42A5F5),
                        ),
                        SizedBox(width: 14),
                        CollectionCard(
                          title: "English",
                          subtitle: "General vocabulary",
                          setsCount: 6,
                          color: Color(0xFF1E88E5),
                        ),
                        SizedBox(width: 14),
                        CollectionCard(
                          title: "TOEIC",
                          subtitle: "Business English",
                          setsCount: 4,
                          color: Color(0xFF1565C0),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}