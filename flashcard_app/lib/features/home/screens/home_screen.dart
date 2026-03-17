import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/feature_card.dart';

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

              // ── Statistic — horizontal scroll ──
              SizedBox(
                height: 148,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _StatScrollCard(
                      title: "Revisions\nthis week",
                      value: "32",
                      imagePath: "assets/component/book.png",
                      bgColor: Color(0xFFBBDEF5),
                    ),
                    SizedBox(width: 12),
                    _StatScrollCard(
                      title: "Total\nXP earned",
                      value: "850 XP",
                      imagePath: "assets/component/star.png",
                      bgColor: Color(0xFFBBDEF5),
                    ),
                    SizedBox(width: 12),
                    _StatScrollCard(
                      title: "Your tree\nstatus",
                      value: "Need Water",
                      imagePath: "assets/component/plant.png",
                      bgColor: Color(0xFFBBDEF5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ── Performance ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _PerformanceSection(
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
                    const Text(
                      "Recent study",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    _RecentStudyCard(
                      title: "Unit 1 - Greetings",
                      totalCards: 30,
                      learnedCards: 10,
                      imagePath: "assets/component/book.png",
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _RecentStudyCard(
                      title: "Unit 2 - Family",
                      totalCards: 30,
                      learnedCards: 18,
                      imagePath: "assets/component/book.png",
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ── Collections ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Collections",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _CollectionCard(title: "Prepare!", setsCount: 2, color: Color(0xFF64B5F6)),
                          SizedBox(width: 14),
                          _CollectionCard(title: "English", setsCount: 6, color: Color(0xFF1E88E5)),
                          SizedBox(width: 14),
                          _CollectionCard(title: "TOEIC", setsCount: 4, color: Color(0xFF42A5F5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ── AI Suggestion ──
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 20),
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: AppColors.highlightColor,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Row(
              //     children: const [
              //       Icon(Icons.smart_toy, size: 40, color: Colors.white),
              //       SizedBox(width: 15),
              //       Expanded(
              //         child: Text(
              //           "AI Suggestion:\nReview animal vocabulary today!",
              //           style: TextStyle(fontSize: 16, color: Colors.white),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

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

// ─── Stat Scroll Card ─────────────────────────────────────────────────────────

class _StatScrollCard extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final Color bgColor;

  const _StatScrollCard({
    required this.title,
    required this.value,
    required this.imagePath,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 148,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 14,
            left: 14,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 2,
            right: -2,
            child: Transform.rotate(
              angle: -0.18,
              child: Image.asset(
                imagePath,
                width: 74,
                height: 74,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 74,
                  height: 74,
                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.black26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent Study Card ────────────────────────────────────────────────────────

class _RecentStudyCard extends StatelessWidget {
  final String title;
  final int totalCards;
  final int learnedCards;
  final String imagePath;
  final VoidCallback onTap;

  const _RecentStudyCard({
    required this.title,
    required this.totalCards,
    required this.learnedCards,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = learnedCards / totalCards;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    size: 36,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text("$totalCards flashcards",
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text("$learnedCards/$totalCards cards learned",
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFBBDEFB), 
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1E88E5), 
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Collection Card ──────────────────────────────────────────────────────────

class _CollectionCard extends StatelessWidget {
  final String title;
  final int setsCount;
  final Color color;

  const _CollectionCard(
      {required this.title, required this.setsCount, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 130,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 52,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text("$setsCount sets of flashcard",
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Performance Section ──────────────────────────────────────────────────────

class _PerformanceSection extends StatefulWidget {
  final int streakDays;
  final List<String> completedDays;

  const _PerformanceSection(
      {required this.streakDays, required this.completedDays});

  @override
  State<_PerformanceSection> createState() => _PerformanceSectionState();
}

class _PerformanceSectionState extends State<_PerformanceSection>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late final List<_Particle> _particles =
      List.generate(40, (_) => _Particle(Random()));

  static const List<String> _weekDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performance",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            color: const Color(0xFFBDE8F5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (_, __) => CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _particleController.value,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: child,
                        ),
                        child: SizedBox(
                          height: 110,
                          child: Image.asset(
                            'assets/character/happy.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.emoji_emotions,
                              size: 80,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "You're on a ",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5A623),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${widget.streakDays}",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                          ),
                          const Text(
                            " day streak!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _weekDays
                            .map((day) => _DayDot(
                                day: day,
                                completed: widget.completedDays.contains(day)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Day dot ──────────────────────────────────────────────────────────────────

class _DayDot extends StatelessWidget {
  final String day;
  final bool completed;
  const _DayDot({required this.day, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? const Color(0xFF1E88E5) 
                : Colors.white.withOpacity(0.5),
            border: completed
                ? null
                : Border.all(color: Colors.white60, width: 1.5),
          ),
          child: Icon(Icons.check,
              size: 16,
              color: completed ? Colors.white : Colors.white38),
        ),
        const SizedBox(height: 5),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: completed ? Colors.black87 : Colors.black45,
          ),
        ),
      ],
    );
  }
}

// ─── Particle model ───────────────────────────────────────────────────────────

class _Particle {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double gravity;
  final double wobbleAmp;
  final double wobbleFreq;
  final double size;
  final double initAngle;
  final double rotSpeed;
  final Color color;
  final int shape;
  final double delay;

  _Particle(Random rng)
      : startX = rng.nextBool()
            ? 0.05 + rng.nextDouble() * 0.15
            : 0.80 + rng.nextDouble() * 0.15,
        startY = 0.55 + rng.nextDouble() * 0.1,
        vx = (rng.nextDouble() - 0.5) * 340,
        vy = -(180 + rng.nextDouble() * 220),
        gravity = 260 + rng.nextDouble() * 120,
        wobbleAmp = 10 + rng.nextDouble() * 18,
        wobbleFreq = 2.5 + rng.nextDouble() * 2.5,
        size = 5 + rng.nextDouble() * 7,
        initAngle = rng.nextDouble() * pi * 2,
        rotSpeed = (rng.nextDouble() - 0.5) * 10,
        color = const [
          Color(0xFFFF6B6B),
          Color(0xFFFFD93D),
          Color(0xFF6BCB77),
          Color(0xFF4D96FF),
          Color(0xFFFF922B),
          Color(0xFFA29BFE),
          Color(0xFFFD79A8),
          Color(0xFF00CEC9),
          Color(0xFFE17055),
        ][rng.nextInt(9)],
        shape = rng.nextInt(3),
        delay = rng.nextDouble() * 0.4;
}

// ─── Confetti painter ────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final raw = progress - p.delay;
      if (raw <= 0) continue;
      final t = raw / (1.0 - p.delay);
      final dt = t * 1.8;

      final px = p.startX * size.width +
          p.vx * dt +
          p.wobbleAmp * sin(t * pi * p.wobbleFreq + p.initAngle);
      final py = p.startY * size.height +
          p.vy * dt +
          0.5 * p.gravity * dt * dt;

      if (px < -20 || px > size.width + 20 || py > size.height + 20) continue;

      final opacity = (t < 0.7 ? 1.0 : (1.0 - t) / 0.3).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final rot = p.initAngle + t * p.rotSpeed * pi * 2;
      final paint = Paint()..color = p.color.withOpacity(opacity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      switch (p.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 1.4,
                height: p.size * 0.6),
            paint,
          );
          break;
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          break;
        default:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 0.28,
                height: p.size * 1.6),
            paint,
          );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}