class FlashcardFsrsData {
  final String cardId;
  final String setId;
  final String userId;

  final double stability;   
  final double difficulty;  
  final int reps;           
  final int lapses;        
  final String state;       
  final DateTime? due;     
  final DateTime? lastReview;

  const FlashcardFsrsData({
    required this.cardId,
    required this.setId,
    required this.userId,
    this.stability = 0,
    this.difficulty = 5,
    this.reps = 0,
    this.lapses = 0,
    this.state = 'new',
    this.due,
    this.lastReview,
  });

  /// Tạo mới (chưa học lần nào)
  factory FlashcardFsrsData.newCard({
    required String cardId,
    required String setId,
    required String userId,
  }) {
    return FlashcardFsrsData(
      cardId: cardId,
      setId: setId,
      userId: userId,
      due: DateTime.now(),
    );
  }

  factory FlashcardFsrsData.fromMap(Map<String, dynamic> map) {
    return FlashcardFsrsData(
      cardId: map['cardId'] ?? '',
      setId: map['setId'] ?? '',
      userId: map['userId'] ?? '',
      stability: (map['stability'] ?? 0).toDouble(),
      difficulty: (map['difficulty'] ?? 5).toDouble(),
      reps: map['reps'] ?? 0,
      lapses: map['lapses'] ?? 0,
      state: map['state'] ?? 'new',
      due: map['due'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due'])
          : null,
      lastReview: map['lastReview'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReview'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'setId': setId,
      'userId': userId,
      'stability': stability,
      'difficulty': difficulty,
      'reps': reps,
      'lapses': lapses,
      'state': state,
      'due': due?.millisecondsSinceEpoch,
      'lastReview': lastReview?.millisecondsSinceEpoch,
    };
  }

  FlashcardFsrsData copyWith({
    double? stability,
    double? difficulty,
    int? reps,
    int? lapses,
    String? state,
    DateTime? due,
    DateTime? lastReview,
  }) {
    return FlashcardFsrsData(
      cardId: cardId,
      setId: setId,
      userId: userId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  /// Priority để sort: thẻ overdue lên đầu, thẻ new tiếp theo
  double get priority {
    final now = DateTime.now();
    if (state == 'new') return -1; // new luôn lên đầu
    if (due == null) return 0;
    final daysOverdue = now.difference(due!).inMinutes / (60 * 24);
    return -daysOverdue; // overdue nhiều hơn = priority thấp hơn = lên đầu
  }
}