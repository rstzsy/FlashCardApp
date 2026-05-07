// lib/features/game/widgets/garden_tool_tray.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

enum GardenTool { water, fertilizer }

class GardenToolDrop {
  final GardenTool tool;
  const GardenToolDrop(this.tool);
}

// ─── Tool Tray (fixed overlay) ────────────────────────────────────────────────

class GardenToolTray extends StatelessWidget {
  final int waterCount;
  final int fertilizerCount;

  const GardenToolTray({
    super.key,
    required this.waterCount,
    required this.fertilizerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,                                             // ← bên trái màn hình
      bottom: MediaQuery.of(context).size.height * 0.60,   // xích lên cao
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DraggableToolItem(
            tool: GardenTool.fertilizer,
            count: fertilizerCount,
            imagePath: 'assets/game/fertilizer.png',
            badgeColor: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: 22),
          _DraggableToolItem(
            tool: GardenTool.water,
            count: waterCount,
            imagePath: 'assets/game/watering_can.png',
            badgeColor: const Color(0xFF29B6F6),
          ),
        ],
      ),
    );
  }
}

// ─── Single draggable tool item ───────────────────────────────────────────────

class _DraggableToolItem extends StatefulWidget {
  final GardenTool tool;
  final int count;
  final String imagePath;
  final Color badgeColor;

  const _DraggableToolItem({
    required this.tool,
    required this.count,
    required this.imagePath,
    required this.badgeColor,
  });

  @override
  State<_DraggableToolItem> createState() => _DraggableToolItemState();
}

class _DraggableToolItemState extends State<_DraggableToolItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _pulseScale = Tween(begin: 1.0, end: 1.09)
      .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.count <= 0;
    if (isEmpty) return _buildIcon(isEmpty: true);

    return LongPressDraggable<GardenToolDrop>(
      data: GardenToolDrop(widget.tool),
      delay: Duration.zero,
      onDragStarted: () {
        HapticFeedback.mediumImpact();
        _pulseCtrl.stop();
      },
      onDragEnd: (_) {
        _pulseCtrl.repeat(reverse: true);
      },
      feedback: _DragFeedback(imagePath: widget.imagePath, tool: widget.tool),
      childWhenDragging: _buildIcon(isEmpty: false),
      child: ScaleTransition(
        scale: _pulseScale,
        child: _buildIcon(isEmpty: false),
      ),
    );
  }

  Widget _buildIcon({required bool isEmpty}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isEmpty ? 0.3 : 1.0,
          child: Image.asset(
            widget.imagePath,
            width: 76,
            height: 76,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              widget.tool == GardenTool.water
                  ? Icons.water_drop_rounded
                  : Icons.eco_rounded,
              size: 64,
              color: isEmpty ? Colors.grey : widget.badgeColor,
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -10,
          child: _CountBadge(
            count: widget.count,
            color: isEmpty ? const Color(0xFFBDBDBD) : widget.badgeColor,
          ),
        ),
      ],
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.55), blurRadius: 6),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ─── Drag feedback: icon trắng theo ngón tay ──────────────────────────────────

class _DragFeedback extends StatelessWidget {
  final String imagePath;
  final GardenTool tool;
  const _DragFeedback({required this.imagePath, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          tool == GardenTool.water
              ? Icons.water_drop_rounded
              : Icons.eco_rounded,
          size: 64,
        ),
      ),
    );
  }
}

// ─── Drop highlight: nền trắng + ngôi sao kim cương vàng nhẹ ─────────────────

class ToolDropHighlight extends StatefulWidget {
  final GardenTool tool;
  const ToolDropHighlight({super.key, required this.tool});

  @override
  State<ToolDropHighlight> createState() => _ToolDropHighlightState();
}

class _ToolDropHighlightState extends State<ToolDropHighlight>
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
      width: 220, // kích thước đủ lớn để chứa cả hiệu ứng ripple và ngôi sao bay quanh
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng trắng pulse
          ScaleTransition(
            scale: _rippleScale,
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fillColor,
                border: Border.all(color: _ringColor.withOpacity(0.85), width: 2.2),
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

          // Ngôi sao kim cương vàng xoay quanh
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _StarOrbitPainter(
                  progress: _starCtrl.value,
                  starColor: _starColor,
                  glowColor: _starGlow,
                ),
              ),
            ),
          ),

          // Icon trung tâm trắng
          Icon(
            widget.tool == GardenTool.water
                ? Icons.water_drop_rounded
                : Icons.eco_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 28,
          ),
        ],
      ),
    );
  }
}

// ─── Painter: ngôi sao kim cương vàng bay quanh quỹ đạo ──────────────────────

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

      // Glow halo
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(opacity * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, starR * 1.5, glowPaint);

      // Kim cương
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