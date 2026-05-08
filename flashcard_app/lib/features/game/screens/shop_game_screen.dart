// lib/features/game/screens/shop_game_screen.dart
//
// FIX CHÍNH:
//   • Background dùng BoxFit.cover + alignment: Alignment.topCenter
//     → ảnh giữ đúng tỉ lệ, không bị kéo méo
//   • Content padding ngang/dưới căn theo viền hoa của frame ảnh
//   • TabBar nằm sát awning, content scroll trong vùng kem trắng

import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/seed_selection_sheet.dart';
import 'package:flashcard_app/features/game/widgets/cute_notification_dialog.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
class _C {
  static const rose        = Color(0xFFF4A8B0);
  static const roseDark    = Color(0xFFD4717A);
  static const gold        = Color(0xFFFFD54F);
  static const goldDark    = Color(0xFFFFB300);
  static const goldText    = Color(0xFFE65100);
  static const green       = Color(0xFF7CB342);
  static const greenLight  = Color(0xFFE8F5E9);
  static const greenBdr    = Color(0xFFA5D6A7);
  static const purple      = Color(0xFF9C27B0);
  static const purpleLight = Color(0xFFF3E5F5);
  static const blue        = Color(0xFF29B6F6);
  static const blueLight   = Color(0xFFE1F5FE);
  static const textDark    = Color(0xFF4A2E25);
  static const textMid     = Color(0xFF6D4C41);
  static const textMuted   = Color(0xFFBCAAA4);
  static const textGreen   = Color(0xFF388E3C);
  static const textBlue    = Color(0xFF0288D1);
}

// ─── Shop model ───────────────────────────────────────────────────────────────
class ShopItem {
  final String imagePath;
  final String name;
  final bool isLocked;
  final int price;
  final String? requiredSetId;
  final String? requiredSetTitle;
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

  bool get isReadyToPlant   => !isLocked && linkedSeed != null;
  bool get isUnlockedNoSeed => !isLocked && linkedSeed == null;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ShopGameScreen extends StatefulWidget {
  final List<GardenPlot> plots;
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

  static final List<ShopItem> _shopItems = [
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
        subtitle: 'Plants, flowers, soil...',
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
        subtitle: 'Lotus, water lily...',
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
        subtitle: 'Scarlet, crimson...',
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
        subtitle: 'Joy, melancholy...',
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
        subtitle: 'Bloom, blossom...',
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
      requiredSetId: 'set_exotic_plants',
      requiredSetTitle: 'World Exotic Plants',
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

  List<GardenPlot> get _planted =>
      widget.plots.where((p) => p.status != PlotStatus.empty).toList();
  List<GardenPlot> get _empty =>
      widget.plots.where((p) => p.status == PlotStatus.empty).toList();

  void _onPlant(int idx, SeedItem seed) {
    widget.onPlantFromShop?.call(idx, seed);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('🌱', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Planted "${seed.title}" in Plot #${idx + 1}!',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
      backgroundColor: _C.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    // ── Ảnh nền tỉ lệ ~828×1690 portrait.
    // Mái hiên (awning): ~0–27% chiều cao ảnh
    // Viền hoa trái/phải: ~7% chiều rộng mỗi bên
    // Hoa góc dưới: ~13% chiều cao
    // Dùng MediaQuery để tính padding đúng trên mọi máy.
    final sidePad  = sw * 0.12;   
    final bottomPad = sh * 0.175; 
    final tabTopPad = sh * 0.13; 


    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/game/shop_bg1.png',
              fit: BoxFit.cover,              // ← KHÔNG kéo méo nữa
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFDE8D8), Color(0xFFF5EBD8)],
                  ),
                ),
              ),
            ),
          ),

          // ── 2. UI layer ─────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(onBack: () => Navigator.pop(context)),

                SizedBox(height: tabTopPad), 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  child: _TabBarWidget(
                    controller: _tab,
                    plantedCount: _planted.length,
                  ),
                ),

                const SizedBox(height: 4),

                // Content: scroll trong vùng kem của frame
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: sidePad,
                      right: sidePad,
                      bottom: bottomPad,
                    ),
                    child: TabBarView(
                      controller: _tab,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ShopTab(
                          items: _shopItems,
                          emptyPlots: _empty,
                          onPlant: _onPlant,
                        ),
                        _GardenTab(plots: _planted),
                      ],
                    ),
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

