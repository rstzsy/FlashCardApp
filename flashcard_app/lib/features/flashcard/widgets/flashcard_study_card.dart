import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/flashcardModel.dart';

class FlashcardStudyCard extends StatefulWidget {
  final FlashcardModel flashcard;

  const FlashcardStudyCard({super.key, required this.flashcard});

  @override
  State<FlashcardStudyCard> createState() => _FlashcardStudyCardState();
}

class _FlashcardStudyCardState extends State<FlashcardStudyCard>
    with SingleTickerProviderStateMixin {
  bool isFront = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  static const Color kCardFront = Color(0xFFF7D6D5);
  static const Color kCardBack = Color(0xFFFFF0EF);
  static const Color kAccentDeep = Color(0xFF7A3333);
  static const Color kAccentMid = Color(0xFFB36B6A);
  static const Color kAccentLight = Color(0xFFC0A0A0);
  static const Color kDivider = Color(0xFFEAC8C7);
  static const Color kExampleBg = Color(0x66F7D6D5);
  static const Color kTagBg = Color(0x8DFFFFFF);
  static const Color kBadgeDay = Color(0xFFF7D6D5);
  static const Color kBadgeLevel = Color(0xFFD5EAF7);

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
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 60));
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder:
            (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 60)),
      );
    }

    return Image.asset(url, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: SizedBox(
        width: double.infinity,
        height: 480,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            // flip
            final angle = _animation.value * pi;
            final showFront = angle < pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
              child:
                  showFront
                      ? _buildFront()
                      : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: _buildBack(),
                      ),
            );
          },
        ),
      ),
    );
  }

  // front card
  Widget _buildFront() {
    final f = widget.flashcard;

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: kCardBack,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Tag Day
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kTagBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Day ${f.day} · ${f.level}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kAccentMid,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          // flashcard content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImage(f.imageUrl),
                  ),
                ),
                const SizedBox(height: 20),

                // word
                Text(
                  f.word,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: kAccentDeep,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Phonetic
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

          // Hint to flip
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.refresh_rounded, size: 18, color: kAccentLight),
                SizedBox(width: 4),
                Text(
                  'Click to flip card',
                  style: TextStyle(fontSize: 16, color: kAccentLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // back card
  Widget _buildBack() {
    final f = widget.flashcard;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBack,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kDivider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top badge
          Row(
            children: [
              _Badge(text: 'Day ${f.day}', bg: kBadgeDay, fg: kAccentMid),
              const Spacer(),
              _Badge(
                text: f.level,
                bg: kBadgeLevel,
                fg: const Color(0xFF3A7FAA),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // row(image + word)
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
                      style: const TextStyle(fontSize: 16, color: kAccentMid),
                    ),
                    const SizedBox(height: 2),
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
            ],
          ),

          const SizedBox(height: 14),

          const Divider(color: kDivider, thickness: 0.5, height: 1),

          const SizedBox(height: 14),

          // example
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kAccentMid,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        f.example,
                        style: const TextStyle(
                          fontSize: 18,
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
        ],
      ),
    );
  }
}

// badge
class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
