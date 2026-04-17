import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController frameController;
  late AnimationController floatController;
  late AnimationController bubbleController;
  late Animation<double> floatAnimation;

  int currentFrame = 0;
  final LoginController _loginController = LoginController();
  final List<String> frames = [
    "assets/character/happy.png",
    "assets/character/amaz.png",
  ];

  @override
  void initState() {
    super.initState();

    // sprite animation
    frameController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )
          ..addListener(() {
            setState(() {
              currentFrame =
                  (frameController.value * frames.length).floor() %
                  frames.length;
            });
          })
          ..repeat();

    // floating up down
    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
    );

    // bubble animation
    bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    frameController.dispose();
    floatController.dispose();
    bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          // bubble background
          _buildBackgroundBlobs(),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 36),

                // title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome to My App",
                        style: GoogleFonts.cabin(
                          fontSize: 40,
                          color: AppColors.highlightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Character ,glow circle
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, floatAnimation.value),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // soft border circle
                          Container(
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.35),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),

                          // inner circle
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, Colors.white],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                          ),

                          // character sprite
                          Positioned(
                            bottom: -10,
                            child: Image.asset(
                              frames[currentFrame],
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // google login button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        try {
                          final user =
                              await _loginController.signInWithGoogle();

                          if (user != null) {
                            print("Login success: ${user.displayName}");

                            // TODO: chuyển màn hình
                            // Navigator.pushReplacement(...)
                          }
                        } catch (e) {
                          print("Login failed: $e");
                        }
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          // bg color button
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary,
                              Color.fromARGB(255, 94, 200, 249),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),

                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                // border icon gg
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),

                                // icon google
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.g_mobiledata_rounded,
                                  color: AppColors.highlightColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Login via Google",
                                style: GoogleFonts.cabin(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // background decore bubble
  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.6),
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
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
