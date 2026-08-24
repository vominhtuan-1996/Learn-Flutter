import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification_service.dart';

enum NotifType { info, success, warning, promo, image }

extension _NotifTypeExt on NotifType {
  String get categoryId {
    switch (this) {
      case NotifType.info:    return 'NOTIF_INFO';
      case NotifType.success: return 'NOTIF_SUCCESS';
      case NotifType.warning: return 'NOTIF_WARNING';
      case NotifType.promo:   return 'NOTIF_PROMO';
      case NotifType.image:   return 'NOTIF_IMAGE';
    }
  }
}

/// Custom native notification:
/// - Android: RemoteViews XML via MethodChannel
/// - iOS:     flutter_local_notifications + categoryIdentifier → NotificationContent.appex
///
/// iOS: reuses LocalNotificationService.plugin (same FlutterLocalNotificationsPlugin
/// singleton) — creating a second instance would double-init the native
/// UNUserNotificationCenter delegate, resetting defaultPresent* flags and
/// silently breaking foreground notification display.
class CustomNotificationService {
  CustomNotificationService._();
  static final instance = CustomNotificationService._();

  static const _channel = MethodChannel('com.learnflutter/custom_notification');
  int _idCounter = 9000;

  // Shared plugin — NOT a new instance.
  FlutterLocalNotificationsPlugin get _plugin => LocalNotificationService.instance.plugin;

  Future<int?> show({
    required String title,
    required String body,
    String payload = '',
    int? id,
    NotifType type = NotifType.info,
    /// iOS only: image URL để extension load. Ghi đè payload khi type = image.
    String? imageUrl,
  }) async {
    if (kIsWeb) return null;
    final notiId = id ?? _idCounter++;

    if (Platform.isIOS) {
      final iosPayload = (type == NotifType.image && imageUrl != null) ? imageUrl : payload;
      return _showIOS(id: notiId, title: title, body: body, payload: iosPayload, type: type);
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
      await _plugin.show(
        id, title, body,
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            categoryIdentifier: type.categoryId,
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true,
            presentList: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: payload,
      );
      return id;
    } catch (e) {
      debugPrint('[CustomNotif] iOS error: $e');
      return null;
    }
  }
}
