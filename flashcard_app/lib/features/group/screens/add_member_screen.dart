import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_popup.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import '../widgets/member_search_bar.dart';

class AddMemberPage extends StatefulWidget {
  final GroupModel group;

  const AddMemberPage({super.key, required this.group});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final List<Map<String, dynamic>> _selectedUsers = [];
  Set<String> _pendingUids = {};   // ← track đã gửi
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final results = await Future.wait([
      GroupService.getAllUsers(),
      GroupService.getExistingMemberIds(widget.group.id ?? ''),
      GroupService.getPendingInvitationUids(widget.group.id ?? ''), 
    ]);

    final users      = results[0] as List<Map<String, dynamic>>;
    final existingIds = results[1] as Set<String>;
    final pendingIds  = results[2] as Set<String>;   

    final filtered = users
        .where((u) =>
            u['uid'] != widget.group.createdBy &&
            !existingIds.contains(u['uid']))
        .toList();

    setState(() {
      _allUsers     = filtered;
      _filteredUsers = filtered;
      _pendingUids  = pendingIds;
      _loading      = false;
    });
  }

  void _searchUser(String keyword) {
    setState(() {
      _filteredUsers = _allUsers
          .where((u) => (u['name'] as String? ?? '')
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void _toggleSelect(Map<String, dynamic> user) {
    final uid = user['uid'] as String;
    if (_pendingUids.contains(uid)) return; 
    setState(() {
      final isSelected = _selectedUsers.any((u) => u['uid'] == uid);
      if (isSelected) {
        _selectedUsers.removeWhere((u) => u['uid'] == uid);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  bool _isSelected(Map<String, dynamic> user) =>
      _selectedUsers.any((u) => u['uid'] == user['uid']);

  Future<void> _sendInvites() async {
    setState(() => _sending = true);

    for (final user in _selectedUsers) {
      await GroupService.sendInvitation(
        groupId:   widget.group.id ?? '',
        groupName: widget.group.name,
        toUid:     user['uid'],
      );
    }

    // Cập nhật pendingUids ngay sau khi gửi
    final newPendingUids = _selectedUsers.map((u) => u['uid'] as String).toSet();

    setState(() {
      _pendingUids = {..._pendingUids, ...newPendingUids};
      _selectedUsers.clear();
      _sending = false;
    });

    if (!mounted) return;
    AppPopup.show(
      context: context,
      title: "Invitations Sent",
      message: "Sent ${newPendingUids.length} invitation(s) successfully!",
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.highlightColor,
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Invite Members",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.highlightColor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemberSearchBar(
            controller: _searchController,
            onChanged: _searchUser,
          ),

          const SizedBox(height: 12),

          // Selected strip
          if (_selectedUsers.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedUsers.length,
                itemBuilder: (_, i) {
                  final u = _selectedUsers[i];
                  final avatar = u['photoUrl'] as String?;
                  return GestureDetector(
                    onTap: () => _toggleSelect(u),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: (avatar != null && avatar.isNotEmpty)
                                    ? NetworkImage(avatar)
                                    : null,
                                child: (avatar == null || avatar.isEmpty)
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (u['name'] as String? ?? '').split(' ').first,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              "All Users",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
                letterSpacing: 0.4,
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_search_rounded,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("User not found",
                                style: TextStyle(color: Colors.grey.shade400)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (_, i) {
                          final u = _filteredUsers[i];
                          final uid = u['uid'] as String;
                          final isPending  = _pendingUids.contains(uid);
                          final isSelected = _isSelected(u);
                          final avatar = u['photoUrl'] as String?;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (avatar != null && avatar.isNotEmpty)
                                  ? NetworkImage(avatar)
                                  : null,
                              child: (avatar == null || avatar.isEmpty)
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              u['name'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(u['email'] ?? ''),
                            trailing: isPending
                                ? _PendingBadge()           // ← Pending
                                : _SelectCheckbox(selected: isSelected), // ← Checkbox
                            onTap: () => _toggleSelect(u),
                          );
                        },
                      ),
          ),

          // Send button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _selectedUsers.isEmpty || _sending ? null : _sendInvites,
                icon: _sending
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _selectedUsers.isEmpty
                      ? "Select users to invite"
                      : "Send ${_selectedUsers.length} Invitation(s)",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.highlightColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pending badge ──────────────────────────────────────────────
class _PendingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: Colors.orange.shade600),
          const SizedBox(width: 4),
          Text(
            "Pending",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Select checkbox ────────────────────────────────────────────
class _SelectCheckbox extends StatelessWidget {
  final bool selected;
  const _SelectCheckbox({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.highlightColor : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.highlightColor : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}