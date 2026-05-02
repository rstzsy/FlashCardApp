// lib/features/game/widgets/seed_card.dart
import 'package:flutter/material.dart';
import 'package:flashcard_app/features/game/models/garden_models.dart';

// ─── Seed card (flower / plant) ──────────────────────────────────────────────

class SeedCard extends StatelessWidget {
  final SeedItem seed;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const SeedCard({
    super.key,
    required this.seed,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.38 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B4A20)
              : const Color(0xFF52351A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8C87A)
                : const Color(0xFF8A6030),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8C87A).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Flower image – fixed ratio, always centered ──────────
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(
                          seed.imagePath ?? 'assets/game/tulip.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/game/tulip.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Title ────────────────────────────────────────────────
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        seed.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF8BC34A)
                              : const Color(0xFF7CB342),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // ── Card count badge ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8C87A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${seed.totalCards}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5A3A10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            // Badge: already planted
            if (isDisabled)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2E0A).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF8A6030), width: 1),
                  ),
                  child: const Text(
                    'Planted',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB89050),
                    ),
                  ),
                ),
              ),

            // Checkmark when selected
            if (isSelected && !isDisabled)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8BC34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Ghost widget while dragging a seed ──────────────────────────────────────

class SeedDragFeedback extends StatelessWidget {
  final SeedItem seed;

  const SeedDragFeedback({super.key, required this.seed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: 100,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF64B5F6).withOpacity(0.85),
                    const Color(0xFF7E57C2).withOpacity(0.55),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Inner highlight
          Positioned(
            bottom: 8,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.7),
                    const Color(0xFF64B5F6).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Flower image – centered in drag ghost
          Positioned(
            top: 0,
            left: 10,
            right: 10,
            child: Image.asset(
              seed.imagePath ?? 'assets/game/tulip.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/game/tulip.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}