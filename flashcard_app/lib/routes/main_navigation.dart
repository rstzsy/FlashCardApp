import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/account_screen.dart';
import '../features/flashcard/screens/flashcard_manager_screen.dart';
import '../features/group/screens/group_list_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/statistic/screens/statistic_screen.dart';
import '../features/game/screens/intro_game_screen.dart';
import '../features/blog/screens/blog_screen.dart';

final GlobalKey<_MainNavigationState> mainNavKey =
    GlobalKey<_MainNavigationState>();
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  static const int _gameTabIndex = 3;

  void switchToTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(), // 0
      FlashcardManagerScreen(), // 1
      const StatisticsScreen(), // 2
      IntroGameScreen(
        // 3
        onBack: () => setState(() => currentIndex = 0),
      ),
      const ProfilePage(), // 4
      GroupListPage(), // 5
      const BlogScreen(), // 6 ← thêm
    ];

    final bool isGameScreen = currentIndex == _gameTabIndex;

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar:
          isGameScreen
              ? null
              : Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 20,
                  top: 10,
                ),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      navItem(Icons.home_outlined, 0),
                      navItem(Icons.style, 1),
                      navItem(Icons.bar_chart_rounded, 2),
                      navItem(Icons.sports_esports, 3),
                      navItem(Icons.group, 5),
                      navItem(Icons.article_outlined, 6), // ← blog
                      
                    ],
                  ),
                ),
              ),
    );
  }

  Widget navItem(IconData icon, int index) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 26,
          color:
              isActive ? Colors.white : const Color.fromARGB(255, 84, 144, 172),
        ),
      ),
    );
  }
}
