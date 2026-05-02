// lib/features/game/screens/home_game_screen.dart

import 'package:flame/game.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/draggable_seed_tray.dart';
import 'package:flashcard_app/features/game/widgets/player_game.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';
import 'package:flutter/material.dart';

class HomeGameScreen extends StatefulWidget {
  const HomeGameScreen({super.key});

  @override
  State<HomeGameScreen> createState() => _HomeGameScreenState();
}

class _HomeGameScreenState extends State<HomeGameScreen> {
  final PlayerGame _playerGame = PlayerGame();
  int? _selectedPlotIndex;

  late final List<GardenPlot> _plots =
      List.generate(9, (i) => GardenPlot(plotIndex: i));

  // ── Add imagePath to every SeedItem ──────────────────────────────────────
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
      imagePath: s.imagePath, // ← carry imagePath through
      alreadyPlanted: planted.contains(s.setId),
    )).toList();
  }

  List<SeedItem> get _plantableSeeds =>
      _seedsWithStatus.where((s) => !s.alreadyPlanted).toList();

  void _onPlotTapped(int i) {
    if (_plots[i].status == PlotStatus.empty) {
      setState(() => _selectedPlotIndex = i);
    } else {
      _showCareOptions(i);
    }
  }

  void _onSeedDropped(int i, SeedItem seed) {
    if (!seed.alreadyPlanted) {
      _plantSeed(i, seed);
      setState(() => _selectedPlotIndex = null);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Planted "${seed.title}" 🌱',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF558B2F),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showCareOptions(int i) {
    final plot = _plots[i];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8EC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4B896),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            plot.setTitle ?? 'Vocab Plant',
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stage ${plot.growthStage}/5',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _CareBtn(
              emoji: '💧', label: 'Water',
              color: const Color(0xFF29B6F6),
              onTap: () => Navigator.pop(context),
            )),
            const SizedBox(width: 12),
            Expanded(child: _CareBtn(
              emoji: '🌿', label: 'Fertilize',
              color: const Color(0xFF66BB6A),
              onTap: () => Navigator.pop(context),
            )),
          ]),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final trayOpen = _selectedPlotIndex != null;

    return Scaffold(
      body: Stack(children: [

        // ── Background ──────────────────────────────────────────────────────
        Container(decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game/home_game_bg.png'),
            fit: BoxFit.cover,
          ),
        )),

        // ── Tap background to close tray ────────────────────────────────────
        if (trayOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlotIndex = null),
              behavior: HitTestBehavior.translucent,
            ),
          ),

        // ── Garden plots ─────────────────────────────────────────────────────
        DroppableGardenPlots(
          plots: _plots,
          onPlotTapped: _onPlotTapped,
          onSeedDropped: _onSeedDropped,
        ),

        // ── Player character ─────────────────────────────────────────────────
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

        // ── Back button ──────────────────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 14, left: 18,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('assets/game/back_button.png',
                width: 48, height: 48, fit: BoxFit.contain),
          ),
        ),

        // ── Planting tray – slides up when a plot is tapped ──────────────────
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

        // ── Bottom nav ───────────────────────────────────────────────────────
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

class _CareBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _CareBtn({
    required this.emoji, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: color,
        )),
      ]),
    ),
  );
}