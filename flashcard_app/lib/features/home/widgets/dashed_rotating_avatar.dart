import 'dart:math' as math;
import 'package:flutter/material.dart';

class MofuAvatar extends StatefulWidget {
  final String? photoUrl;
  final String fallbackAsset;

  /// Đường kính avatar, không tính halo
  final double size;

  /// Độ rộng của vùng halo bên ngoài avatar
  final double haloSize;

  final VoidCallback? onTap;

  const MofuAvatar({
    super.key,
    required this.fallbackAsset,
    this.photoUrl,
    this.size = 44,
    this.haloSize = 58,
    this.onTap,
  });

  @override
  State<MofuAvatar> createState() => _MofuAvatarState();
}

class _MofuAvatarState extends State<MofuAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.haloSize,
        height: widget.haloSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ============================================================
            // PASTEL HALO
            // ============================================================
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Container(
                    width: widget.haloSize,
                    height: widget.haloSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFFFF9AB5),
                          Color(0xFFFFC6D5),
                          Color(0xFFC9A7F5),
                          Color(0xFF9EDCF5),
                          Color(0xFFBDEEDC),
                          Color(0xFFFFD6E2),
                          Color(0xFFFF9AB5),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ============================================================
            // AVATAR
            // ============================================================
            Container(
              width: widget.size,
              height: widget.size,
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),

            // ============================================================
            // SPARKLE TOP RIGHT
            // ============================================================
            Positioned(
              top: -2,
              right: 1,
              child: _Sparkle(
                size: 7,
                color: const Color(0xFFFFD86B),
              ),
            ),

            // ============================================================
            // SPARKLE LEFT
            // ============================================================
            Positioned(
              left: -1,
              top: 14,
              child: _Sparkle(
                size: 5,
                color: const Color(0xFFFF9AB5),
              ),
            ),

            // ============================================================
            // SMALL DOT BOTTOM RIGHT
            // ============================================================
            Positioned(
              right: 2,
              bottom: 5,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9EDCF5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return Image.network(
        widget.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            widget.fallbackAsset,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      widget.fallbackAsset,
      fit: BoxFit.cover,
    );
  }
}

// ============================================================================
// SPARKLE
// ============================================================================

class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _Sparkle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(
        color: color,
      ),
    );
  }
}

// ============================================================================
// SPARKLE PAINTER
// ============================================================================

class _SparklePainter extends CustomPainter {
  final Color color;

  const _SparklePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final path = Path();

    path.moveTo(
      center.dx,
      0,
    );

    path.quadraticBezierTo(
      center.dx + size.width * 0.15,
      center.dy - size.height * 0.15,
      size.width,
      center.dy,
    );

    path.quadraticBezierTo(
      center.dx + size.width * 0.15,
      center.dy + size.height * 0.15,
      center.dx,
      size.height,
    );

    path.quadraticBezierTo(
      center.dx - size.width * 0.15,
      center.dy + size.height * 0.15,
      0,
      center.dy,
    );

    path.quadraticBezierTo(
      center.dx - size.width * 0.15,
      center.dy - size.height * 0.15,
      center.dx,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}