import 'dart:io';

import 'package:flutter/services.dart';
import 'package:learnflutter/core/services/live_activity/live_activity_data.dart';

/// Bridge Flutter → native Live Activity (iOS ActivityKit / Android ongoing notification).
///
/// iOS:     ActivityKit — Lock Screen banner + Dynamic Island (iOS 17.0+).
///          areActivitiesEnabled() trả false trên iOS < 17 — extension không embed.
/// Android: Ongoing notification (implemented separately).
class LiveActivityService {
  LiveActivityService._();
  static final instance = LiveActivityService._();

  static const _channel = MethodChannel('live_activity');

  /// Start activity. Trả về activityId — lưu lại để [update]/[end].
  /// Trả `null` nếu device không hỗ trợ hoặc user chưa cấp quyền.
  Future<String?> start(LiveActivityData data) async {
    if (!Platform.isIOS && !Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<String>('start', data.toMap());
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[LiveActivity] start failed: ${e.message}');
      return null;
    }
  }

  /// Update dynamic state của activity đang chạy.
  Future<void> update(String activityId, LiveActivityState state) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('update', {
      'id': activityId,
      ...state.toMap(),
    });
  }

  /// Kết thúc và dismiss activity.
  Future<void> end(String activityId) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('end', {'id': activityId});
  }

  /// iOS: check [ActivityAuthorizationInfo.areActivitiesEnabled].
  /// Android: luôn `true` (API 26+).
  Future<bool> areActivitiesEnabled() async {
    if (Platform.isAndroid) return true;
    if (Platform.isIOS) {
      return await _channel.invokeMethod<bool>('areEnabled') ?? false;
    }
    return false;
  }
}
