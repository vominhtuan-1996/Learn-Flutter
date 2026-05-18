import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// [LogFileService] quản lý việc xuất log Talker ra file .txt và dọn dẹp log cũ.
///
/// Flow:
///  1. App về background → gọi [saveHistoryToFile] để persist log ra file
///  2. Workmanager task chạy → gọi [getLatestLogFile] rồi gửi file lên Google Chat
///  3. Định kỳ gọi [clearOldLogFiles] để dọn log quá hạn
class LogFileService {
  LogFileService._();

  static const _logFolderName = 'talker_logs';

  /// Trả về đường dẫn thư mục chứa log files.
  static Future<Directory> get _logDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/$_logFolderName');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  /// [exportTalkerHistory] xuất toàn bộ log history từ [Talker] instance ra file .txt.
  ///
  /// File được đặt tên theo ngày hiện tại: `talker_YYYY-MM-DD.txt`.
  /// Nếu file đã tồn tại trong ngày, nội dung sẽ được **ghi đè** (snapshot mới nhất).
  /// Trả về [File] đã được ghi.
  static Future<File> exportTalkerHistory(Talker talker) async {
    final dir = await _logDir;
    final dateStr = _dateString(DateTime.now());
    final file = File('${dir.path}/talker_$dateStr.txt');

    final buffer = StringBuffer();
    buffer.writeln('=== Talker Log Report ===');
    buffer.writeln('Ngày: $dateStr');
    buffer.writeln('Tổng số log: ${talker.history.length}');
    buffer.writeln('==========================');
    buffer.writeln();

    for (final record in talker.history) {
      final time = _formatTime(record.time);
      final level = record.logLevel?.name.toUpperCase() ?? 'LOG';
      final message =
          record.generateTextMessage(timeFormat: TimeFormat.timeAndSeconds);
      buffer.writeln('[$time] [$level] $message');
    }

    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  /// [getLatestLogFile] trả về file log mới nhất trong thư mục,
  /// hoặc `null` nếu chưa có file nào.
  static Future<File?> getLatestLogFile() async {
    final dir = await _logDir;
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.txt'))
        .cast<File>()
        .toList();

    if (files.isEmpty) return null;

    files.sort((a, b) => b.path.compareTo(a.path));
    return files.first;
  }

  /// [getAllLogFiles] trả về danh sách tất cả file log, sắp xếp mới nhất trước.
  static Future<List<File>> getAllLogFiles() async {
    final dir = await _logDir;
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.txt'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  /// [clearOldLogFiles] xoá các file log cũ hơn [keepDays] ngày.
  /// Mặc định giữ lại 7 ngày gần nhất.
  static Future<void> clearOldLogFiles({int keepDays = 7}) async {
    final dir = await _logDir;
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.txt')) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) {
          await entity.delete();
        }
      }
    }
  }

  /// [readLogFile] đọc nội dung file log, trả về chuỗi rỗng nếu lỗi.
  static Future<String> readLogFile(File file) async {
    try {
      return await file.readAsString();
    } catch (_) {
      return '';
    }
  }

  /// [getLogDirPath] trả về đường dẫn thư mục log để hiển thị UI.
  static Future<String> getLogDirPath() async {
    final dir = await _logDir;
    return dir.path;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static String _dateString(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
