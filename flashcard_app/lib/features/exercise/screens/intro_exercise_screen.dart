import 'package:flutter/material.dart';

import 'compound_word_screen.dart';
import 'fertilizer_challenge_screen.dart';

class IntroExerciseScreen extends StatelessWidget {
  const IntroExerciseScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _NavBox(
                        image: 'assets/component/game.png', 
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFD6E0), Color(0xFFFFB3C6)],
                        ),
                        label: 'Compound\nWords Game',
                        onTap: () => _push(context, const SentenceGameScreen()),
                      ),
                    ),
                    Expanded(
                      child: _ImageBox(
                        image: 'assets/character/shock.png',
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFFD4C5F9), Color(0xFFBFAEF5)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ImageBox(
                        image: 'assets/character/discovery.png',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB5EAD7), Color(0xFF9DDEC8)],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _NavBox(
                        image: 'assets/component/game.png', 
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFFFFE5B4), Color(0xFFFFD08A)],
                        ),
                        label: 'Words\nFilling Game',
                        onTap: () => _push(context, const FertilizerChallengeScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // center icon
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text('', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),

          // back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: Color(0xFF333355)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// nav box
class _NavBox extends StatefulWidget {
  final String image;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _NavBox({
    required this.image,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_NavBox> createState() => _NavBoxState();
}

class _NavBoxState extends State<_NavBox>
    with SingleTickerProviderStateMixin {
  double _scale = 1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _scale = 0.96);
        _controller.forward(from: 0);
      },
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(gradient: widget.gradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(widget.image),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5A4A6A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// image box
class _ImageBox extends StatelessWidget {
  final String image;
  final LinearGradient gradient;

  const _ImageBox({
    required this.image,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.asset(image, width: 200),
      ),
    );
  }
}
