import 'package:flutter/material.dart';

class VocabularySuggestionCard extends StatelessWidget {
  final String word;
  final String meaning;
  final String phonetic;
  final double priorityScore;
  final String reason;
  final String tag;
  final int dueDaysAgo;

  const VocabularySuggestionCard({
    super.key,
    required this.word,
    required this.meaning,
    required this.phonetic,
    required this.priorityScore,
    required this.reason,
    required this.tag,
    required this.dueDaysAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFAFA9EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // word + tags
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phonetic,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F77DD),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFAFA9EC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.label_outline_rounded,
                        size: 13, color: Color(0xFF534AB7)),
                    const SizedBox(width: 5),
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF534AB7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 28, color: Color(0xFFCECBF6)),

          // meaning
          const Text(
            "MEANING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7F77DD),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meaning,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF3B3B3B),
            ),
          ),

          const SizedBox(height: 14),

          // ------ chips ------
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Priority chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_outlined,
                        size: 13, color: Color(0xFF3C3489)),
                    const SizedBox(width: 5),
                    Text(
                      "Priority ${(priorityScore * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3489),
                      ),
                    ),
                  ],
                ),
              ),

              // Overdue chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: Color(0xFF0F6E56)),
                    const SizedBox(width: 5),
                    Text(
                      "Overdue $dueDaysAgo day(s)",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F6E56),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ------ reason box ------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: Color(0xFF7F77DD)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF534AB7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}