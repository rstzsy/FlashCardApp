import 'package:flutter/material.dart';
import 'dart:math';

class PerformanceSection extends StatefulWidget {
  final int streakDays;
  final List<String> completedDays;

  const PerformanceSection(
      {super.key, required this.streakDays, required this.completedDays});

  @override
  State<PerformanceSection> createState() => PerformanceSectionState();
}

class PerformanceSectionState extends State<PerformanceSection>
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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

// ─── Particle ────────────────────────────────────────────────────────────────

class _Particle {
  final double startX, startY, vx, vy, gravity;
  final double wobbleAmp, wobbleFreq, size, initAngle, rotSpeed, delay;
  final Color color;
  final int shape;

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
          Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
          Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFA29BFE),
          Color(0xFFFD79A8), Color(0xFF00CEC9), Color(0xFFE17055),
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
      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.initAngle + t * p.rotSpeed * pi * 2);
      switch (p.shape) {
        case 0:
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size * 1.4, height: p.size * 0.6), paint);
          break;
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          break;
        default:
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size * 0.28, height: p.size * 1.6), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
