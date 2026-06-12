import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/flashcardModel.dart';

class FlashcardStudyCard extends StatefulWidget {
  final FlashcardModel flashcard;
  final VoidCallback? onFlippedToBack;

  const FlashcardStudyCard({
    super.key,
    required this.flashcard,
    this.onFlippedToBack,
  });

  @override
  State<FlashcardStudyCard> createState() => _FlashcardStudyCardState();
}

class _FlashcardStudyCardState extends State<FlashcardStudyCard>
    with SingleTickerProviderStateMixin {
  bool isFront = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  static const Color kCardBack    = Color(0xFFFFF0EF);
  static const Color kAccentDeep  = Color(0xFF7A3333);
  static const Color kAccentMid   = Color(0xFFB36B6A);
  static const Color kAccentLight = Color(0xFFC0A0A0);
  static const Color kDivider     = Color(0xFFEAC8C7);
  static const Color kExampleBg   = Color(0x66F7D6D5);
  static const Color kTagBg       = Color(0x8DFFFFFF);
  static const Color kBadgeDay    = Color(0xFFF7D6D5);
  static const Color kBadgeLevel  = Color(0xFFD5EAF7);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.4, 0.2, 0.2, 1.0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flipCard() {
    if (_controller.isAnimating) return;
    final wasFlippingToBack = isFront;
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
    if (wasFlippingToBack) {
      widget.onFlippedToBack?.call();
    }
  }

  // ── FSRS tag info ──────────────────────────────────────────────────────────
  ({String label, Color bg, Color fg})? get _fsrsTag {
    final fsrs = widget.flashcard.fsrsData;
    if (fsrs == null || fsrs.state == 'new') return null;

    final isOverdue = fsrs.due != null && fsrs.due!.isBefore(DateTime.now());

    switch (fsrs.state) {
      case 'learning':
        return (
          label: 'Learning',
          bg: const Color(0xFFFFECB3),
          fg: const Color(0xFF7A5800),
        );
      case 'relearning':
        return (
          label: 'Relearning',
          bg: const Color(0xFFFFCDD2),
          fg: const Color(0xFF7A1A1A),
        );
      case 'review':
        return isOverdue
            ? (
                label: 'Overdue',
                bg: const Color(0xFFFFCDD2),
                fg: const Color(0xFF7A1A1A),
              )
            : (
                label: 'Review',
                bg: const Color(0xFFE8F5E9),
                fg: const Color(0xFF1B5E20),
              );
      default:
        return null;
    }
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 60, color: kAccentLight));
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, size: 60, color: kAccentLight)),
      );
    }
    return Image.asset(url, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          final showFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final f = widget.flashcard;
    final tag = _fsrsTag;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardBack,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kAccentMid.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Top-left: FSRS tag (nếu có) ────────────────────────────────
          if (tag != null)
            Positioned(
              top: 16,
              left: 16,
              child: _Tag(label: tag.label, bg: tag.bg, fg: tag.fg),
            ),

          // ── Top-right: Day · Level ──────────────────────────────────────
          Positioned(
            top: 16,
            right: 16,
            child: _Tag(
              label: 'Day ${f.day} · ${f.level}',
              bg: kTagBg,
              fg: kAccentMid,
            ),
          ),

          // ── Center content ──────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImage(f.imageUrl),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  f.word,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: kAccentDeep,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  f.phonetic,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: kAccentMid.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom hint ─────────────────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 16, color: kAccentLight.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  'Tap to reveal answer',
                  style: TextStyle(
                    fontSize: 13,
                    color: kAccentLight.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final f = widget.flashcard;
    final tag = _fsrsTag;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBack,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kDivider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kAccentMid.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: badges ──────────────────────────────────────────────
          Row(
            children: [
              _Tag(
                label: 'Day ${f.day}',
                bg: kBadgeDay,
                fg: kAccentMid,
              ),
              const SizedBox(width: 8),
              if (tag != null) _Tag(label: tag.label, bg: tag.bg, fg: tag.fg),
              const Spacer(),
              _Tag(
                label: f.level,
                bg: kBadgeLevel,
                fg: const Color(0xFF3A7FAA),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Word + image row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImage(f.imageUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.word,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: kAccentDeep,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      f.meaning,
                      style: const TextStyle(fontSize: 15, color: kAccentMid),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.phonetic,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: kAccentMid.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: kDivider, thickness: 0.5, height: 1),
          const SizedBox(height: 14),

          // ── Example ──────────────────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kExampleBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXAMPLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kAccentMid,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        f.example,
                        style: const TextStyle(
                          fontSize: 17,
                          color: kAccentDeep,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Flip back hint ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 13, color: kAccentLight.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  'Tap to flip back',
                  style: TextStyle(
                    fontSize: 12,
                    color: kAccentLight.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable tag widget ────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}