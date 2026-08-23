import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../models/flashcardModel.dart';
import '../../exercise/screens/intro_exercise_screen.dart';
import '../../game/services/word_garden_service.dart';
import '../controllers/flashcard_study_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/flashcard_study_card.dart';
import '../widgets/flashcard_study_footer.dart';
import '../widgets/flashcard_study_header.dart';
import '../widgets/fsrs_rating_buttons.dart';
import '../../auth/service/study_streak_service.dart';
import '../services/fsrs_service.dart';
import '../models/flashcard_fsrs_data.dart';
import 'dart:async';
import '../services/flashcard_notification_service.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final String setId;
  final String? setName; // ← truyền sẵn tên bộ từ khi navigate (không bắt buộc)

  const FlashcardStudyScreen({
    super.key,
    required this.setId,
    this.setName,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final FlashcardStudyController controller = FlashcardStudyController();

  TabController? _tabController;
  late Future<List<FlashcardModel>> futureCards;

  List<FlashcardModel> _dueCards = [];
  List<FlashcardModel> _allCards = [];

  int _dueIndex = 0;
  int _allIndex = 0;
  bool _dueShowRating = false;
  bool _allShowRating = false;
  bool _isRating = false;
  Timer? _dueRefreshTimer;

  String? _setName; // tên bộ từ thật, dùng cho thông báo (và header nếu cần)

  @override
  void initState() {
    super.initState();

    _setName = widget.setName; // nếu đã được truyền sẵn thì dùng luôn, khỏi query

    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        if (_tabController!.index == 0) {
          _refreshDueCards();
          setState(() => _dueShowRating = false);
        }
        setState(() {});
      }
    });

    WidgetsBinding.instance.addObserver(this);

    _loadData();

    _dueRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshDueCards(),
    );
  }

  @override
  void dispose() {
    _dueRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      futureCards =
          controller.getFlashcardsBySetId(widget.setId).then((cards) async {
        final now = DateTime.now();
        _allCards = cards;
        _dueCards = cards.where((c) {
          final fsrs = c.fsrsData;
          if (fsrs == null || fsrs.state == 'new') return true;
          return fsrs.due?.isBefore(now) ?? true;
        }).toList();
        _dueIndex = 0;
        _allIndex = 0;
        _dueShowRating = false;
        _allShowRating = false;
        await _scheduleSetReminder();
        return cards;
      });
    });
  }

  void _refreshDueCards() {
    if (!mounted) return;
    final now = DateTime.now();

    setState(() {
      _dueCards = _allCards.where((c) {
        final fsrs = c.fsrsData;
        if (fsrs == null || fsrs.state == 'new') return true;
        return fsrs.due?.isBefore(now) ?? true;
      }).toList();

      _dueIndex = 0;
      _dueShowRating = false;
    });

    _scheduleSetReminder(); // gọi ngoài setState vì là hàm async
  }

  /// Lấy tên bộ từ thật từ Firestore (chỉ chạy nếu chưa có sẵn _setName)
  Future<void> _loadSetName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('FlashcardSets')
          .doc(widget.setId)
          .get();
      final data = doc.data();
      _setName = data?['Name'] ??
          data?['name'] ??
          data?['Title'] ??
          data?['SetName'] ??
          widget.setId;
    } catch (_) {
      _setName = widget.setId;
    }
  }

  Future<void> _scheduleSetReminder() async {
    if (_allCards.isEmpty) return;

    if (_setName == null) {
      await _loadSetName();
    }

    DateTime? earliestDue;
    for (final c in _allCards) {
      final fsrs = c.fsrsData;
      final due = (fsrs == null || fsrs.state == 'new')
          ? DateTime.now()
          : fsrs.due;
      if (due == null) continue;
      if (earliestDue == null || due.isBefore(earliestDue)) earliestDue = due;
    }
    if (earliestDue == null) return;

    // Đếm số thẻ sẽ due tính đến đúng thời điểm earliestDue (không phải chỉ due NGAY BÂY GIỜ)
    final dueAtEarliest = _allCards.where((c) {
      final fsrs = c.fsrsData;
      final due = (fsrs == null || fsrs.state == 'new')
          ? DateTime.now()
          : fsrs.due;
      if (due == null) return false;
      return !due.isAfter(earliestDue!);
    }).length;

    FlashcardNotificationService.instance.scheduleReminder(
      setId: widget.setId,
      setName: _setName ?? widget.setId,
      dueTime: earliestDue,
      dueCount: dueAtEarliest > 0 ? dueAtEarliest : 1,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDueCards();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  bool get _isOnDueTab => (_tabController?.index ?? 0) == 0;

  List<FlashcardModel> get _activeCards => _isOnDueTab ? _dueCards : _allCards;

  int get _currentIndex => _isOnDueTab ? _dueIndex : _allIndex;
  set _currentIndex(int v) {
    if (_isOnDueTab) {
      _dueIndex = v;
    } else {
      _allIndex = v;
    }
  }

  bool get _showRating => _isOnDueTab ? _dueShowRating : _allShowRating;
  set _showRating(bool v) {
    if (_isOnDueTab) {
      _dueShowRating = v;
    } else {
      _allShowRating = v;
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _onCardFlipped() {
    if (!_showRating) {
      setState(() => _showRating = true);
    }
  }

  Future<void> _onRate(FsrsRating rating) async {
    if (_isRating || _currentIndex >= _activeCards.length) return;
    setState(() => _isRating = true);

    final card = _activeCards[_currentIndex];
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final updatedFsrs = await controller.rateCard(
        card: card,
        rating: rating,
        setId: widget.setId,
      );

      if (updatedFsrs != null) {
        final updatedCard = card.copyWith(fsrsData: updatedFsrs);

        final allIdx = _allCards.indexWhere((c) => c.id == card.id);
        if (allIdx != -1) _allCards[allIdx] = updatedCard;

        final now = DateTime.now();
        _dueCards = _allCards.where((c) {
          final fsrs = c.fsrsData;
          if (fsrs == null || fsrs.state == 'new') return true;
          return fsrs.due?.isBefore(now) ?? true;
        }).toList();
      }

      StudyStreakService.recordStudySession(
        userId: uid,
        wordsStudied: 1,
        setId: widget.setId,
      );
    }

    setState(() {
      _isRating = false;
      _dueShowRating = false;
      _allShowRating = false;
      if (_dueIndex >= _dueCards.length) {
        _dueIndex = (_dueCards.length - 1).clamp(0, 99999);
      }
    });

    await _scheduleSetReminder(); // cập nhật lại lịch nhắc sau mỗi lần rate
    await _advanceCard();
  }

  Future<void> _advanceCard() async {
    final cards = _activeCards;
    if (_currentIndex < cards.length - 1) {
      setState(() => _currentIndex = _currentIndex + 1);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    Map<String, String>? receivedPlant;

    if (user != null) {
      receivedPlant = await WordGardenService().createRandomSeed(
        userId: user.uid,
        setId: widget.setId,
      );
    }

    if (!mounted) return;

    AppPopup.show(
      context: context,
      title: "Session Complete! 🎉",
      message: receivedPlant != null
          ? "You received a ${receivedPlant['name']} seed\nfor your word garden!"
          : "Keep studying to grow your garden!",
      iconWidget: receivedPlant != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(receivedPlant['imagePath']!, width: 120, height: 120),
                const SizedBox(height: 8),
                Text(
                  receivedPlant['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A3333),
                  ),
                ),
              ],
            )
          : Image.asset('assets/component/trophy1.png', width: 150, height: 150),
      buttonText: "Study Again",
      showConfetti: receivedPlant != null,
      onPressed: () {
        setState(() {
          _currentIndex = 0;
          _showRating = false;
        });
      },
    );
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex = _currentIndex - 1;
        _showRating = false;
      });
    }
  }

  void goToPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IntroExerciseScreen(setId: widget.setId),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FlashcardStudyHeader(setId: widget.setId, setName: widget.setName, onReload: _loadData),
            Expanded(
              child: FutureBuilder<List<FlashcardModel>>(
                future: futureCards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  return Column(
                    children: [
                      _buildTabBar(),
                      Expanded(
                        child: IndexedStack(
                          index: _tabController?.index ?? 0,
                          children: [
                            _buildStudyView(_dueCards, isDue: true),
                            _buildStudyView(_allCards, isDue: false),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController!,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF7A3333),
        unselectedLabelColor: const Color(0xFFB36B6A),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: [
          Tab(text: "Due Today  (${_dueCards.length})"),
          Tab(text: "All Cards  (${_allCards.length})"),
        ],
      ),
    );
  }

  Widget _buildStudyView(List<FlashcardModel> cards, {required bool isDue}) {
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎉", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              isDue ? "All caught up for today!" : "No flashcards found",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A3333),
              ),
            ),
            if (isDue) ...[
              const SizedBox(height: 8),
              const Text(
                "Come back later or study all cards",
                style: TextStyle(fontSize: 14, color: Color(0xFFB36B6A)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _tabController?.animateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7D6D5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Study All Cards",
                  style: TextStyle(
                    color: Color(0xFF7A3333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final index = isDue ? _dueIndex : _allIndex;
    final showRating = isDue ? _dueShowRating : _allShowRating;
    final flashcard = cards[index];
    final isActiveTab = (_tabController?.index ?? 0) == (isDue ? 0 : 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: FlashcardStudyCard(
              key: ValueKey('${isDue ? 'due' : 'all'}_$index'),
              flashcard: flashcard,
              onFlippedToBack: isActiveTab ? _onCardFlipped : null,
            ),
          ),
          const SizedBox(height: 12),
          FlashcardStudyFooter(
            current: index + 1,
            total: cards.length,
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showRating
                ? FsrsRatingButtons(
                    key: ValueKey('rating_${isDue ? 'due' : 'all'}'),
                    onRate: _isRating ? (_) {} : _onRate,
                  )
                : _buildNavButtons(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: goToPractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7D6D5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Let Practices",
                style: TextStyle(
                  color: Color(0xFF7A3333),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      key: const ValueKey('nav'),
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _prevCard,
            icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF1A6A99)),
            label: const Text(
              "Back",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1A6A99),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBFDEF3),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _onRate(FsrsRating.good),
            icon: const Icon(Icons.skip_next, size: 16, color: Color(0xFF2E7D56)),
            label: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2E7D56),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5F0E3),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}