class UserModel {
  final String id;
  final String name;
  final String avatar;
  bool isSelected;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.isSelected = false,
  });
}