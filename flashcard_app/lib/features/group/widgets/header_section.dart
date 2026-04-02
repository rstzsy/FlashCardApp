import 'package:flashcard_app/features/group/screens/group_leader_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/themes/app_colors.dart';
import '../screens/add_member_screen.dart';
import 'copy_link.dart';
import 'info_tag.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  final String groupLink = "https://flashcard.app/group/apple123";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          /// TEXT + TAG
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 90),

              const Text(
                "Apple Group",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const InfoTag("20", "Members"),
                  const SizedBox(width: 10),
                  const InfoTag("5", "Collections"),
                  const SizedBox(width: 10),

                  // link btn
                  _circleButton(
                    Icons.link,
                    onPressed: () {
                      _showGroupLink(context);
                    },
                  ),
                ],
              ),
            ],
          ),

          // back btn
          Positioned(
            left: 0,
            top: 40,
            child: _circleButton(
              Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // add member btn
          Positioned(
            right: 16,
            top: 40,
            child: Row(
              children: [
                _circleButton(
                  Icons.group_add_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMemberPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _circleButton(
                  Icons.leaderboard_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,
            top: 90,
            child: Image.asset("assets/character/happy.png", width: 100),
          ),
        ],
      ),
    );
  }

  // button widget
  Widget _circleButton(IconData icon, {required VoidCallback onPressed}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.highlightColor),
        onPressed: onPressed,
      ),
    );
  }

  // show link
  void _showGroupLink(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // group card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Image.asset("assets/character/happy.png", height: 120),

                    const SizedBox(height: 10),

                    const Text(
                      "Apple Group",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.highlightColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // link
                    CopyLinkBox(link: groupLink),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "SHARE GROUP LINK",
                style: TextStyle(
                  color: AppColors.highlightColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              // share button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareIcon("assets/component/instagram.png", "Instagram"),
                  _shareIcon("assets/component/facebook.png", "Facebook"),
                  _shareIcon("assets/component/communication.png", "Messenger"),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _shareIcon(String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        Share.share(groupLink);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
