import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:learnflutter/core/engines/engine_dialog/app_dialog_engine.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_service.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Dịch vụ quản lý các tác vụ liên quan đến Shorebird OTA Patch.
/// Sử dụng Singleton pattern để đảm bảo chỉ có 1 instance xử lý logic cập nhật.
class ShorebirdService {
  ShorebirdService._();
  static final ShorebirdService instance = ShorebirdService._();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Payload + ID cho noti "tap để mở lại app áp dụng patch".
  static const int _restartNotiId = 7700001;
  static const String restartPayload = 'shorebird:restart_to_apply_patch';

  /// Wire vào `LocalNotificationService.init(onTap: ...)` trong main.
  /// Khi user bấm noti có payload [restartPayload] → restart app (cold launch
  /// để Shorebird engine load patch mới).
  static Future<void> handleNotificationTap(String? payload) async {
    if (payload != restartPayload) return;
    debugPrint('Shorebird: User tapped restart noti → restarting app...');
    await Restart.restartApp();
  }

  // Trạng thái debounce để tránh kiểm tra liên tục
  DateTime? _lastCheckedTime;
  final Duration _debounceDuration = const Duration(minutes: 15);
  bool _isChecking = false;

  /// Hàm kiểm tra cập nhật bản vá.
  /// Gọi hàm này từ vòng đời ứng dụng (vd: AppLifecycleState.resumed).
  Future<void> checkUpdate({bool forceCheck = false}) async {
    // Chỉ check trên nền tảng hỗ trợ (không chạy trên web, macos, windows trong debug)
    if (kIsWeb || (!defaultTargetPlatform.name.toLowerCase().contains('ios') && !defaultTargetPlatform.name.toLowerCase().contains('android'))) {
      return;
    }

    if (_isChecking) return;

    // Xử lý debounce
    if (!forceCheck && _lastCheckedTime != null) {
      final difference = DateTime.now().difference(_lastCheckedTime!);
      if (difference < _debounceDuration) {
        debugPrint('Shorebird: Bỏ qua kiểm tra, mới check cách đây ${difference.inMinutes} phút.');
        return;
      }
    }

    _isChecking = true;
    try {
      debugPrint('Shorebird: Bắt đầu kiểm tra bản vá...');
      final status = await _updater.checkForUpdate();
      final isUpdateAvailable = status == UpdateStatus.outdated;

      _lastCheckedTime = DateTime.now();

      if (isUpdateAvailable) {
        debugPrint('Shorebird: Có bản vá mới! Auto-download (silent).');
        // Auto flow: show simulating dialog + download, không cần user confirm.
        await _startSilentDownloadAndRestart();
      } else {
        debugPrint('Shorebird: Hiện không có bản vá nào mới.');
      }
    } catch (e) {
      debugPrint('Shorebird: Lỗi kiểm tra bản vá: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Đóng dialog hiện tại (nếu còn).
  void _dismissCurrentDialog() {
    final nav = UtilsHelper.navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  /// Auto-download bản vá silently (không yêu cầu user confirm) + restart
  /// ngay khi tải xong. UI chỉ là dialog progress mô phỏng để user biết
  /// app đang cập nhật, không có nút bấm.
  Future<void> _startSilentDownloadAndRestart() async {
    try {
      // Mở dialog download (autoSimulate để progress tự chạy — Shorebird SDK
      // không expose progress thật).
      unawaited(
        AppDialogEngine.showUpdatePatch(
          version: 'Bản vá mới',
          changelog: const ['Đang tải bản cập nhật mới...'],
          progress: 0.0,
          isDownloading: true,
          autoSimulate: true,
          onUpdate: () {},
        ),
      );

      // Đợi dialog mount xong rồi mới bắt đầu download
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await _updater.update();

      // Confirm patch sẵn sàng → auto restart, không hỏi user.
      final after = await _updater.checkForUpdate();
      _dismissCurrentDialog();

      if (after == UpdateStatus.restartRequired) {
        debugPrint('Shorebird: Patch tải xong → push noti để user mở lại app.');
        await _showRestartNotification();
      } else {
        debugPrint('Shorebird: Update xong nhưng status không phải restartRequired ($after).');
      }
    } on UpdateException catch (e) {
      _dismissCurrentDialog();
      debugPrint('Shorebird: UpdateException [${e.reason}]: ${e.message}');
      // Im lặng với user — đây là silent flow. Chỉ log debug. Nếu muốn
      // toast cho dev, gỡ comment bên dưới.
      // AppDialogEngine.error('Tải bản vá thất bại.', title: 'Lỗi');
    } catch (e) {
      _dismissCurrentDialog();
      debugPrint('Shorebird: Lỗi tải bản vá: $e');
    }
  }

  /// Push local noti — tap noti sẽ gọi [handleNotificationTap] → restart app.
  Future<void> _showRestartNotification() async {
    try {
      await LocalNotificationService.instance.show(
        id: _restartNotiId,
        title: 'Đã có bản cập nhật mới',
        body: 'Bấm để khởi động lại và áp dụng bản vá.',
        payload: restartPayload,
      );
    } catch (e) {
      debugPrint('Shorebird: Không show được noti restart: $e');
    }
  }
}
