import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/flashcard_form_model.dart';
import '../widgets/flashcard_list.dart';

class UpdateFlashcardScreen extends StatefulWidget {
  const UpdateFlashcardScreen({super.key});

  @override
  State<UpdateFlashcardScreen> createState() => _UpdateFlashcardScreenState();
}

class _UpdateFlashcardScreenState extends State<UpdateFlashcardScreen> {
  List<FlashcardFormModel> cards = [];

  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();

  IconData _selectedIcon = Icons.menu_book;
  Color _selectedColor = const Color(0xFFE9B4B3);

  final List<IconData> _icons = [
    Icons.menu_book,
    Icons.school,
    Icons.work,
    Icons.favorite,
    Icons.star,
    Icons.lightbulb,
    Icons.language,
    Icons.chat,
  ];

  final List<Color> _colors = [
    Color(0xFFF59CB2),
    Color(0xFFB48D71),
    Color(0xFFA05C46),
    Color(0xFFE49E91),
    Color(0xFFD5708B),
    Color(0xFFE9B4B3),
    Color(0xFFF2DCBE),
    Color(0xFFF0B6C6),
  ];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _titleCtrl.text = "English Vocabulary";
    _subtitleCtrl.text = "Basic words";
    _selectedIcon = Icons.language;
    _selectedColor = _colors[2];

    cards = [
      FlashcardFormModel(
        word: TextEditingController(text: "Apple"),
        meaning: TextEditingController(text: "Quả táo"),
        phonetic: TextEditingController(text: "/ˈæp.əl/"),
        example: TextEditingController(text: "I eat an apple"),
      ),
      FlashcardFormModel(
        word: TextEditingController(text: "Book"),
        meaning: TextEditingController(text: "Quyển sách"),
        phonetic: TextEditingController(text: "/bʊk/"),
        example: TextEditingController(text: "This is my book"),
      ),
    ];
  }

  void _addCard() {
    setState(() {
      cards.add(FlashcardFormModel.empty());
    });
  }

  void _deleteCard(int index) {
    setState(() => cards.removeAt(index));
  }

  void _pickImage(int index) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        cards[index].image = File(picked.path);
      });
    }
  }

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemBuilder: (_, i) {
              return IconButton(
                icon: Icon(_icons[i]),
                onPressed: () {
                  setState(() => _selectedIcon = _icons[i]);
                  Navigator.pop(context);
                },
              );
            },
          ),
    );
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _colors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = _colors[i]);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
    );
  }

  void _submitUpdate() {
    debugPrint("=== UPDATE FLASHCARD ===");
    debugPrint("Title: ${_titleCtrl.text}");
    debugPrint("Subtitle: ${_subtitleCtrl.text}");
    debugPrint("Icon: $_selectedIcon");
    debugPrint("Color: $_selectedColor");

    for (int i = 0; i < cards.length; i++) {
      final c = cards[i];
      debugPrint("---- Card ${i + 1} ----");
      debugPrint("Word: ${c.word.text}");
      debugPrint("Meaning: ${c.meaning.text}");
      debugPrint("Phonetic: ${c.phonetic.text}");
      debugPrint("Example: ${c.example.text}");
      debugPrint("Image: ${c.image?.path}");
    }
  }

  Widget _input(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF0C2B53), fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFB3B1B1), fontSize: 14),
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        title: const Text(
          "Update Flashcard",
          style: TextStyle(
            color: AppColors.highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.mainColor,
      ),
      body: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _input(_titleCtrl, "Title"),
                      const SizedBox(height: 10),
                      _input(_subtitleCtrl, "Subtitle"),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: SelectOptionButton(
                              label: "Icon",
                              icon: _selectedIcon,
                              onTap: _pickIcon,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectOptionButton(
                              label: "Color",
                              color: _selectedColor,
                              onTap: _pickColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 1,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(_selectedIcon, size: 40, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // list
          Expanded(
            child: FlashcardList(
              cards: cards,
              onPickImage: _pickImage,
              onDelete: _deleteCard,
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: "Add Card",
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onTap: _addCard,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: "Save Flashcard",
                    backgroundColor: Colors.white,
                    textColor: AppColors.highlightColor,
                    onTap: _submitUpdate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectOptionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onTap;

  const SelectOptionButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading;

    // color button
    if (color != null) {
      leading = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    // icon button
    else if (icon != null) {
      leading = Icon(icon, size: 18, color: Colors.black54);
    }
    // fallback
    else {
      leading = const SizedBox();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
