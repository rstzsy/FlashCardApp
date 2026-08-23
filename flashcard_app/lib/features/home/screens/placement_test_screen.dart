import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../service/placement_test_service.dart';
import '../widgets/placement_dialog.dart';

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'She _____ to school every day.',
      'answers': ['go', 'goes', 'going', 'gone'],
      'correct': 1,
    },
    {
      'question': 'I _____ coffee every morning.',
      'answers': ['drink', 'drinks', 'drinking', 'drank'],
      'correct': 0,
    },
    {
      'question': 'They _____ football yesterday.',
      'answers': ['play', 'plays', 'played', 'playing'],
      'correct': 2,
    },
    {
      'question': 'There _____ a book on the table.',
      'answers': ['are', 'be', 'is', 'were'],
      'correct': 2,
    },
    {
      'question': 'He is _____ than his brother.',
      'answers': ['tall', 'taller', 'tallest', 'more tall'],
      'correct': 1,
    },
    {
      'question': 'I have lived here _____ 2020.',
      'answers': ['for', 'since', 'at', 'on'],
      'correct': 1,
    },
    {
      'question': 'If it rains, we _____ at home.',
      'answers': ['stay', 'stayed', 'will stay', 'staying'],
      'correct': 2,
    },
    {
      'question': 'She _____ her homework before dinner.',
      'answers': ['has finished', 'finish', 'finishing', 'finishs'],
      'correct': 0,
    },
    {
      'question': 'This is the _____ movie I have ever seen.',
      'answers': ['good', 'better', 'best', 'well'],
      'correct': 2,
    },
    {
      'question': 'If I _____ more time, I would learn Japanese.',
      'answers': ['have', 'had', 'will have', 'having'],
      'correct': 1,
    },
  ];

  Map<String, dynamic> get _currentQuestion => _questions[_currentIndex];

  int get _totalQuestions => _questions.length;

  double get _progress => (_currentIndex + 1) / _totalQuestions;

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;

      if (index == _currentQuestion['correct']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (!_hasAnswered) return;

    if (_currentIndex == _totalQuestions - 1) {
      _showResult();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _hasAnswered = false;
    });
  }

  Future<void> _showResult() async {
    String level;

    if (_score <= 3) {
      level = 'Beginner';
    } else if (_score <= 6) {
      level = 'Elementary';
    } else if (_score <= 8) {
      level = 'Intermediate';
    } else {
      level = 'Upper Intermediate';
    }

    try {
      await PlacementTestService.saveTestResult(
        score: _score,
        totalQuestions: _totalQuestions,
        level: level,
      );

      if (!mounted) return;

      TestCompletedDialog.show(
        context,
        score: _score,
        totalQuestions: _totalQuestions,
        level: level,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save test result: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTestInfo(),

                    const SizedBox(height: 16),

                    _buildQuestionCard(),

                    const SizedBox(height: 18),

                    const Text(
                      'Choose your answer:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildAnswers(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // header
  Widget _buildHeader() {
    return Padding(
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
                      'Placement Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0355A1),
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1}/$_totalQuestions',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF04558B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  'Discover your English level',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.highlightColor,
                  ),
                ),

                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF04558B),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // test info
  Widget _buildTestInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9B4B3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Color(0xFFD5708B)),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English Placement Test',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '10 questions • Multiple choice',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_score correct',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // question card
  Widget _buildQuestionCard() {
    return Container(
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
            'QUESTION ${_currentIndex + 1}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Question ${_currentIndex + 1} / $_totalQuestions',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),

          const SizedBox(height: 18),

          Text(
            _currentQuestion['question'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // answers
  Widget _buildAnswers() {
    final answers = _currentQuestion['answers'] as List<String>;

    return Column(
      children: List.generate(
        answers.length,
        (index) => _buildAnswer(index, answers[index]),
      ),
    );
  }

  Widget _buildAnswer(int index, String answer) {
    final bool isSelected = _selectedAnswer == index;
    final bool isCorrect = index == _currentQuestion['correct'];

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = const Color(0xFF2D2D2D);

    if (!_hasAnswered) {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
    } else if (isSelected && isCorrect) {
      backgroundColor = const Color(0xFFF1F8E9);
      borderColor = const Color(0xFF558B2F);
      textColor = const Color(0xFF33691E);
    } else if (isSelected && !isCorrect) {
      backgroundColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFE53935);
      textColor = const Color(0xFFB71C1C);
    } else if (!isSelected && isCorrect) {
      backgroundColor = const Color(0xFFF1F8E9);
      borderColor = const Color(0xFF558B2F);
      textColor = const Color(0xFF33691E);
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getOptionCircleColor(index, isSelected, isCorrect),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getOptionTextColor(index, isSelected, isCorrect),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            if (_hasAnswered && isSelected)
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color:
                    isCorrect
                        ? const Color(0xFF558B2F)
                        : const Color(0xFFE53935),
              ),
          ],
        ),
      ),
    );
  }

  Color _getOptionCircleColor(int index, bool isSelected, bool isCorrect) {
    if (!_hasAnswered) {
      return Colors.grey.shade100;
    }

    if (isCorrect) {
      return const Color(0xFFDCEDC8);
    }

    if (isSelected) {
      return const Color(0xFFFFCDD2);
    }

    return Colors.grey.shade100;
  }

  Color _getOptionTextColor(int index, bool isSelected, bool isCorrect) {
    if (!_hasAnswered) {
      return Colors.grey.shade700;
    }

    if (isCorrect) {
      return const Color(0xFF33691E);
    }

    if (isSelected) {
      return const Color(0xFFB71C1C);
    }

    return Colors.grey.shade700;
  }

  // next button
  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _hasAnswered ? _nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C4D8D),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentIndex == _totalQuestions - 1
                    ? 'See Results'
                    : 'Next question',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Circle button widget for the header back button
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
