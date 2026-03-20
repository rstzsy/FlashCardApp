import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class MemberSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MemberSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<MemberSearchBar> createState() => _MemberSearchBarState();
}

class _MemberSearchBarState extends State<MemberSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.highlightColor.withOpacity(0.25),
          //     blurRadius: 14,
          //     spreadRadius: 1,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: "Search username…",
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.highlightColor,
            ),
            filled: true,
            fillColor: AppColors.mainColor, 
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFDDDDDD),
                width: 2.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.highlightColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
