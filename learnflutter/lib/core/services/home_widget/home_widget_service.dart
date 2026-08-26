import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Data model gửi lên iOS Widget.
class WidgetUserData {
  const WidgetUserData({
    required this.userName,
    required this.balance,
    required this.stats,
  });

  final String userName;
  final String balance;

  /// Mỗi item: {'label': '...', 'value': '...'}
  final List<Map<String, String>> stats;
}

/// Bridge Flutter → iOS WidgetKit (Home Screen Widget).
///
/// Dùng App Group UserDefaults làm shared storage.
/// iOS Widget đọc cùng App Group ID → render SwiftUI.
///
/// Usage:
/// ```dart
/// await HomeWidgetService.instance.init();
/// await HomeWidgetService.instance.update(WidgetUserData(
///   userName: 'Nguyễn Văn A',
///   balance: '1,234,567 ₫',
///   stats: [
///     {'label': 'Đơn hàng', 'value': '12'},
///     {'label': 'Điểm thưởng', 'value': '850'},
///   ],
/// ));
/// ```
class HomeWidgetService {
  HomeWidgetService._();
  static final instance = HomeWidgetService._();

  static const _appGroupId      = 'group.com.fpt.isc.prod.HomeWidget';
  static const _iOSWidgetName   = 'HomeWidget';
  static const _androidWidgetName = 'AppHomeWidgetProvider';

  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _ready = true;
  }

  Future<void> _ensureReady() async {
    if (!_ready) await init();
  }

  Future<void> update(WidgetUserData data) async {
    if (kIsWeb) return;
    await _ensureReady();
    await Future.wait([
      HomeWidget.saveWidgetData('user_name', data.userName),
      HomeWidget.saveWidgetData('balance', data.balance),
      HomeWidget.saveWidgetData('stats', jsonEncode(data.stats)),
      HomeWidget.saveWidgetData('last_updated', _now()),
    ]);
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
    debugPrint('[HomeWidget] updated for ${data.userName}');
  }

  /// Xóa sạch data widget (e.g. khi logout).
  Future<void> clear() async {
    if (kIsWeb) return;
    await _ensureReady();
    await Future.wait([
      HomeWidget.saveWidgetData<String?>('user_name', null),
      HomeWidget.saveWidgetData<String?>('balance', null),
      HomeWidget.saveWidgetData<String?>('stats', null),
      HomeWidget.saveWidgetData<String?>('last_updated', null),
    ]);
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  String _now() {
    final t = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(t.day)}/${p(t.month)}/${t.year} ${p(t.hour)}:${p(t.minute)}';
  }
}
