import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/collection_card.dart';
import '../controllers/flashcard_manage_controller.dart';
import 'flashcard_create_screen.dart';
import 'flashcard_study_screen.dart';

class FlashcardManagerScreen extends StatelessWidget {
  FlashcardManagerScreen({super.key});

  final controller = FlashcardManagerController();

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
              MaterialPageRoute(builder: (_) => const CreateFlashcardScreen()),
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
              child: FutureBuilder(
                future: controller.loadFlashcardSets(
                  FirebaseAuth.instance.currentUser!.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final collections = snapshot.data ?? [];

                  if (collections.isEmpty) {
                    return const Center(child: Text("No flashcards yet"));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: collections.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final item = collections[index];

                      return CollectionCard(
                        title: item['title'],
                        subtitle: item['subtitle'],
                        setsCount: item['totalCards'],
                        color: item['color'],
                        icon: item['icon'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FlashcardStudyScreen(),
                            ),
                          );
                        },
                        onFavoriteChanged: (fav) {},
                      );
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
