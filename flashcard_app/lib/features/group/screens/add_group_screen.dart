import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../models/userModel.dart';
import '../widgets/add_group_button.dart';
import '../widgets/member_search_bar.dart';
import '../widgets/select_member_strip.dart';
import '../widgets/user_list_item.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<UserModel> _users = [
    UserModel(id: "1", name: "shisaki", avatar: "assets/account/acc1.jpg"),
    UserModel(
      id: "2",
      name: "Nguyen Van Phuoc",
      avatar: "assets/account/acc2.jpg",
    ),
    UserModel(id: "3", name: "Van", avatar: "assets/account/acc3.jpg"),
    UserModel(
      id: "4",
      name: "Ngoc Nguyen Hong",
      avatar: "assets/account/acc4.jpg",
    ),
    UserModel(
      id: "5",
      name: "Tran Thi Thanh",
      avatar: "assets/account/acc5.jpg",
    ),
  ];

  List<UserModel> _filteredUsers = [];
  List<UserModel> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  void _searchUser(String keyword) {
    setState(() {
      _filteredUsers =
          _users
              .where(
                (u) => u.name.toLowerCase().contains(keyword.toLowerCase()),
              )
              .toList();
    });
  }

  void _toggleSelect(UserModel user) {
    setState(() {
      user.isSelected = !user.isSelected;

      if (user.isSelected) {
        _selectedUsers.add(user);
      } else {
        _selectedUsers.remove(user);
      }
    });
  }

  void _addMembers() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      AppPopup.show(
        context: context,
        title: "Missing Name",
        message: "Please enter group name",
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    for (var user in _selectedUsers) {
      debugPrint("Add member: ${user.name}");
    }

    AppPopup.show(
      context: context,
      title: "Success",
      message:
          "Group \"$groupName\" created with ${_selectedUsers.length} members",
    );
  }

  Widget _buildGroupNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TextField(
        controller: _groupNameController,
        style: const TextStyle(color: AppColors.highlightColor),
        decoration: InputDecoration(
          hintText: "Enter group name",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.group, color: AppColors.highlightColor),
          filled: true,
          fillColor: AppColors.mainColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.highlightColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.highlightColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.highlightColor,
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Create Group",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.highlightColor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // group name input
          _buildGroupNameInput(),

          // search
          MemberSearchBar(
            controller: _searchController,
            onChanged: _searchUser,
          ),

          const SizedBox(height: 12),

          // selected users
          SelectedMemberStrip(
            selectedUsers: _selectedUsers,
            onRemove: _toggleSelect,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              "Suggests",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
                letterSpacing: 0.4,
              ),
            ),
          ),

          Expanded(
            child:
                _filteredUsers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 56,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "User not exist",
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      itemCount: _filteredUsers.length,
                      itemBuilder:
                          (_, i) => UserListItem(
                            user: _filteredUsers[i],
                            onTap: () => _toggleSelect(_filteredUsers[i]),
                          ),
                    ),
          ),

          // add button
          AddGroupButton(
            selectedCount: _selectedUsers.length,
            groupName: _groupNameController.text,
            onPressed: _selectedUsers.isEmpty ? null : _addMembers,
          ),
        ],
      ),
    );
  }
}
