---
description: Quy trình tiêu chuẩn cho luồng Splash, đi từ main -> app_root (splash 1) -> intro_splash (splash 2) -> login
---

# Splash Flow Workflow

Tài liệu này hướng dẫn chi tiết luồng khởi động của ứng dụng, đảm bảo trải nghiệm người dùng mượt mà và chuyển đổi chính xác từ màn hình chào sang màn hình đăng nhập.

## 1. Điểm khởi đầu: `main.dart`

Ứng dụng bắt đầu từ hàm `main()` trong [main.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/main.dart).
- Thực hiện khởi tạo dependencies (Hive, ApiClient, Firebase nếu có).
- Gọi `runApp` với `MyApp`.
- `MyApp` đặt `home: AppRoot()`.

## 2. Giai đoạn 1: GIF Splash (`app_root.dart`)

[AppRoot](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/app/app_root.dart) chịu trách nhiệm hiển thị logo động đầu tiên.
- **Widget**: Sử dụng `FlutterSplashScreen.gif`.
- **Cấu hình**: 
    - `gifPath`: Đường dẫn tới file GIF animation (`assets/images/launch_tcss_v7.gif`).
    - `duration`: Khoảng thời gian hiển thị (mặc định 14s hoặc theo logic khởi tạo).
- **Điều hướng**: Sau khi kết thúc GIF, ứng dụng chuyển sang `nextScreen: const IntroSplash()`.

## 3. Giai đoạn 2: Intro Animation (`intro_splash.dart`)

[IntroSplash](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/app/intro_splash.dart) là màn hình giới thiệu thương hiệu với các hiệu ứng chuyển động tinh tế.
- **Animation**: Sử dụng `AnimationController` cho các hiệu ứng `ScaleTransition` và `FadeTransition` của logo và text.
- **Auto-navigate**: Một `Timer` (mặc định 4s) sẽ tự động gọi hàm chuyển màn hình.
- **Nút tương tác**: Cung cấp nút "Bắt đầu" để người dùng có thể bỏ qua thời gian chờ.

## 4. Chuyển đến màn hình Login

Theo yêu cầu chuẩn hóa, luồng kết thúc tại màn hình Đăng nhập.
- **Router**: Sử dụng [Routes.login](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/component/routes/route.dart) (đường dẫn `login_screen`).
- **Logic chuyển màn**:
    ```dart
    Navigator.of(context).pushReplacementNamed(Routes.login);
    ```
- **Lưu ý**: Đảm bảo `LoginScreen` đã túi ưu theo [login_module.md](file:///Users/tuanios_su12/learn_flutter/.agent/workflows/login_module.md).

## 5. Danh sách file liên quan
- [main.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/main.dart)
- [app_root.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/app/app_root.dart)
- [intro_splash.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/app/intro_splash.dart)
- [route.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/component/routes/route.dart)
