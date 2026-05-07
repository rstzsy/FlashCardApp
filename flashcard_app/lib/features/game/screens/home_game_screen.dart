// lib/features/game/screens/home_game_screen.dart

import 'package:flame/game.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/draggable_seed_tray.dart';
import 'package:flashcard_app/features/game/widgets/player_game.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';
import 'package:flashcard_app/features/game/widgets/garden_tool_tray.dart';
import 'package:flutter/material.dart';

class HomeGameScreen extends StatefulWidget {
  const HomeGameScreen({super.key});

  @override
  State<HomeGameScreen> createState() => _HomeGameScreenState();
}

class _HomeGameScreenState extends State<HomeGameScreen> {
  final PlayerGame _playerGame = PlayerGame();
  int? _selectedPlotIndex;

  // ── Garden plots ───────────────────────────────────────────────────────────
  late final List<GardenPlot> _plots =
      List.generate(9, (i) => GardenPlot(plotIndex: i));

  // ── Tool inventory (nhận từ server / quest rewards) ────────────────────────
  int _waterCount = 12;
  int _fertilizerCount = 5;

  // ── Seeds ──────────────────────────────────────────────────────────────────
  final List<SeedItem> _availableSeeds = [
    SeedItem(
      setId: 'set_001', title: 'Animals', subtitle: 'Nature',
      totalCards: 20, difficulty: 'Easy',
      imagePath: 'assets/game/tulip.png',
    ),
    SeedItem(
      setId: 'set_002', title: 'Business', subtitle: 'Commerce',
      totalCards: 30, difficulty: 'Hard',
      imagePath: 'assets/game/rose.png',
    ),
    SeedItem(
      setId: 'set_003', title: 'Daily Talk', subtitle: 'Conversation',
      totalCards: 15, difficulty: 'Medium',
      imagePath: 'assets/game/lotus.png',
    ),
    SeedItem(
      setId: 'set_004', title: 'Travel', subtitle: 'Tourism',
      totalCards: 25, difficulty: 'Medium',
      imagePath: 'assets/game/Frangipani.png',
    ),
  ];

  List<SeedItem> get _seedsWithStatus {
    final planted = _plots
        .where((p) => p.setId != null)
        .map((p) => p.setId!)
        .toSet();
    return _availableSeeds.map((s) => SeedItem(
      setId: s.setId,
      title: s.title,
      subtitle: s.subtitle,
      totalCards: s.totalCards,
      difficulty: s.difficulty,
      imagePath: s.imagePath,
      alreadyPlanted: planted.contains(s.setId),
    )).toList();
  }

  List<SeedItem> get _plantableSeeds =>
      _seedsWithStatus.where((s) => !s.alreadyPlanted).toList();

  // ── Plot interactions ──────────────────────────────────────────────────────

  void _onPlotTapped(int i) {
    // Chỉ mở tray chọn hạt giống khi ô đất trống
    if (_plots[i].status == PlotStatus.empty) {
      setState(() => _selectedPlotIndex = i);
    }
    // Ô đã trồng: không cần mở bottom sheet nữa
    // — người dùng dùng tool tray để tưới/bón trực tiếp
  }

  void _onSeedDropped(int i, SeedItem seed) {
    if (!seed.alreadyPlanted) {
      _plantSeed(i, seed);
      setState(() => _selectedPlotIndex = null);
    }
  }

  /// Xử lý khi người dùng thả tool vào ô cây
  void _onToolDropped(int plotIndex, GardenTool tool) {
    final plot = _plots[plotIndex];
    if (plot.status != PlotStatus.planted) return;

    switch (tool) {
      case GardenTool.water:
        if (_waterCount <= 0) {
          _showToast('Hết nước rồi! 💧', const Color(0xFF0288D1));
          return;
        }
        setState(() {
          _waterCount--;
          _plots[plotIndex].lastWatered = DateTime.now();
          _plots[plotIndex].canFertilize = true;
        });
        _showToast('Đã tưới "${plot.setTitle}" 💧', const Color(0xFF0288D1));

      case GardenTool.fertilizer:
        if (_fertilizerCount <= 0) {
          _showToast('Hết phân bón rồi! 🌿', const Color(0xFF388E3C));
          return;
        }
        setState(() {
          _fertilizerCount--;
          // Bón phân tăng trưởng nhanh hơn
          _plots[plotIndex].growthStage =
              (_plots[plotIndex].growthStage + 1).clamp(0, 5);
        });
        _showToast('Đã bón phân "${plot.setTitle}" 🌿', const Color(0xFF388E3C));
    }
  }

  void _plantSeed(int i, SeedItem seed) {
    setState(() {
      _selectedPlotIndex = null;
      _plots[i]
        ..status = PlotStatus.planted
        ..setId = seed.setId
        ..setTitle = seed.title
        ..growthStage = 0
        ..lastWatered = DateTime.now();
    });
    _showToast('Đã trồng "${seed.title}" 🌱', const Color(0xFF558B2F));
  }

  void _showToast(String message, Color color) {
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final trayOpen = _selectedPlotIndex != null;

    return Scaffold(
      body: Stack(children: [

        // ── Background ────────────────────────────────────────────────────────
        Container(decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game/home_game_bg.png'),
            fit: BoxFit.cover,
          ),
        )),

        // ── Tap background to close seed tray ────────────────────────────────
        if (trayOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlotIndex = null),
              behavior: HitTestBehavior.translucent,
            ),
          ),

        // ── Garden plots (nhận cả seed drop + tool drop) ──────────────────────
        DroppableGardenPlots(
          plots: _plots,
          onPlotTapped: _onPlotTapped,
          onSeedDropped: _onSeedDropped,
          onToolDropped: _onToolDropped,   // ← MỚI
        ),

        // ── Player character ──────────────────────────────────────────────────
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

        // ── Back button ───────────────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 14, left: 18,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('assets/game/back_button.png',
                width: 48, height: 48, fit: BoxFit.contain),
          ),
        ),

        // ── Tool Tray — bình tưới & phân bón (luôn hiển thị) ─────────────────
        // Ẩn khi seed tray đang mở để tránh chồng UI
        if (!trayOpen)
          GardenToolTray(
            waterCount: _waterCount,
            fertilizerCount: _fertilizerCount,
          ),

        // ── Seed planting tray (slides up khi chọn ô trống) ──────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: 0, right: 0,
          bottom: trayOpen ? 0 : -260,
          child: PlantingTray(
            allSeeds: _seedsWithStatus,
            plantableSeeds: _plantableSeeds,
            plotIndex: _selectedPlotIndex ?? 0,
            onSeedSelected: (seed) {
              if (_selectedPlotIndex != null) {
                _plantSeed(_selectedPlotIndex!, seed);
              }
            },
            onClose: () => setState(() => _selectedPlotIndex = null),
          ),
        ),

        // ── Bottom nav ────────────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          bottom: trayOpen ? -100 : size.height * 0.02,
          left: 0, right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ShopGameScreen(plots: _plots))),
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