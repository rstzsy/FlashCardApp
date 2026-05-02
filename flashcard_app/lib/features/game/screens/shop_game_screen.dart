// lib/features/game/screens/shop_game_screen.dart
//
// Shop screen with 2 tabs:
//   1. Shop – grid of plants, integrates SeedSelectionSheet
//   2. My Garden – vertical list view of planted trees
//
// Changes vs previous version:
//   - ShopItem extended with requiredSetTitle, requiredSetId, linkedSeed
//   - Locked plant → dialog shows required flashcard set + "Study Now" button
//   - Unlocked plant → SeedSelectionSheet.show() to choose a plot and plant
//   - _ShopCard shows the linked flashcard set name inside the card

import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/seed_selection_sheet.dart';

// ─── Shop model (extended) ───────────────────────────────────────────────────

class ShopItem {
  final String imagePath;
  final String name;
  final bool isLocked;
  final int price;

  /// ID of the flashcard set required to unlock this plant.
  /// Null if no specific set is required.
  final String? requiredSetId;

  /// Display name of the required flashcard set shown when the plant is locked.
  final String? requiredSetTitle;

  /// Linked seed – attached once the user completes the corresponding flashcard set.
  /// Null if not yet unlocked or no seed has been linked.
  final SeedItem? linkedSeed;

  const ShopItem({
    required this.imagePath,
    required this.name,
    this.isLocked = false,
    this.price = 0,
    this.requiredSetId,
    this.requiredSetTitle,
    this.linkedSeed,
  });

  /// Plant is truly ready to plant: unlocked AND has a linked seed.
  bool get isReadyToPlant => !isLocked && linkedSeed != null;

  /// Plant is unlocked but has no seed (user hasn't studied the matching set yet).
  bool get isUnlockedNoSeed => !isLocked && linkedSeed == null;
}

// ─── Main screen ─────────────────────────────────────────────────────────────

class ShopGameScreen extends StatefulWidget {
  /// Plot list from HomeGameScreen
  final List<GardenPlot> plots;

  /// Callback when user plants from the shop → update external state
  final Function(int plotIndex, SeedItem seed)? onPlantFromShop;

  const ShopGameScreen({
    super.key,
    required this.plots,
    this.onPlantFromShop,
  });

  @override
  State<ShopGameScreen> createState() => _ShopGameScreenState();
}

