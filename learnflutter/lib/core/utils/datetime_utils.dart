// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

/// Lớp chứa các định dạng thời gian chuẩn được sử dụng trong toàn bộ ứng dụng.
/// Các hằng số này giúp đảm bảo tính nhất quán khi hiển thị và xử lý thời gian ở nhiều nơi khác nhau.
class DateTimeType {
  static const DATE_TIME_FORMAT = 'yyyy-MM-ddThh:mm:ssZ';
  static const DATE_TIME_FORMAT_GMT = 'hh:mm:ss dd/MM/yyyy';
  static const DATE_TIME_FORMAT_QR_CODE = 'hh:mm dd/MM/yyyy';
  static const TIME_FORMAT = 'hh:mm:ss';
  static const DATE_TIME_FORMAT_VN = 'dd/MM/yyyy';
  static const DATE_TIME_FORMAT_MM_YYYY = 'MM/yyyy';
  static const DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM = "dd/MM/yyyy - HH'h'mm";
}

/// Lớp tiện ích cung cấp các phương thức xử lý và chuyển đổi thời gian.
/// Bao gồm các chức năng chuyển đổi giữa timestamp, DateTime, và chuỗi theo nhiều định dạng khác nhau.
class DateTimeUtils {
  DateTimeUtils._();

  /// Chuyển đổi DateTime thành timestamp (giây kể từ epoch).
  /// Nếu không truyền vào dateTime, sẽ sử dụng thời gian hiện tại.
  static int timestamp({DateTime? dateTime}) {
    dateTime ??= DateTime.now();
    return (dateTime.millisecondsSinceEpoch / 1000).round();
  }

  /// Lấy thời gian hiện tại dưới dạng chuỗi theo định dạng được chỉ định.
  /// Mặc định sử dụng định dạng 'dd/MM/yyyy' phù hợp với chuẩn Việt Nam.
  static String getCurrentTime({String format = 'dd/MM/yyyy'}) {
    final time = DateTime.now();
    return DateFormat(format).format(time);
  }

  /// Chuyển đổi chuỗi thời gian UTC sang định dạng local theo mẫu được chỉ định.
  /// Trả về chuỗi rỗng nếu quá trình parse thất bại.
  static String parseUTCTime(String date,
      [String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT]) {
    try {
      DateFormat format = DateFormat(formatTemplate);
      DateTime time = DateTime.tryParse(date)!.toLocal();
      return format.format(time);
    } catch (e) {
      return '';
    }
  }

  /// Chuyển đổi chuỗi thời gian sang đối tượng DateTime.
  /// Sử dụng inputFormat để parse chuỗi đầu vào và trả về DateTime ở múi giờ local.
  static DateTime parseStringToDateTime(String date,
      [String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT,
      String inputFormat = DateTimeType.DATE_TIME_FORMAT_MM_YYYY]) {
    try {
      DateTime parseDate = DateFormat(inputFormat).parse(date);
      return DateTime.parse(parseDate.toString()).toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Chuyển đổi chuỗi thời gian từ một định dạng sang định dạng khác.
  /// Hỗ trợ cả UTC và local time zone tùy theo tham số isUTC.
  static String parseStringToString(String? date,
      [String inputFormat = DateTimeType.DATE_TIME_FORMAT,
      String formatTemplate = DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM,
      bool isUTC = true]) {
    try {
      DateFormat format = DateFormat(formatTemplate);
      DateTime parseDate =
          DateFormat(inputFormat).parse(date!, isUTC).toLocal();
      return format.format(parseDate);
    } catch (e) {
      return "";
    }
  }

  /// Chuyển đổi timestamp (giây) sang chuỗi thời gian theo định dạng được chỉ định.
  /// Timestamp được nhân với 1000 để chuyển từ giây sang milliseconds.
  static String timestampToDateString(int? timestamp,
      {String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT}) {
    DateFormat format = DateFormat(formatTemplate);
    return format
        .format(DateTime.fromMillisecondsSinceEpoch((timestamp ?? 0) * 1000));
  }

  /// Chuyển đổi timestamp (giây) sang đối tượng DateTime.
  static DateTime timestampToDate(int? timestamp) {
    return DateTime.fromMillisecondsSinceEpoch((timestamp ?? 0) * 1000);
  }
}

/// Lớp phát hiện việc người dùng thay đổi giờ hệ thống (clock tampering).
/// Sử dụng Stopwatch để theo dõi thời gian thực và so sánh với DateTime.now() để phát hiện sự bất thường.
/// Hỗ trợ cả kiểm tra offline (dựa vào Stopwatch) và online (dựa vào NTP server).
class ClockTamperDetector {
  late DateTime _startSystemTime;
  late Stopwatch _stopwatch;
  Duration maxAllowedDrift;

  ClockTamperDetector({this.maxAllowedDrift = const Duration(seconds: 5)});

  /// Bắt đầu theo dõi thời gian hệ thống.
  /// Lưu lại thời điểm bắt đầu và khởi động Stopwatch để so sánh sau này.
  void startMonitoring() {
    _startSystemTime = DateTime.now();
    _stopwatch = Stopwatch()..start();
  }

  /// Kiểm tra xem người dùng có chỉnh giờ hệ thống không (offline check).
  /// So sánh độ lệch giữa thời gian thực tế và thời gian đo bằng Stopwatch.
  bool isTamperedOffline() {
    final now = DateTime.now();
    final realElapsed = now.difference(_startSystemTime);
    final stopwatchElapsed = _stopwatch.elapsed;

    final drift = realElapsed - stopwatchElapsed;

    return drift.abs() > maxAllowedDrift;
  }

  /// Kiểm tra với thời gian từ NTP server (online check).
  /// So sánh thời gian thiết bị với thời gian chuẩn từ NTP để phát hiện sự chênh lệch bất thường.
  Future<bool> isTamperedOnline() async {
    try {
      final ntpTime = await NTP.now();
      final deviceTime = DateTime.now();
      final drift = ntpTime.difference(deviceTime);

      return drift.abs() > maxAllowedDrift;
    } catch (e) {
      debugPrint("⚠️ Lỗi khi kiểm tra NTP: $e");
      return false;
    }
  }

  /// Lấy độ lệch thời gian hiện tại (so với stopwatch).
  /// Giá trị dương nghĩa là đồng hồ hệ thống chạy nhanh hơn, âm nghĩa là chạy chậm hơn.
  Duration getOfflineDrift() {
    final now = DateTime.now();
    final realElapsed = now.difference(_startSystemTime);
    final stopwatchElapsed = _stopwatch.elapsed;
    return realElapsed - stopwatchElapsed;
  }
}
