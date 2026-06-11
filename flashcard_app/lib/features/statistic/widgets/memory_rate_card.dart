import 'package:flutter/material.dart';
import 'circular_ring_chart.dart';
import 'mini_stat.dart';
import 'palette.dart';


class MemoryRateCard extends StatelessWidget {
  final int learnedWords;
  final double memoryRate;

  const MemoryRateCard({required this.learnedWords, required this.memoryRate});

  String get _statusLabel {
    if (memoryRate >= 75) return 'Great';
    if (memoryRate >= 50) return 'Good';
    if (memoryRate >= 25) return 'Low';
    return 'Weak';
  }

  Color get _statusColor {
    if (memoryRate >= 75) return P.greenDark;
    if (memoryRate >= 50) return P.blueDark;
    if (memoryRate >= 25) return P.pinkDark;
    return P.pinkDark;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: P.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: P.purple.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularRingChart(percent: memoryRate / 100, size: 180),
          const SizedBox(height: 20),
          const Divider(color: P.divider, height: 1),
          const SizedBox(height: 16),
          // data at pie chart bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MiniStat(
                icon: Icons.menu_book_rounded,
                iconBg: P.blue,
                iconColor: P.blueDark,
                label: 'Words\nLearned',
                value: learnedWords.toString(),
              ),
              Container(width: 1, height: 48, color: P.divider),
              MiniStat(
                icon: Icons.psychology_rounded,
                iconBg: P.pink,
                iconColor: P.pinkDark,
                label: 'Memory\nRate',
                value: '${memoryRate.toStringAsFixed(0)}%',
              ),
              Container(width: 1, height: 48, color: P.divider),
              MiniStat(
                icon: Icons.donut_large_rounded,
                iconBg: P.purple,
                iconColor: P.purpleDark,
                label: 'Current\nStatus',
                value: _statusLabel,
                valueColor: _statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}