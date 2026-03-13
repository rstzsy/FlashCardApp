import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/themes/app_colors.dart';
import '../widgets/language_bottom.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/switch_component.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notification = true;
  bool darkMode = false;
  String language = "English";
  String _selectedCode = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.mainColor,
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
            SettingsSwitchTile(
              icon: Icons.dark_mode_rounded,
              iconBg: const Color(0xFFEEEDFE),
              iconColor: const Color(0xFF534AB7),
              title: "Dark Mode",
              subtitle: "Dark theme interfaces",
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel("Languages"),
          _card([
            _navTile(
              icon: Icons.language_rounded,
              iconBg: const Color(0xFFE1F5EE),
              iconColor: const Color(0xFF0F6E56),
              title: "Languages",
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 231, 234),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  language,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.highlightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: showLanguageDialog,
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel("Account"),
          _card([
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

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
    child: Row(
      children: [
        // Container(
        //   width: 4,
        //   height: 16,
        //   decoration: BoxDecoration(
        //     color: AppColors.highlightColor,
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        // ),
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

  Widget _switchTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF7F77DD),
        ),
      ],
    ),
  );

  Widget _navTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    Color? titleColor,
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: titleColor ?? Colors.black87,
              ),
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

  void showLanguageDialog() {
    LanguageBottomSheet.show(
      context,
      selectedCode: _selectedCode,
      onSelected: (lang) {
        setState(() {
          _selectedCode = lang.code;
          language = lang.name;
        });
      },
    );
  }

  void showLogoutDialog() {
    LogoutDialog.show(
      context,
      onConfirm: () {
        // handle logout
      },
    );
  }
}
