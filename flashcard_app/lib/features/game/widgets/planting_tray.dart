import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';
import 'package:flashcard_app/features/game/widgets/seed_card.dart';
import 'package:flashcard_app/features/game/widgets/tray_shared.dart';

class PlantingTray extends StatefulWidget {
  final List<SeedItem> allSeeds;

  final List<SeedItem> plantableSeeds;

  final int plotIndex;
  final Function(SeedItem) onSeedSelected;
  final VoidCallback onClose;

  const PlantingTray({
    super.key,
    required this.allSeeds,
    required this.plantableSeeds,
    required this.plotIndex,
    required this.onSeedSelected,
    required this.onClose,
  });

  @override
  State<PlantingTray> createState() => _PlantingTrayState();
}

class _PlantingTrayState extends State<PlantingTray> {
  SeedItem? _selected;
  late final PageController _pageCtrl = PageController(
    viewportFraction: 0.40,
  );

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlantingTray old) {
    super.didUpdateWidget(old);
    if (old.plotIndex != widget.plotIndex) _selected = null;
  }

  void _onCardTap(SeedItem seed) {
    if (seed.alreadyPlanted) return;
    HapticFeedback.selectionClick();
    setState(() =>
        _selected = _selected?.setId == seed.setId ? null : seed);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 6),
          child: _QuickPlantButton(
            enabled: _selected != null,
            onTap: () {
              if (_selected != null) {
                HapticFeedback.mediumImpact();
                widget.onSeedSelected(_selected!);
              }
            },
          ),
        ),

        _TrayContainer(
          bottomPad: bottomPad,
          child: widget.allSeeds.isEmpty
              ? const _EmptyState()
              : _buildPageView(),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    final seeds = widget.allSeeds;
    return SizedBox(
      height: 148,
      child: PageView.builder(
        controller: _pageCtrl,
        padEnds: false,
        itemCount: seeds.length,
        itemBuilder: (_, i) {
          final seed = seeds[i];
          final isSelected = _selected?.setId == seed.setId;
          final isDisabled = seed.alreadyPlanted;

          final card = SeedCard(
            seed: seed,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onTap: () => _onCardTap(seed),
          );

          final leftPad = i == 0 ? 14.0 : 6.0;
          final rightPad = i == seeds.length - 1 ? 14.0 : 6.0;

          if (isDisabled) {
            return Padding(
              padding: EdgeInsets.fromLTRB(leftPad, 6, rightPad, 6),
              child: card,
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(leftPad, 6, rightPad, 6),
            child: Draggable<SeedItem>(
              data: seed,
              feedback: Material(
                color: Colors.transparent,
                child: SeedDragFeedback(seed: seed),
              ),
              childWhenDragging: Opacity(
                opacity: 0.25,
                child: SeedCard(
                  seed: seed,
                  isSelected: isSelected,
                  isDisabled: false,
                  onTap: () {},
                ),
              ),
              child: GestureDetector(
                onTap: () => _onCardTap(seed),
                child: card,
              ),
            ),
          );
        },
      ),
    );
  }
}


class _QuickPlantButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _QuickPlantButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFC8A05A)
              : const Color(0xFF8C7048).withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? const Color(0xFFE8C87A)
                : const Color(0xFF6B5030),
            width: 1.5,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFC8A05A).withOpacity(0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFF8B5E1A)
                    : const Color(0xFF5C3D12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: enabled
                      ? const Color(0xFFE8C87A)
                      : const Color(0xFF4A3010),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.spa_rounded,
                size: 11,
                color: enabled
                    ? const Color(0xFFFFE89A)
                    : const Color(0xFF7A5A30),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'Trồng nhanh',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: enabled
                    ? const Color(0xFFFFF5D6)
                    : const Color(0xFF9A7840),
                shadows: enabled
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TrayContainer extends StatelessWidget {
  final double bottomPad;
  final Widget child;

  const _TrayContainer({required this.bottomPad, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6335).withOpacity(0.30),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            border: const Border(
              top: BorderSide(color: Color(0xFFBE9460), width: 2),
              left: BorderSide(color: Color(0xFFBE9460), width: 1),
              right: BorderSide(color: Color(0xFFBE9460), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: CustomPaint(painter: FlowerPatternPainter()),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, bottomPad + 10),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪴', style: TextStyle(fontSize: 34)),
            SizedBox(height: 8),
            Text('Chưa có hạt giống nào',
                style: TextStyle(
                    color: Color(0xFFE8C99A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Mở khóa cây trong Cửa hàng',
                style: TextStyle(color: Color(0xFFB8966A), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}