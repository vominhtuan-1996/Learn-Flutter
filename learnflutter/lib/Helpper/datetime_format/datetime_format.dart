// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class DateTimeType {
  static const DATE_TIME_FORMAT = 'yyyy-MM-ddThh:mm:ssZ';
  static const DATE_TIME_FORMAT_GMT = 'hh:mm:ss dd/MM/yyyy';
  static const DATE_TIME_FORMAT_QR_CODE = 'hh:mm dd/MM/yyyy';
  static const TIME_FORMAT = 'hh:mm:ss';
  static const DATE_TIME_FORMAT_VN = 'dd/MM/yyyy';
  static const DATE_TIME_FORMAT_MM_YYYY = 'MM/yyyy';
  static const DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM = "dd/MM/yyyy - HH'h'mm";
}

class DateTimeFormat {
  DateTimeFormat._();

  /// dateTime == null get Timestamp current
  static int timestamp({DateTime? dateTime}) {
    dateTime ??= DateTime.now();
    return (dateTime.millisecondsSinceEpoch / 1000).round();
  }

  static String getCurrentTime({String format = 'dd/MM/yyyy'}) {
    final time = DateTime.now();
    return DateFormat(format).format(time);
  }

  static String parseUTCTime(String date, [String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT]) {
    try {
      DateFormat format = DateFormat(formatTemplate);
      DateTime time = DateTime.tryParse(date)!.toLocal();
      return format.format(time);
    } catch (e) {
      return '';
    }
  }

  static DateTime parseStringToDateTime(String date, [String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT, String inputFormat = DateTimeType.DATE_TIME_FORMAT_MM_YYYY]) {
    try {
      DateTime parseDate = DateFormat(inputFormat).parse(date);
      return DateTime.parse(parseDate.toString()).toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  static String parseStringToString(String? date, [String inputFormat = DateTimeType.DATE_TIME_FORMAT, String formatTemplate = DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM, bool isUTC = true]) {
    try {
      DateFormat format = DateFormat(formatTemplate);
      DateTime parseDate = DateFormat(inputFormat).parse(date!, isUTC).toLocal();
      return format.format(parseDate);
    } catch (e) {
      return "";
    }
  }

  static String timestampToDateString(int? timestamp, {String formatTemplate = DateTimeType.DATE_TIME_FORMAT_GMT}) {
    DateFormat format = DateFormat(formatTemplate);
    return format.format(DateTime.fromMillisecondsSinceEpoch((timestamp ?? 0) * 1000));
  }

  static DateTime timestampToDate(int? timestamp) {
    return DateTime.fromMillisecondsSinceEpoch((timestamp ?? 0) * 1000);
  }
}
