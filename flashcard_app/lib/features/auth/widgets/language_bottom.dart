import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class LanguageItem {
  final String code;
  final String flag;
  final String name;
  final String native;

  const LanguageItem({
    required this.code,
    required this.flag,
    required this.name,
    required this.native,
  });
}

class LanguageBottomSheet extends StatefulWidget {
  final String selectedCode;
  final void Function(LanguageItem) onSelected;

  const LanguageBottomSheet({
    super.key,
    required this.selectedCode,
    required this.onSelected,
  });

  static final List<LanguageItem> languages = [
    LanguageItem(code: 'en', flag: '🇬🇧', name: 'English',    native: 'English'),
    LanguageItem(code: 'vi', flag: '🇻🇳', name: 'Vietnamese', native: 'Tiếng Việt'),
    LanguageItem(code: 'ja', flag: '🇯🇵', name: 'Japanese',   native: '日本語'),
    LanguageItem(code: 'ko', flag: '🇰🇷', name: 'Korean',     native: '한국어'),
    LanguageItem(code: 'zh', flag: '🇨🇳', name: 'Chinese',    native: '中文'),
    LanguageItem(code: 'fr', flag: '🇫🇷', name: 'French',     native: 'Français'),
  ];

  static void show(
    BuildContext context, {
    required String selectedCode,
    required void Function(LanguageItem) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LanguageBottomSheet(
        selectedCode: selectedCode,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedCode;
  }

  void _pick(LanguageItem lang) {
    setState(() => _current = lang.code);
    // just close when animation done
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onSelected(lang);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 10) / 2; // 2 columns

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0DBFF),
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // Header
          const SizedBox(height: 14),
          const Text(
            'Choose Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.highlightColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select your preferred language',
            style: TextStyle(fontSize: 16, color: AppColors.highlightColor),
          ),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppColors.primary,
          ),

          // wrap to avoid conflict
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: LanguageBottomSheet.languages.map((lang) {
                return SizedBox(
                  width: cardWidth,
                  height: cardWidth / 1.3,
                  child: _LangCard(
                    lang: lang,
                    isSelected: lang.code == _current,
                    onTap: () => _pick(lang),
                  ),
                );
              }).toList(),
            ),
          ),

          // Cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 148, 221, 254),
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

class _LangCard extends StatelessWidget {
  final LanguageItem lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangCard({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          //color: isSelected ? const Color.fromARGB(255, 225, 240, 246) : const Color(0xFFFDFCFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color.fromARGB(255, 240, 252, 253),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 192, 226, 248).withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Checkmark
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.elasticOut,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.highlightColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 6),
                  Text(
                    lang.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.highlightColor,
                    ),
                  ),
                  Text(
                    lang.native,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.highlightColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}