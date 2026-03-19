import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/account_screen.dart';
import '../features/group/screens/group_list_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/statistic/screens/statistic_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const Placeholder(),
    const StatisticsScreen(),
    const Placeholder(),
    const ProfilePage(),
    GroupListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 10),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),

            // background color pagination
            color: AppColors.primary,

            // shadow
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
              navItem(Icons.person_outline, 4),
              navItem(Icons.group, 5),
            ],
          ),
        ),
      ),
    );
  }
  
  // set state for page navigate
  Widget navItem(IconData icon, int index) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? Colors.white : const Color.fromARGB(255, 84, 144, 172),
        ),
      ),
    );
  }
}