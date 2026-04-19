import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'dart:ui';

class AppPopup {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = Colors.green,
    Widget? iconWidget,
    String buttonText = "OK",
    VoidCallback? onPressed,
    bool showConfetti = false, 
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AppPopupContent(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        iconWidget: iconWidget,
        buttonText: buttonText,
        onPressed: onPressed,
        showConfetti: showConfetti,
      ),
    );
  }
}


class _AppPopupContent extends StatefulWidget {
  final String title, message, buttonText;
  final IconData icon;
  final Color iconColor;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final bool showConfetti;

  const _AppPopupContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconWidget,
    required this.buttonText,
    required this.onPressed,
    required this.showConfetti,
  });

  @override
  State<_AppPopupContent> createState() => _AppPopupContentState();
}

class _AppPopupContentState extends State<_AppPopupContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(60, (_) => _Particle(Random()));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.showConfetti) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: AppColors.mainColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            if (widget.showConfetti)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.iconWidget ??
                      Icon(widget.icon, size: 60, color: widget.iconColor),
                  const SizedBox(height: 15),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.highlightColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.highlightColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onPressed?.call();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 193, 226, 255),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 145, 184, 244),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.buttonText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE24B4A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Particle model ──────────────────────────────────────────────────────────

class _Particle {
  final double startX, startY, vx, vy, gravity;
  final double wobbleAmp, wobbleFreq, size, initAngle, rotSpeed, delay;
  final Color color;
  final int shape;

  _Particle(Random rng)
      : startX = rng.nextBool()
            ? 0.05 + rng.nextDouble() * 0.2
            : 0.75 + rng.nextDouble() * 0.2,
        startY = 0.6 + rng.nextDouble() * 0.1,
        vx = (rng.nextDouble() - 0.5) * 320,
        vy = -(160 + rng.nextDouble() * 240),
        gravity = 240 + rng.nextDouble() * 120,
        wobbleAmp = 8 + rng.nextDouble() * 16,
        wobbleFreq = 2.0 + rng.nextDouble() * 3.0,
        size = 5 + rng.nextDouble() * 7,
        initAngle = rng.nextDouble() * pi * 2,
        rotSpeed = (rng.nextDouble() - 0.5) * 10,
        color = const [
          Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
          Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFA29BFE),
          Color(0xFFFD79A8), Color(0xFF00CEC9),
        ][rng.nextInt(8)],
        shape = rng.nextInt(3),
        delay = rng.nextDouble() * 0.45;
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
      final dt = t * 2.0;
      final px = p.startX * size.width +
          p.vx * dt +
          p.wobbleAmp * sin(t * pi * p.wobbleFreq + p.initAngle);
      final py = p.startY * size.height + p.vy * dt + 0.5 * p.gravity * dt * dt;
      if (px < -20 || px > size.width + 20 || py > size.height + 20) continue;
      final opacity = (t < 0.7 ? 1.0 : (1.0 - t) / 0.3).clamp(0.0, 1.0);
      if (opacity <= 0) continue;
      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.initAngle + t * p.rotSpeed * pi * 2);
      switch (p.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.4, height: p.size * 0.6),
            paint,
          );
          break;
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          break;
        default:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size * 0.28, height: p.size * 1.6),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}