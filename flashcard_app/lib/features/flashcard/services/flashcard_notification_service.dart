import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FlashcardNotificationService {
  FlashcardNotificationService._internal();
  static final FlashcardNotificationService instance = FlashcardNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    const androidInit = AndroidInitializationSettings('ic_stat_notification');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl == null) return true;
    final granted = await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  void _onNotificationTap(NotificationResponse response) {
    log('Notification tapped, payload: ${response.payload}');
  }

  NotificationDetails _details({String? avatarPath}) {
    final iosDetails = DarwinNotificationDetails(
      sound: 'reminder_sound.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: avatarPath != null
          ? [DarwinNotificationAttachment(avatarPath, identifier: 'avatar')]
          : null,
    );
    return NotificationDetails(iOS: iosDetails);
  }

  Future<void> showDueNowNotification({
    required String setId,
    required String setName,
    required int dueCount,
  }) async {
    if (dueCount <= 0) return;
    await _plugin.show(
      setId.hashCode,
      'Đến giờ ôn từ vựng rồi! 📚',
      'Bộ "$setName" đang có $dueCount từ cần ôn tập. Ôn ngay để không quên nhé!',
      _details(),
      payload: 'set:$setId',
    );
  }

  Future<void> scheduleReminder({
    required String setId,
    required String setName,
    required DateTime dueTime,
    required int dueCount,
  }) async {
    await cancelForSet(setId);
    if (dueCount <= 0) return;

    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime.from(dueTime, tz.local);
    if (!target.isAfter(now)) {
      target = now.add(const Duration(seconds: 5));
    }

    await _plugin.zonedSchedule(
      setId.hashCode,
      'Đến giờ ôn từ vựng rồi! 📚',
      'Bộ "$setName" có $dueCount từ đang chờ bạn ôn tập.',
      target,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'set:$setId',
    );
  }

  Future<void> scheduleDailyDigest({int hour = 20, int minute = 0}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      999999,
      'Ôn tập từ vựng mỗi ngày 🌱',
      'Ghé qua kiểm tra các từ đến hạn ôn tập hôm nay nhé!',
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_digest',
    );
  }

  Future<void> cancelForSet(String setId) => _plugin.cancel(setId.hashCode);
  Future<void> cancelAll() => _plugin.cancelAll();
}