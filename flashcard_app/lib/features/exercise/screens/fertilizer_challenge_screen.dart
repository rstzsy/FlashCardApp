import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../models/fillQuestionModel.dart';
import '../controllers/fertilizer_challenge_controller.dart';
import 'score_game_screen.dart';

class FertilizerChallengeScreen extends StatefulWidget {
  final String setId;

  const FertilizerChallengeScreen({
    super.key,
    required this.setId,
  });

  @override
  State<FertilizerChallengeScreen> createState() =>
      _FertilizerChallengeScreenState();
}

class _FertilizerChallengeScreenState
    extends State<FertilizerChallengeScreen> {
  final FertilizerController _controller = FertilizerController();

  bool _isLoading = true;
  bool _isFinishing = false; // loading state
  String? _errorMessage;
  String? _selectedWord;
  bool? _isCorrect;

  final int _totalDots = 5;
  final String _stageText = "Stage: Seedling → Sapling";

  bool get _hasAnswered => _selectedWord != null;
  int get _totalQuestions => _controller.questions.length;
  int get _currentIndex => _controller.currentIndex;

  int get _progressPercent => _totalQuestions == 0
      ? 0
      : ((_currentIndex / _totalQuestions) * 100).round();

  int get _filledDots => _totalQuestions == 0
      ? 0
      : ((_currentIndex / _totalQuestions) * _totalDots).round();

  FillQuestionModel? get _currentQuestion =>
      _controller.questions.isEmpty ? null : _controller.currentQuestion;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _controller.loadQuestions(widget.setId);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _selectWord(String word) {
    if (_hasAnswered) return;
    final correct = _controller.checkAnswer(word);
    setState(() {
      _selectedWord = word;
      _isCorrect = correct;
    });
  }

  Future<void> _goToNextQuestion() async {
    if (_controller.isLast) {
      // save result and navigate to score screen
      setState(() => _isFinishing = true);
      await _controller.finishGame(widget.setId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreScreen(
            score: _controller.score,
            total: _controller.questions.length,
            setId: widget.setId,
          ),
        ),
      );
      return;
    }

    await _controller.nextQuestion();
    setState(() {
      _selectedWord = null;
      _isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? _buildLoading()
            : _errorMessage != null
                ? _buildError()
                : _controller.questions.isEmpty
                    ? _buildEmpty()
                    : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                "Failed to load questions.\n$_errorMessage",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadData();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmpty() => const Center(
        child: Text(
          "No questions found for this set.",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );

  Widget _buildContent() {
    final question = _currentQuestion!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Fertilizer Challenge",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 3, 85, 161),
                          ),
                        ),
                        Text(
                          "$_progressPercent%",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 4, 85, 139),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Fill in the blank",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.highlightColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _totalQuestions == 0
                            ? 0
                            : _currentIndex / _totalQuestions,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color.fromARGB(255, 4, 85, 139),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // scroll body content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // card info
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // folder icon decoration
                      SizedBox(
                        width: 44,
                        height: 38,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 18,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD5708B),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 7,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE9B4B3),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(7),
                                    bottomLeft: Radius.circular(7),
                                    bottomRight: Radius.circular(7),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 16,
                                    color: const Color(0xFFD5708B)
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // get title from flashcard set
                            Text(
                              _controller.setTitle.isNotEmpty
                                  ? _controller.setTitle
                                  : widget.setId,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _stageText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // progress dots
                            Row(
                              children: List.generate(_totalDots, (i) {
                                final filled = i < _filledDots;
                                return Container(
                                  width: filled ? 10 : 8,
                                  height: filled ? 10 : 8,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: filled
                                        ? const Color.fromARGB(255, 31, 116, 227)
                                        : Colors.grey.shade300,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FILL IN THE BLANK",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Question ${_currentIndex + 1} / $_totalQuestions",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSentenceWithBlank(question.sentence),
                      const SizedBox(height: 16),
                      Text(
                        "Hint: tap a word below to fill in the blank",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Choose a word:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),

                const SizedBox(height: 12),

                // word choices
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: question.choices.map((word) {
                    final isSelected = word == _selectedWord;

                    Color chipBg;
                    Color chipBorder;
                    Color chipText;

                    if (!_hasAnswered) {
                      chipBg = Colors.white;
                      chipBorder = Colors.grey.shade300;
                      chipText = const Color(0xFF2D2D2D);
                    } else if (isSelected && _isCorrect!) {
                      chipBg = AppColors.primary;
                      chipBorder = AppColors.primary;
                      chipText = Colors.white;
                    } else if (isSelected && !_isCorrect!) {
                      chipBg = const Color(0xFFFFEBEE);
                      chipBorder = const Color(0xFFE53935);
                      chipText = const Color(0xFFB71C1C);
                    } else if (!isSelected &&
                        word == question.correctAnswer &&
                        !_isCorrect!) {
                      chipBg = const Color(0xFFF1F8E9);
                      chipBorder = const Color(0xFF558B2F);
                      chipText = const Color(0xFF33691E);
                    } else {
                      chipBg = Colors.white;
                      chipBorder = Colors.grey.shade200;
                      chipText = Colors.grey.shade400;
                    }

                    return GestureDetector(
                      onTap: () => _selectWord(word),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: chipBorder, width: 1.5),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: chipText,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // see result
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _hasAnswered
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // button disabled when finish
                      onPressed: _isFinishing ? null : _goToNextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C4D8D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF1C4D8D).withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isFinishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _controller.isLast
                                      ? "See Results"
                                      : "Next question",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _controller.isLast
                                      ? Icons.emoji_events_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // build blank
  Widget _buildSentenceWithBlank(String sentence) {
    const placeholder = '_____';
    final parts = sentence.split(placeholder);

    if (parts.length != 2) {
      return Text(
        sentence,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
          height: 1.5,
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 6,
      children: [
        if (parts[0].trim().isNotEmpty) _buildQuestionText(parts[0].trim()),
        _BlankSlot(
          filledWord: _selectedWord,
          isCorrect: _hasAnswered ? _isCorrect : null,
        ),
        if (parts[1].trim().isNotEmpty) _buildQuestionText(parts[1].trim()),
      ],
    );
  }

  Widget _buildQuestionText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
          height: 1.5,
        ),
      );
}

// blank slot
class _BlankSlot extends StatelessWidget {
  final String? filledWord;
  final bool? isCorrect;

  const _BlankSlot({this.filledWord, this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final bool empty = filledWord == null;

    Color underlineColor;
    Color textColor;
    Color bgColor;

    if (empty) {
      underlineColor = Colors.grey.shade400;
      textColor = Colors.transparent;
      bgColor = Colors.transparent;
    } else if (isCorrect == true) {
      underlineColor = const Color(0xFF558B2F);
      textColor = const Color(0xFF558B2F);
      bgColor = const Color(0xFFDCEDC8).withOpacity(0.5);
    } else {
      underlineColor = const Color(0xFFE53935);
      textColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE).withOpacity(0.6);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(minWidth: 110),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: underlineColor, width: 2),
        ),
      ),
      child: empty
          ? const SizedBox(height: 30, width: 110)
          : Text(
              filledWord!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.5,
              ),
            ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF2D2D2D)),
      ),
    );
  }
}