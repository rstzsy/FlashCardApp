import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/themes/app_colors.dart';
import '../../flashcard/screens/flashcard_manager_screen.dart';
import '../widgets/language_bottom.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/switch_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';
import 'edit_account_screen.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../routes/main_navigation.dart'; // import mainNavKey
import '../../../core/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../flashcard/services/flashcard_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notification = true;
  bool darkMode = false;
  bool twoFactor = false;
  String language = "English";
  String _selectedCode = 'en';

  // ── Load trạng thái 2FA từ Firestore khi mở màn hình ──
  @override
  void initState() {
    super.initState();
    _loadTwoFactorStatus();
  }

  Future<void> _replayTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_flashcard_tutorial');

    if (!mounted) return;

    // return to main navigation screen (pop all routes)
    Navigator.of(context).popUntil((route) => route.isFirst);

    // change to flashcard tab 
    mainNavKey.currentState?.switchToTab(1);
  }

  Future<void> _loadTwoFactorStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) {
      setState(() {
        twoFactor = doc.data()?['twoFactorEnabled'] == true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppColors.highlightColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _sectionLabel("Customs"),
          _card([
            SettingsSwitchTile(
              icon: Icons.notifications_rounded,
              iconBg: const Color(0xFFEAF3DE),
              iconColor: const Color(0xFF3B6D11),
              title: "Notification",
              subtitle: "Receive notifications from App",
              value: notification,
              onChanged: (v) => setState(() => notification = v),
            ),
            _divider(),
            _navTile(
              icon: Icons.notifications_active_rounded,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
              title: "Test Notification",
              subtitle: "Bấm để bắn thông báo ngay",
              onTap: () {
                FlashcardNotificationService.instance.showDueNowNotification(
                  setId: 'test_set',
                  setName: 'Bộ từ Test',
                  dueCount: 5,
                );
              },
            ),
            _divider(),
            SettingsSwitchTile(
              icon: Icons.dark_mode_rounded,
              iconBg: const Color(0xFFEEEDFE),
              iconColor: const Color(0xFF534AB7),
              title: "Dark Mode",
              subtitle: "Dark theme interfaces",
              value: themeProvider.isDarkMode,
              onChanged: (v) => context.read<ThemeProvider>().toggleTheme(v),
            ),
            _divider(),
            SettingsSwitchTile(
              icon: Icons.verified_user_rounded,
              iconBg: const Color(0xFFE8F4FD),
              iconColor: const Color(0xFF1565C0),
              title: "Two-Factor Auth",
              subtitle: "Biometric verification on login",
              value: twoFactor,
              onChanged: _onTwoFactorChanged,
            ),
          ]),
          const SizedBox(height: 16),
          // _sectionLabel("Languages"),
          // _card([
          //   _navTile(
          //     icon: Icons.language_rounded,
          //     iconBg: const Color(0xFFE1F5EE),
          //     iconColor: const Color(0xFF0F6E56),
          //     title: "Languages",
          //     trailing: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 10,
          //         vertical: 4,
          //       ),
          //       decoration: BoxDecoration(
          //         color: const Color.fromARGB(255, 245, 231, 234),
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Text(
          //         language,
          //         style: const TextStyle(
          //           fontSize: 13,
          //           color: AppColors.highlightColor,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //     onTap: showLanguageDialog,
          //   ),
          // ]),
          const SizedBox(height: 16),
          _sectionLabel("Account"),
          _card([
            _navTile(
              icon: Icons.manage_accounts_rounded,
              iconBg: const Color(0xFFEEEDFE),
              iconColor: const Color(0xFF534AB7),
              title: "Edit Account",
              subtitle: "Change your name and photo",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditAccountScreen(),
                    ),
                  ),
            ),
            _divider(),
            _navTile(
              icon: Icons.school_rounded,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
              title: "Replay Tutorial",
              subtitle: "View the app tutorial again",
              onTap: _replayTutorial,
            ),
            _divider(),
            _navTile(
              icon: Icons.logout_rounded,
              iconBg: const Color(0xFFFCEBEB),
              iconColor: const Color(0xFFE24B4A),
              title: "Logout",
              titleColor: const Color(0xFFE24B4A),
              onTap: showLogoutDialog,
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _onTwoFactorChanged(bool v) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (v) {
      if (mounted) {
        AppPopup.show(
          context: context,
          title: "Confirm enabling 2FA",
          message:
              "From the next login, you will need to authenticate using biometrics. We have sent a confirmation email to ${FirebaseAuth.instance.currentUser?.email}.",
          iconWidget: Image.asset(
            'assets/component/mail2FA.png',
            width: 150,
            height: 150,
          ),
          buttonText: "Got it",
          onPressed: () async {
            // Save Firestore → Cloud Function will automatically send email
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update({'twoFactorEnabled': true});
            if (mounted) setState(() => twoFactor = true);
          },
        );
      }
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'twoFactorEnabled': false,
      });
      if (mounted) setState(() => twoFactor = false);
    }
  }

  // ── Widgets helpers (giữ nguyên) ───────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
    child: Row(
      children: [
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: AppColors.highlightColor,
          ),
        ),
      ],
    ),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF534AB7).withOpacity(0.07),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _divider() =>
      const Divider(height: 1, indent: 64, color: Color(0xFFF3F0FF));

  Widget _iconWrap(IconData icon, Color bg, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: color, size: 20),
  );

  Widget _navTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          _iconWrap(icon, iconBg, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (trailing != null) const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: const Color(0xFFC5BFFF),
          ),
        ],
      ),
    ),
  );

  // void showLanguageDialog() {
  //   LanguageBottomSheet.show(
  //     context,
  //     selectedCode: _selectedCode,
  //     onSelected: (lang) {
  //       setState(() {
  //         _selectedCode = lang.code;
  //         language = lang.name;
  //       });
  //     },
  //   );
  // }

  void showLogoutDialog() {
    LogoutDialog.show(
      context,
      onConfirm: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.introHomeScreen,
            (route) => false,
          );
        }
      },
    );
  }
}
