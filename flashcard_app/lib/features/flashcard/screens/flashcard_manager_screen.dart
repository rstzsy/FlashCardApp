import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/collection_card.dart';
import 'flashcard_create_screen.dart';

class FlashcardManagerScreen extends StatelessWidget {
  const FlashcardManagerScreen({super.key});

  // fake data
  static final List<Map<String, dynamic>> _collections = [
    {
      'title': 'Basic English',
      'subtitle': 'Library - 100 words',
      'color': const Color(0xFFF59CB2),
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'IELTS Vocabulary',
      'subtitle': 'Classroom',
      'color': const Color(0xFFB48D71),
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Daily Phrases',
      'subtitle': 'Social Network',
      'color': const Color(0xFFA05C46),
      'icon': Icons.chat_rounded,
    },
    {
      'title': 'Business English',
      'subtitle': 'Bussiness',
      'color': const Color(0xFFE49E91),
      'icon': Icons.work_outline_rounded,
    },
    {
      'title': 'Travel',
      'subtitle': 'Around the word',
      'color': const Color(0xFFD5708B),
      'icon': Icons.flight_takeoff_rounded,
    },
    {
      'title': 'Slang',
      'subtitle': 'Emotions',
      'color': const Color(0xFFE9B4B3),
      'icon': Icons.sentiment_satisfied_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,

      // floating button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 10),
        child: FloatingActionButton(
          backgroundColor: AppColors.highlightColor,
          onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateFlashcardScreen(),
            ),
          );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Title
            const Text(
              "My Flashcards",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
              ),
            ),

            const SizedBox(height: 20),

            // grid list
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _collections.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //1row - 3 items
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = _collections[index];

                  return CollectionCard(
                    title: item['title'],
                    subtitle: item['subtitle'],
                    setsCount: 0,
                    color: item['color'],
                    icon: item['icon'],
                    onFavoriteChanged: (fav) {
                      debugPrint("${item['title']} favorite: $fav");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
