import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../group/models/group_model.dart';
import '../services/blog_service.dart';

class GroupMembersScreen extends StatefulWidget {
  final GroupModel group;
  const GroupMembersScreen({super.key, required this.group});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    final members =
        await BlogService.getGroupMembers(widget.group.id);
    if (mounted) {
      setState(() {
        _members = members;
        _loading = false;
      });
    }
  }

  Future<void> _toggleRole(Map<String, dynamic> member) async {
    final role = member['role'] as String;
    if (role == 'admin') return;

    if (role == 'moderator') {
      await BlogService.demoteModerator(
        groupId:   widget.group.id,
        targetUid: member['uid'] as String,
      );
    } else {
      await BlogService.promoteMember(
        groupId:   widget.group.id,
        targetUid: member['uid'] as String,
      );
    }
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Column(
        children: [
          // Header
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DD9F5).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Color(0xFF0277BD),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Manage Members',
                  style: TextStyle(
                    fontSize:   20,
                    fontWeight: FontWeight.w800,
                    color:      Color(0xFF01579B),
                  ),
                ),
              ],
            ),
          ),

          // Body
          _loading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0277BD)),
                  ),
                )
              : Expanded(
                  child: _members.isEmpty
                      ? const Center(
                          child: Text(
                            'No members found.',
                            style: TextStyle(
                                fontSize: 14,
                                color:    Colors.black45),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _members.length,
                          itemBuilder: (_, i) {
                            final m       = _members[i];
                            final role    = m['role'] as String;
                            final isAdmin = role == 'admin';
                            final isMod   = role == 'moderator';

                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.55),
                                borderRadius:
                                    BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4DD9F5)
                                        .withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        const Color(0xFFDBEAFE),
                                    backgroundImage:
                                        (m['avatar'] as String)
                                                .isNotEmpty
                                            ? NetworkImage(
                                                m['avatar'] as String)
                                            : null,
                                    child: (m['avatar'] as String)
                                            .isEmpty
                                        ? Text(
                                            (m['name'] as String)
                                                    .isNotEmpty
                                                ? (m['name'] as String)[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize:   16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D4ED8),
                                            ),
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 12),

                                  // Name + badge
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['name'] as String,
                                          style: const TextStyle(
                                            fontSize:   14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _RoleBadge(role: role),
                                      ],
                                    ),
                                  ),

                                  // Promote / Demote button
                                  if (!isAdmin)
                                    GestureDetector(
                                      onTap: () => _toggleRole(m),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isMod
                                              ? Colors.orange
                                                  .withOpacity(0.15)
                                              : const Color(0xFF0277BD)
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),
                                        child: Text(
                                          isMod ? 'Demote' : 'Promote',
                                          style: TextStyle(
                                            fontSize:   12,
                                            fontWeight: FontWeight.w700,
                                            color: isMod
                                                ? Colors.orange.shade800
                                                : const Color(
                                                    0xFF0277BD),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}

// ── Role badge ─────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color  bg;
    final Color  fg;

    switch (role) {
      case 'admin':
        label = '👑 Admin';
        bg    = const Color(0xFFFFF3E0);
        fg    = const Color(0xFFEF6C00);
      case 'moderator':
        label = '🛡️ Moderator';
        bg    = const Color(0xFFE3F2FD);
        fg    = const Color(0xFF0277BD);
      default:
        label = '👤 Member';
        bg    = const Color(0xFFF3F4F6);
        fg    = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      fg,
        ),
      ),
    );
  }
}