import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

import '../../../core/widgets/collection_card.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../controllers/flashcard_manage_controller.dart';
import 'flashcard_create_screen.dart';
import 'flashcard_study_screen.dart';

class FlashcardManagerScreen extends StatefulWidget {
  const FlashcardManagerScreen({super.key});

  @override
  State<FlashcardManagerScreen> createState() => _FlashcardManagerScreenState();
}

class _FlashcardManagerScreenState extends State<FlashcardManagerScreen>
    with SingleTickerProviderStateMixin {
  final controller = FlashcardManagerController();

  late Future<List<dynamic>> futureSets;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // chatbot button
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatingAnimation.value),
                  child: child,
                );
              },

              child: SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  heroTag: "chatbot_btn",
                  backgroundColor: const Color.fromARGB(135, 255, 255, 255),
                  elevation: 6,
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/component/chatbot.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // create button
            FloatingActionButton(
              heroTag: "create_btn",
              backgroundColor: AppColors.highlightColor,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateFlashcardScreen(),
                  ),
                );

                if (result == true) {
                  setState(() => _loadData());
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
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
                              builder:
                                  (_) => FlashcardStudyScreen(
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
