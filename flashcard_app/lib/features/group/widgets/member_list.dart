import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import 'member_card.dart';

class MemberList extends StatelessWidget {
  final GroupModel group;

  const MemberList({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Members",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.highlightColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 160,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                final currentUser = FirebaseAuth.instance.currentUser;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    MemberCard(
                      name: currentUser?.displayName ?? 'You',
                      avatar: currentUser?.photoURL,
                      isOwner: true,
                    )
                  ],
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final member = members[i];
                  final isOwner = member['uid'] == group.createdBy;

                  return MemberCard(
                    name: member['name'] ?? 'Unknown',
                    avatar: member['photoUrl'],
                    isOwner: member['uid'] == group.createdBy,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _loadMembers() async {
    if (group.id == null) return [];

    final membersSnap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.id)
        .collection('members')
        .get();

    if (membersSnap.docs.isEmpty) return [];

    final List<Map<String, dynamic>> members = [];

    for (final memberDoc in membersSnap.docs) {
      final uid = memberDoc.id;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        members.add({
          'uid': uid,                    
          'role': memberDoc.data()['role'] ?? 'member',
          ...userDoc.data()!,
        });
      }
    }

    members.sort((a, b) {
      if (a['uid'] == group.createdBy) return -1;
      if (b['uid'] == group.createdBy) return 1;
      return 0;
    });

    return members;
  }
}