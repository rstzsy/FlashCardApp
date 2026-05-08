// lib/features/game/widgets/seed_card.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';

// ─── Seed card (flower / plant) ──────────────────────────────────────────────

class SeedCard extends StatelessWidget {
  final SeedItem seed;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const SeedCard({
    super.key,
    required this.seed,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.38 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B4A20)
              : const Color(0xFF52351A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8C87A)
                : const Color(0xFF8A6030),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8C87A).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(
                          seed.imagePath ?? 'assets/game/tulip.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/game/tulip.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        seed.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF8BC34A)
                              : const Color(0xFF7CB342),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8C87A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${seed.totalCards}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5A3A10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            if (isDisabled)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2E0A).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF8A6030), width: 1),
                  ),
                  child: const Text(
                    'Planted',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB89050),
                    ),
                  ),
                ),
              ),

            if (isSelected && !isDisabled)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8BC34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Ghost widget while dragging a seed ──────────────────────────────────────

class SeedDragFeedback extends StatefulWidget {
  final SeedItem seed;
  const SeedDragFeedback({super.key, required this.seed});

  @override
  State<SeedDragFeedback> createState() => _SeedDragFeedbackState();
}

class _SeedDragFeedbackState extends State<SeedDragFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kim cương trắng vàng rải nhiều lớp — vẽ trước ảnh hoa
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _ScatteredDiamondPainter(progress: _ctrl.value),
              ),
            ),
          ),

          // Vệt trắng to đậm phía sau hoa
          Container(
            width: 130,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.72),
                  Colors.white.withOpacity(0.28),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Ảnh hoa — nằm trên tất cả
          Image.asset(
            widget.seed.imagePath ?? 'assets/game/tulip.png',
            width: 82,
            height: 82,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/game/tulip.png',
              width: 82,
              height: 82,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Painter: kim cương trắng vàng rải 3 lớp xung quanh + đằng sau hoa ───────

class _ScatteredDiamondPainter extends CustomPainter {
  final double progress;

  static const Color _starNear  = Color(0xFFFFFBE6); // trắng hơi vàng
  static const Color _starMid   = Color(0xFFFFEDAA); // vàng nhạt
  static const Color _glowColor = Color(0xFFFFD966); // vàng glow

  static final List<_DiamondSeed> _seeds = _buildSeeds();

  static List<_DiamondSeed> _buildSeeds() {
    final rng = Random(42);
    final list = <_DiamondSeed>[];

    // Lớp 0: gần trung tâm — đằng sau cây, nhỏ mờ
    for (int i = 0; i < 5; i++) {
      list.add(_DiamondSeed(
        angle: rng.nextDouble() * 2 * pi,
        dist: 10.0 + rng.nextDouble() * 24.0,
        size: 1.8 + rng.nextDouble() * 1.8,
        speedMul: 0.5 + rng.nextDouble() * 0.5,
        phaseOff: rng.nextDouble(),
        layer: 0,
      ));
    }

    // Lớp 1: giữa
    for (int i = 0; i < 6; i++) {
      list.add(_DiamondSeed(
        angle: rng.nextDouble() * 2 * pi,
        dist: 36.0 + rng.nextDouble() * 18.0,
        size: 2.4 + rng.nextDouble() * 2.4,
        speedMul: 0.7 + rng.nextDouble() * 0.6,
        phaseOff: rng.nextDouble(),
        layer: 1,
      ));
    }

    // Lớp 2: ngoài — sáng hơn, lớn hơn
    for (int i = 0; i < 4; i++) {
      list.add(_DiamondSeed(
        angle: rng.nextDouble() * 2 * pi,
        dist: 56.0 + rng.nextDouble() * 10.0,
        size: 3.2 + rng.nextDouble() * 2.2,
        speedMul: 0.9 + rng.nextDouble() * 0.5,
        phaseOff: rng.nextDouble(),
        layer: 2,
      ));
    }

    return list;
  }

  const _ScatteredDiamondPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final s in _seeds) {
      final rotSpeed = [0.12, 0.22, 0.32][s.layer];
      final angle = s.angle + progress * rotSpeed * 2 * pi * s.speedMul;

      final pos = Offset(
        center.dx + s.dist * cos(angle),
        center.dy + s.dist * sin(angle),
      );

      // Nhấp nháy
      final blink = 0.5 + 0.5 * sin((progress * 2 * pi * 1.5) + s.phaseOff * 2 * pi);
      final baseOpacity = [0.30, 0.52, 0.78][s.layer];
      final opacity = (baseOpacity * (0.45 + 0.55 * blink)).clamp(0.10, 1.0);

      final color = s.layer == 2 ? _starMid : _starNear;

      // Glow
      if (s.layer >= 1) {
        canvas.drawCircle(
          pos,
          s.size * 1.6,
          Paint()
            ..color = _glowColor.withOpacity(opacity * 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      // Kim cương
      _drawDiamond(canvas, pos, s.size,
          Paint()
            ..color = color.withOpacity(opacity)
            ..style = PaintingStyle.fill);
    }
  }

  void _drawDiamond(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx,            c.dy - r)
      ..lineTo(c.dx + r * 0.45, c.dy)
      ..lineTo(c.dx,            c.dy + r)
      ..lineTo(c.dx - r * 0.45, c.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScatteredDiamondPainter old) => old.progress != progress;
}

class _DiamondSeed {
  final double angle;
  final double dist;
  final double size;
  final double speedMul;
  final double phaseOff;
  final int layer;

  const _DiamondSeed({
    required this.angle,
    required this.dist,
    required this.size,
    required this.speedMul,
    required this.phaseOff,
    required this.layer,
  });
}