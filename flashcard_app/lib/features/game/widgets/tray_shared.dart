// lib/features/game/widgets/tray_shared.dart
import 'package:flutter/material.dart';

// ─── Nút + trên ô đất trống ──────────────────────────────────────────────────

// tray_shared.dart

class PlotPlusDot extends StatelessWidget {
  const PlotPlusDot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // ← ẩn hoàn toàn
}

// ─── Highlight vòng tròn khi drag thả vào ô ─────────────────────────────────

class PlotDropHighlight extends StatelessWidget {
  const PlotDropHighlight({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF64B5F6).withOpacity(0.18),
              border: Border.all(
                color: const Color(0xFF64B5F6).withOpacity(0.60),
                width: 2.5,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7E57C2).withOpacity(0.20),
            ),
          ),
          Image.asset(
            'assets/game/plant.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Text('🌱', style: TextStyle(fontSize: 26)),
          ),
        ],
      );
}

// ─── Họa tiết hoa văn nền tray ───────────────────────────────────────────────

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