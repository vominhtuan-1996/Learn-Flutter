import 'package:learnflutter/core/service/log/log_file_service.dart';
import 'package:talker_flutter/talker_flutter.dart';

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
