import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service quản lý tập trung Local Notification cho toàn bộ ứng dụng.
///
/// Thiết kế theo mô hình Singleton để đảm bảo chỉ có một instance plugin
/// duy nhất trong vòng đời app, tránh khởi tạo trùng lặp gây leak resource.
///
/// Cách sử dụng:
/// ```dart
/// await LocalNotificationService.instance.init(
///   onTap: (payload) => debugPrint('Tapped: $payload'),
/// );
/// await LocalNotificationService.instance.show(
///   title: 'Hello',
///   body: 'World',
/// );
/// ```
class LocalNotificationService {
  LocalNotificationService._internal();

  static final LocalNotificationService instance =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _autoId = 0;

  /// Channel mặc định dùng cho thông báo thường (Android 8.0+ yêu cầu channel).
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'default_channel',
    'Default',
    description: 'Kênh thông báo mặc định của ứng dụng',
    importance: Importance.high,
  );

  /// Khởi tạo plugin. Gọi 1 lần duy nhất trong [main] trước khi runApp().
  ///
  /// [onTap] được gọi khi người dùng nhấn vào notification (kèm payload).
  Future<void> init({
    void Function(String? payload)? onTap,
  }) async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS/macOS: bật defaultPresent* để banner / sound / badge hiển thị ngay cả khi
    // app đang ở foreground (iOS mặc định KHÔNG hiện banner ở foreground).
    const iosInit = DarwinInitializationSettings(
      // Xin quyền ngay khi init để iOS hiển thị popup permission lần đầu.
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Bật defaultPresent* để banner / sound / badge hiển thị ngay cả khi
      // app đang ở foreground (iOS mặc định KHÔNG hiện banner ở foreground).
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response.payload);
      },
    );

    // Tạo channel mặc định cho Android (no-op trên iOS/macOS) — bắt buộc
    // trên Android 8.0+ nếu không có channel thì show() sẽ bị OS chặn im lặng.
    if (!kIsWeb && Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_defaultChannel);

      // Android 13+ (API 33) cần xin quyền POST_NOTIFICATIONS lúc runtime.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Yêu cầu quyền hiển thị notification (iOS/macOS/Android 13+).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (Platform.isIOS || Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Hiển thị notification ngay lập tức.
  ///
  /// Trả về [id] đã dùng để có thể [cancel] sau này.
  /// Throw nếu plugin chưa được init hoặc OS reject (sẽ log debug).
  Future<int> show({
    required String title,
    required String body,
    String? payload,
    int? id,
    NotificationDetails? details,
  }) async {
    if (!_initialized) {
      throw StateError(
        'LocalNotificationService chưa init. Gọi init() trước khi show().',
      );
    }

    // Đảm bảo đã có quyền trước khi show — nếu chưa, request lại (no-op nếu
    // đã từng được trả lời). Tránh trường hợp show() bị OS chặn im lặng.
    final enabled = await isEnabled();
    if (!enabled) {
      await requestPermission();
    }

    final notiId = id ?? _nextId();
    try {
      await _plugin.show(
        notiId,
        title,
        body,
        details ?? _defaultDetails(),
        payload: payload,
      );
      debugPrint('[LocalNotif] show id=$notiId title="$title" OK');
    } catch (e, st) {
      debugPrint('[LocalNotif] show FAILED id=$notiId: $e\n$st');
      rethrow;
    }
    return notiId;
  }

  /// Kiểm tra notification có đang được phép hiển thị hay không.
  /// Trên iOS/macOS: dựa vào [checkPermissions]. Android 13+: theo
  /// [areNotificationsEnabled]. Các trường hợp khác trả về true (giả định bật).
  Future<bool> isEnabled() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final opts = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return opts?.isAlertEnabled == true ||
          opts?.isBadgeEnabled == true ||
          opts?.isSoundEnabled == true;
    }
    return true;
  }

  /// Hủy 1 notification theo [id].
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Hủy toàn bộ notifications đang hiển thị / đã lên lịch.
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Truy cập plugin gốc cho các tác vụ nâng cao (zonedSchedule, periodic...).
  FlutterLocalNotificationsPlugin get raw => _plugin;

  // ─── Internal ──────────────────────────────────────────────────────────

  int _nextId() => _autoId++;

  NotificationDetails _defaultDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      // Set presentBanner/List/Alert TRỰC TIẾP cho từng notification để chắc
      // chắn banner hiển thị khi app đang foreground (override init defaults).
      // iOS 14+: presentAlert đã deprecated, dùng presentBanner + presentList.
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
