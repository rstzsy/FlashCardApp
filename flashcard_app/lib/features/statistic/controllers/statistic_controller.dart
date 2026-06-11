import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/statisticModel.dart';
import '../services/statistic_pdf_service.dart';
import '../services/statistic_service.dart';

class StatisticsController {
  final StatisticsService _service = StatisticsService();

  Future<StatisticsModel?> getStatistics(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bạn chưa đăng nhập")));

        return null;
      }

      return await _service.getStatistics(user.uid);
    } catch (e, stackTrace) {
      debugPrint("StatisticsController Error: $e");

      debugPrint("Statistics StackTrace: $stackTrace");

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Không thể tải thống kê")));
      }

      return null;
    }
  }

  Future<void> exportPdf(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final statistics = await _service.getStatistics(user.uid);

    final exportData = await _service.getExportData(user.uid);

    await StatisticPdfService().exportStatisticsPdf(
      userName: user.displayName ?? user.email ?? "Student",
      learnedWords: statistics.learnedWords,
      memoryRate: statistics.memoryRate,
      setStudies: exportData,
    );
  }
}
