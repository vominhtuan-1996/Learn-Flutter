import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// [DailyLogScheduler] quản lý lịch gửi log định kỳ sử dụng [Workmanager].
///
/// Trạng thái scheduler (bật/tắt) được persist qua [SharedPreferences]
/// để khôi phục sau khi app restart.
///
/// Cách sử dụng:
/// ```dart
/// // Bật gửi hằng ngày
/// await DailyLogScheduler.initialize();
///
/// // Gửi ngay lập tức (test)
/// await DailyLogScheduler.triggerNow();
///
/// // Tắt
/// await DailyLogScheduler.cancelAll();
/// ```
class DailyLogScheduler {
  DailyLogScheduler._();

  // Task names được đăng ký với Workmanager
  static const taskNameDaily = 'daily_log_sender';
  static const taskNameOneShot = 'one_shot_log_sender';

  // Key lưu SharedPreferences
  static const _prefKeyEnabled = 'daily_log_scheduler_enabled';

  /// [initialize] đăng ký periodic task gửi log mỗi **1 ngày**.
  ///
  /// Minimum constraint của Workmanager là 15 phút — khi publish production
  /// đặt [frequencyInMinutes] = 1440 (= 24 giờ).
  /// Khi test local, set [frequencyInMinutes] = 15 (minimum cho phép).
  static Future<void> initialize({
    int frequencyInMinutes = 1440, // 24 giờ
  }) async {
    await Workmanager().registerPeriodicTask(
      taskNameDaily,
      taskNameDaily,
      frequency: Duration(minutes: frequencyInMinutes),
      // Constraint: chỉ chạy khi có network (để gửi được)
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      // Nếu task pending và đến hạn — chạy ngay
      existingWorkPolicy: ExistingWorkPolicy.replace,
      // Giữ task tồn tại dù app bị kill
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, true);
  }

  /// [cancelAll] huỷ tất cả scheduled task và lưu trạng thái tắt.
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, false);
  }

  /// [cancelByName] huỷ task theo tên cụ thể.
  static Future<void> cancelByName(String name) async {
    await Workmanager().cancelByUniqueName(name);
  }

  /// [triggerNow] chạy gửi log **ngay lập tức** (one-shot task).
  /// Dùng để test thủ công hoặc khi user nhấn nút "Gửi Ngay".
  ///
  /// Lưu ý: Workmanager one-shot có thể bị delay vài giây do OS scheduling.
  /// Với mục đích test real-time, nên gọi service trực tiếp thay vì qua Workmanager.
  static Future<void> triggerNow() async {
    await Workmanager().registerOneOffTask(
      '${taskNameOneShot}_${DateTime.now().millisecondsSinceEpoch}',
      taskNameOneShot,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// [isEnabled] kiểm tra trạng thái scheduler từ [SharedPreferences].
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? false;
  }

  /// [restoreIfEnabled] được gọi khi app khởi động để tự động khôi phục scheduler
  /// nếu user đã bật trước đó.
  ///
  /// Gọi trong `main()` hoặc sau khi Workmanager được initialize:
  /// ```dart
  /// await DailyLogScheduler.restoreIfEnabled();
  /// ```
  static Future<void> restoreIfEnabled() async {
    final enabled = await isEnabled();
    if (enabled) {
      await initialize();
    }
  }
}
