import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/tray_shared.dart';
import 'package:flashcard_app/features/game/widgets/planting_tray.dart';
import 'package:flashcard_app/features/game/widgets/garden_tool_tray.dart';


const List<_Anchor> _kAnchors = [
  _Anchor(cx: 0.500, cy: 0.500),
  _Anchor(cx: 0.330, cy: 0.555),
  _Anchor(cx: 0.670, cy: 0.550),
  _Anchor(cx: 0.150, cy: 0.595),
  _Anchor(cx: 0.520, cy: 0.580),
  _Anchor(cx: 0.885, cy: 0.575),
  _Anchor(cx: 0.320, cy: 0.615),
  _Anchor(cx: 0.720, cy: 0.615),
  _Anchor(cx: 0.520, cy: 0.685),
];

class _Anchor {
  final double cx, cy;
  const _Anchor({required this.cx, required this.cy});
}

const double _kTapW = 0.20;
const double _kTapH = 0.12;


enum BurstType { fertilizer, water }


class DroppableGardenPlots extends StatelessWidget {
  final List<GardenPlot> plots;
  final Function(int) onPlotTapped;
  final Function(int, SeedItem) onSeedDropped;
  final Function(int plotIndex, GardenTool tool)? onToolDropped;

  const DroppableGardenPlots({
    super.key,
    required this.plots,
    required this.onPlotTapped,
    required this.onSeedDropped,
    this.onToolDropped,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tapW = size.width * _kTapW;
    final tapH = size.height * _kTapH;

    return Stack(
      children: List.generate(
        plots.length.clamp(0, _kAnchors.length),
        (i) {
          final a   = _kAnchors[i];
          final row = i ~/ 3;
          final cx  = size.width  * a.cx;
          final cy  = size.height * a.cy;

          return Positioned(
            left:   cx - tapW / 2,
            top:    cy - tapH / 2,
            width:  tapW,
            height: tapH,
            child: _DroppablePlotCell(
              key:           ValueKey('plot_${plots[i].plotIndex}'),
              plot:          plots[i],
              row:           row,
              onTap:         () => onPlotTapped(i),
              onSeedDropped: (s) => onSeedDropped(i, s),
              onToolDropped: onToolDropped != null
                  ? (tool) => onToolDropped!(i, tool)
                  : null,
            ),
          );
        },
      ),
    );
  }
}


class _DroppablePlotCell extends StatefulWidget {
  final GardenPlot plot;
  final int row;
  final VoidCallback onTap;
  final Function(SeedItem) onSeedDropped;
  final Function(GardenTool)? onToolDropped;

  const _DroppablePlotCell({
    super.key,
    required this.plot,
    required this.row,
    required this.onTap,
    required this.onSeedDropped,
    this.onToolDropped,
  });

