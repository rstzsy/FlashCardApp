import 'package:flutter/material.dart';

class ShopItem {
  final String imagePath;
  final String name;
  final bool isLocked;

  const ShopItem({
    required this.imagePath,
    required this.name,
    this.isLocked = false,
  });
}

class ShopGameScreen extends StatelessWidget {
  const ShopGameScreen({super.key});

  static const List<ShopItem> _items = [
    ShopItem(imagePath: 'assets/game/Frangipani.png', name: 'Frangipani', isLocked: true),
    ShopItem(imagePath: 'assets/game/lotus.png',      name: 'Lotus',      isLocked: true),
    ShopItem(imagePath: 'assets/game/Plumeria.png',   name: 'Plumeria',   isLocked: true),
    ShopItem(imagePath: 'assets/game/rose.png',       name: 'Rose',       isLocked: true),
    ShopItem(imagePath: 'assets/game/sunFlower.png',  name: 'Sunflower',  isLocked: true),
    ShopItem(imagePath: 'assets/game/tulip.png',      name: 'Tulip'),
    ShopItem(imagePath: 'assets/game/Frangipani.png', name: 'Frangipani 2'),
    ShopItem(imagePath: 'assets/game/lotus.png',      name: 'Lotus 2'),
    ShopItem(imagePath: 'assets/game/Plumeria.png',   name: 'Plumeria 2'),
    ShopItem(imagePath: 'assets/game/rose.png',       name: 'Rose 2'),
    ShopItem(imagePath: 'assets/game/tulip.png',      name: 'Tulip 2'),
    ShopItem(imagePath: 'assets/game/plant.png',   name: 'Plumeria 3'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<double> shelfTops = [
      size.height * 0.275,
      size.height * 0.415,
      size.height * 0.575,
      size.height * 0.720, 
    ];

    final List<int> shelfCounts = [4, 4, 4, 3];

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/game/shop_bg.png',
              width: size.width,
              height: size.height,
              fit: BoxFit.fill,
            ),
          ),

          // ── Shelf Items ──────────────────────────────────────
          ..._buildShelfItems(size, shelfTops, shelfCounts),

          // ── Back Button ──────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 18,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/game/back_button.png',
                width: size.width * 0.11,
                height: size.width * 0.11,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShelfItems(
    Size size,
    List<double> shelfTops,
    List<int> shelfCounts,
  ) {
    final List<Widget> widgets = [];
    int itemIndex = 0;

    final double itemWidth   = size.width * 0.14;
    final double itemSpacing = size.width * 0.055;

    for (int shelf = 0; shelf < shelfTops.length; shelf++) {
      final count = shelfCounts[shelf];
      final totalWidth = count * itemWidth + (count - 1) * itemSpacing;
      final startX = (size.width - totalWidth) / 2;

      for (int col = 0; col < count; col++) {
        if (itemIndex >= _items.length) break;
        final item = _items[itemIndex++];
        final left = startX + col * (itemWidth + itemSpacing);

        widgets.add(
          Positioned(
            top: shelfTops[shelf],
            left: left,
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: item.isLocked ? 0.55 : 1.0,
                      child: Image.asset(
                        item.imagePath,
                        width: itemWidth,
                        height: itemWidth,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            SizedBox(width: itemWidth, height: itemWidth),
                      ),
                    ),

                    if (item.isLocked)
                      Container(
                        width: itemWidth * 0.45,
                        height: itemWidth * 0.45,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: itemWidth * 0.28,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}