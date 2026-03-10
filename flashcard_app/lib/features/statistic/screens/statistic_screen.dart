import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/chibi_stat_card.dart';
import '../widgets/weekly_process_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  final int learnedWords = 120;
  final double memoryRate = 70;

  @override
  Widget build(BuildContext context) {
    final isHappy = memoryRate >= 50;
    final sprite = isHappy
        ? "assets/character/happy.png"
        : "assets/character/worry.png";

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Stats",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            // card pr
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isHappy
                      ? [Colors.white, const Color(0xFFFFD6E7)]
                      : [Colors.white, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isHappy
                            ? const Color(0xFFFFD6E7)
                            : AppColors.mainColor)
                        .withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -10,
                    right: 20,
                    child: _Blob(size: 70, color: Colors.white.withOpacity(0.25)),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _Blob(size: 45, color: Colors.white.withOpacity(0.18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // animation switch image
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeOutBack,
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Image.asset(
                            sprite,
                            key: ValueKey(sprite),
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.red,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            isHappy
                                ? "Yay! You're amazing!"
                                : "Let's study more today!",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D2D2D),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // stat card 
            Row(
              children: [
                Expanded(
                  child: ChibiStatCard(
                    iconPath: "assets/component/book.png",
                    value: "$learnedWords",
                    label: "Words Learned",
                    color: const Color.fromARGB(255, 52, 91, 109),
                    bgGradient: const [Colors.white, AppColors.primary],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChibiStatCard(
                    iconPath: "assets/component/brain.png",
                    value: "${memoryRate.toInt()}%",
                    label: "Memory Rate",
                    color: isHappy
                        ? const Color(0xFF3EC97C)
                        : const Color(0xFFFF6B6B),
                    bgGradient: isHappy
                        ? const [Colors.white, Color(0xFFC8F5DC)]
                        : const [Colors.white, Color(0xFFFFEEEE)],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // bar chart
            const WeeklyProgressChart(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}