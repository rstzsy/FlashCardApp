import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

import '../../../core/widgets/collection_card.dart';
import '../controllers/flashcard_manage_controller.dart';
import 'flashcard_create_screen.dart';
import 'flashcard_study_screen.dart';

class FlashcardManagerScreen extends StatefulWidget {
  const FlashcardManagerScreen({super.key});

  @override
  State<FlashcardManagerScreen> createState() =>
      _FlashcardManagerScreenState();
}

class _FlashcardManagerScreenState extends State<FlashcardManagerScreen> {
  final controller = FlashcardManagerController();

  late Future<List<dynamic>> futureSets;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load data
  void _loadData() {
    futureSets = controller.loadFlashcardSets(
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,

      // create
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 10),
        child: FloatingActionButton(
          backgroundColor: AppColors.highlightColor,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFlashcardScreen(),
              ),
            );

            // reload after create
            if (result == true) {
              setState(() => _loadData());
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // title
            const Text(
              "My Flashcards",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.highlightColor,
              ),
            ),

            const SizedBox(height: 20),

            // list
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futureSets,
                builder: (context, snapshot) {
                  // loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // error
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  final collections = snapshot.data ?? [];

                  // empty
                  if (collections.isEmpty) {
                    return const Center(child: Text("No flashcards yet"));
                  }

                  // grid
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

                        // open study
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardStudyScreen(
                                setId: item['setId'],
                              ),
                            ),
                          );

                          // reload if udate/del
                          if (result == "deleted" || result == true) {
                            setState(() => _loadData());
                          }
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