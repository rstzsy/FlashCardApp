import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _current = 0;

  static const List<_PromoData> _items = [
    _PromoData(
      badge: "Flashcard",
      title: "Learn words\nwith Flashcards",
      subtitle: "Flip, review & memorize anytime",
      imagePath: "assets/component/flashcard_promo.png",
      bgColor: Color(0xFFE8D5F5),
      badgeColor: Color(0xFF9C6FCD),
    ),
    _PromoData(
      badge: "Spaced Repetition",
      title: "Review at the\nright moment",
      subtitle: "Smart scheduling keeps words fresh",
      imagePath: "assets/component/spaced_promo.png",
      bgColor: Color(0xFFD5EAF5),
      badgeColor: Color(0xFF1E88E5),
    ),
    _PromoData(
      badge: "Word Garden",
      title: "Grow your\nWord Garden",
      subtitle: "Play games, plant words, harvest knowledge",
      imagePath: "assets/component/word_garden_promo.png",
      bgColor: Color(0xFFD9F5D5),
      badgeColor: Color(0xFF43A047),
    ),
    _PromoData(
      badge: "AI Coach",
      title: "Your personal\nAI study coach",
      subtitle: "AI creates cards & suggests lessons for you",
      imagePath: "assets/component/ai_promo.png",
      bgColor: Color(0xFFFFF3CC),
      badgeColor: Color(0xFFF5A623),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Explore Features",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // ── SizedBox cao hơn card để ảnh có chỗ nhô lên ──
        SizedBox(
          height: 160, // card cao 110, ảnh nhô lên 30px
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, index) => _PromoCard(data: _items[index]),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? _items[_current].badgeColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Promo Card ───────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  final _PromoData data;
  const _PromoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 120;
    const double imageSize  = 150; 
    const double imageBottom = 0;  

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        clipBehavior: Clip.none, // cho phép ảnh nhô ra ngoài
        alignment: Alignment.bottomRight,
        children: [
          // ── Thân card ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: cardHeight,
              padding: const EdgeInsets.fromLTRB(18, 14, 110, 14),
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: data.badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.50),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // ── Ảnh nhô ra khỏi card phía trên ──
          Positioned(
            bottom: imageBottom,
            right: 10,
            child: Image.asset(
              data.imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.auto_awesome_rounded,
                size: 60,
                color: data.badgeColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _PromoData {
  final String badge;
  final String title;
  final String subtitle;
  final String imagePath;
  final Color bgColor;
  final Color badgeColor;

  const _PromoData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.bgColor,
    required this.badgeColor,
  });
}