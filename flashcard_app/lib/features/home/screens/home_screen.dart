import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../auth/service/achievement_service.dart';
import '../service/achievement_popup.dart';
import '../service/placement_test_service.dart';
import '../widgets/feature_item.dart';
import '../widgets/placement_test_card.dart';
import '../widgets/recent_study_card.dart';
import '../../../core/widgets/collection_card.dart';
import '../widgets/performance_section.dart';
import '../widgets/promo_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/auth/screens/account_screen.dart';
import '../service/recent_study_service.dart';
import '../../../features/flashcard/screens/flashcard_study_screen.dart';
import '../../../features/flashcard/services/flashcard_manage_service.dart';
import 'placement_test_screen.dart';
import 'package:flutter/services.dart';
import '../widgets/dashed_rotating_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? _placementTestCompleted;
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAchievement();
      _checkPlacementTest();
    });
  }

  Future<void> _checkPlacementTest() async {
    final completed = await PlacementTestService.hasCompletedTest();

    if (!mounted) return;

    setState(() {
      _placementTestCompleted = completed;
    });
  }

  Future<void> _checkAchievement() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) return;

      final data = userDoc.data()!;

      final streak = (data['streak'] ?? 0) as int;

      final badge = await AchievementService.checkNewAchievement(uid, streak);

      if (!mounted || badge == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AchievementDialog(milestone: badge),
      );
    } catch (e) {
      debugPrint("Achievement Error: $e");
    }
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: EdgeInsets.only(
                top: topPadding + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 213, 248, 249),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'User';
                  final photoUrl = data['photoUrl'];
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Good Morning",
                                style: TextStyle(color: AppColors.highlightColor),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: AppColors.highlightColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          MofuAvatar(
                            photoUrl: photoUrl,
                            fallbackAsset: 'assets/character/amaz.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: AppColors.highlightColor),
                            hintText: "Search here...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Phần còn lại của body, bọc SafeArea(top:false) để né notch/home indicator dưới ──
            SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Statistic ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FeatureItem(
                            title: "Revisions\nThis Week",
                            description: "Lessons reviewed this week.",
                            imagePath: "assets/component/flash_card_home.png",
                          ),
                        ),
                        const DashedSeparator(),
                        Expanded(
                          child: FeatureItem(
                            title: "Total\nXP Earned",
                            description: "Watch your experience grow.",
                            imagePath: "assets/component/fire.png",
                          ),
                        ),
                        const DashedSeparator(),
                        Expanded(
                          child: FeatureItem(
                            title: "Your Tree\nStatus",
                            description: "Stay consistent to grow.",
                            imagePath: "assets/component/tree_home.png",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Promo Banner ──
                  const PromoBanner(),

                  const SizedBox(height: 25),

                  // placement test
                  if (_placementTestCompleted != true)
                    PlacementTestCard(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlacementTestScreen(),
                          ),
                        );

                        // check firebase to see if placement test completed
                        _checkPlacementTest();
                      },
                    ),

                  const SizedBox(height: 25),



                  // ── Performance ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: PerformanceSection(),
                  ),

                  const SizedBox(height: 25),

                  // ── Recent Study ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recent Study",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            Text(
                              "See All",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.highlightColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: RecentStudyService.getRecentSets(limit: 3),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 100,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final sets = snapshot.data ?? [];

                            if (sets.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    "You haven't studied any sets yet.\nStart learning now! 🚀",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black45, fontSize: 14),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: sets.asMap().entries.map((entry) {
                                final i   = entry.key;
                                final set = entry.value;

                                Color bg;
                                try {
                                  bg = _hexToColor(set['colorHex']);
                                } catch (_) {
                                  final fallbacks = [
                                    const Color(0xFFDCEDC8),
                                    const Color(0xFFB2EBF2),
                                    const Color(0xFFFFE0B2),
                                  ];
                                  bg = fallbacks[i % fallbacks.length];
                                }

                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: i < sets.length - 1 ? 12.0 : 0.0),
                                  child: RecentStudyCard(
                                    title:        set['title']       ?? 'Untitled',
                                    description:  set['description'] ?? '',
                                    totalCards:   (set['totalCards'] as num?)?.toInt() ?? 0,
                                    learnedCards: (set['learnedCards'] as num?)?.toInt() ?? 0,
                                    imagePath:    "assets/component/book_watermark.png",
                                    bgColor:      bg,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FlashcardStudyScreen(
                                            setId: set['setId'] ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ── Collections ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Collections",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: FlashcardManagerService().getFlashcardSets(
                          FirebaseAuth.instance.currentUser!.uid,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 145,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final sets = snapshot.data ?? [];

                          if (sets.isEmpty) {
                            return const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  "No collections yet. Create one!",
                                  style: TextStyle(color: Colors.black45, fontSize: 14),
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 145,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 20, right: 8),
                              clipBehavior: Clip.none,
                              itemCount: sets.length,
                              itemBuilder: (context, index) {
                                final set = sets[index];

                                Color cardColor;
                                try {
                                  final hex = (set['ColorHex'] as String).replaceAll('#', '');
                                  cardColor = Color(int.parse('FF$hex', radix: 16));
                                } catch (_) {
                                  cardColor = const Color(0xFFB48D71);
                                }

                                IconData? iconData;
                                try {
                                  final cp = int.parse(set['Icon'] as String, radix: 16);
                                  iconData = IconData(cp, fontFamily: 'MaterialIcons');
                                } catch (_) {
                                  iconData = null;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: CollectionCard(
                                    title:     set['Title']    ?? 'Untitled',
                                    subtitle:  set['Subtitle'] ?? '',
                                    setsCount: (set['TotalCards'] as num?)?.toInt() ?? 0,
                                    color:     cardColor,
                                    // icon:      iconData,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FlashcardStudyScreen(
                                            setId: set['SetId'] ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
