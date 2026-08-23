import 'package:flutter/material.dart';
import '../../../models/statisticModel.dart';
import '../controllers/statistic_controller.dart';
import '../widgets/hero_card.dart';
import '../widgets/memory_rate_card.dart';
import '../widgets/palette.dart';
import '../widgets/weekly_segment_card.dart';
import '../../../core/themes/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  final StatisticsController _controller = StatisticsController();

  StatisticsModel? statistics;
  bool isLoading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadStatistics();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final result = await _controller.getStatistics(context);
    if (!mounted) return;
    setState(() {
      statistics = result;
      isLoading = false;
    });
    _animCtrl.forward(from: 0);
    debugPrint('weeklyProgress: ${result?.weeklyProgress}');
    debugPrint('today: ${DateTime.now()}'); // date and time
    debugPrint('weekday: ${DateTime.now().weekday}');

    // cal first day of week
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    debugPrint('monday of this week: $monday');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
         backgroundColor: AppColors.mainColor,
        body: Center(child: CircularProgressIndicator(color: P.green)),
      );
    }

    final learnedWords = statistics?.learnedWords ?? 0;
    final memoryRate = statistics?.memoryRate ?? 0.0;
    final weekly = statistics?.weeklyProgress ?? <int>[];
    final isHappy = memoryRate >= 50;

    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Stats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: P.text,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: _loadStatistics,
          color: P.greenDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroCard(isHappy: isHappy, memoryRate: memoryRate),
                const SizedBox(height: 20),

                _sectionLabel('Overview'),
                const SizedBox(height: 12),
                MemoryRateCard(
                  learnedWords: learnedWords,
                  memoryRate: memoryRate,
                ),
                const SizedBox(height: 20),

                _sectionLabel('Weekly Progress'),
                const SizedBox(height: 12),
                WeeklySegmentCard(
                  values: weekly,
                  totalLearned: learnedWords,
                  today: DateTime.now().weekday, 
                ),
                const SizedBox(height: 24),

                ExportButton(
                  onPressed: () async => _controller.exportPdf(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: P.textSub,
      letterSpacing: 0.8,
    ),
  );
}

// export button
class ExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ExportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.download_rounded, size: 22, color: P.pinkDark),
        label: const Text(
          'Export Data',
          style: TextStyle(
            color: P.pinkDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: P.pink.withOpacity(0.30),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class Blob extends StatelessWidget {
  final double size;
  final Color color;
  const Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
