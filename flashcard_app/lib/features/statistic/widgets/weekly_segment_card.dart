import 'package:flutter/material.dart';
import 'palette.dart';
import 'segment_bar.dart';


class WeeklySegmentCard extends StatelessWidget {
  final List<int> values;
  final int totalLearned;
  final int today; // dart weekday: 1=Mon … 7=Sun

  const WeeklySegmentCard({
    required this.values,
    required this.totalLearned,
    required this.today,
  });

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _colors = [
    P.green,
    P.blue,
    P.purple,
    P.green,
    P.blue,
    P.pink,
    P.pink,
  ];

  List<int> _reorderToWeek() {
    final ordered = List<int>.filled(7, 0);
    final todaySlot = today - 1;

    for (int i = 0; i < 7; i++) {
      final slot = (todaySlot - (6 - i) + 7) % 7;
      ordered[slot] = values[i];
    }

    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: P.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            'No data yet',
            style: TextStyle(color: P.textSub, fontSize: 13),
          ),
        ),
      );
    }

    final ordered = _reorderToWeek();
    final maxVal = ordered.reduce((a, b) => a > b ? a : b);
    final peakIdx = ordered.indexOf(maxVal);
    final todaySlot = today - 1; // 0=Mon -> 6=Sun

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: P.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: P.blue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THIS WEEK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: P.blueDark,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: P.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: P.blueDark,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalLearned words',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: P.text,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(7, (i) {
            final label = _dayLabels[i];
            final color = _colors[i];
            final ratio = maxVal > 0 ? ordered[i] / maxVal : 0.0;
            final isPeak = i == peakIdx && maxVal > 0;
            final isToday = i == todaySlot;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                (isPeak || isToday)
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                            color:
                                isToday
                                    ? P.blueDark
                                    : isPeak
                                    ? color
                                    : P.textSub,
                          ),
                        ),
                        if (isToday)
                          const Text(
                            ' •',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: P.blueDark,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SegmentBar(
                      percent: ratio,
                      color: isToday ? P.blueDark : color,
                      height: (isPeak || isToday) ? 12 : 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${ordered[i]}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            (isPeak || isToday)
                                ? FontWeight.w800
                                : FontWeight.w400,
                        color:
                            isToday
                                ? P.blueDark
                                : isPeak
                                ? color
                                : P.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}