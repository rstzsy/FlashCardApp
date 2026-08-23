import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import 'member_card.dart';

class MemberList extends StatefulWidget {
  final GroupModel group;

  const MemberList({super.key, required this.group});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  bool get _isOwner =>
      FirebaseAuth.instance.currentUser?.uid == widget.group.createdBy;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    if (widget.group.id == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    final membersSnap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.id)
        .collection('members')
        .get();

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
      if (a['uid'] == widget.group.createdBy) return -1;
      if (b['uid'] == widget.group.createdBy) return 1;
      if (a['role'] == 'moderator') return -1;
      if (b['role'] == 'moderator') return 1;
      return 0;
    });

    if (mounted) setState(() {
      _members = members;
      _loading = false;
    });
  }

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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _members.isEmpty
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        MemberCard(
                          name: FirebaseAuth.instance.currentUser
                                  ?.displayName ??
                              'You',
                          avatar:
                              FirebaseAuth.instance.currentUser?.photoURL,
                          isOwner: true,
                          isModerator: false,
                        ),
                      ],
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _members.length,
                      itemBuilder: (_, i) {
                        final member = _members[i];
                        final isOwner =
                            member['uid'] == widget.group.createdBy;
                        final isModerator = member['role'] == 'moderator';
                        final isSelf = member['uid'] ==
                            FirebaseAuth.instance.currentUser?.uid;

                        return GestureDetector(
                          onLongPress: (_isOwner && !isSelf && !isOwner)
                              ? () => _showRoleOptions(
                                    context,
                                    member: member,
                                    isModerator: isModerator,
                                  )
                              : null,
                          child: MemberCard(
                            name: member['name'] ?? 'Unknown',
                            avatar: member['photoUrl'],
                            isOwner: isOwner,
                            isModerator: !isOwner && isModerator,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showRoleOptions(
    BuildContext context, {
    required Map<String, dynamic> member,
    required bool isModerator,
  }) {
    final name = member['name'] ?? 'Unknown';
    final uid = member['uid'] as String;

    showModalBottomSheet(
      context: context,
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              isModerator
                  ? 'Current role: Moderator'
                  : 'Current role: Member',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),

            const SizedBox(height: 20),

            if (!isModerator)
              _actionTile(
                context,
                icon: Icons.shield_outlined,
                label: 'Promote to Moderator',
                color: AppColors.highlightColor,
                onTap: () async {
                  Navigator.pop(context);
                  await GroupService.promoteMember(
                    groupId: widget.group.id ?? '',
                    uid: uid,
                  );
                  await _loadMembers();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('$name is now a moderator')),
                    );
                  }
                },
              ),

            if (isModerator)
              _actionTile(
                context,
                icon: Icons.person_outline,
                label: 'Demote to Member',
                color: Colors.orange,
                onTap: () async {
                  Navigator.pop(context);
                  await GroupService.demoteMember(
                    groupId: widget.group.id ?? '',
                    uid: uid,
                  );
                  await _loadMembers();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$name is now a member')),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}