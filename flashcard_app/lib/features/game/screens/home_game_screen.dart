import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/services/garden_service.dart';
import 'package:flashcard_app/features/game/services/word_garden_service.dart';
import 'package:flashcard_app/features/game/widgets/draggable_seed_tray.dart';
import 'package:flashcard_app/features/game/widgets/planting_tray.dart';
import 'package:flashcard_app/features/game/widgets/player_game.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';
import 'package:flashcard_app/features/game/widgets/garden_tool_tray.dart';
import 'package:flashcard_app/features/game/models/harvest_achievement_models.dart';
import 'package:flashcard_app/core/widgets/app_popup.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';

class HomeGameScreen extends StatefulWidget {
  const HomeGameScreen({super.key});

  @override
  State<HomeGameScreen> createState() => _HomeGameScreenState();
}

class _HomeGameScreenState extends State<HomeGameScreen> {
  final PlayerGame        _playerGame        = PlayerGame();
  final GardenService     _gardenService     = GardenService();
  final WordGardenService _wordGardenService = WordGardenService();

  int? _selectedPlotIndex;
  bool _isLoading = true;
  int? _harvestingPlotIndex;

  List<GardenPlot> _plots = List.generate(
    GardenService.kMaxPlots, (i) => GardenPlot(plotIndex: i),
  );
  List<SeedItem> _userSeeds = [];

  int _waterCount      = 0;
  int _fertilizerCount = 0;
  int _totalStars      = 0;

  @override
  void initState() {
    super.initState();
    _loadGarden();
  }