// ─── Top bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(color: _C.rose, width: 1.5),
                boxShadow: [BoxShadow(
                  color: _C.roseDark.withOpacity(0.20),
                  blurRadius: 8, offset: const Offset(0, 2),
                )],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.roseDark),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Flower Shop',
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900,
              color: _C.textDark, letterSpacing: -0.5,
              shadows: [Shadow(
                color: Color(0x44000000),
                blurRadius: 6, offset: Offset(0, 1),
              )],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: _C.gold,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _C.goldDark, width: 1.5),
              boxShadow: [BoxShadow(
                color: _C.goldDark.withOpacity(0.25),
                blurRadius: 8, offset: const Offset(0, 2),
              )],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⭐', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('350', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900,
                  color: _C.goldText,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ─────────────────────────────────────────────────────────────────
class _TabBarWidget extends StatelessWidget {
  final TabController controller;
  final int plantedCount;
  const _TabBarWidget({required this.controller, required this.plantedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.rose.withOpacity(0.70), width: 1.5),
      ),
      child: TabBar(
        controller: controller,
        labelColor: _C.textDark,
        unselectedLabelColor: _C.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        indicator: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.rose, width: 1.5),
          boxShadow: [BoxShadow(
            color: _C.roseDark.withOpacity(0.12),
            blurRadius: 6, offset: const Offset(0, 2),
          )],
        ),
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌸', style: TextStyle(fontSize: 14)),
              SizedBox(width: 5),
              Text('Shop'),
            ],
          )),
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪴', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              const Text('My Garden'),
              if (plantedCount > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _C.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$plantedCount', style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white,
                  )),
                ),
              ],
            ],
          )),
        ],
      ),
    );
  }
}

// ─── Shop tab ─────────────────────────────────────────────────────────────────
class _ShopTab extends StatelessWidget {
  final List<ShopItem> items;
  final List<GardenPlot> emptyPlots;
  final Function(int, SeedItem) onPlant;

  const _ShopTab({
    required this.items,
    required this.emptyPlots,
    required this.onPlant,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _PlantCard(
        item: items[i], emptyPlots: emptyPlots, onPlant: onPlant,
      ),
    );
  }
}

// ─── Plant card ───────────────────────────────────────────────────────────────
class _PlantCard extends StatelessWidget {
  final ShopItem item;
  final List<GardenPlot> emptyPlots;
  final Function(int, SeedItem) onPlant;
  const _PlantCard({required this.item, required this.emptyPlots, required this.onPlant});

  Color get _border => item.isLocked
      ? const Color(0xFFE0CCBF)
      : item.isReadyToPlant
          ? _C.greenBdr
          : const Color(0xFFEDD8C8);

  Color get _bg => item.isLocked
      ? Colors.white.withOpacity(0.72)
      : item.isReadyToPlant
          ? const Color(0xEEF4FAF0)
          : Colors.white.withOpacity(0.82);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _tap(context),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border,
              width: item.isReadyToPlant ? 1.8 : 1.2),
          boxShadow: [BoxShadow(
            color: item.isReadyToPlant
                ? _C.green.withOpacity(0.14)
                : Colors.black.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 58,
                  child: Center(
                    child: Opacity(
                      opacity: item.isLocked ? 0.38 : 1.0,
                      child: Image.asset(
                        item.imagePath, width: 56, height: 56,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Text('🌱', style: TextStyle(fontSize: 38)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.2,
                    color: item.isLocked ? _C.textMuted : _C.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.isLocked)
                  _Chip(icon: '📚',
                    label: _cut(item.requiredSetTitle ?? 'Unlock', 10),
                    bg: _C.purpleLight, fg: _C.purple)
                else if (item.isReadyToPlant) ...[
                  _Chip(icon: '🌱',
                    label: _cut(item.linkedSeed!.title, 9),
                    bg: _C.greenLight, fg: _C.textGreen, border: _C.greenBdr),
                  // const SizedBox(height: 3),
                  // Text('Tap to plant', style: TextStyle(
                  //   fontSize: 9, fontWeight: FontWeight.w700,
                  //   color: _C.green.withOpacity(0.85),
                  // )),
                ] else if (item.isUnlockedNoSeed)
                  _Chip(icon: '📖', label: 'Study needed',
                    bg: const Color(0xFFFFF3E0),
                    fg: const Color(0xFFE65100),
                    border: const Color(0xFFFFCC80))
                else
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('⭐', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Text('${item.price}', style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: _C.goldText,
                    )),
                  ]),
              ],
            ),
          ),
          // Corner badge
          Positioned(top: 6, right: 6, child: _cornerBadge()),
        ]),
      ),
    );
  }

  String _cut(String s, int n) => s.length > n ? '${s.substring(0, n)}…' : s;

  Widget _cornerBadge() {
    if (item.isLocked) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
        child: const Icon(Icons.lock_rounded, size: 11, color: Colors.white),
      );
    }
    if (item.isReadyToPlant) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(color: _C.green, shape: BoxShape.circle),
        child: const Icon(Icons.eco_rounded, size: 11, color: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }

  void _tap(BuildContext ctx) {
    if (item.isLocked)            _lockedDialog(ctx);
    else if (item.isReadyToPlant) _plantSheet(ctx);
    else if (item.isUnlockedNoSeed) _studyDialog(ctx);
  }

  void _lockedDialog(BuildContext ctx) => CuteNotificationDialog.show(
    context: ctx,
    icon: '🔒', title: 'Locked',
    body: 'Complete this flashcard set to unlock "${item.name}":',
    setTitle: item.requiredSetTitle,
    setBg: _C.purpleLight, setBorder: const Color(0xFFCE93D8),
    setTitleColor: const Color(0xFF6A1B9A),
    setSub: 'View all cards + pass the quiz', setSubColor: _C.purple,
    onStudy: () => Navigator.pop(ctx),
  );

  void _studyDialog(BuildContext ctx) => CuteNotificationDialog.show(
    context: ctx,
    icon: '🌱', title: item.name,
    body: 'Unlocked! Complete the set below to receive a seed 🌟',
    setTitle: item.requiredSetTitle,
    setBg: _C.greenLight, setBorder: _C.greenBdr,
    setTitleColor: const Color(0xFF2E7D32),
    setSub: 'Complete → get seed → plant', setSubColor: _C.textGreen,
    onStudy: () => Navigator.pop(ctx),
  );

  void _plantSheet(BuildContext ctx) {
    if (item.linkedSeed == null) return;
    final idx = emptyPlots.isNotEmpty ? emptyPlots.first.plotIndex : 0;
    SeedSelectionSheet.show(
      context: ctx,
      availableSeeds: [item.linkedSeed!],
      plotIndex: idx,
      onSeedSelected: (seed) => onPlant(idx, seed),
    );
  }
}