class _ShopGameScreenState extends State<ShopGameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ── Sample shop data ──────────────────────────────────────────────────────
  // In production this comes from backend / state management.
  // linkedSeed is attached once the user completes the corresponding set.
  static final List<ShopItem> _shopItems = [
    // ── Locked plants – show required flashcard set ───────────────────────
    ShopItem(
      imagePath: 'assets/game/Frangipani.png',
      name: 'White Frangipani',
      isLocked: true,
      price: 120,
      requiredSetId: 'set_flowers_advanced',
      requiredSetTitle: 'Advanced Flowers & Plants',
    ),
    ShopItem(
      imagePath: 'assets/game/lotus.png',
      name: 'Pink Lotus',
      isLocked: true,
      price: 200,
      requiredSetId: 'set_nature_master',
      requiredSetTitle: 'Nature – Master Level',
    ),
    ShopItem(
      imagePath: 'assets/game/Plumeria.png',
      name: 'Golden Plumeria',
      isLocked: true,
      price: 150,
      requiredSetId: 'set_tropical_plants',
      requiredSetTitle: 'Tropical Plants',
    ),
    ShopItem(
      imagePath: 'assets/game/rose.png',
      name: 'Rose',
      isLocked: true,
      price: 180,
      requiredSetId: 'set_romance_vocab',
      requiredSetTitle: 'Romantic Vocabulary',
    ),
    ShopItem(
      imagePath: 'assets/game/sunFlower.png',
      name: 'Sunflower',
      isLocked: true,
      price: 100,
      requiredSetId: 'set_weather_nature',
      requiredSetTitle: 'Weather & Nature',
    ),

    // ── Unlocked plants – linkedSeed from completed flashcard sets ─────────
    ShopItem(
      imagePath: 'assets/game/tulip.png',
      name: 'Tulip',
      isLocked: false,
      price: 80,
      requiredSetId: 'set_basic_flowers',
      requiredSetTitle: 'Basic Flowers',
      linkedSeed: SeedItem(
        setId: 'set_basic_flowers',
        title: 'Basic Flowers',
        subtitle: 'Tulip, Rose, Daisy...',
        totalCards: 24,
        difficulty: 'Easy',
        imagePath: 'assets/game/tulip.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/Frangipani.png',
      name: 'Purple Frangipani',
      isLocked: false,
      price: 90,
      requiredSetId: 'set_garden_vocab',
      requiredSetTitle: 'Garden Vocabulary',
      linkedSeed: SeedItem(
        setId: 'set_garden_vocab',
        title: 'Garden Vocabulary',
        subtitle: 'Plants, flowers, soil, fertilizer...',
        totalCards: 32,
        difficulty: 'Easy',
        imagePath: 'assets/game/Frangipani.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/lotus.png',
      name: 'White Lotus',
      isLocked: false,
      price: 110,
      requiredSetId: 'set_water_plants',
      requiredSetTitle: 'Aquatic Plants',
      linkedSeed: SeedItem(
        setId: 'set_water_plants',
        title: 'Aquatic Plants',
        subtitle: 'Lotus, water lily, duckweed...',
        totalCards: 18,
        difficulty: 'Medium',
        imagePath: 'assets/game/lotus.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/Plumeria.png',
      name: 'Red Plumeria',
      isLocked: false,
      price: 95,
      requiredSetId: 'set_color_adjectives',
      requiredSetTitle: 'Color Adjectives',
      linkedSeed: SeedItem(
        setId: 'set_color_adjectives',
        title: 'Color Adjectives',
        subtitle: 'Scarlet, crimson, vermillion...',
        totalCards: 28,
        difficulty: 'Medium',
        imagePath: 'assets/game/Plumeria.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/rose.png',
      name: 'Golden Rose',
      isLocked: false,
      price: 130,
      requiredSetId: 'set_emotions_vocab',
      requiredSetTitle: 'Emotion Vocabulary',
      linkedSeed: SeedItem(
        setId: 'set_emotions_vocab',
        title: 'Emotion Vocabulary',
        subtitle: 'Joy, melancholy, euphoria...',
        totalCards: 40,
        difficulty: 'Hard',
        imagePath: 'assets/game/rose.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/tulip.png',
      name: 'Purple Tulip',
      isLocked: false,
      price: 85,
      requiredSetId: 'set_spring_vocab',
      requiredSetTitle: 'Spring Vocabulary',
      linkedSeed: SeedItem(
        setId: 'set_spring_vocab',
        title: 'Spring Vocabulary',
        subtitle: 'Bloom, blossom, petal...',
        totalCards: 22,
        difficulty: 'Easy',
        imagePath: 'assets/game/tulip.png',
      ),
    ),
    ShopItem(
      imagePath: 'assets/game/plant.png',
      name: 'Exotic Plant',
      isLocked: false,
      price: 60,
      // Unlocked but no seed – user hasn't studied the matching set yet
      requiredSetId: 'set_exotic_plants',
      requiredSetTitle: 'World Exotic Plants',
      linkedSeed: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<GardenPlot> get _plantedPlots =>
      widget.plots.where((p) => p.status != PlotStatus.empty).toList();

  /// Empty plots – passed into SeedSelectionSheet
  List<GardenPlot> get _emptyPlots =>
      widget.plots.where((p) => p.status == PlotStatus.empty).toList();

  void _handlePlantFromShop(int plotIndex, SeedItem seed) {
    widget.onPlantFromShop?.call(plotIndex, seed);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Planted "${seed.title}" in plot #${plotIndex + 1}!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7CB342),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/game/shop_bg.png',
          //     fit: BoxFit.fill,
          //     errorBuilder: (_, __, ___) => Container(
          //       decoration: const BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomCenter,
          //           colors: [Color(0xFFF9F3E8), Color(0xFFEDE0CE)],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF0F5), Color(0xFFFFD6E7)],
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/game/back_button.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Shop',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4E342E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      // Coin display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFB300), width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌟', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(
                              '350',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tab bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0D0BC)),
                    ),
                    child: TabBar(
                      controller: _tab,
                      labelColor: const Color(0xFF4E342E),
                      unselectedLabelColor: const Color(0xFFAA9080),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w500),
                      indicator: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFD4B896), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      indicatorPadding: const EdgeInsets.all(3),
                      dividerColor: Colors.transparent,
                      tabs: [
                        const Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🌸 ', style: TextStyle(fontSize: 14)),
                              Text('Shop'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪴 ',
                                  style: TextStyle(fontSize: 14)),
                              const Text('My Garden'),
                              if (_plantedPlots.isNotEmpty) ...[
                                const SizedBox(width: 5),
                                _CountBadge(count: _plantedPlots.length),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Tab content ──────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _ShopTab(
                        items: _shopItems,
                        emptyPlots: _emptyPlots,
                        onPlant: _handlePlantFromShop,
                      ),
                      _MyGardenTab(plots: _plantedPlots),
                    ],
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

// ─── Tab 1: Shop ─────────────────────────────────────────────────────────────

class _ShopTab extends StatelessWidget {
  final List<ShopItem> items;
  final List<GardenPlot> emptyPlots;
  final Function(int plotIndex, SeedItem seed) onPlant;

  const _ShopTab({
    required this.items,
    required this.emptyPlots,
    required this.onPlant,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ShopCard(
        item: items[i],
        emptyPlots: emptyPlots,
        onPlant: onPlant,
      ),
    );
  }
}

// ─── Individual shop card ─────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final List<GardenPlot> emptyPlots;
  final Function(int plotIndex, SeedItem seed) onPlant;

  const _ShopCard({
    required this.item,
    required this.emptyPlots,
    required this.onPlant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isLocked
                ? const Color(0xFFD7CCC8)
                : item.isReadyToPlant
                    ? const Color(0xFF7CB342)
                    : const Color(0xFFD4B896),
            width: item.isReadyToPlant ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isReadyToPlant
                  ? const Color(0xFF7CB342).withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Plant image – fixed height, always centered ──
                  SizedBox(
                    height: 70,
                    child: Center(
                      child: Opacity(
                        opacity: item.isLocked ? 0.45 : 1.0,
                        child: Image.asset(
                          item.imagePath,
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/game/tulip.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Plant name ───────────────────────────────────
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.isLocked
                          ? const Color(0xFFBCAAA4)
                          : const Color(0xFF5D4037),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ── Price / Seed info / Study required ────────────
                  if (item.isLocked)
                    _LockedLabel(setTitle: item.requiredSetTitle)
                  else if (item.isReadyToPlant)
                    _SeedLinkedLabel(seed: item.linkedSeed!)
                  else if (item.isUnlockedNoSeed)
                    _NeedStudyLabel(setTitle: item.requiredSetTitle)
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 2),
                        Text(
                          '${item.price}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ── Lock overlay (top-right) ──────────────────────────
            if (item.isLocked)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0x88000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, size: 11, color: Colors.white),
                ),
              ),

            // ── "Ready to plant" badge (top-right) ───────────────
            if (item.isReadyToPlant)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7CB342),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded, size: 11, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (item.isLocked) {
      _showLockedDialog(context);
    } else if (item.isReadyToPlant) {
      _showPlantSheet(context);
    } else if (item.isUnlockedNoSeed) {
      _showNeedStudyDialog(context);
    }
  }

  // ── Dialog: locked plant ────────────────────────────────────────────────
  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF8EC),
        title: const Row(
          children: [
            Text('🔒 ', style: TextStyle(fontSize: 18)),
            Text(
              'Locked',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4E342E),
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To unlock "${item.name}", complete the flashcard set:',
              style: const TextStyle(
                color: Color(0xFF6D4C41),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCE93D8)),
              ),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.requiredSetTitle ?? 'Any flashcard set',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'View all cards + pass the quiz',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9C4DCC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to flashcard screen with requiredSetId
              // context.push('/flashcard/${item.requiredSetId}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7CB342),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 15, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Study Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog: unlocked but no seed (flashcard set not studied yet) ─────────
  void _showNeedStudyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF8EC),
        title: Row(
          children: [
            const Text('🌱 ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4E342E),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This plant is unlocked! Complete the flashcard set below to receive a seed and start planting 🌟',
              style: TextStyle(
                color: Color(0xFF6D4C41),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.requiredSetTitle ?? 'Any flashcard set',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Complete → get seed → plant',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to flashcard screen with requiredSetId
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7CB342),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Study Now',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── SeedSelectionSheet: unlocked + has seed → pick plot and plant ─────────
  void _showPlantSheet(BuildContext context) {
    if (item.linkedSeed == null) return;

    final seeds = [item.linkedSeed!];
    final defaultPlotIndex =
        emptyPlots.isNotEmpty ? emptyPlots.first.plotIndex : 0;

    SeedSelectionSheet.show(
      context: context,
      availableSeeds: seeds,
      plotIndex: defaultPlotIndex,
      onSeedSelected: (seed) {
        onPlant(defaultPlotIndex, seed);
      },
    );
  }
}

// ─── Card state sub-widgets ──────────────────────────────────────────────────

/// Label for locked plants: shows required flashcard set
class _LockedLabel extends StatelessWidget {
  final String? setTitle;
  const _LockedLabel({this.setTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5).withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📚', style: TextStyle(fontSize: 9)),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              setTitle != null ? _truncate(setTitle!, 10) : 'Study to unlock',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9C4DCC),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _truncate(String text, int max) =>
      text.length > max ? '${text.substring(0, max)}...' : text;
}

/// Label for unlocked plant with linked seed: shows flashcard set name
class _SeedLinkedLabel extends StatelessWidget {
  final SeedItem seed;
  const _SeedLinkedLabel({required this.seed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌱', style: TextStyle(fontSize: 9)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  _truncate(seed.title, 9),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF388E3C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Tap to plant',
          style: TextStyle(
            fontSize: 9,
            color: const Color(0xFF7CB342).withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _truncate(String text, int max) =>
      text.length > max ? '${text.substring(0, max)}...' : text;
}

/// Label for unlocked plant with no seed yet
class _NeedStudyLabel extends StatelessWidget {
  final String? setTitle;
  const _NeedStudyLabel({this.setTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFCC80), width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📖', style: TextStyle(fontSize: 9)),
          SizedBox(width: 3),
          Text(
            'Study needed',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: My Garden – vertical list ────────────────────────────────────────

class _MyGardenTab extends StatelessWidget {
  final List<GardenPlot> plots;
  const _MyGardenTab({required this.plots});

  static const _stageNames = [
    'Seed', 'Sprout', 'Seedling', 'Sapling', 'Flowering', 'Mature',
  ];
  static const _stageAssets = [
    'assets/game/tree/stage_0.png',
    'assets/game/tree/stage_1.png',
    'assets/game/tree/stage_2.png',
    'assets/game/tree/stage_3.png',
    'assets/game/tree/stage_4.png',
    'assets/game/tree/stage_5.png',
  ];
  static const _stageEmoji = ['🌰', '🌱', '🌿', '🪴', '🌸', '🍎'];

  @override
  Widget build(BuildContext context) {
    if (plots.isEmpty) return _buildEmpty();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: plots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _GardenListCard(
        plot: plots[i],
        index: i,
        stageNames: _stageNames,
        stageAssets: _stageAssets,
        stageEmoji: _stageEmoji,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🌾', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Your garden is empty!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap an empty plot in the garden\nor choose a plant from the shop to start 🌱',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF9E9E9E), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Garden list card ─────────────────────────────────────────────────────────

class _GardenListCard extends StatelessWidget {
  final GardenPlot plot;
  final int index;
  final List<String> stageNames;
  final List<String> stageAssets;
  final List<String> stageEmoji;

  const _GardenListCard({
    required this.plot,
    required this.index,
    required this.stageNames,
    required this.stageAssets,
    required this.stageEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final stage = plot.growthStage.clamp(0, 5);
    final isMastered = plot.status == PlotStatus.mastered;
    final progress = stage / 5.0;

    final stageColor = isMastered
        ? const Color(0xFFFFB300)
        : stage >= 4
            ? const Color(0xFF66BB6A)
            : stage >= 2
                ? const Color(0xFF7CB342)
                : const Color(0xFFA5D6A7);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMastered
              ? const Color(0xFFFFD54F)
              : const Color(0xFFE0D0BC),
          width: isMastered ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isMastered
                ? const Color(0xFFFFB300).withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Plant image ────────────────────────────────────
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isMastered
                    ? const Color(0xFFFFF9C4)
                    : const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMastered
                      ? const Color(0xFFFFD54F)
                      : const Color(0xFFDCEDC8),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    stageAssets[stage],
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      stageEmoji[stage],
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  if (plot.needsWater)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF29B6F6),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                            child: Text('💧',
                                style: TextStyle(fontSize: 10))),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // ── Details ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plot.setTitle ?? 'Vocab Plant #${index + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4E342E),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMastered)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFD54F).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 11, color: Color(0xFFE65100)),
                              SizedBox(width: 2),
                              Text(
                                'Mastered',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_florist_rounded,
                          size: 12, color: stageColor),
                      const SizedBox(width: 4),
                      Text(
                        stageNames[stage],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: stageColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          width: 1,
                          height: 10,
                          color: const Color(0xFFE0D0BC)),
                      const SizedBox(width: 10),
                      const Icon(Icons.grid_view_rounded,
                          size: 12, color: Color(0xFFBCAAA4)),
                      const SizedBox(width: 4),
                      Text(
                        'Plot #${plot.plotIndex + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBCAAA4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEEEEEE),
                            valueColor:
                                AlwaysStoppedAnimation(stageColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$stage/5',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: stageColor,
                        ),
                      ),
                    ],
                  ),
                  if (plot.needsWater) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF81D4FA), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('💧', style: TextStyle(fontSize: 10)),
                          SizedBox(width: 4),
                          Text(
                            'Needs Water',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0288D1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),
            _ActionButton(plot: plot),
          ],
        ),
      ),
    );
  }
}

// ─── Action button (right side of card) ──────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final GardenPlot plot;
  const _ActionButton({required this.plot});

  @override
  Widget build(BuildContext context) {
    if (plot.needsWater) {
      return _SmallBtn(
        emoji: '💧',
        label: 'Water',
        color: const Color(0xFF29B6F6),
        onTap: () => _showWaterSnack(context),
      );
    }
    if (plot.status == PlotStatus.mastered) {
      return _SmallBtn(
        emoji: '🏆',
        label: 'Harvest',
        color: const Color(0xFFFFB300),
        onTap: () {},
      );
    }
    return _SmallBtn(
      emoji: '🔍',
      label: 'View',
      color: const Color(0xFF7CB342),
      onTap: () {},
    );
  }

  void _showWaterSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Watered "${plot.setTitle ?? 'plant'}" 💧',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0288D1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _SmallBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Count badge ──────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB342),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}