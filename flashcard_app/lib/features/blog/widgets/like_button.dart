import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback onLike;
  final VoidCallback? onCountTap;
  final String Function(int) fmt;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.onLike,
    required this.fmt,
    this.onCountTap,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _burst;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.5)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.5, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
    ]).animate(_ctrl);

    _burst = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _fade = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.5, 1.0)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onLike();
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Burst particles ──
                  ...List.generate(6, (i) {
                    final angle = (i / 6) * 2 * 3.14159;
                    final dx =
                        _burst.value * 14 * (i % 2 == 0 ? 1 : 0.75);
                    return Positioned(
                      left: 18 +
                          dx *
                              (0.5 + 0.5 * (i / 6)) *
                              (i < 3 ? 1 : -1) *
                              (i.isEven ? 1 : 0.6),
                      top: 18 +
                          dx *
                              (0.5 + 0.5 * (i / 6)) *
                              (i < 2 || i > 4 ? -1 : 1) *
                              (i.isOdd ? 1 : 0.6),
                      child: Opacity(
                        opacity:
                            _ctrl.isAnimating ? _fade.value : 0,
                        child: Container(
                          width: i.isEven ? 5 : 3.5,
                          height: i.isEven ? 5 : 3.5,
                          decoration: BoxDecoration(
                            color: widget.isLiked
                                ? Colors.redAccent
                                : Colors.pinkAccent.shade100,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),

                  // ── Heart icon ──
                  Transform.scale(
                    scale: _scale.value,
                    child: Icon(
                      widget.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20,
                      color: widget.isLiked
                          ? Colors.redAccent
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: widget.onCountTap,
          child: Text(
            widget.fmt(widget.count),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}