  Future<void> _loadGarden() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _isLoading = false); return; }

    try {
      final plots     = await _gardenService.loadGardenPlots(uid);
      final seeds     = await _gardenService.loadUserSeeds(uid);
      final resources = await _gardenService.loadUserResources(uid);

      if (mounted) setState(() {
        _plots           = plots;
        _userSeeds       = seeds;
        _waterCount      = resources['water']      ?? 0;
        _fertilizerCount = resources['fertilizer'] ?? 0;
        _totalStars      = resources['stars']      ?? 0;
        _isLoading       = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<SeedItem> get _seedsWithStatus  => _userSeeds;
  List<SeedItem> get _plantableSeeds   =>
      _userSeeds.where((s) => !s.alreadyPlanted).toList();

  void _onPlotTapped(int i) {
    final plot = _plots[i];

    if (plot.status == PlotStatus.mastered) {
      _harvestPlot(i);
      return;
    }

    if (plot.status == PlotStatus.empty) {
      setState(() => _selectedPlotIndex = i);
    }
  }

  Future<void> _harvestPlot(int i) async {
    final plot = _plots[i];
    final uid  = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || plot.treeId == null) return;
  
    setState(() => _harvestingPlotIndex = i);
  
    await Future.delayed(const Duration(milliseconds: 1200));
  
    final newAchievement = await _gardenService.harvestTree(
      userId:    uid,
      treeId:    plot.treeId!,
      plantName: plot.plantName ?? plot.setTitle ?? '',
      imagePath: plot.imagePath ?? '',
      setId:     plot.setId ?? '',
    );
  
    final harvestedName = plot.plantName ?? plot.setTitle ?? '';
  
    if (mounted) setState(() {
      _plots[i]            = GardenPlot(plotIndex: i);
      _harvestingPlotIndex = null;
    });
  
    if (!mounted) return;
  
    if (newAchievement != null) {
      _showHarvestAchievementPopup(newAchievement, harvestedName);
    } else {
      _showToast('Harvested "$harvestedName" successfully! 🌸', const Color(0xFFFFB300));
    }
  }

  void _showHarvestAchievementPopup(
    HarvestAchievement achievement,
    String harvestedPlantName,
  ) {
    AppPopup.show(
      context: context,
      title: "New Badge! 🎉",
      message:
          "You harvested \"$harvestedPlantName\" and just unlocked\n"
          "the \"${achievement.title}\" badge for ${achievement.threshold} harvests!",
      iconWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(achievement.imagePath, width: 120, height: 120),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A3333),
            ),
          ),
        ],
      ),
      buttonText: "Awesome!",
      showConfetti: true,
      onPressed: () {
      },
    );
  }

  void _onSeedDropped(int i, SeedItem seed) {
    if (!seed.alreadyPlanted) _plantSeed(i, seed);
  }

  void _onToolDropped(int plotIndex, GardenTool tool) {
    if (!mounted) return;
    final plot = _plots[plotIndex];
    if (plot.status != PlotStatus.planted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    switch (tool) {
      case GardenTool.water:
        if (_waterCount <= 0) {
          _showToast('No water left! 💧', const Color(0xFF0288D1));
          return;
        }
        setState(() {
          _waterCount--;
          _plots[plotIndex] = _plots[plotIndex].copyWith(
            lastWatered:  DateTime.now(),
            canFertilize: true,
            wateredAtCurrentStage: true,
          );
        });
        if (plot.treeId != null) _gardenService.waterTree(plot.treeId!);
        if (uid != null) _gardenService.deductResource(userId: uid, type: 'water');
        _showToast('Watered "${plot.plantName ?? plot.setTitle}" 💧', const Color(0xFF0288D1));

      case GardenTool.fertilizer:
        if (_fertilizerCount <= 0) {
          _showToast('No fertilizer left! 🌿', const Color(0xFF388E3C));
          return;
        }

        if (!plot.wateredAtCurrentStage) {
          _showToast(
            'Water the plant before fertilizing! 💧',
            const Color(0xFF0288D1),
          );
          return;
        }

        final newStage = (_plots[plotIndex].growthStage + 1).clamp(0, 5);
        setState(() {
          _fertilizerCount--;
          _plots[plotIndex] = _plots[plotIndex].copyWith(
            growthStage:           newStage,
            wateredAtCurrentStage: false, 
            status: newStage >= 5 ? PlotStatus.mastered : PlotStatus.planted,
          );
        });

        if (plot.treeId != null) {
          _gardenService.updateGrowthStage(
            treeId: plot.treeId!,
            stage:  newStage,
          );
        }
        if (uid != null) _gardenService.deductResource(userId: uid, type: 'fertilizer');
        _showToast('Fertilized "${plot.plantName ?? plot.setTitle}" 🌿', const Color(0xFF388E3C));
    }
  }

  void _plantSeed(int i, SeedItem seed) {
    setState(() {
      _selectedPlotIndex = null;
      _plots[i] = _plots[i].copyWith(
        status:      PlotStatus.planted,
        setId:       seed.setId,
        setTitle:    seed.title,
        plantName:   seed.title,
        imagePath:   seed.imagePath,
        growthStage: 0,
        lastWatered: DateTime.now(),
      );

      _userSeeds = _userSeeds
          .where((s) => s.setId != seed.setId)
          .toList();
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && seed.seedDocId != null) {
      _wordGardenService.plantSeedToPlot(
        userId:    uid,
        setId:     seed.setId,
        plantName: seed.title,
        imagePath: seed.imagePath ?? '',
        seedDocId: seed.seedDocId!,
        plotIndex: i,
      );
    }

    _showToast('Planted "${seed.title}" 🌱', const Color(0xFF558B2F));
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    final trayOpen = _selectedPlotIndex != null;

    if (_isLoading) {
      return const Scaffold(
        body: Stack(children: [
          Positioned.fill(child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/game/home_game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          )),
          Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          )),
        ]),
      );
    }

    return Scaffold(
      body: Stack(children: [

        Container(decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game/home_game_bg.png'),
            fit: BoxFit.cover,
          ),
        )),

        if (trayOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlotIndex = null),
              behavior: HitTestBehavior.translucent,
            ),
          ),

        Stack(
          children: [
            DroppableGardenPlots(
              plots:         _plots,
              onPlotTapped:  _onPlotTapped,
              onSeedDropped: _onSeedDropped,
              onToolDropped: _onToolDropped,
            ),

            if (_harvestingPlotIndex != null)
              _HarvestEffect(
                plotIndex: _harvestingPlotIndex!,
                onComplete: () {},
              ),
          ],
        ),

        Positioned(
          left: 0, right: 20, bottom: size.height * 0.16,
          child: Center(
            child: SizedBox(width: 180, height: 180,
              child: Stack(children: [
                IgnorePointer(
                  child: GameWidget(
                    game: _playerGame,
                    backgroundBuilder: (ctx) => const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 110,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _playerGame.jump(),
                  ),
                ),
              ]),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 14, left: 18,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('assets/game/back_button.png',
                width: 48, height: 48, fit: BoxFit.contain),
          ),
        ),

        if (!trayOpen)
          GardenToolTray(
            waterCount:      _waterCount,
            fertilizerCount: _fertilizerCount,
          ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: 0, right: 0,
          bottom: trayOpen ? 0 : -260,
          child: PlantingTray(
            allSeeds:       _seedsWithStatus,
            plantableSeeds: _plantableSeeds,
            plotIndex:      _selectedPlotIndex ?? 0,
            onSeedSelected: (seed) {
              if (_selectedPlotIndex != null) {
                _plantSeed(_selectedPlotIndex!, seed);
              }
            },
            onClose: () => setState(() => _selectedPlotIndex = null),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          bottom: trayOpen ? -100 : size.height * 0.02,
          left: 0, right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () async {
                if (!mounted) return;
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ShopGameScreen(
                    plots: _plots,
                    userSeeds: _userSeeds,
                    onPlantFromShop: (plotIndex, seed) {
                      _plantSeed(plotIndex, seed);
                    },
                  ),
                ));
                _loadGarden();
              },
              child: Image.asset('assets/game/btn_home.png',
                  width: size.width * 0.25, height: size.width * 0.25,
                  fit: BoxFit.contain),
            ),
            SizedBox(width: size.width * 0.06),
            GestureDetector(
              onTap: () {},
              child: Image.asset('assets/game/btn_mail.png',
                  width: size.width * 0.25, height: size.width * 0.25,
                  fit: BoxFit.contain),
            ),
          ]),
        ),
      ]),
    );
  }
}


