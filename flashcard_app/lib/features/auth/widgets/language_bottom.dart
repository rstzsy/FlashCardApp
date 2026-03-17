import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class LanguageItem {
  final String code;
  final String countryCode; // ISO 3166-1 alpha-2 cho flagcdn
  final String name;
  final String native;

  const LanguageItem({
    required this.code,
    required this.countryCode,
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
    LanguageItem(code: 'en', countryCode: 'gb', name: 'English',    native: 'English'),
    LanguageItem(code: 'vi', countryCode: 'vn', name: 'Vietnamese', native: 'Tiếng Việt'),
    LanguageItem(code: 'ja', countryCode: 'jp', name: 'Japanese',   native: '日本語'),
    LanguageItem(code: 'ko', countryCode: 'kr', name: 'Korean',     native: '한국어'),
    LanguageItem(code: 'zh', countryCode: 'cn', name: 'Chinese',    native: '中文'),
    LanguageItem(code: 'fr', countryCode: 'fr', name: 'French',     native: 'Français'),
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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onSelected(lang);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 10) / 2;

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

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppColors.primary,
          ),

          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: LanguageBottomSheet.languages.map((lang) {
                return SizedBox(
                  width: cardWidth,
                  height: 105,
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

// ─── Lang Card ────────────────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFF0FCFD),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC0E2F8).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // ── Checkmark ──
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

            // ── Content ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cờ dùng Image.network từ flagcdn — hiển thị tốt trên mọi thiết bị
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://flagcdn.com/w80/${lang.countryCode}.png',
                      width: 42,
                      height: 28,
                      fit: BoxFit.cover,
                      // Fallback khi offline: hiển thị icon globe
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.language,
                        size: 28,
                        color: AppColors.highlightColor,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 42,
                          height: 28,
                          child: Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.highlightColor,
                    ),
                  ),
                  Text(
                    lang.native,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
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