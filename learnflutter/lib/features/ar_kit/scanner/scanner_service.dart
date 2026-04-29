import 'dart:io';

import 'package:flutter/services.dart';

/// Bridge to the native LiDAR scanner (iOS only).
class ScannerService {
  ScannerService._();

  static const MethodChannel _channel = MethodChannel('learnflutter/scanner');

  /// Whether this device supports ARKit scene reconstruction (LiDAR).
  static Future<bool> isSupported() async {
    if (!Platform.isIOS) return false;
    final v = await _channel.invokeMethod<bool>('isSupported');
    return v ?? false;
  }

  static Future<void> startScan() async {
    await _channel.invokeMethod<bool>('startScan');
  }

  static Future<void> stopScan() async {
    await _channel.invokeMethod<bool>('stopScan');
  }

  /// Exports the captured mesh. [format] is `obj` or `usdz`. Returns the file path.
  static Future<String?> exportScan({String format = 'obj'}) {
    return _channel.invokeMethod<String>(
      'exportScan',
      {'format': format},
    );
  }
}
