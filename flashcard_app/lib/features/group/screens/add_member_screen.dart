import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../models/userModel.dart';
import '../widgets/add_member_button.dart';
import '../widgets/member_search_bar.dart';
import '../widgets/select_member_strip.dart';
import '../widgets/user_list_item.dart';


class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<UserModel> _users = [
    UserModel(id: "1", name: "shisaki", avatar: "assets/account/acc1.jpg"),
    UserModel(id: "2", name: "Nguyen Van Phuoc", avatar: "assets/account/acc2.jpg"),
    UserModel(id: "3", name: "Van", avatar: "assets/account/acc3.jpg"),
    UserModel(id: "4", name: "Ngoc Nguyen Hong", avatar: "assets/account/acc4.jpg"),
    UserModel(id: "5", name: "Tran Thi Thanh", avatar: "assets/account/acc5.jpg"),
  ];

  List<UserModel> _filteredUsers = [];
  final List<UserModel> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  void _searchUser(String keyword) {
    setState(() {
      _filteredUsers = _users
          .where((u) => u.name.toLowerCase().contains(keyword.toLowerCase()))
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
    AppPopup.show(
      context: context,
      title: "Success",
      message: "Add ${_selectedUsers.length} members into group",
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
          "Add Members",
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
          MemberSearchBar(
            controller: _searchController,
            onChanged: _searchUser,
          ),
          const SizedBox(height: 12),
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
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search_rounded,
                            size: 56, color: Colors.grey.shade300),
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
                    itemBuilder: (_, i) => UserListItem(
                      user: _filteredUsers[i],
                      onTap: () => _toggleSelect(_filteredUsers[i]),
                    ),
                  ),
          ),
          AddMemberButton(
            selectedCount: _selectedUsers.length,
            onPressed: _selectedUsers.isEmpty ? null : _addMembers,
          ),
        ],
      ),
    );
  }
}