class _HarvestEffect extends StatefulWidget {
  final int plotIndex;
  final VoidCallback onComplete;

  const _HarvestEffect({required this.plotIndex, required this.onComplete});

  @override
  State<_HarvestEffect> createState() => _HarvestEffectState();
}

class _HarvestEffectState extends State<_HarvestEffect>
    with TickerProviderStateMixin {

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward().then((_) => widget.onComplete());

  late final Animation<double> _scale = CurvedAnimation(
    parent: _ctrl, curve: Curves.elasticOut,
  );
  late final Animation<double> _fade = Tween(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ),
  );

  static const _anchors = [
    Offset(0.500, 0.500), Offset(0.330, 0.555), Offset(0.670, 0.550),
    Offset(0.150, 0.595), Offset(0.520, 0.580), Offset(0.885, 0.575),
    Offset(0.320, 0.630), Offset(0.720, 0.615), Offset(0.520, 0.695),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final anchor = _anchors[widget.plotIndex.clamp(0, _anchors.length - 1)];
    final cx     = size.width  * anchor.dx;
    final cy     = size.height * anchor.dy;

    return Positioned(
      left: cx - 80,
      top:  cy - 80,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: SizedBox(
            width: 160, height: 160,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _StarBurstPainter(progress: _ctrl.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarBurstPainter extends CustomPainter {
  final double progress;
  const _StarBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR   = size.width / 2;
    final paint  = Paint()..style = PaintingStyle.fill;

    const starCount = 12;
    for (int i = 0; i < starCount; i++) {
      final angle   = (i / starCount) * 2 * pi;
      final r       = maxR * progress;
      final pos     = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      final starSize = (6.0 + 4.0 * sin(progress * pi)) * (1 - progress * 0.4);
      final opacity  = (1.0 - progress).clamp(0.0, 1.0);

      paint.color      = Colors.amber.withOpacity(opacity * 0.4);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, starSize * 1.5, paint);
      paint.maskFilter = null;

      paint.color = Colors.white.withOpacity(opacity);
      _drawStar(canvas, pos, starSize, paint);
    }

    final glowR  = maxR * 0.5 * progress;
    final glowOp = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    paint.color      = Colors.white.withOpacity(glowOp * 0.6);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, glowR, paint);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    const n = 5;
    for (int i = 0; i < n * 2; i++) {
      final angle  = (i * pi / n) - pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final pt     = Offset(c.dx + radius * cos(angle), c.dy + radius * sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.progress != progress;
}