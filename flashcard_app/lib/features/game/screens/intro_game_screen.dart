import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroGameScreen extends StatefulWidget {
  const IntroGameScreen({super.key});

  @override
  State<IntroGameScreen> createState() => _IntroGameScreenState();
}

class _IntroGameScreenState extends State<IntroGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _glowController;

  Animation<double> _pulseAnimation = const AlwaysStoppedAnimation(1.0);
  Animation<double> _floatAnimation = const AlwaysStoppedAnimation(0.0);
  Animation<double> _glowAnimation  = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background ─────────────────────────────────────────────
          Image.asset(
            'assets/game/bggame.png',
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
          ),

          // ── 2. Top vignette (làm nền logo dễ đọc hơn) ────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Bottom vignette (nổi bật vùng nút play) ───────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 4. Logo (căn giữa phần trên, floating) ────────────────────
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hào quang phía sau logo
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, _) => Container(
                      width: size.width * 0.72,
                      height: size.width * 0.50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(0.18 * _glowAnimation.value),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Ảnh logo
                  Image.asset(
                    'assets/game/MofuGardenGame.png',
                    width: size.width * 0.82,  
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Settings button (top-right) ────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 18,
            child: _SettingsButton(onTap: () {}),
          ),

          // ── 6. Play button (lower-center, pulsing + glow) ─────────────
          Positioned(
            bottom: size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, AppRoutes.game);
                  },
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent
                                .withOpacity(0.55 * _glowAnimation.value),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(0.20 * _glowAnimation.value),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Image.asset(
                      'assets/game/intro_play_button.png',
                      width: size.width * 0.78,  
                      height: size.width * 0.48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 7. "TAP TO PLAY" label dưới nút ──────────────────────────
          Positioned(
            bottom: size.height * 0.055,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Opacity(
                opacity: 0.55 + 0.45 * _glowAnimation.value,
                child: child,
              ),
              child: const Text(
                'TAP TO PLAY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Button ───────────────────────────────────────────────────────────
class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1BAE6B),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.settings_rounded, color: Colors.white, size: 23),
      ),
    );
  }
}