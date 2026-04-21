import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_popup.dart'; 

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _pickedImage;
  String? _currentPhotoUrl;
  String? _currentEmail;
  bool _isSaving = false;

  static const _surface = Color(0xFFF2F5FA);
  static const _card = Colors.white;
  static const _cardBorder = Color(0xFFE4EDF5);
  static const _iconBg = Color(0xFFEBF5FB);
  static const _labelColor = Color(0xFFA05C46);
  static const _valueColor = Color(0xFFB48D71);
  static const _mutedValue = Color.fromARGB(255, 219, 149, 134);
  static const _infoNote = Color.fromARGB(255, 248, 225, 233);
  static const _infoNoteBorder = Color.fromARGB(255, 241, 174, 194);
  static const _infoNoteText = Color.fromARGB(255, 230, 56, 120);
  static const _danger = Color(0xFFE24B4A);

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};
    setState(() {
      _nameController.text = data['name'] ?? user.displayName ?? '';
      _currentEmail = data['email'] ?? user.email ?? '';
      _currentPhotoUrl = data['photoUrl'] ?? data['photoURL'] ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<String?> _uploadImage(File file, String uid) async {
    final ref = FirebaseStorage.instance.ref('avatars/$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? newPhotoUrl = _currentPhotoUrl;
      if (_pickedImage != null) {
        newPhotoUrl = await _uploadImage(_pickedImage!, user.uid);
      }
      final newName = _nameController.text.trim();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': newName,
        'photoUrl': newPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(newName);
      if (newPhotoUrl != null) await user.updatePhotoURL(newPhotoUrl);

      if (mounted) {
        AppPopup.show(
          context: context,
          title: "Updated!",
          message: "Your profile has been saved successfully.",
          iconWidget: Image.asset(
            'assets/character/happy.png', 
            width: 100,
            height: 100,
          ),
          showConfetti: true,
          buttonText: "Great!",
          onPressed: () => Navigator.pop(context),
        );
      }
    } catch (_) {
      if (mounted) {
        AppPopup.show(
          context: context,
          title: "Oops!",
          message: "Failed to update. Please try again.",
          icon: Icons.error_outline_rounded,
          iconWidget: Image.asset(
            'assets/character/worry.png', 
            width: 100,
            height: 100,
          ),
          showConfetti: false,
          buttonText: "Try Again",
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Profile info"),
                    _buildProfileCard(),
                    const SizedBox(height: 10),
                    _buildInfoNote(
                        "Email is linked to Google and cannot be changed here"),
                    const SizedBox(height: 16),
                    _sectionLabel("Account"),
                    _buildAccountCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 218, 241, 248)),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 74, 183, 250)
                        .withOpacity(0.22),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Color.fromARGB(255, 248, 127, 156), size: 24),
                ),
              ),
              const Text(
                "Edit Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.highlightColor,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: _isSaving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 74, 183, 250)
                        .withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromARGB(255, 7, 14, 17),
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            color: Color.fromARGB(255, 253, 121, 136),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFC8E8F4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE8F5FB),
                    ),
                    child: ClipOval(
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, fit: BoxFit.cover)
                          : (_currentPhotoUrl != null &&
                                  _currentPhotoUrl!.isNotEmpty
                              ? Image.network(_currentPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback())
                              : _avatarFallback()),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        size: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap to change photo",
            style: TextStyle(
                fontSize: 14,
                color: AppColors.highlightColor,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Center(
        child: Text(
          (_nameController.text.isNotEmpty
                  ? _nameController.text[0]
                  : 'A')
              .toUpperCase(),
          style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 252, 179, 228)),
        ),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.highlightColor,
              letterSpacing: 0.9),
        ),
      );

  Widget _imageBox(String assetPath) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 251, 243, 235), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      );

  Widget _iconBox(IconData icon) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: _iconBg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 17),
      );

  Widget _buildProfileCard() => _card2([
        // Name — editable
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              _imageBox('assets/component/profile.png'), // ← ảnh
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Display name",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _labelColor)),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _valueColor),
                      decoration: const InputDecoration(
                        hintText: "Your name",
                        hintStyle:
                            TextStyle(color: _mutedValue, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 3),
                        errorStyle:
                            TextStyle(color: _danger, fontSize: 11),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Name cannot be empty";
                        }
                        if (v.trim().length < 2) {
                          return "At least 2 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.primary),
              ),
            ],
          ),
        ),
        _rowDivider(),
        // Email — locked
        _readOnlyRow(
          imageAsset: 'assets/component/mail.png', 
          label: "Email address",
          value: _currentEmail ?? '',
          muted: true,
          trailing: Icon(Icons.lock_outline_rounded,
              size: 15, color: _labelColor.withOpacity(0.5)),
        ),
      ]);

  Widget _buildAccountCard() => _card2([
        _readOnlyRow(
          imageAsset: 'assets/component/shield.png', 
          label: "Sign-in provider",
          valueWidget: _googleBadge(),
        ),
        _rowDivider(),
        _readOnlyRow(
          imageAsset: 'assets/component/lock.png', 
          label: "Password",
          value: "Managed by Google",
          muted: true,
        ),
      ]);

  Widget _buildInfoNote(String text) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _infoNote,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _infoNoteBorder),
        ),
        child: Row(
          children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 240, 43, 96),
                    shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _infoNoteText,
                      height: 1.4)),
            ),
          ],
        ),
      );

  Widget _card2(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(children: children),
      );

  Widget _rowDivider() => const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F5FA),
      indent: 16,
      endIndent: 0);

  // ── _readOnlyRow nhận imageAsset hoặc icon ──
  Widget _readOnlyRow({
    IconData? icon,
    String? imageAsset,
    required String label,
    String? value,
    bool muted = false,
    Widget? trailing,
    Widget? valueWidget,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            imageAsset != null ? _imageBox(imageAsset) : _iconBox(icon!),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _labelColor)),
                  const SizedBox(height: 3),
                  valueWidget ??
                      Text(value ?? '',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: muted ? _mutedValue : _valueColor)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );

  Widget _googleBadge() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBorder)),
              child: const Center(
                child: Text("G",
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4))),
              ),
            ),
            const SizedBox(width: 5),
            const Text("Google",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _infoNoteText)),
          ],
        ),
      );

  
}