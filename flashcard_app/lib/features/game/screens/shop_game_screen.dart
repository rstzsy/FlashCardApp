import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/seed_selection_sheet.dart';
import 'package:flashcard_app/features/game/widgets/cute_notification_dialog.dart';
import 'package:flashcard_app/features/game/data/shop_data.dart';
import 'package:flashcard_app/features/game/services/garden_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class ShopItem {
  final String imagePath;
  final String name;
  final bool isLocked;
  final int price;
  final String? requiredSetId;
  final String? requiredSetTitle;
  final SeedItem? linkedSeed;
  final bool userHasSeed;
  final bool userHasPlanted;
  final bool userHasHarvested;

  const ShopItem({
    required this.imagePath,
    required this.name,
    this.isLocked = true,
    this.price = 0,
    this.requiredSetId,
    this.requiredSetTitle,
    this.linkedSeed,
    this.userHasSeed      = false,
    this.userHasPlanted   = false,
    this.userHasHarvested = false,
  });

  bool get isReadyToPlant   => !isLocked && userHasSeed && !userHasPlanted && !userHasHarvested;
  bool get isUnlockedNoSeed => !isLocked && !userHasSeed && !userHasPlanted && !userHasHarvested;

  ShopItem copyWith({
    bool? isLocked,
    bool? userHasSeed,
    bool? userHasPlanted,
    bool? userHasHarvested,
    SeedItem? linkedSeed,
  }) => ShopItem(
    imagePath:        imagePath,
    name:             name,
    isLocked:         isLocked         ?? this.isLocked,
    price:            price,
    requiredSetId:    requiredSetId,
    requiredSetTitle: requiredSetTitle,
    linkedSeed:       linkedSeed       ?? this.linkedSeed,
    userHasSeed:      userHasSeed      ?? this.userHasSeed,
    userHasPlanted:   userHasPlanted   ?? this.userHasPlanted,
    userHasHarvested: userHasHarvested ?? this.userHasHarvested,
  );
}

class ShopGameScreen extends StatefulWidget {
  final List<GardenPlot> plots;
  final List<SeedItem>   userSeeds;
  final Function(int plotIndex, SeedItem seed)? onPlantFromShop;

  const ShopGameScreen({
    super.key,
    required this.plots,
    required this.userSeeds,
    this.onPlantFromShop,
  });

  @override
  State<ShopGameScreen> createState() => _ShopGameScreenState();
}

