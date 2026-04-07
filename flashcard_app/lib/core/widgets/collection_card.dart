import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
//  CollectionCard — StatefulWidget để ngôi sao tap được
// ══════════════════════════════════════════════════════
class CollectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int setsCount;
  final Color color;
  final IconData icon;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  const CollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.setsCount,
    required this.color,
    this.icon = Icons.menu_book_rounded,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<CollectionCard>
    with SingleTickerProviderStateMixin {
  late bool _fav;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 1.5).chain(
      CurveTween(curve: Curves.elasticOut),
    ).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleFav() {
    setState(() => _fav = !_fav);
    _ctrl.forward(from: 0);
    widget.onFavoriteChanged?.call(_fav);
  }

  // Tạo màu tab tối hơn thân ~15%
  Color _darken(Color c, double amount) => Color.fromARGB(
        c.alpha,
        (c.red   * (1 - amount)).round().clamp(0, 255),
        (c.green * (1 - amount)).round().clamp(0, 255),
        (c.blue  * (1 - amount)).round().clamp(0, 255),
      );

  @override
  Widget build(BuildContext context) {
    const double cardWidth  = 120;
    const double cardHeight = 100;
    const double tabWidth   = 46;
    const double tabHeight  = 18;
    const double bodyRadius = 12.0;
    const double tabRadius  = 7.0;

    final Color tabColor  = _darken(widget.color, 0.15);
    final Color iconColor = _darken(widget.color, 0.22);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              // ── Tab góc trên trái ──
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: tabWidth,
                  height: tabHeight + 4,
                  decoration: BoxDecoration(
                    color: tabColor,
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(tabRadius),
                      topRight: Radius.circular(tabRadius),
                    ),
                  ),
                ),
              ),

              // ── Thân folder ──
              Positioned(
                top: tabHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.only(
                      topRight:    Radius.circular(bodyRadius),
                      bottomLeft:  Radius.circular(bodyRadius),
                      bottomRight: Radius.circular(bodyRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:       tabColor.withOpacity(0.28),
                        blurRadius:  10,
                        offset:      const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // ── Icon trung tâm ──
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(
                            widget.icon,
                            size: 34,
                            color: iconColor.withOpacity(0.50),
                          ),
                        ),
                      ),

                      // ── Ngôi sao — tap để yêu thích ──
                      Positioned(
                        top: 4,
                        right: 6,
                        child: GestureDetector(
                          onTap: _toggleFav,
                          child: AnimatedBuilder(
                            animation: _scale,
                            builder: (_, child) => Transform.scale(
                              scale: _scale.value,
                              child: child,
                            ),
                            child: Icon(
                              _fav ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18,
                              color: _fav
                                  ? const Color(0xFFFFD600)   // vàng khi yêu thích
                                  : Colors.white.withOpacity(0.72),
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
        ),

        const SizedBox(height: 8),

        // ── Hex label ──
        Text(
          widget.subtitle,
          style: const TextStyle(
            fontSize:      12,
            fontWeight:    FontWeight.w600,
            color:         Color(0xFF5C3520),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  CollectionGridScreen — 9 folder đúng màu từ ảnh
// ══════════════════════════════════════════════════════
class CollectionGridScreen extends StatelessWidget {
  const CollectionGridScreen({super.key});

  // Màu lấy đúng từ ảnh
  static const _folders = [
    {'hex': 0xFFF59CB2, 'label': 'f59cb2', 'icon': Icons.palette_rounded},
    {'hex': 0xFFB48D71, 'label': 'b48d71', 'icon': Icons.description_rounded},
    {'hex': 0xFFA05C46, 'label': 'a05c46', 'icon': Icons.sentiment_satisfied_rounded},
    {'hex': 0xFFE49E91, 'label': 'e49e91', 'icon': Icons.school_rounded},
    {'hex': 0xFFD5708B, 'label': 'd5708b', 'icon': Icons.menu_book_rounded},
    {'hex': 0xFFE9B4B3, 'label': 'e9b4b3', 'icon': Icons.menu_book_rounded},
    {'hex': 0xFFF2DCBE, 'label': 'f2dcbe', 'icon': Icons.menu_book_rounded},
    {'hex': 0xFFF0B6C6, 'label': 'f0b6c6', 'icon': Icons.description_rounded},
    {'hex': 0xFFEECEB6, 'label': 'eeceb6', 'icon': Icons.work_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 36),
            const Text(
              'My Color Codes',
              style: TextStyle(
                fontSize:      28,
                fontWeight:    FontWeight.w700,
                color:         Color(0xFF4A2818),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:  3,
                  mainAxisSpacing: 28,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.82,
                ),
                itemCount: _folders.length,
                itemBuilder: (context, i) {
                  final f = _folders[i];
                  return CollectionCard(
                    title:     f['label'] as String,
                    subtitle:  f['label'] as String,
                    setsCount: 0,
                    color:     Color(f['hex'] as int),
                    icon:      f['icon'] as IconData,
                    onFavoriteChanged: (fav) {
                      // Xử lý lưu trạng thái yêu thích ở đây
                      debugPrint('${f['label']} favorite: $fav');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}