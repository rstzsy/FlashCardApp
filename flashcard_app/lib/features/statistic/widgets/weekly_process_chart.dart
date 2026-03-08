import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/themes/app_colors.dart';

class WeeklyProgressChart extends StatelessWidget {
  const WeeklyProgressChart({super.key});

  static const _values = [20.0, 35.0, 40.0, 60.0, 45.0, 55.0, 30.0];

  static const _barColors = [
    Color.fromARGB(255, 240, 169, 169),
    Color.fromARGB(255, 252, 233, 179),
    Color.fromARGB(255, 154, 210, 240),
    Color.fromARGB(255, 140, 176, 237),
    Color.fromARGB(255, 172, 157, 236),
    Color.fromARGB(255, 207, 190, 241),
    Color.fromARGB(255, 170, 244, 203),
  ];

  List<BarChartGroupData> _buildBars() {
    return List.generate(_values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          // style bar chart
          BarChartRodData(
            toY: _values[i],
            width: 45, 
            color: _barColors[i],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                "assets/component/calendar.png",
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weekly Progress",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  "Words learned this week",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.highlightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // bar chart
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              maxY: 90,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} words',
                      const TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(show: false),

              // bottom border
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFDDDDDD), width: 2),
                ),
              ),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= _values.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${_values[i].toInt()} words',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${v.toInt() + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: _buildBars(),
            ),
          ),
        ),
      ],
    );
  }
}