class _ShopGameScreenState extends State<ShopGameScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tab;
  final GardenService    _gardenService = GardenService();
  final FirebaseFirestore _db           = FirebaseFirestore.instance;

  List<GardenPlot> _gardenPlots  = [];
  List<SeedItem>   _allUserSeeds = [];
  int              _totalStars   = 0;
  bool             _gardenLoading = true;

  Set<String> _plantedSetIds   = {};   
  Set<String> _harvestedSetIds = {};  
  StreamSubscription? _gardenSub;
  StreamSubscription? _seedsSub;
  StreamSubscription? _harvestedSub;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _initStreams();
  }

  void _initStreams() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _gardenLoading = false);
      return;
    }

    _gardenSub = _db
        .collection('WordGardenTrees')
        .where('UserId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      final plots = List.generate(9, (i) => GardenPlot(plotIndex: i));
      final plantedIds = <String>{};

      for (final doc in snap.docs) {
        final data        = doc.data();
        final plotIndex   = (data['PlotIndex']   as int?)  ?? 0;
        final growthStage = (data['GrowthStage'] as int?)  ?? 0;
        final isMastered  = (data['IsMastered']  as bool?) ?? false;
        final setId       = data['SetId'] as String?;

        if (plotIndex < 0 || plotIndex >= 9) continue;
        if (setId != null && setId.isNotEmpty) plantedIds.add(setId);

        plots[plotIndex] = GardenPlot(
          plotIndex:   plotIndex,
          status:      isMastered ? PlotStatus.mastered : PlotStatus.planted,
          treeId:      doc.id,
          setId:       setId,
          setTitle:    data['SetTitle']  as String?,
          plantName:   data['PlantName'] as String?,
          imagePath:   data['ImagePath'] as String?,
          growthStage: growthStage.clamp(0, 5),
          isMastered:  isMastered,
          lastWatered: (data['LastWatered'] as Timestamp?)?.toDate(),
          canFertilize: data['LastWatered'] != null && growthStage >= 1,
        );
      }

      if (mounted) setState(() {
        _gardenPlots   = plots.where((p) => p.status != PlotStatus.empty).toList();
        _plantedSetIds = plantedIds;
        _gardenLoading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _gardenLoading = false);
    });

    _seedsSub = _db
        .collection('UserSeeds')
        .where('UserId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      final seeds = snap.docs.map((doc) {
        final data = doc.data();
        return SeedItem(
          setId:          data['SetId']     as String? ?? '',
          title:          data['PlantName'] as String? ?? '',
          totalCards:     0,
          difficulty:     'Easy',
          imagePath:      data['ImagePath'] as String?,
          seedDocId:      doc.id,
          alreadyPlanted: (data['IsPlanted'] as bool?) ?? false,
        );
      }).toList();
      if (mounted) setState(() => _allUserSeeds = seeds);
    });

    _harvestedSub = _db
        .collection('HarvestedPlants')
        .where('UserId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      final ids = snap.docs
          .map((d) => (d.data()['SetId'] as String? ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (mounted) setState(() => _harvestedSetIds = ids);
    });

    _loadStars(uid);
  }

  Future<void> _loadStars(String uid) async {
    try {
      final resources = await _gardenService.loadUserResources(uid);
      if (mounted) setState(() => _totalStars = resources['stars'] ?? 0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _gardenSub?.cancel();
    _seedsSub?.cancel();
    _harvestedSub?.cancel();
    _tab.dispose();
    super.dispose();
  }

  Set<String> get _inTraySetIds {
    final planted   = _plantedSetIds;
    final harvested = _harvestedSetIds;
    return widget.userSeeds
        .map((s) => s.setId)
        .where((id) => !planted.contains(id) && !harvested.contains(id))
        .toSet();
  }

  List<ShopItem> get _mergedItems {
    final inTraySetIds = _inTraySetIds;
    final seedMap = <String, SeedItem>{
      for (final s in widget.userSeeds) s.setId: s,
    };

    final unlockedItems = _allUserSeeds.map((seed) {
      final hasHarvested = _harvestedSetIds.contains(seed.setId);
      final hasPlanted   = !hasHarvested && _plantedSetIds.contains(seed.setId);
      final hasSeed      = !hasHarvested && !hasPlanted && inTraySetIds.contains(seed.setId);

      return ShopItem(
        imagePath:        seed.imagePath ?? 'assets/game/tulip.png',
        name:             seed.title,
        isLocked:         false,
        price:            0,
        requiredSetId:    seed.setId,
        userHasSeed:      hasSeed,
        userHasPlanted:   hasPlanted,
        userHasHarvested: hasHarvested,
        linkedSeed:       hasSeed ? seedMap[seed.setId] : null,
      );
    }).toList();

    final receivedNames = _allUserSeeds.map((s) => s.title).toSet();

    final lockedItems = kShopItems
        .where((item) => !receivedNames.contains(item.name))
        .map((item) => item.copyWith(
              isLocked:       true,
              userHasSeed:    false,
              userHasPlanted: false,
              userHasHarvested: false,
              linkedSeed:     null,
            ))
        .toList();

    unlockedItems.sort((a, b) {
      int score(ShopItem x) {
        if (x.userHasHarvested) return 0;
        if (x.userHasPlanted)   return 1;
        if (x.userHasSeed)      return 2;
        return 3;
      }
      return score(a).compareTo(score(b));
    });

    return [...unlockedItems, ...lockedItems];
  }

  List<GardenPlot> get _emptyPlots =>
      widget.plots.where((p) => p.status == PlotStatus.empty).toList();

  void _onPlant(int idx, SeedItem seed) {
    if (!mounted) return;
    widget.onPlantFromShop?.call(idx, seed);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('🌱', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Planted "${seed.title}" in Plot #${idx + 1}!',
          style: const TextStyle(fontWeight: FontWeight.w700),
        )),
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
    final mq        = MediaQuery.of(context);
    final sw        = mq.size.width;
    final sh        = mq.size.height;
    final sidePad   = sw * 0.12;
    final bottomPad = sh * 0.175;
    final tabTopPad = sh * 0.13;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/game/shop_bg1.png',
            fit: BoxFit.cover,
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
        SafeArea(
          bottom: false,
          child: Column(children: [
            _TopBar(onBack: () => Navigator.pop(context), stars: _totalStars),
            SizedBox(height: tabTopPad),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePad),
              child: _TabBarWidget(
                controller: _tab,
                plantedCount: _gardenPlots.length,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: sidePad, right: sidePad, bottom: bottomPad,
                ),
                child: TabBarView(
                  controller: _tab,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ShopTab(
                      items:      _mergedItems,
                      emptyPlots: _emptyPlots,
                      onPlant:    _onPlant,
                    ),
                    _gardenLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _GardenTab(plots: _gardenPlots),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}


class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final int stars;
  const _TopBar({required this.onBack, this.stars = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(children: [
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
              color: Color(0x44000000), blurRadius: 6, offset: Offset(0, 1),
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
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⭐', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text('$stars', style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, color: _C.goldText,
            )),
          ]),
        ),
      ]),
    );
  }
}

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

