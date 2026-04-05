import 'package:flutter/material.dart';
import 'package:flashcard_app/routes/app_routes.dart';

class HomeGameScreen extends StatelessWidget {
  const HomeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/game/home_game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

      
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 18,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/game/back_button.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.shopGame);
                  },
                  child: Image.asset(
                    'assets/game/btn_home.png',
                    width: size.width * 0.25,
                    height: size.width * 0.25,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(width: size.width * 0.06),

                GestureDetector(
                  onTap: () {
                    // TODO: xử lý nút Mail
                  },
                  child: Image.asset(
                    'assets/game/btn_mail.png',
                    width: size.width * 0.25,
                    height: size.width * 0.25,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}