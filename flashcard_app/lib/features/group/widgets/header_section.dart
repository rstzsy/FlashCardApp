import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import '../screens/group_leader_board_screen.dart';
import 'copy_link.dart';
import 'info_tag.dart';
import '../screens/add_member_screen.dart';

class HeaderSection extends StatelessWidget {
  final GroupModel group;

  const HeaderSection({super.key, required this.group});

  String get groupLink => "https://flashcard.app/group/${group.id ?? 'unknown'}";

  Stream<List<int>> _countsStream(String groupId) {
    if (groupId.isEmpty) return Stream.value([0, 0]);

    final db = FirebaseFirestore.instance;

    final membersStream = db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((s) => s.docs.length);

    final collectionsStream = db
        .collection('groups')
        .doc(groupId)
        .collection('collections')
        .snapshots()
        .map((s) => s.docs.length);

    // Combine 2 streams: mỗi khi members thay đổi, fetch lại collections
    return membersStream.asyncMap((memberCount) async {
      final colSnap = await db
          .collection('groups')
          .doc(groupId)
          .collection('collections')
          .get();
      return [memberCount, colSnap.docs.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupId = group.id ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 90),

              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),

              const SizedBox(height: 16),

              StreamBuilder<List<int>>(
                stream: _countsStream(groupId),
                builder: (context, snapshot) {
                  final memberCount = snapshot.data?[0] ?? 0;
                  final collectionCount = snapshot.data?[1] ?? 0;

                  return Row(
                    children: [
                      InfoTag('$memberCount', 'Members'),
                      const SizedBox(width: 10),
                      InfoTag('$collectionCount', 'Collections'),
                      const SizedBox(width: 10),
                      _circleButton(
                        Icons.link,
                        onPressed: () => _showGroupLink(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Back button
          Positioned(
            left: 0,
            top: 40,
            child: _circleButton(
              Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Invite + leaderboard buttons
          Positioned(
            right: 16,
            top: 40,
            child: Row(
              children: [
                _circleButton(
                  Icons.person_add_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMemberPage(group: group),
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
                        builder: (_) => LeaderboardScreen(groupId: group.id ?? ''),
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
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.highlightColor,
                      ),
                    ),
                    const SizedBox(height: 12),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareIcon("assets/component/instagram.png", "Instagram"),
                  _shareIcon("assets/component/facebook.png", "Facebook"),
                  _shareIcon(
                      "assets/component/communication.png", "Messenger"),
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
      onTap: () => Share.share(groupLink),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(imagePath, width: 26, height: 26),
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