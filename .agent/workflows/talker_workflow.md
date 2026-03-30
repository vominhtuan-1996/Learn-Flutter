---
description: Quy trình tích hợp talker_flutter ^5.1.14 (advanced logger) vào Flutter project và xem log trực tiếp trên thiết bị bằng TalkerScreen
---

# Talker Flutter Workflow

## Tổng quan

Package **talker_flutter 5.1.14** là một hệ thống logging và error handling nâng cao cho Flutter.
Điểm nổi bật so với `debugPrint` hay `Logger` thông thường:

- Xem log ngay **trực tiếp trên thiết bị** (không cần cắm máy) qua `TalkerScreen`
- Hỗ trợ **nhiều mức log**: debug, info, warning, error, critical, good
- **Handle Exception + StackTrace** tự động đẹp mắt
- Tích hợp sẵn với **Dio** (HTTP logger), **BLoC**, **Riverpod**
- Lọc, tìm kiếm, xuất file log dễ dàng

---

## Bước 1 – Thêm dependency

Mở `pubspec.yaml` và thêm:

```yaml
dependencies:
  talker_flutter: ^5.1.14
  # Tuỳ chọn: nếu muốn log Dio HTTP requests
  talker_dio_logger: ^5.1.14
```

Chạy:

```bash
flutter pub get
```

---

## Bước 2 – Khởi tạo Talker (global singleton)

> **Quan trọng**: Dùng `TalkerFlutter.init()` thay vì `Talker()` để đảm bảo log không bị cắt trên iOS.

Tạo file `lib/core/service/talker/app_talker.dart`:

```dart
import 'package:talker_flutter/talker_flutter.dart';

/// [AppTalker] cung cấp một instance Talker duy nhất (singleton) cho toàn bộ ứng dụng.
/// Việc dùng singleton đảm bảo TalkerScreen hiển thị log từ mọi nơi trong app,
/// kể cả log từ Dio interceptor, BLoC, hay các service layer.
class AppTalker {
  AppTalker._();

  /// [instance] là singleton Talker được khởi tạo bằng TalkerFlutter.init()
  /// để đảm bảo tính toàn vẹn message trên cả Android và iOS.
  static final Talker instance = TalkerFlutter.init(
    settings: TalkerSettings(
      /// Bật/tắt toàn bộ talker (tiện để tắt hoàn toàn trên production).
      enabled: true,
      /// Hiển thị log trong console (có thể tắt trên production).
      useConsoleLogs: true,
      /// Giới hạn số log được giữ trong bộ nhớ (tránh tràn RAM).
      maxHistoryItems: 1000,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        /// Mức log tối thiểu được ghi — đặt verbose để bắt tất cả trong debug.
        level: LogLevel.verbose,
      ),
    ),
  );
}
```

---

## Bước 3 – Tích hợp TalkerRouteObserver (tuỳ chọn nhưng khuyến nghị)

Mở `lib/main.dart` (hoặc file chứa `MaterialApp`) và thêm observer:

```dart
import 'package:learnflutter/core/service/talker/app_talker.dart';
import 'package:talker_flutter/talker_flutter.dart';

MaterialApp(
  // ...
  navigatorObservers: [
    /// [TalkerRouteObserver] tự động log mọi sự kiện navigation (push, pop, replace).
    /// Rất hữu ích để trace user flow khi debug.
    TalkerRouteObserver(AppTalker.instance),
  ],
);
```

---

## Bước 4 – Tích hợp TalkerDioLogger (nếu dùng Dio)

Trong class quản lý Dio (ví dụ `DioClient`, `ApiService`):

```dart
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';

final dio = Dio();

dio.interceptors.add(
  TalkerDioLogger(
    talker: AppTalker.instance,
    settings: const TalkerDioLoggerSettings(
      /// In header của request để debug auth token.
      printRequestHeaders: true,
      /// In header của response.
      printResponseHeaders: false,
      /// In message của response body.
      printResponseMessage: true,
      /// In error đầy đủ khi API fail.
      printErrorMessage: true,
    ),
  ),
);
```

---

## Bước 5 – Tạo màn hình demo TalkerExampleScreen

Tạo file tại `lib/features/log/talker_example_screen.dart`:

```dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerExampleScreen extends StatefulWidget {
  /// [talker] truyền vào từ ngoài để chia sẻ cùng một log history.
  final Talker talker;
  const TalkerExampleScreen({super.key, required this.talker});

  @override
  State<TalkerExampleScreen> createState() => _TalkerExampleScreenState();
}

class _TalkerExampleScreenState extends State<TalkerExampleScreen> {
  Talker get _talker => widget.talker;

  @override
  void initState() {
    super.initState();
    _talker.info('🚀 TalkerExampleScreen khởi tạo');
  }

  void _handleException() {
    try {
      throw Exception('Lỗi API: Timeout sau 30 giây');
    } catch (e, st) {
      _talker.handle(e, st, '📡 Exception trong NetworkService');
    }
  }

  void _openTalkerScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TalkerScreen(
        talker: _talker,
        theme: TalkerScreenTheme(
          backgroundColor: Color(0xFF1A1A2E),
          textColor: Colors.white,
          cardColor: Color(0xFF16213E),
        ),
        appBarTitle: 'Talker Log Viewer',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: Text('Talker Example'),
        actions: [
          IconButton(icon: Icon(Icons.bug_report), onPressed: _openTalkerScreen),
        ],
      ),
      child: Column(
        children: [
          TextButton(onPressed: () => _talker.debug('debug'), child: Text('Debug')),
          TextButton(onPressed: () => _talker.info('info'), child: Text('Info')),
          TextButton(onPressed: () => _talker.warning('warning'), child: Text('Warning')),
          TextButton(onPressed: () => _talker.error('error'), child: Text('Error')),
          TextButton(onPressed: () => _talker.critical('critical'), child: Text('Critical')),
          TextButton(onPressed: () => _talker.good('good'), child: Text('Good')),
          TextButton(onPressed: _handleException, child: Text('Handle Exception')),
          TextButton(onPressed: _openTalkerScreen, child: Text('📋 View Logs')),
        ],
      ),
    );
  }
}
```

> **Lưu ý**: File đầy đủ với UI chi tiết đã được tạo tại `lib/features/log/talker_example_screen.dart`.

---

## Bước 6 – Đăng ký Route

Mở `lib/shared/widgets/routes/route.dart`.

### 6.1 – Thêm import

```dart
import 'package:learnflutter/features/log/talker_example_screen.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';
```

### 6.2 – Thêm route constant vào class `Routes`

```dart
static const String talkerScreen = 'talker_example_screen';
```

### 6.3 – Thêm case trong `generateRoute`

```dart
case talkerScreen:
  return SlideRightRoute(
    routeSettings: RouteSettings(name: talkerScreen),
    builder: (_) => TalkerExampleScreen(talker: AppTalker.instance),
  );
```

---

## Bước 7 – Thêm nút vào TestScreen

Mở `lib/features/test_screen/test_screen.dart`, thêm vào `children`:

```dart
TextButton(
  onPressed: () {
    Navigator.of(context).pushNamed(Routes.talkerScreen);
  },
  child: const Text('Talker Logger Example'),
),
```

> **Vị trí khuyến nghị**: Đặt gần nhóm nút log/debug hiện có (gần `Routes.log`).

---

## Bước 8 – Chạy và kiểm tra

```bash
flutter run
```

1. Từ màn hình chính → `TestScreen`
2. Nhấn nút **`Talker Logger Example`**
3. Nhấn từng nút ghi log (Debug, Info, Warning, Error, v.v.)
4. Nhấn **📋 View Logs** để xem `TalkerScreen` trên thiết bị
5. Thử filter, search, và share log file

---

## API Reference nhanh

| Phương thức | Mô tả | Màu trên TalkerScreen |
|---|---|---|
| `talker.debug(msg)` | Log dev nội bộ | Xám |
| `talker.verbose(msg)` | Chi tiết nhất | Xám nhạt |
| `talker.info(msg)` | Thông tin sự kiện | Xanh dương |
| `talker.warning(msg)` | Cảnh báo | Cam |
| `talker.error(msg)` | Lỗi (app tiếp tục) | Đỏ |
| `talker.critical(msg)` | Lỗi nghiêm trọng | Đỏ đậm |
| `talker.good(msg)` | Thành công | Xanh lá |
| `talker.handle(e, st, msg)` | Bắt Exception+StackTrace | Đỏ với trace |
| `talker.logTyped(TalkerLog)` | Log tuỳ chỉnh hoàn toàn | Tuỳ chỉnh |
| `talker.cleanHistory()` | Xoá log history | — |

---

## Tích hợp nâng cao

| Tính năng | Package | Ghi chú |
|---|---|---|
| HTTP logging | `talker_dio_logger: ^5.1.14` | Xem Bước 4 |
| BLoC logging | `talker_bloc_logger: ^5.1.14` | Đăng ký `TalkerBlocObserver` |
| Riverpod logging | `talker_riverpod_logger: ^5.1.14` | Đăng ký `TalkerRiverpodObserver` |
| Navigation tracking | Sẵn trong `talker_flutter` | Xem Bước 3 |
| Firebase Crashlytics | Dùng `TalkerObserver` | Gửi log lên Crashlytics |
