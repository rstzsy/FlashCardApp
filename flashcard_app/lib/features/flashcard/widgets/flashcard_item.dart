import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

import '../../../models/flashcard_form_model.dart'; 

class FlashcardItem extends StatelessWidget {
  final int index;
  final FlashcardFormModel card; 
  final VoidCallback onPickImage;
  final VoidCallback onDelete;

  const FlashcardItem({
    super.key,
    required this.index,
    required this.card,
    required this.onPickImage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$index",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              // menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text("Remove"),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // word
          _input(card.word, "Vocabulary"),

          const SizedBox(height: 10),

          // meaning
          Row(
            children: [
              Expanded(
                child: _input(card.meaning, "Meaning"),
              ),
              const SizedBox(width: 10),

              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: card.image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.black),
                            SizedBox(height: 6),
                            Text(
                              "Image",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            card.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // phonetic
          _input(card.phonetic, "Phonetic"),

          const SizedBox(height: 10),

          // example
          _input(card.example, "Example"),
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(
        color: Color.fromARGB(255, 12, 43, 83),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color.fromARGB(251, 179, 177, 177)),
        filled: true,
        fillColor: Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}