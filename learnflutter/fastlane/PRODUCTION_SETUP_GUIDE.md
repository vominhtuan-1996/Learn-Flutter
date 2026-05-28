# 🚀 Hướng Dẫn Cài Đặt & Sử Dụng Production Workflow (Enterprise)

Tài liệu này hướng dẫn cài đặt và sử dụng luồng CI/CD cục bộ hoặc trên server tích hợp **Shorebird** (OTA Patch), **Fastlane** (Build & Sign), và **Firebase App Distribution**.

## 1. Yêu cầu hệ thống (Prerequisites)
- **Mac OS**: Bắt buộc để build iOS.
- **Xcode & Command Line Tools**: Cài đặt bản Xcode mới nhất.
- **Ruby & Bundler**: Để chạy Fastlane.
- **Node.js**: Để cài đặt Firebase CLI.

## 2. Cài đặt các công cụ

Mở Terminal và chạy tuần tự các lệnh sau:

### Fastlane
```bash
brew install fastlane
```

### Shorebird
```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```
Sau đó cấu hình Shorebird cho dự án:
```bash
shorebird init
```

### Firebase CLI
```bash
npm install -g firebase-tools
```

---

## 3. Cấu hình Biến Môi Trường (Secrets & Env)

Trong thư mục `fastlane/`, bạn sẽ thấy file `.env.example`.
1. Sao chép file `.env.example` thành `.env`:
   ```bash
   cp fastlane/.env.example fastlane/.env
   ```
2. Mở file `fastlane/.env` và điền các thông số thực tế của bạn. Cụ thể:
   - **Firebase**:
     - `FIREBASE_IOS_APP_ID`, `FIREBASE_ANDROID_APP_ID` lấy từ Firebase Console.
     - `FIREBASE_TOKEN` lấy bằng `firebase login:ci` (refresh token). Token này được truyền vào action qua `firebase_cli_token:` trong Fastfile.
   - **Shorebird**: Token CI/CD (`SHOREBIRD_TOKEN`). Lấy bằng lệnh `shorebird login:ci`.
   - **iOS Enterprise Profile**: Bundle ID (`IOS_BUNDLE_ID`) và Tên file Provisioning (`IOS_PROVISIONING_PROFILE_SPECIFIER`).

> ⚠️ **Quan trọng**: Tuyệt đối không commit file `.env` lên Git. Tên file phải là `.env` (không phải `.evn`) — fastlane chỉ tự load `fastlane/.env`.

---

## 3.1. Cài đặt Fastlane Plugin & Gemfile

Fastfile dùng action `firebase_app_distribution` — đây là plugin, phải cài 1 lần:

```bash
fastlane add_plugin firebase_app_distribution
bundle install
```

Lệnh trên sẽ tạo `fastlane/Pluginfile` và `Gemfile`/`Gemfile.lock`. Sau khi có `Gemfile`, **bắt buộc** gọi fastlane qua `bundle exec` (các script `release_ios.sh` / `release_android.sh` đã được cập nhật để dùng `bundle exec fastlane ...`). Nếu chạy `fastlane` trực tiếp sẽ gặp lỗi `Plugin 'firebase_app_distribution' was not properly loaded`.

---

## 3.2. iOS Signing với Shorebird (--no-codesign)

`release_ios.sh` gọi `shorebird release ios --no-codesign`, sinh ra `.xcarchive` chưa ký tại `build/ios/archive/Runner.xcarchive`. Fastfile được cấu hình để **bỏ qua bước archive** và chỉ làm export + sign:

```ruby
build_app(
  workspace: "ios/Runner.xcworkspace",
  scheme: "Runner",
  export_method: "enterprise",
  skip_build_archive: true,
  archive_path: "build/ios/archive/Runner.xcarchive",
  output_directory: "build/ios/ipa",
  export_team_id: "<TEAM_ID>",
  export_options: {
    method: "enterprise",
    teamID: "<TEAM_ID>",
    signingStyle: "manual",
    provisioningProfiles: {
      "<BUNDLE_ID>" => "<PROVISIONING_PROFILE_NAME>"
    }
  }
)
```

Yêu cầu:
- Provisioning profile (`dis_prod` hoặc tên thật) đã được cài vào `~/Library/MobileDevice/Provisioning Profiles/` và match đúng Bundle ID + Team ID.
- Certificate Distribution tương ứng đã có trong Keychain.

---

## 4. Tích hợp với Process Agent

Hệ thống script này đã được tích hợp với **Process Agent** tại file `agent_process.md`.

Quy trình thuộc về **GIAI ĐOẠN 7: PRODUCTION DEPLOYMENT**.

Bạn có thể kích hoạt quy trình này thông qua lệnh chat:
- `/deploy release`: Kích hoạt build bản Release đầy đủ (Shorebird release -> Fastlane -> Firebase).
- `/deploy patch`: Kích hoạt build OTA Patch để sửa lỗi giao diện/logic (Shorebird patch).

---

## 5. Hướng dẫn chạy thủ công (Manual Run)

Các script triển khai đã được lưu ở thư mục `fastlane/`. Các script đều tự `cd` về project root, nên có thể chạy từ bất cứ đâu.

### Phát hành phiên bản Release mới (Bao gồm Enterprise Build -> Firebase)
Phiên bản này cần thiết khi bạn có thay đổi Native code, thay đổi plugin, hoặc build version mới.

**Cho iOS:**
```bash
./fastlane/release_ios.sh
```

**Cho Android:**
```bash
./fastlane/release_android.sh
```

### Phát hành bản vá OTA (Shorebird Patch)
Sử dụng khi bạn chỉ cập nhật giao diện (UI), Dart logic, Animation... và muốn người dùng nhận bản cập nhật ngay lập tức mà không cần cài lại app.

```bash
./fastlane/patch.sh
```

Bản patch này sẽ tự động phân phối xuống các thiết bị người dùng đã cài bản Release trước đó.
