import 'dart:math';

import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../widgets/top_user_group.dart';
import '../widgets/header_leader_group.dart';
import '../widgets/user_item_leader_group.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: [
          _buildBackgroundBlobs(), 

          SafeArea(
            child: Column(
              children: const [
                LeaderboardHeader(),
                TopUserWidget(),
                Expanded(child: UserListWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

// user list
class UserListWidget extends StatelessWidget {
  const UserListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserItemWidget(user: users[index]);
      },
    );
  }
}

// model -> backend dto
class User {
  final String name;
  final String avatar;
  final int percent;
  final int rank;

  User({
    required this.name,
    required this.avatar,
    required this.percent,
    required this.rank,
  });
}

// data
List<User> users = [
  User(name: "Michael Kaphler", avatar: "https://i.pravatar.cc/150?img=2", percent: 75, rank: 2),
  User(name: "Alice Keller", avatar: "https://i.pravatar.cc/150?img=3", percent: 73, rank: 3),
  User(name: "Peter Drisdago", avatar: "https://i.pravatar.cc/150?img=4", percent: 69, rank: 4),
  User(name: "George Limbot", avatar: "https://i.pravatar.cc/150?img=5", percent: 70, rank: 5),
  User(name: "Julie Berger", avatar: "https://i.pravatar.cc/150?img=6", percent: 68, rank: 6),
  User(name: "Dave Jhonson", avatar: "https://i.pravatar.cc/150?img=7", percent: 65, rank: 7),
];
