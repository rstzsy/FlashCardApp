import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flashcard_app/core/themes/app_colors.dart';

import '../../../models/flashcard_form_model.dart';

class FlashcardItem extends StatefulWidget {
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
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  Timer? _debounce;

  Future<String?> getPhonetic(String word) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/$word',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          // phonetic
          final phonetic = data[0]['phonetic'];
          if (phonetic != null && phonetic.toString().isNotEmpty) {
            return phonetic.toString();
          }

          // fallback to phonetics
          final phonetics = data[0]['phonetics'];
          if (phonetics is List) {
            for (final item in phonetics) {
              final text = item['text'];
              if (text != null && text.toString().isNotEmpty) {
                return text.toString();
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Get phonetic error: $e');
    }

    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.index}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onDelete();
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
          _input(
            widget.card.word,
            "Vocabulary",
            onChanged: (value) {
              _debounce?.cancel();

              final word = value.trim();

              if (word.isEmpty) {
                widget.card.phonetic.clear();
                return;
              }

              _debounce = Timer(
                const Duration(milliseconds: 700),
                () async {
                  final phonetic = await getPhonetic(word);

                  if (!mounted) return;

                  if (phonetic != null) {
                    widget.card.phonetic.text = phonetic;
                  }
                },
              );
            },
          ),

          const SizedBox(height: 10),

          // meaning + image
          Row(
            children: [
              Expanded(
                child: _input(
                  widget.card.meaning,
                  "Meaning",
                ),
              ),
              const SizedBox(width: 10),

              GestureDetector(
                onTap: widget.onPickImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildImageWidget(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // phonetic
          _input(
            widget.card.phonetic,
            "Phonetic",
          ),

          const SizedBox(height: 10),

          // example
          _input(
            widget.card.example,
            "Example",
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (widget.card.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          widget.card.image!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.card.imageUrl != null &&
        widget.card.imageUrl!.isNotEmpty) {
      if (widget.card.imageUrl!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            widget.card.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (_, __, ___) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.black,
                ),
                SizedBox(height: 6),
                Text(
                  "Error",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          widget.card.imageUrl!,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image,
          color: Colors.black,
        ),
        SizedBox(height: 6),
        Text(
          "Image",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color.fromARGB(255, 12, 43, 83),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromARGB(251, 179, 177, 177),
        ),
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