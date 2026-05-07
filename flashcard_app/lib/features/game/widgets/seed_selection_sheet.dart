import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';

class SeedSelectionSheet extends StatefulWidget {
  final List<SeedItem> availableSeeds;
  final int plotIndex;
  final Function(SeedItem) onSeedSelected;

  const SeedSelectionSheet({
    super.key,
    required this.availableSeeds,
    required this.plotIndex,
    required this.onSeedSelected,
  });

  /// Mở bottom sheet từ bên ngoài
  static Future<void> show({
    required BuildContext context,
    required List<SeedItem> availableSeeds,
    required int plotIndex,
    required Function(SeedItem) onSeedSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SeedSelectionSheet(
        availableSeeds: availableSeeds,
        plotIndex: plotIndex,
        onSeedSelected: onSeedSelected,
      ),
    );
  }

  @override
  State<SeedSelectionSheet> createState() => _SeedSelectionSheetState();
}

class _SeedSelectionSheetState extends State<SeedSelectionSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  SeedItem? _selectedSeed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmPlant() {
    if (_selectedSeed == null) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    widget.onSeedSelected(_selectedSeed!);
  }

  @override
  Widget build(BuildContext context) {
    final plantableSeeds =
        widget.availableSeeds.where((s) => !s.alreadyPlanted).toList();
    final hasSeeds = plantableSeeds.isNotEmpty;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar ──────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B896),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon vùng đất
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E6D3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/game/seed_icon.png',
                          width: 30,
                          height: 30,
                          errorBuilder: (_, __, ___) =>
                              const Text('🌱', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn hạt giống',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4E342E),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              _PlotBadge(index: widget.plotIndex + 1),
                              const SizedBox(width: 8),
                              Text(
                                '${plantableSeeds.length} hạt có sẵn',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Nút đóng
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE0D4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Divider(height: 1, color: Color(0xFFEDE0D4)),

              Flexible(
                child: hasSeeds
                    ? _buildSeedList(plantableSeeds)
                    : _buildEmptyState(),
              ),

              // ── Bottom: nút Trồng ───────────────────────────
              if (hasSeeds) _buildBottomBar(),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeedList(List<SeedItem> seeds) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: seeds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _SeedCard(
        seed: seeds[i],
        isSelected: _selectedSeed?.setId == seeds[i].setId,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedSeed = seeds[i]);
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final isActive = _selectedSeed != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDE0D4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview seed được chọn
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isActive
                ? Padding(
                    key: ValueKey(_selectedSeed!.setId),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SelectedPreview(seed: _selectedSeed!),
                  )
                : const SizedBox.shrink(),
          ),

          // Nút Trồng
          SizedBox(
            width: double.infinity,
            height: 54,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: isActive ? _confirmPlant : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CB342),
                  disabledBackgroundColor: const Color(0xFFCFD8DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isActive ? 4 : 0,
                  shadowColor: const Color(0xFF7CB342).withOpacity(0.4),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isActive
                      ? Row(
                          key: const ValueKey('active'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🌱', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Trồng "${_selectedSeed!.title}"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          key: ValueKey('inactive'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded,
                                size: 18, color: Color(0xFF90A4AE)),
                            SizedBox(width: 8),
                            Text(
                              'Chọn hạt giống bên trên',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF90A4AE),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪴', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có hạt giống nào!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hoàn thành một bộ flashcard để nhận\nhạt giống và bắt đầu trồng cây nhé 🌟',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), height: 1.5),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: const Text('Đi học flashcard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7CB342),
              side: const BorderSide(color: Color(0xFF7CB342), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview seed đã chọn (hiện ngay trước nút Trồng) ───────────────────────

class _SelectedPreview extends StatelessWidget {
  final SeedItem seed;
  const _SelectedPreview({required this.seed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            'Đã chọn: ',
            style: const TextStyle(fontSize: 12, color: Color(0xFF66BB6A)),
          ),
          Expanded(
            child: Text(
              seed.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF388E3C),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${seed.totalCards} từ',
            style: const TextStyle(fontSize: 11, color: Color(0xFF81C784)),
          ),
        ],
      ),
    );
  }
}

// ─── Badge số thứ tự ô đất ──────────────────────────────────────────────────

class _PlotBadge extends StatelessWidget {
  final int index;
  const _PlotBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBE9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD4B896)),
      ),
      child: Text(
        'Ô #$index',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8D6E63),
        ),
      ),
    );
  }
}

// ─── Card từng hạt giống ────────────────────────────────────────────────────

class _SeedCard extends StatelessWidget {
  final SeedItem seed;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeedCard({
    required this.seed,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7CB342)
                : const Color(0xFFEDE0D4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF7CB342).withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon hạt giống ──────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC8E6C9)
                    : const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(
                  'assets/game/tree/stage_0.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Text('🌱', style: TextStyle(fontSize: 26)),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Thông tin seed ──────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seed.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF388E3C)
                          : const Color(0xFF4E342E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (seed.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      seed.subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _DiffBadge(
                        label: seed.difficultyLabel,
                        color: seed.difficultyColor,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.style_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(
                        '${seed.totalCards} thẻ',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Radio / check ───────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF7CB342) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7CB342)
                      : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DiffBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}