  @override
  State<_DroppablePlotCell> createState() => _DroppablePlotCellState();
}

class _DroppablePlotCellState extends State<_DroppablePlotCell>
    with TickerProviderStateMixin {

  late final AnimationController _tapCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 110));
  late final Animation<double> _tapScale = Tween(begin: 1.0, end: 0.82)
      .animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));

  late final AnimationController _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  late final Animation<double> _pulseScale = Tween(begin: 1.0, end: 1.18)
      .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  late final AnimationController _growCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _growScale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0,  end: 1.18), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.00), weight: 20),
  ]).animate(CurvedAnimation(parent: _growCtrl, curve: Curves.easeOut));

  bool        _showGrowBurst  = false;
  BurstType   _burstType      = BurstType.fertilizer;
  bool        _isHoveringSeed = false;
  bool        _isHoveringTool = false;
  GardenTool? _hoveringTool;

  @override
  void didUpdateWidget(_DroppablePlotCell old) {
    super.didUpdateWidget(old);

    if (widget.plot.growthStage > old.plot.growthStage &&
        widget.plot.status == PlotStatus.planted) {
      _triggerGrowEffect(type: BurstType.fertilizer);
    }

    if (widget.plot.lastWatered != old.plot.lastWatered &&
        widget.plot.status == PlotStatus.planted) {
      _triggerGrowEffect(type: BurstType.water);
    }
  }

  void _triggerGrowEffect({BurstType type = BurstType.fertilizer}) {
    _growCtrl.forward(from: 0);
    setState(() {
      _burstType     = type;
      _showGrowBurst = true;
    });
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _pulseCtrl.dispose();
    _growCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
    widget.onTap();
  }

  static const _rowSize    = [64.0, 69.0, 78.0];
  static const _stageEmoji = ['🌰', '🌱', '🌿', '🪴', '🌸', '🍎'];

  bool get _isPlanted => widget.plot.status == PlotStatus.planted;
  bool get _isEmpty   => widget.plot.status == PlotStatus.empty;

  @override
  Widget build(BuildContext context) {
    final treeSize = _rowSize[widget.row.clamp(0, 2)];

    return DragTarget<GardenToolDrop>(
      onWillAcceptWithDetails: (d) => _isPlanted,
      onAcceptWithDetails: (d) {
        setState(() { _isHoveringTool = false; _hoveringTool = null; });
        HapticFeedback.mediumImpact();
        widget.onToolDropped?.call(d.data.tool);
      },
      onMove: (details) {
        if (_isPlanted && !_isHoveringTool) {
          setState(() {
            _isHoveringTool = true;
            _hoveringTool   = details.data.tool;
          });
        }
      },
      onLeave: (_) {
        if (_isHoveringTool) {
          setState(() { _isHoveringTool = false; _hoveringTool = null; });
        }
      },
      builder: (ctx, toolCandidates, _) {
        return DragTarget<SeedItem>(
          onWillAcceptWithDetails: (d) => _isEmpty,
          onAcceptWithDetails: (d) {
            setState(() => _isHoveringSeed = false);
            HapticFeedback.mediumImpact();
            widget.onSeedDropped(d.data);
          },
          onMove: (_) {
            if (_isEmpty && !_isHoveringSeed) setState(() => _isHoveringSeed = true);
          },
          onLeave: (_) {
            if (_isHoveringSeed) setState(() => _isHoveringSeed = false);
          },
          builder: (ctx2, seedCandidates, _) {
            final acceptingSeed = seedCandidates.isNotEmpty && _isEmpty;
            final acceptingTool = toolCandidates.isNotEmpty && _isPlanted;

            return GestureDetector(
              onTap: _onTap,
              behavior: HitTestBehavior.translucent,
              child: ScaleTransition(
                scale: _tapScale,
                child: Center(
                  child: _buildContent(
                    acceptingSeed: acceptingSeed,
                    acceptingTool: acceptingTool,
                    treeSize:      treeSize,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent({
    required bool   acceptingSeed,
    required bool   acceptingTool,
    required double treeSize,
  }) {
    switch (widget.plot.status) {

      case PlotStatus.empty:
        if (acceptingSeed || _isHoveringSeed) return const PlotDropHighlight();
        return ScaleTransition(
          scale: _pulseScale,
          child: const PlotPlusDot(),
        );

      case PlotStatus.planted:
        final s = widget.plot.growthStage.clamp(0, 5);
        final treeImagePath = s >= 5 && widget.plot.imagePath != null
            ? widget.plot.imagePath!
            : 'assets/game/tree/stage_$s.png';

        return Stack(
          alignment:    Alignment.center,
          clipBehavior: Clip.none,
          children: [
            OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(clipBehavior: Clip.none, children: [

                    AnimatedBuilder(
                      animation: _growCtrl,
                      builder: (_, child) => Transform.scale(
                        scale: _growCtrl.isAnimating ? _growScale.value : 1.0,
                        child: child,
                      ),
                      child: Image.asset(
                        treeImagePath,
                        width:  treeSize,
                        height: treeSize,
                        fit:    BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          _stageEmoji[s],
                          style: TextStyle(fontSize: treeSize * 0.6),
                        ),
                      ),
                    ),

                    if (widget.plot.needsWater)
                      Positioned(
                        top: -6, right: -6,
                        child: Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color:  const Color(0xFF29B6F6),
                            shape:  BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Center(
                            child: Text('💧', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),

                    if (acceptingTool || _isHoveringTool)
                      Positioned.fill(
                        child: ToolDropHighlight(
                          tool: _hoveringTool ?? GardenTool.water,
                        ),
                      ),
                  ]),

                  const SizedBox(height: 1),

                  if (widget.plot.setTitle != null)
                    Container(
                      constraints: BoxConstraints(maxWidth: treeSize + 8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color:        Colors.white.withOpacity(0.80),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.plot.setTitle!,
                        style: const TextStyle(
                          fontSize: 7, fontWeight: FontWeight.w700,
                          color: Color(0xFF4E342E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 1),

                  SizedBox(
                    width: 34,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value:           widget.plot.growthStage / 5.0,
                        minHeight:       3,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor:      AlwaysStoppedAnimation(
                          widget.plot.growthStage >= 4
                              ? const Color(0xFFFFB300)
                              : const Color(0xFF7CB342),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showGrowBurst)
              GrowthBurstOverlay(
                type: _burstType,
                onDone: () {
                  if (mounted) setState(() => _showGrowBurst = false);
                },
              ),
          ],
        );

      case PlotStatus.mastered:
        final masteredImage =
            widget.plot.imagePath ?? 'assets/game/tree/stage_4.png';

        return OverflowBox(
          maxHeight: double.infinity,
          alignment: Alignment.topCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              masteredImage,
              width:  treeSize + 6,
              height: treeSize + 6,
              fit:    BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                '🌸',
                style: TextStyle(fontSize: (treeSize + 6) * 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color:        const Color(0xFFFFD54F).withOpacity(0.93),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_rounded, size: 9, color: Color(0xFFE65100)),
                SizedBox(width: 2),
                Text('Mastered', style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: Color(0xFFE65100),
                )),
              ]),
            ),
          ]),
        );
    }
  }
}


class GrowthBurstOverlay extends StatefulWidget {
  final VoidCallback onDone;
  final BurstType    type;

  const GrowthBurstOverlay({
    super.key,
    required this.onDone,
    this.type = BurstType.fertilizer,
  });

  @override
  State<GrowthBurstOverlay> createState() => _GrowthBurstOverlayState();
}

class _GrowthBurstOverlayState extends State<GrowthBurstOverlay>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward().then((_) => widget.onDone());

  late final Animation<double> _ringScale = Tween(begin: 0.3, end: 2.2).animate(
    CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
  );
  late final Animation<double> _ringOpacity = Tween(begin: 0.9, end: 0.0).animate(
    CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
  );
  late final Animation<double> _particleDist = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut)),
  );
  late final Animation<double> _particleOpacity = Tween(begin: 1.0, end: 0.0).animate(
    CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.45, 0.95, curve: Curves.easeIn)),
  );

  List<String> get _particles => widget.type == BurstType.water
      ? ['💧', '💦', '💧', '💦']
      : ['🍃', '🌿', '✨', '🍃'];

  Color get _ringColor => widget.type == BurstType.water
      ? const Color(0xFF29B6F6)
      : const Color(0xFF7CB342);

  static const _angles  = [40.0, 140.0, 220.0, 310.0];
  static const _maxDist = 40.0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: 100, height: 100,
        child: Stack(alignment: Alignment.center, children: [

          Opacity(
            opacity: _ringOpacity.value,
            child: Transform.scale(
              scale: _ringScale.value,
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  border: Border.all(color: _ringColor, width: 2.5),
                ),
              ),
            ),
          ),

          ..._particles.asMap().entries.map((e) {
            final angle = _angles[e.key] * pi / 180;
            final dist  = _particleDist.value * _maxDist;
            return Transform.translate(
              offset: Offset(cos(angle) * dist, sin(angle) * dist),
              child: Opacity(
                opacity: _particleOpacity.value,
                child: Text(e.value, style: const TextStyle(fontSize: 13)),
              ),
            );
          }),
        ]),
      ),
    );
  }
}