class _ShopTab extends StatelessWidget {
  final List<ShopItem>   items;
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
        crossAxisCount:    3,
        mainAxisSpacing:   10,
        crossAxisSpacing:  10,
        childAspectRatio:  0.68,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _PlantCard(
        item: items[i], emptyPlots: emptyPlots, onPlant: onPlant,
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final ShopItem         item;
  final List<GardenPlot> emptyPlots;
  final Function(int, SeedItem) onPlant;

  const _PlantCard({
    required this.item,
    required this.emptyPlots,
    required this.onPlant,
  });

  Color get _border {
    if (item.userHasHarvested) return Colors.amber.withOpacity(0.6);
    if (item.isLocked)         return const Color(0xFFE0CCBF);
    if (item.isReadyToPlant)   return _C.greenBdr;
    return const Color(0xFFEDD8C8);
  }

  Color get _bg {
    if (item.userHasHarvested) return const Color(0xFFFFF8E1).withOpacity(0.7);
    if (item.isLocked)         return Colors.white.withOpacity(0.72);
    if (item.isReadyToPlant)   return const Color(0xEEF4FAF0);
    return Colors.white.withOpacity(0.82);
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: item.userHasHarvested,
      child: GestureDetector(
        onTap: () => _tap(context),
        child: Opacity(
          opacity: item.userHasHarvested ? 0.60 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _border,
                width: item.userHasHarvested ? 2.0
                     : item.isReadyToPlant   ? 1.8
                     : 1.2,
              ),
              boxShadow: item.userHasHarvested
                  ? [BoxShadow(
                      color: Colors.amber.withOpacity(0.15),
                      blurRadius: 8, offset: const Offset(0, 2),
                    )]
                  : null,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: item.isLocked ? 0.38 : 1.0,
                              child: Image.asset(
                                item.imagePath,
                                width: 56, height: 56,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Text('🌱', style: TextStyle(fontSize: 38)),
                              ),
                            ),
                            if (item.userHasHarvested)
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: _C.gold,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [BoxShadow(
                                      color: _C.goldDark.withOpacity(0.4),
                                      blurRadius: 4,
                                    )],
                                  ),
                                  child: const Center(
                                    child: Text('👑', style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.2,
                        color: item.isLocked        ? _C.textMuted
                             : item.userHasHarvested ? _C.goldText
                             : _C.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    if (item.userHasHarvested)
                      _Chip(
                        icon: '👑', label: 'Harvested',
                        bg: const Color(0xFFFFF3CD),
                        fg: _C.goldText,
                        border: _C.gold,
                      )
                    else if (item.userHasPlanted)
                      _Chip(
                        icon: '🌳', label: 'Growing',
                        bg: _C.greenLight, fg: _C.textGreen, border: _C.greenBdr,
                      )
                    else if (item.userHasSeed)
                      _Chip(
                        icon: '🌱', label: 'In tray',
                        bg: const Color(0xFFFFF3E0),
                        fg: const Color(0xFFE65100),
                        border: const Color(0xFFFFCC80),
                      )
                    else if (!item.isLocked)
                      _Chip(
                        icon: '🌰', label: 'No seed',
                        bg: _C.blueLight, fg: _C.textBlue,
                      )
                    else
                      _Chip(
                        icon: '🔒', label: 'Not received',
                        bg: _C.purpleLight, fg: _C.purple,
                      ),
                  ],
                ),
              ),

              Positioned(top: 6, right: 6, child: _cornerBadge()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _cornerBadge() {
    if (item.userHasHarvested) {
      return Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: _C.goldDark,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: _C.goldDark.withOpacity(0.4), blurRadius: 4,
          )],
        ),
        child: const Center(
          child: Text('👑', style: TextStyle(fontSize: 10)),
        ),
      );
    }
    if (item.userHasSeed) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(
          color: Color(0xFFFFA726), shape: BoxShape.circle,
        ),
        child: const Icon(Icons.inventory_2_rounded, size: 11, color: Colors.white),
      );
    }
    if (item.isLocked) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(
          color: Color(0x99000000), shape: BoxShape.circle,
        ),
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
    if (item.isLocked)              _lockedDialog(ctx);
    else if (item.isReadyToPlant)   _plantSheet(ctx);
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

