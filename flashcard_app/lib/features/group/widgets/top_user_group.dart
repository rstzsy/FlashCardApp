import 'package:flutter/material.dart';

import 'header_leader_group.dart';


class TopUserWidget extends StatelessWidget {
  const TopUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AvatarWithCrown(),
        SizedBox(height: 10),
        UserName(),
        SizedBox(height: 6),
        CompletedBadge(),
        SizedBox(height: 20),
      ],
    );
  }
}

class UserName extends StatelessWidget {
  const UserName({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Kameron Porter",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class CompletedBadge extends StatelessWidget {
  const CompletedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 233, 165),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "100% completed",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}