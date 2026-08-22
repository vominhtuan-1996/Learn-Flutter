import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotifType { info, success, warning, promo }

extension _NotifTypeExt on NotifType {
  String get categoryId {
    switch (this) {
      case NotifType.info:    return 'NOTIF_INFO';
      case NotifType.success: return 'NOTIF_SUCCESS';
      case NotifType.warning: return 'NOTIF_WARNING';
      case NotifType.promo:   return 'NOTIF_PROMO';
    }
  }
}

/// Custom native notification:
/// - Android: RemoteViews XML via MethodChannel
/// - iOS:     flutter_local_notifications + categoryIdentifier → NotificationContent.appex
class CustomNotificationService {
  CustomNotificationService._();
  static final instance = CustomNotificationService._();

  static const _channel = MethodChannel('com.learnflutter/custom_notification');
  int _idCounter = 9000;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(iOS: darwinInit));
    _initialized = true;
  }

  Future<int?> show({
    required String title,
    required String body,
    String payload = '',
    int? id,
    NotifType type = NotifType.info,
  }) async {
    if (kIsWeb) return null;
    final notiId = id ?? _idCounter++;

    if (Platform.isIOS) {
      return _showIOS(id: notiId, title: title, body: body, payload: payload, type: type);
    }
    if (Platform.isAndroid) {
      return _showAndroid(id: notiId, title: title, body: body, payload: payload);
    }
    return null;
  }

  Future<int?> _showAndroid({
    required int id, required String title, required String body, required String payload,
  }) async {
    try {
      await _channel.invokeMethod('showCustomNotification', {
        'id': id, 'title': title, 'body': body, 'payload': payload,
      });
      return id;
    } catch (e) {
      debugPrint('[CustomNotif] Android error: $e');
      return null;
    }
  }

  Future<int?> _showIOS({
    required int id, required String title, required String body,
    required String payload, required NotifType type,
  }) async {
    try {
      await _ensureInit();
      final details = NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: type.categoryId,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      );
      await _plugin.show(id, title, body, details, payload: payload);
      return id;
    } catch (e) {
      debugPrint('[CustomNotif] iOS error: $e');
      return null;
    }
  }
}