class _Chip extends StatelessWidget {
  final String icon, label;
  final Color bg, fg;
  final Color? border;
  const _Chip({
    required this.icon, required this.label,
    required this.bg,   required this.fg,
    this.border,
  });

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

class _GardenTab extends StatelessWidget {
  final List<GardenPlot> plots;
  const _GardenTab({required this.plots});

  static const _stageNames  = ['Seed','Sprout','Seedling','Sapling','Flowering','Mature'];
  static const _stageAssets = [
    'assets/game/tree/stage_0.png', 'assets/game/tree/stage_1.png',
    'assets/game/tree/stage_2.png', 'assets/game/tree/stage_3.png',
    'assets/game/tree/stage_4.png', 'assets/game/tree/stage_5.png',
  ];
  static const _stageEmoji  = ['🌰','🌱','🌿','🪴','🌸','🍎'];

  @override
  Widget build(BuildContext context) {
    if (plots.isEmpty) return _emptyState();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i.isOdd) return const SizedBox(height: 10);
                final idx = i ~/ 2;
                return _GardenCard(
                  plot:        plots[idx],
                  index:       idx,
                  stageNames:  _stageNames,
                  stageAssets: _stageAssets,
                  stageEmoji:  _stageEmoji,
                );
              },
              childCount: plots.length * 2 - 1,
            ),
          ),
        ),
      ],
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
        child: Text(
          'Plant your first flower\nfrom the Shop tab! 🌱',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _C.textMid, height: 1.6),
        ),
      ),
    ],
  ));
}

class _GardenCard extends StatelessWidget {
  final GardenPlot plot;
  final int index;
  final List<String> stageNames, stageAssets, stageEmoji;

  const _GardenCard({
    required this.plot,  required this.index,
    required this.stageNames, required this.stageAssets, required this.stageEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final stage      = plot.growthStage.clamp(0, 5);
    final isMaster   = plot.status == PlotStatus.mastered;
    final progress   = stage / 5.0;
    final stageColor = isMaster             ? _C.goldDark
                     : stage >= 4           ? const Color(0xFF66BB6A)
                     : stage >= 2           ? _C.green
                     : _C.greenBdr;

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
              Image.asset(
                plot.imagePath ?? stageAssets[stage],
                width: 42, height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  stageAssets[stage],
                  width: 42, height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    stageEmoji[stage],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              if (plot.needsWater)
                Positioned(
                  top: 3, right: 3,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: _C.blue, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('💧', style: TextStyle(fontSize: 8)),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 12),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(
                  plot.plantName ?? plot.setTitle ?? 'Plant #${index + 1}',
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

class _ActionBtn extends StatefulWidget {
  final GardenPlot plot;
  const _ActionBtn({required this.plot});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _harvesting = false;
  final GardenService _gardenService = GardenService();

  void _snack(String msg, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _doHarvest() async {
    final plot = widget.plot;
    final uid  = FirebaseAuth.instance.currentUser?.uid;
    if (_harvesting || plot.treeId == null || uid == null) return;

    setState(() => _harvesting = true);
    try {
      await _gardenService.harvestTree(
        userId:    uid,
        treeId:    plot.treeId!,
        plantName: plot.plantName ?? plot.setTitle ?? 'Unknown',
        imagePath: plot.imagePath ?? '',
        setId:     plot.setId ?? '',          
      );
      if (mounted) _snack('👑 Harvested ${plot.plantName ?? "plant"}!', _C.goldDark);
    } catch (e) {
      if (mounted) _snack('❌ Harvest failed. Try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _harvesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plot = widget.plot;

    if (plot.needsWater) {
      return _MiniBtn(
        imageAsset: 'assets/game/watering_can.png',
        label: 'Water',
        color: _C.blue,
        onTap: () => _snack('💧 Watered!', _C.blue),
      );
    }

    if (plot.status == PlotStatus.mastered) {
      return _MiniBtn(
        emoji: _harvesting ? '⏳' : '👑',
        label: _harvesting ? '...' : 'Harvest',
        color: _C.goldDark,
        onTap: _harvesting ? () {} : _doHarvest,
      );
    }

    return _MiniBtn(emoji: '🔍', label: 'View', color: _C.green, onTap: () {});
  }
}

class _MiniBtn extends StatelessWidget {
  final String?   emoji;
  final String?   imageAsset;
  final String    label;
  final Color     color;
  final VoidCallback onTap;

  const _MiniBtn({
    this.emoji,
    this.imageAsset,
    required this.label,
    required this.color,
    required this.onTap,
  });

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
        if (imageAsset != null)
          Image.asset(imageAsset!, width: 24, height: 24, fit: BoxFit.contain)
        else
          Text(emoji ?? '', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w800, color: color,
        )),
      ]),
    ),
  );
}