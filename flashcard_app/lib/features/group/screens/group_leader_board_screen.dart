import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/top_user_group.dart';
import '../widgets/header_leader_group.dart';
import '../widgets/user_item_leader_group.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String groupId;
  const LeaderboardScreen({super.key, required this.groupId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = LeaderboardService.getGroupLeaderboard(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          SafeArea(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const Column(
                    children: [
                      LeaderboardHeader(),
                      Expanded(
                        child: Center(
                          child: Text("No data yet",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    const LeaderboardHeader(),
                    TopUserWidget(entry: entries.first),
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length - 1,
                        itemBuilder: (_, i) =>
                            UserItemWidget(entry: entries[i + 1]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(children: [
      Positioned(
        top: -60, right: -60,
        child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.6),
          ),
        ),
      ),
      Positioned(
        top: 100, left: -40,
        child: Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
      Positioned(
        bottom: 160, right: -30,
        child: Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
      ),
      Positioned(
        bottom: 80, left: 20,
        child: Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    ]);
  }
}