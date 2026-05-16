import 'dart:math';
import 'package:flutter/material.dart';


class PlotPlusDot extends StatelessWidget {
  const PlotPlusDot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}


class PlotDropHighlight extends StatefulWidget {
  const PlotDropHighlight({super.key});

  @override
  State<PlotDropHighlight> createState() => _PlotDropHighlightState();
}

class _PlotDropHighlightState extends State<PlotDropHighlight>
    with TickerProviderStateMixin {
  late final AnimationController _rippleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  late final Animation<double> _rippleScale = Tween(begin: 0.86, end: 1.10)
      .animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeInOut));

  late final AnimationController _starCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  static const Color _ringColor = Color(0xFFFFFFFF);
  static const Color _fillColor = Color(0x28FFFFFF);
  static const Color _starColor = Color(0xFFFFD966);
  static const Color _starGlow  = Color(0xFFFFAA00);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: _rippleScale,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fillColor,
                border: Border.all(
                  color: _ringColor.withOpacity(0.85),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _StarOrbitPainter(
                  progress: _starCtrl.value,
                  starColor: _starColor,
                  glowColor: _starGlow,
                ),
              ),
            ),
          ),

          Image.asset(
            'assets/game/tree/stage_0.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              '🌱',
              style: TextStyle(fontSize: 26),
            ),
          ),
        ],
      ),
    );
  }
}


class _StarOrbitPainter extends CustomPainter {
  final double progress;
  final Color starColor;
  final Color glowColor;

  const _StarOrbitPainter({
    required this.progress,
    required this.starColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitR = size.width / 2 - 5;

    const count = 6;
    for (int i = 0; i < count; i++) {
      final angle = (i / count + progress) * 2 * pi;
      final pos = Offset(
        center.dx + orbitR * cos(angle),
        center.dy + orbitR * sin(angle),
      );

      final pulse = 0.65 + 0.35 * sin((progress * 2 * pi * 1.3) + i * 1.05);
      final starR = 4.8 * pulse;

      final raw = (i / count + progress * 0.7) % 1.0;
      final opacity = (0.45 + 0.55 * raw).clamp(0.3, 1.0);

      final glowPaint = Paint()
        ..color = glowColor.withOpacity(opacity * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, starR * 1.5, glowPaint);

      final paint = Paint()
        ..color = starColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      _drawDiamond(canvas, pos, starR, paint);
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path()
      ..moveTo(center.dx,            center.dy - r)
      ..lineTo(center.dx + r * 0.45, center.dy)
      ..lineTo(center.dx,            center.dy + r)
      ..lineTo(center.dx - r * 0.45, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarOrbitPainter old) => old.progress != progress;
}


class FlowerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const spacing = 44.0;
    const r = 7.0;
    final offsets = [
      const Offset(r * 0.7, 0),
      const Offset(0, r * 0.7),
      const Offset(-r * 0.7, 0),
      const Offset(0, -r * 0.7),
    ];

    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final c = Offset(x, y);
        for (final o in offsets) {
          canvas.drawCircle(c + o, r * 0.55, paint);
        }
        canvas.drawCircle(c, r * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}