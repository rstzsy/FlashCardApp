// lib/features/game/widgets/garden_plots_overlay.dart

import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';

const List<_Anchor> _kAnchors = [
  _Anchor(cx: 0.500, cy: 0.495),
  _Anchor(cx: 0.330, cy: 0.540),
  _Anchor(cx: 0.670, cy: 0.540),
  _Anchor(cx: 0.150, cy: 0.585),
  _Anchor(cx: 0.520, cy: 0.580),
  _Anchor(cx: 0.885, cy: 0.575),
  _Anchor(cx: 0.320, cy: 0.630),
  _Anchor(cx: 0.720, cy: 0.620),
  _Anchor(cx: 0.500, cy: 0.675),
];

class _Anchor {
  final double cx, cy;
  const _Anchor({required this.cx, required this.cy});
}

const double _kTapW = 0.16;
const double _kTapH = 0.09;

const List<String> _kStageAssets = [
  'assets/game/tree/stage_0.png',
  'assets/game/tree/stage_1.png',
  'assets/game/tree/stage_2.png',
  'assets/game/tree/stage_3.png',
  'assets/game/tree/stage_4.png',
  'assets/game/tree/stage_5.png',
];
const List<String> _kEmoji = ['🌰', '🌱', '🌿', '🪴', '🌸', '🍎'];
const List<double> _kTreeSize = [38.0, 44.0, 52.0];

// ─────────────────────────────────────────────────────────────────────────────

class GardenPlotsOverlay extends StatelessWidget {
  final List<GardenPlot> plots;
  final Function(int) onPlotTapped;

  const GardenPlotsOverlay({
    super.key,
    required this.plots,
    required this.onPlotTapped,
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
          final a = _kAnchors[i];
          final cx = size.width * a.cx;
          final cy = size.height * a.cy;
          final row = i ~/ 3;

          return Positioned(
            left: cx - tapW / 2,
            top: cy - tapH / 2,
            width: tapW,
            height: tapH,
            child: _PlotCell(
              plot: plots[i],
              row: row,
              onTap: () => onPlotTapped(i),
            ),
          );
        },
      ),
    );
  }
}

// ─── Cell widget ─────────────────────────────────────────────────────────────

class _PlotCell extends StatefulWidget {
  final GardenPlot plot;
  final int row;
  final VoidCallback onTap;
  const _PlotCell({required this.plot, required this.row, required this.onTap});

  @override
  State<_PlotCell> createState() => _PlotCellState();
}

class _PlotCellState extends State<_PlotCell> with TickerProviderStateMixin {
  late final AnimationController _tapCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 110));
  late final Animation<double> _tapScale = Tween(begin: 1.0, end: 0.80)
      .animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.translucent,
      child: ScaleTransition(
        scale: _tapScale,
        child: Center(child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    final treeSize = _kTreeSize[widget.row.clamp(0, 2)];
    final stage = widget.plot.growthStage.clamp(0, 5);

    switch (widget.plot.status) {

      case PlotStatus.empty:
        return const SizedBox.shrink();

      case PlotStatus.planted:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(clipBehavior: Clip.none, children: [
              Image.asset(
                _kStageAssets[stage],
                width: treeSize, height: treeSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  _kEmoji[stage],
                  style: TextStyle(fontSize: treeSize * 0.65),
                ),
              ),
              if (widget.plot.needsWater)
                Positioned(
                  top: -5, right: -6,
                  child: Container(
                    width: 17, height: 17,
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.45),
                        blurRadius: 4,
                      )],
                    ),
                    child: const Center(
                      child: Text('💧', style: TextStyle(fontSize: 9)),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 2),
            if (widget.plot.setTitle != null) _Label(widget.plot.setTitle!),
            const SizedBox(height: 2),
            _StageBar(stage: stage),
          ],
        );

      case PlotStatus.mastered:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _kStageAssets[5],
              width: treeSize + 6, height: treeSize + 6,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Text('🍎', style: TextStyle(fontSize: (treeSize + 6) * 0.65)),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withOpacity(0.93),
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
          ],
        );
    }
  }
}

// ─── Label & StageBar ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.82),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF4E342E),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _StageBar extends StatelessWidget {
  final int stage;
  const _StageBar({required this.stage});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 34,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: stage / 5.0,
        minHeight: 4,
        backgroundColor: Colors.white.withOpacity(0.50),
        valueColor: AlwaysStoppedAnimation(
          stage >= 4 ? const Color(0xFFFFB300) : const Color(0xFF7CB342),
        ),
      ),
    ),
  );
}