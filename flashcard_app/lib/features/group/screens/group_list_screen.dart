import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';
import '../controllers/group_controller.dart';
import '../services/group_service.dart';
import '../widgets/group_card.dart';
import 'add_group_screen.dart';
import 'group_dashboard_screen.dart';
import '../widgets/delete_group_dialog.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<GroupController>().listenToGroups();
    }
  }

  void _goToAddGroup() async {
    await Navigator.push<GroupModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddGroupPage()),
    );
  }

  void _showInvitations() {
    showModalBottomSheet(
      context: context,
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _InvitationSheet(),
    );
  }

  void _confirmDeleteGroup(BuildContext context, GroupModel group) {
    DeleteGroupDialog.show(
      context,
      groupName: group.name,
      onConfirm: () async {
        await GroupService.deleteGroup(group.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GroupController>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Group List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.highlightColor,
          ),
        ),
        actions: [
          if (uid != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invitations')
                  .where('toUid', isEqualTo: uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.highlightColor,
                      ),
                      onPressed: _showInvitations,
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.highlightColor),
            onPressed: _goToAddGroup,
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_off,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        "No groups yet",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.groups.length,
                  itemBuilder: (context, index) {
                    final group = controller.groups[index];
                    final isAdmin = GroupService.isAdmin(group);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupCard(
                        group: group,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDashboard(group: group),
                            ),
                          );
                        },
                        onLongPress: isAdmin
                            ? () => _confirmDeleteGroup(context, group)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Invitation Sheet ──────────────────────────────────────────────────────────

class _InvitationSheet extends StatelessWidget {
  const _InvitationSheet();

  Color _cardColor(int index) {
    const colors = [
      Color(0xFFDFF2EB),
      Color(0xFFFFF3DC),
      Color(0xFFEDE7FF),
      Color(0xFFFFE4E4),
      Color(0xFFD6EFFF),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                "Group Invitations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('invitations')
                      .where('toUid', isEqualTo: uid)
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mail_outline,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              "No invitations",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final inviteId = docs[i].id;
                        final bgColor = _cardColor(i);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -2,
                                top: 0,
                                bottom: 0,
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Image.asset(
                                    'assets/component/book_watermark.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['groupName'] ?? 'Unknown Group',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text(
                                    "Invited by ${data['fromName'] ?? 'Unknown'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black.withOpacity(0.55),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  Row(
                                    children: [
                                      const Icon(Icons.mail_outline,
                                          size: 16, color: Colors.black45),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "Pending",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const Spacer(),

                                      GestureDetector(
                                        onTap: () =>
                                            _declineInvite(inviteId),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Decline',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      GestureDetector(
                                        onTap: () => _acceptInvite(
                                          context,
                                          inviteId: inviteId,
                                          groupId: data['groupId'],
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.highlightColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acceptInvite(
    BuildContext context, {
    required String inviteId,
    required String groupId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final db = FirebaseFirestore.instance;

    await db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .set({
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await db.collection('groups').doc(groupId).update({
      'memberCount': FieldValue.increment(1),
    });

    await db.collection('invitations').doc(inviteId).update({
      'status': 'accepted',
    });

    if (!context.mounted) return;

    final groupDoc = await db.collection('groups').doc(groupId).get();
    if (!context.mounted) return;

    if (groupDoc.exists) {
      final group = GroupModel.fromFirestore(groupDoc.id, groupDoc.data()!);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDashboard(group: group),
        ),
      );
    }
  }

  Future<void> _declineInvite(String inviteId) async {
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(inviteId)
        .update({'status': 'declined'});
  }
}