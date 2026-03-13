import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/feature_card.dart';
import '../widgets/stat_card.dart';

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
              // header
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
                            Text(
                              "Good Morning",
                              style: TextStyle(color: Colors.white),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Mai Thanh",
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
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
                            backgroundImage: AssetImage(
                              'assets/character/amaz.png',
                            ),
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
                          icon: Icon(
                            Icons.search,
                            color: AppColors.highlightColor,
                          ),
                          hintText: "Search here...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // statistic
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    StatCard(
                      title: "Revisions",
                      value: "32",
                      imagePath: "assets/component/book.png",
                    ),

                    StatCard(
                      title: "Streak",
                      value: "12 days",
                      imagePath: "assets/component/fire.png",
                    ),

                    StatCard(
                      title: "XP",
                      value: "850",
                      imagePath: "assets/component/star.png",
                    ),

                    StatCard(
                      title: "Tree",
                      value: "Need Water",
                      imagePath: "assets/component/plant.png",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // recommend AI
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.highlightColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.smart_toy, size: 40, color: Colors.white),

                    SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "AI Suggestion:\nReview animal vocabulary today!",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 140,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  children: [
                    FeatureCard(
                      image: "assets/character/confident.png",
                      title: "Create flashcard with AI",
                      buttonText: "Start",
                      onPressed: () {},
                    ),

                    FeatureCard(
                      image: "assets/character/game.png",
                      title: "Play game to review vocab now!",
                      buttonText: "Review",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}