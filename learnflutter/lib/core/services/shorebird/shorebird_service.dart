import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:learnflutter/core/engines/engine_dialog/app_dialog_engine.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Dịch vụ quản lý các tác vụ liên quan đến Shorebird OTA Patch.
/// Sử dụng Singleton pattern để đảm bảo chỉ có 1 instance xử lý logic cập nhật.
class ShorebirdService {
  ShorebirdService._();
  static final ShorebirdService instance = ShorebirdService._();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

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
        debugPrint('Shorebird: Có bản vá mới! Hiển thị dialog cập nhật.');
        _showUpdateDialog();
      } else {
        debugPrint('Shorebird: Hiện không có bản vá nào mới.');
      }
    } catch (e) {
      debugPrint('Shorebird: Lỗi kiểm tra bản vá: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Hiển thị AppDialogEngine với giao diện cập nhật
  void _showUpdateDialog() {
    AppDialogEngine.showUpdatePatch(
      version: 'Bản vá mới', // Shorebird không trả về version name cụ thể của patch, nên dùng chuỗi mặc định
      changelog: ['Sửa lỗi ứng dụng & cải thiện hiệu suất', 'Tối ưu hoá trải nghiệm giao diện người dùng', 'Được phân phối qua OTA (Over-The-Air)'],
      progress: 0.0,
      isDownloading: false,
      onUpdate: () async {
        // Callback khi user ấn cập nhật ngay
        _startDownloadAndRestart();
      },
    );
  }

  /// Xử lý tải bản vá về và khởi động lại
  Future<void> _startDownloadAndRestart() async {
    try {
      // Kiểm tra status hiện tại trước khi tải.
      // Nếu patch đã được tải sẵn từ phiên trước (cache) -> chỉ cần khởi động lại.
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.restartRequired) {
        AppDialogEngine.success(
          'Bản vá đã sẵn sàng. Vui lòng khởi động lại ứng dụng để áp dụng.',
          title: 'Đã có bản vá',
        );
        return;
      }

      if (status == UpdateStatus.upToDate) {
        AppDialogEngine.info(
          'Ứng dụng đã ở phiên bản mới nhất.',
          title: 'Không có bản vá',
        );
        return;
      }

      if (status != UpdateStatus.outdated) {
        // unavailable: updater không có trong build (flutter build thường, không phải shorebird release)
        AppDialogEngine.error('Thiết bị hiện không hỗ trợ cập nhật OTA.', title: 'Không hỗ trợ');
        return;
      }

      AppDialogEngine.info('Đang tải bản vá...', title: 'Đang tải');

      await _updater.update();

      // Sau khi update() thành công, trạng thái phải là restartRequired.
      final after = await _updater.checkForUpdate();
      if (after == UpdateStatus.restartRequired) {
        AppDialogEngine.success(
          'Bản vá đã tải xong. Ứng dụng sẽ áp dụng trong lần khởi động tiếp theo.',
          title: 'Hoàn tất',
        );
      } else {
        // Không có thay đổi sau update — patch có thể đã được áp dụng từ cache mà không cần tải.
        AppDialogEngine.info('Không có bản vá mới cần tải.', title: 'Đã cập nhật');
      }
    } on UpdateException catch (e) {
      debugPrint('Shorebird: UpdateException [${e.reason}]: ${e.message}');
      switch (e.reason) {
        case UpdateFailureReason.noUpdate:
          AppDialogEngine.info('Không có bản vá mới.', title: 'Đã cập nhật');
          break;
        case UpdateFailureReason.downloadFailed:
          AppDialogEngine.error('Tải bản vá thất bại. Kiểm tra kết nối mạng và thử lại.', title: 'Lỗi tải');
          break;
        case UpdateFailureReason.installFailed:
          AppDialogEngine.error('Cài đặt bản vá thất bại.', title: 'Lỗi cài đặt');
          break;
        case UpdateFailureReason.unknown:
          AppDialogEngine.error('Không thể cập nhật. Vui lòng thử lại sau.', title: 'Lỗi');
          break;
      }
    } catch (e) {
      debugPrint('Shorebird: Lỗi tải bản vá: $e');
      AppDialogEngine.error('Không thể cập nhật, vui lòng thử lại sau.', title: 'Lỗi');
    }
  }
}
