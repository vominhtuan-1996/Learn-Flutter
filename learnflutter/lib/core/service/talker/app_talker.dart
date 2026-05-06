import 'package:learnflutter/core/service/log/log_file_service.dart';
import 'package:talker_flutter/talker_flutter.dart';

/* ============================================================================
 * 🛠 ADVANCED MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì nâng cao)
 * ============================================================================
 * 
 * 1. CẤU HÌNH PRODUCTION (Production Readiness):
 *    - QUY TẮC: Khi release ứng dụng, cần cân nhắc đặt `useConsoleLogs: false` 
 *      để tối ưu hiệu năng. Nếu ứng dụng không yêu cầu log offline, có thể đặt 
 *      `enabled: false`.
 * 
 * 2. BẢO MẬT & QUYỀN RIÊNG TƯ (Privacy & Security):
 *    - QUY TẮC: TUYỆT ĐỐI KHÔNG log các thông tin nhạy cảm như Password, 
 *      Full Credit Card Number, hoặc Access Token của người dùng.
 *    - ĐỊNH HƯỚNG: Tích hợp bộ lọc (Filter) tự động đè ký tự '*' lên các key 
 *      nhạy cảm trong response API trước khi đưa vào Talker.
 * 
 * 3. GHI LOG TỪ NHIỀU ISOLATE (Multi-isolate Logging):
 *    - CẢNH BÁO: Talker mặc định chỉ bắt được log trên Main Isolate. 
 *    - QUY TẮC: Để bắt log từ các Isolate khác (Isolate.spawn), cần sử dụng 
 *      `SendPort` để gửi message về Main thread và gọi `AppTalker.instance` tại đó.
 * 
 * 4. TÍCH HỢP HỆ THỐNG GIÁM SÁT (Monitoring Integration):
 *    - ĐỊNH HƯỚNG: Trong tương lai, có thể bổ sung `TalkerObserver` để tự động 
 *      đẩy các log level `error` hoặc `critical` lên Sentry hoặc Firebase Crashlytics.
 * 
 * 5. QUẢN LÝ BỘ NHỚ (Memory Management):
 *    - QUY TẮC: Giữ `maxHistoryItems` ở mức vừa phải (VD: 1000) để tránh chiếm 
 *      dụng quá nhiều RAM khi ứng dụng chạy trong thời gian dài.
 * ============================================================================
 */

/// [AppTalker] cung cấp một instance Talker duy nhất (singleton) cho toàn bộ ứng dụng.
/// Sử dụng singleton pattern để đảm bảo [TalkerScreen] có thể hiển thị log
/// từ mọi nguồn trong app: DioInterceptor, BLoC, Service layer, v.v.
///
/// Cách sử dụng từ bất kỳ đâu trong codebase:
/// ```dart
/// AppTalker.instance.info('User logged in');
/// AppTalker.instance.error('API call failed');
/// ```
class AppTalker {
  AppTalker._();

  /// [instance] là singleton Talker được khởi tạo bằng [TalkerFlutter.init()]
  /// để đảm bảo tính toàn vẹn của message log trên cả Android và iOS.
  /// (iOS có thể cắt log dài nếu dùng Talker() thay vì TalkerFlutter.init())
  static final Talker instance = TalkerFlutter.init(
    settings: TalkerSettings(
      /// [enabled] bật/tắt toàn bộ hệ thống talker.
      /// Đặt thành false trên production nếu không muốn ghi log.
      enabled: true,

      /// [useConsoleLogs] in log ra console IDE (Android Studio, VS Code).
      /// Có thể tắt trên production để tiết kiệm hiệu năng.
      useConsoleLogs: true,

      /// [maxHistoryItems] giới hạn số log giữ trong bộ nhớ.
      /// Tránh OutOfMemoryException khi app chạy lâu.
      maxHistoryItems: 1000,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        /// [level] xác định mức tối thiểu để log được ghi.
        /// verbose: ghi tất cả. debug: bỏ qua verbose. v.v.
        level: LogLevel.verbose,
      ),
    ),
  );

  /// [saveHistoryToFile] xuất toàn bộ log trong RAM hiện tại ra file vật lý.
  /// Nên gọi mỗi khi app vào background (paused) hoặc trước khi crash.
  static Future<void> saveHistoryToFile() async {
    try {
      await LogFileService.exportTalkerHistory(instance);
    } catch (e) {
      // ignore
    }
  }
}