// ─── Small chip ───────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String icon, label;
  final Color bg, fg;
  final Color? border;
  const _Chip({required this.icon, required this.label,
    required this.bg, required this.fg, this.border});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(7),
      border: border != null ? Border.all(color: border!, width: 0.8) : null,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 9)),
      const SizedBox(width: 3),
      Flexible(child: Text(label, style: TextStyle(
        fontSize: 9, fontWeight: FontWeight.w800, color: fg,
      ), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]),
  );
}

// ─── My Garden tab ────────────────────────────────────────────────────────────
class _GardenTab extends StatelessWidget {
  final List<GardenPlot> plots;
  const _GardenTab({required this.plots});

  static const _stageNames  = ['Seed','Sprout','Seedling','Sapling','Flowering','Mature'];
  static const _stageAssets = [
    'assets/game/tree/stage_0.png','assets/game/tree/stage_1.png',
    'assets/game/tree/stage_2.png','assets/game/tree/stage_3.png',
    'assets/game/tree/stage_4.png','assets/game/tree/stage_5.png',
  ];
  static const _stageEmoji = ['🌰','🌱','🌿','🪴','🌸','🍎'];

  @override
  Widget build(BuildContext context) {
    if (plots.isEmpty) return _emptyState();
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: plots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _GardenCard(
        plot: plots[i], index: i,
        stageNames: _stageNames,
        stageAssets: _stageAssets,
        stageEmoji: _stageEmoji,
      ),
    );
  }

  Widget _emptyState() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          shape: BoxShape.circle,
          border: Border.all(color: _C.rose, width: 2),
        ),
        child: const Center(child: Text('🌾', style: TextStyle(fontSize: 40))),
      ),
      const SizedBox(height: 14),
      const Text('Your garden is empty!', style: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w900, color: _C.textDark,
      )),
      const SizedBox(height: 8),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text('Go to Shop and plant\nyour first flower! 🌱',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _C.textMid, height: 1.6),
        ),
      ),
    ],
  ));
}

// ─── Garden card ─────────────────────────────────────────────────────────────
class _GardenCard extends StatelessWidget {
  final GardenPlot plot;
  final int index;
  final List<String> stageNames, stageAssets, stageEmoji;

