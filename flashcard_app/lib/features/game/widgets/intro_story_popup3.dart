import 'package:flutter/material.dart';

class IntroStoryPopup3 extends StatefulWidget {
  final VoidCallback onClose;

  const IntroStoryPopup3({super.key, required this.onClose});

  @override
  State<IntroStoryPopup3> createState() => _IntroStoryPopup3State();
}

class _IntroStoryPopup3State extends State<IntroStoryPopup3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.75, end: 1.0));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: Colors.black.withOpacity(0.70),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Transform.translate(
              offset: const Offset(-2, 0),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/game/intro_story_popup3.png', 
                    width: size.width * 0.99,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size.width * 0.95 * 0.15,
                    child: GestureDetector(
                      onTap: _dismiss,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}