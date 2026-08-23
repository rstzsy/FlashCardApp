import 'package:home_widget/home_widget.dart';

class WidgetSyncService {
  static const String appGroupId = 'group.com.mofu.flashcardApp';
  static const String iOSWidgetName = 'FlashcardWidget';

  static Future<void> syncStreakData({
    required int streakDays,
    required List<String> completedDays,
  }) async {
    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.saveWidgetData<int>('streak_days', streakDays);
    await HomeWidget.saveWidgetData<String>(
      'completed_days',
      completedDays.join(','),
    );
    await HomeWidget.updateWidget(iOSName: iOSWidgetName);
  }
}