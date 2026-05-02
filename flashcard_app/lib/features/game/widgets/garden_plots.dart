// lib/features/game/widgets/garden_plots.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/tray_shared.dart';
import 'package:flashcard_app/features/game/widgets/planting_tray.dart';
import 'package:flashcard_app/features/game/widgets/garden_plots.dart';

// ─── Vị trí anchor của từng ô đất trên màn hình ──────────────────────────────

const List<_Anchor> _kAnchors = [
  _Anchor(cx: 0.500, cy: 0.500),
  _Anchor(cx: 0.330, cy: 0.540),
  _Anchor(cx: 0.670, cy: 0.540),
  _Anchor(cx: 0.150, cy: 0.585),
  _Anchor(cx: 0.520, cy: 0.580),
  _Anchor(cx: 0.885, cy: 0.575),
  _Anchor(cx: 0.320, cy: 0.630),
  _Anchor(cx: 0.720, cy: 0.620),
  _Anchor(cx: 0.520, cy: 0.675),
];

class _Anchor {
  final double cx, cy;
  const _Anchor({required this.cx, required this.cy});
}

const double _kTapW = 0.16;
const double _kTapH = 0.09;

// ─── Widget hiển thị toàn bộ các ô đất có thể thả seed ──────────────────────

class DroppableGardenPlots extends StatelessWidget {
  final List<GardenPlot> plots;
  final Function(int) onPlotTapped;
  final Function(int, SeedItem) onSeedDropped;

  const DroppableGardenPlots({
    super.key,
    required this.plots,
    required this.onPlotTapped,
    required this.onSeedDropped,
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
          final row = i ~/ 3;
          final cx = size.width * a.cx;
          final cy = size.height * a.cy;

          return Positioned(
            left: cx - tapW / 2,
            top: cy - tapH / 2,
            width: tapW,
            height: tapH,
            child: _DroppablePlotCell(
              plot: plots[i],
              row: row,
              onTap: () => onPlotTapped(i),
              onSeedDropped: (s) => onSeedDropped(i, s),
            ),
          );
        },
      ),
    );
  }
}

// ─── Một ô đất đơn lẻ: xử lý tap + drop + animation ────────────────────────

class _DroppablePlotCell extends StatefulWidget {
  final GardenPlot plot;
  final int row;
  final VoidCallback onTap;
  final Function(SeedItem) onSeedDropped;

  const _DroppablePlotCell({
    required this.plot,
    required this.row,
    required this.onTap,
    required this.onSeedDropped,
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

  bool _isHovering = false;

  @override
  void dispose() {
    _tapCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
    widget.onTap();
  }

  static const _rowSize = [38.0, 44.0, 52.0];
  static const _stageEmoji = ['🌰', '🌱', '🌿', '🪴', '🌸', '🍎'];

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.plot.status == PlotStatus.empty;
    final treeSize = _rowSize[widget.row.clamp(0, 2)];

    return DragTarget<SeedItem>(
      onWillAcceptWithDetails: (d) => isEmpty,
      onAcceptWithDetails: (d) {
        setState(() => _isHovering = false);
        HapticFeedback.mediumImpact();
        widget.onSeedDropped(d.data);
      },
      onMove: (_) {
        if (isEmpty && !_isHovering) setState(() => _isHovering = true);
      },
      onLeave: (_) {
        if (_isHovering) setState(() => _isHovering = false);
      },
      builder: (ctx, candidates, _) {
        final accepting = candidates.isNotEmpty && isEmpty;
        return GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.translucent,
          child: ScaleTransition(
            scale: _tapScale,
            child: Center(child: _buildContent(accepting, treeSize)),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool accepting, double treeSize) {
    switch (widget.plot.status) {
      case PlotStatus.empty:
        if (accepting || _isHovering) return const PlotDropHighlight();
        return ScaleTransition(scale: _pulseScale, child: const PlotPlusDot());

      case PlotStatus.planted:
        final s = widget.plot.growthStage.clamp(0, 5);
        return OverflowBox(
          maxHeight: double.infinity,
          alignment: Alignment.topCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(clipBehavior: Clip.none, children: [
              Image.asset(
                'assets/game/tree/stage_$s.png',
                width: treeSize,
                height: treeSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(_stageEmoji[s],
                    style: TextStyle(fontSize: treeSize * 0.6)),
              ),
              if (widget.plot.needsWater)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF29B6F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                        child: Text('💧', style: TextStyle(fontSize: 10))),
                  ),
                ),
            ]),
            const SizedBox(height: 1),
            if (widget.plot.setTitle != null)
              Container(
                constraints: BoxConstraints(maxWidth: treeSize + 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.plot.setTitle!,
                  style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E342E)),
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
                  value: widget.plot.growthStage / 5.0,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation(
                    widget.plot.growthStage >= 4
                        ? const Color(0xFFFFB300)
                        : const Color(0xFF7CB342),
                  ),
                ),
              ),
            ),
          ]),
        );

      case PlotStatus.mastered:
        return OverflowBox(
          maxHeight: double.infinity,
          alignment: Alignment.topCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/game/tree/stage_5.png',
              width: treeSize + 6,
              height: treeSize + 6,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text('🍎',
                  style: TextStyle(fontSize: (treeSize + 6) * 0.6)),
            ),
            const SizedBox(height: 2),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withOpacity(0.93),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_rounded, size: 9, color: Color(0xFFE65100)),
                SizedBox(width: 2),
                Text('Thành thạo',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE65100))),
              ]),
            ),
          ]),
        );
    }
  }
}