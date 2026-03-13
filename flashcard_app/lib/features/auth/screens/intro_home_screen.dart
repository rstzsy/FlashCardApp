import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../routes/app_routes.dart';

class IntroHomeScreen extends StatefulWidget {
  const IntroHomeScreen({super.key});

  @override
  State<IntroHomeScreen> createState() => _IntroHomeScreenState();
}

class _IntroHomeScreenState extends State<IntroHomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  late AnimationController frameController;
  late AnimationController floatController;
  late Animation<double> floatAnimation;

  late AnimationController _startBtnController;
  late Animation<double> _startBtnScale;
  late Animation<double> _startBtnOpacity;

  int currentFrame = 0;

  final List<_OnboardingData> pages = [
    _OnboardingData(
      title: "Learn English",
      titleBold: "with Flashcards",
      subtitle: "Anytime. Anywhere.",
      description:
          "Build your vocabulary with smart flashcards word, meaning, pronunciation & illustration all in one card.",
      accentColor: const Color(0xBDE8F5),
      frames: [
        "assets/character/happy.png",
        "assets/character/amaz.png",
      ],
    ),
    _OnboardingData(
      title: "Powered by",
      titleBold: "AI",
      subtitle: "Your Personal Study Coach",
      description:
          "AI creates flashcards for you, suggests what to review, and plans a study schedule tailored to your goals.",
      accentColor: const Color(0x44ACFF),
      frames: [
        "assets/character/happy.png",
        "assets/character/bored.png",
      ],
    ),
    _OnboardingData(
      title: "Stay on",
      titleBold: "Track",
      subtitle: "Streaks · Badges · XP",
      description:
          "Spaced repetition keeps words fresh in your memory. Earn badges, maintain your streak, and watch your progress grow.",
      accentColor: const Color(0x1C4D8D),
      frames: [
        "assets/character/happy.png",
        "assets/character/surprised.png",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });

    frameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )
      ..addListener(() {
        setState(() {
          final currentFrames = pages[_currentPage].frames;
          currentFrame =
              (frameController.value * currentFrames.length).floor() %
              currentFrames.length;
        });
      })
      ..repeat();

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
    );

    _startBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startBtnScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _startBtnController, curve: Curves.elasticOut),
    );
    _startBtnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _startBtnController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    frameController.dispose();
    floatController.dispose();
    _pageController.dispose();
    _startBtnController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int i) {
    setState(() => _currentPage = i);
    if (i == pages.length - 1) {
      _startBtnController.forward(from: 0);
    } else {
      _startBtnController.reverse();
    }
  }

  double _pageVisibility(int pageIndex) {
    final diff = (_pageOffset - pageIndex).abs();
    return (1.0 - diff.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final visibility = _pageVisibility(index);
                      final slideOffset = (_pageOffset - index) * 60.0;

                      return Opacity(
                        opacity: visibility.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(slideOffset, 0),
                          child: _buildPage(context, pages[index], visibility),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, _OnboardingData p, double visibility) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),

          Transform.translate(
            offset: Offset(0, (1 - visibility) * 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: GoogleFonts.baloo2(
                    fontSize: 36,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      p.accentColor.withOpacity(0.6),
                      AppColors.highlightColor.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.8],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    p.titleBold,
                    style: GoogleFonts.baloo2(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.subtitle,
                  style: GoogleFonts.baloo2(
                    fontSize: 22,
                    color: Colors.black.withOpacity(0.35),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, floatAnimation.value),
                  child: child,
                ),
                child: Transform.scale(
                  scale: 0.85 + visibility * 0.15,
                  child: Image.asset(
                    p.frames[currentFrame % p.frames.length],
                    height: size.height * 0.40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          Opacity(
            opacity: visibility.clamp(0.0, 1.0),
            child: Text(
              p.description,
              style: GoogleFonts.cabin(
                fontSize: 15,
                color: Colors.black.withOpacity(0.6),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == pages.length - 1;
    final currentAccent = pages[_currentPage].accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dots: bọc toàn bộ row trong frosted blur nhẹ ──
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(pages.length, (i) {
                    final isActive = i == _currentPage;
                    final isPast   = i < _currentPage;

                    Color dotColor;
                    if (isActive) {
                      dotColor = currentAccent;
                    } else if (isPast) {
                      dotColor = currentAccent.withOpacity(0.55);
                    } else {
                      dotColor = const Color.fromARGB(255, 134, 202, 241).withOpacity(0.22);
                    }

                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          width: isActive ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: dotColor,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: currentAccent.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // ── Button: bọc trong frosted blur nhẹ ──
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: isLastPage
                ? Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ScaleTransition(
                      scale: _startBtnScale,
                      child: FadeTransition(
                        opacity: _startBtnOpacity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: _StartNowButton(
                              accentColor: currentAccent,
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    final accent = pages[_currentPage].accentColor;
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.5),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: -30,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 20,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Start Now Button ────────────────────────────────────────────────────────

class _StartNowButton extends StatefulWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _StartNowButton({required this.accentColor, required this.onTap});

  @override
  State<_StartNowButton> createState() => _StartNowButtonState();
}

class _StartNowButtonState extends State<_StartNowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: [AppColors.primary, widget.accentColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Start Now",
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────

class _OnboardingData {
  final String title;
  final String titleBold;
  final String subtitle;
  final String description;
  final Color accentColor;
  final List<String> frames;

  const _OnboardingData({
    required this.title,
    required this.titleBold,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.frames,
  });
}