  const _GardenCard({
    required this.plot, required this.index,
    required this.stageNames, required this.stageAssets, required this.stageEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final stage    = plot.growthStage.clamp(0, 5);
    final isMaster = plot.status == PlotStatus.mastered;
    final progress = stage / 5.0;
    final stageColor = isMaster ? _C.goldDark
        : stage >= 4 ? const Color(0xFF66BB6A)
        : stage >= 2 ? _C.green : _C.greenBdr;

    return Container(
      decoration: BoxDecoration(
        color: isMaster
            ? const Color(0xF5FFFBF0)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMaster ? _C.gold : _C.rose.withOpacity(0.45),
          width: isMaster ? 2.0 : 1.2,
        ),
        boxShadow: [BoxShadow(
          color: isMaster
              ? _C.goldDark.withOpacity(0.12)
              : Colors.black.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 3),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          // Thumbnail
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(
              color: isMaster ? const Color(0xFFFFF9C4) : _C.greenLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isMaster ? _C.gold : _C.greenBdr, width: 1.4,
              ),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(stageAssets[stage], width: 42, height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Text(stageEmoji[stage], style: const TextStyle(fontSize: 30)),
              ),
              if (plot.needsWater)
                Positioned(top: 3, right: 3,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: _C.blue, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(child: Text('💧', style: TextStyle(fontSize: 8))),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(
                  plot.setTitle ?? 'Plant #${index + 1}',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w900, color: _C.textDark,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
                if (isMaster)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _C.gold.withOpacity(0.90),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star_rounded, size: 11, color: _C.goldText),
                      SizedBox(width: 2),
                      Text('Mastered', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: _C.goldText,
                      )),
                    ]),
                  ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.local_florist_rounded, size: 12, color: stageColor),
                const SizedBox(width: 4),
                Text(stageNames[stage], style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: stageColor,
                )),
                const SizedBox(width: 8),
                Container(width: 1, height: 10, color: _C.textMuted.withOpacity(0.4)),
                const SizedBox(width: 8),
                Text('Plot #${plot.plotIndex + 1}', style: const TextStyle(
                  fontSize: 12, color: _C.textMuted, fontWeight: FontWeight.w600,
                )),
              ]),
              const SizedBox(height: 7),
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress, minHeight: 7,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation(stageColor),
                  ),
                )),
                const SizedBox(width: 8),
                Text('$stage/5', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: stageColor,
                )),
              ]),
              if (plot.needsWater) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.blueLight,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFF81D4FA), width: 1),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('💧', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 4),
                    Text('Needs Water', style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: _C.textBlue,
                    )),
                  ]),
                ),
              ],
            ],
          )),

          const SizedBox(width: 8),
          _ActionBtn(plot: plot),
        ]),
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final GardenPlot plot;
  const _ActionBtn({required this.plot});

  @override
  Widget build(BuildContext context) {
    if (plot.needsWater) return _MiniBtn(emoji: '💧', label: 'Water',
      color: _C.blue, onTap: () => _snack(context, '💧 Watered!', _C.blue));
    if (plot.status == PlotStatus.mastered) return _MiniBtn(
      emoji: '🏆', label: 'Harvest', color: _C.goldDark, onTap: () {});
    return _MiniBtn(emoji: '🔍', label: 'View', color: _C.green, onTap: () {});
  }

  void _snack(BuildContext ctx, String msg, Color c) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: c, behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ));
}

class _MiniBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _MiniBtn({required this.emoji, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.40), width: 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w800, color: color,
        )),
      ]),
    ),
  );
}

// ─── Shared dialog ────────────────────────────────────────────────────────────
class _FlowerDialog extends StatelessWidget {
  final String icon, title, body, setSub;
  final String? setTitle;
  final Color setBg, setBorder, setTitleColor, setSubColor;
  final VoidCallback onStudy;

  const _FlowerDialog({
    required this.icon, required this.title, required this.body,
    required this.setTitle, required this.setBg, required this.setBorder,
    required this.setTitleColor, required this.setSub, required this.setSubColor,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFFFDF4EC),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 4, margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: _C.rose, borderRadius: BorderRadius.circular(4))),
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(
          fontWeight: FontWeight.w900, fontSize: 16, color: _C.textDark,
        ))),
      ]),
    ]),
    content: Column(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(body, style: const TextStyle(color: _C.textMid, fontSize: 13, height: 1.5)),
      const SizedBox(height: 14),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: setBg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: setBorder, width: 1.2),
        ),
        child: Row(children: [
          const Text('📚', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(setTitle ?? 'Flashcard set', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w900, color: setTitleColor,
            )),
            const SizedBox(height: 2),
            Text(setSub, style: TextStyle(fontSize: 11, color: setSubColor)),
          ])),
        ]),
      ),
    ]),
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Later', style: TextStyle(
          color: _C.textMuted, fontWeight: FontWeight.w700,
        )),
      ),
      ElevatedButton.icon(
        onPressed: onStudy,
        icon: const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white),
        label: const Text('Study Now', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w800,
        )),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.green, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ],
  );
}