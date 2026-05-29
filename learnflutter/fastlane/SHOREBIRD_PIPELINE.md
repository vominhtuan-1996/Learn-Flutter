# 🚀 Shorebird Full Pipeline — Cài đặt & Vận hành

Tài liệu này mô tả toàn bộ pipeline production-ready cho Flutter app:

> **Shorebird** (OTA Patch) → **Fastlane** (Build & Sign) → **Firebase App Distribution** (phân phối)

Áp dụng cho project Flutter dùng **FVM** + **Enterprise iOS** + **Android AAB**.

---

## 1. Yêu cầu hệ thống

| Tool | Version | Cách cài |
|------|---------|----------|
| macOS | 13+ | (cần cho iOS build) |
| Xcode | 15+ | App Store |
| Xcode CLT | latest | `xcode-select --install` |
| Android Studio | latest | [developer.android.com](https://developer.android.com/studio) |
| Android SDK Platform | **36** (API 36) | SDK Manager |
| Android NDK | **27.0.12077973** | SDK Manager → SDK Tools → tick "Show Package Details" |
| JDK | 17+ (JDK 21 OK) | `brew install openjdk@17` |
| Ruby | 3.2+ | `rbenv install 3.2.9` |
| Node.js | 18+ | `nvm install --lts` |
| FVM | latest | `brew tap leoafarias/fvm && brew install fvm` |
| Shorebird CLI | latest | xem bên dưới |
| Fastlane | latest | xem bên dưới |
| Firebase CLI | latest | `npm i -g firebase-tools` |
| CocoaPods | 1.16+ | `brew install cocoapods` |
| bundletool | 1.18+ | xem bên dưới |

### 1.1 Cài Shorebird CLI

```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
shorebird login              # đăng nhập tài khoản
shorebird init               # khởi tạo cho project (tạo shorebird.yaml)
```

### 1.2 Cài Fastlane qua Bundler (recommended)

```bash
# Trong project root
cd /path/to/learn_flutter
gem install bundler
echo 'source "https://rubygems.org"' > Gemfile
echo 'gem "fastlane"' >> Gemfile
bundle install
bundle exec fastlane add_plugin firebase_app_distribution
```

> ⚠️ Khi có `Gemfile`, **bắt buộc** gọi `bundle exec fastlane ...`. Nếu chạy `fastlane` trực tiếp sẽ gặp lỗi `Plugin 'firebase_app_distribution' was not properly loaded`.

### 1.3 Cài bundletool

```bash
curl -L -o ~/Downloads/bundletool.jar \
  https://github.com/google/bundletool/releases/download/1.18.3/bundletool-all-1.18.3.jar
java -jar ~/Downloads/bundletool.jar version    # verify
```

Có thể set env `BUNDLETOOL_JAR=/path/to/bundletool.jar` nếu đặt nơi khác.

---

## 2. Cấu trúc dự án cần có

```
learn_flutter/
├── pubspec.yaml             # version: x.y.z+build (CFBundleShortVersionString / versionName)
├── shorebird.yaml           # app_id
├── .fvmrc                   # { "flutter": "3.29.3" }
├── Gemfile / Gemfile.lock   # fastlane + plugins
├── android/
│   ├── build.gradle         # repos + namespace inject + JVM 17
│   ├── settings.gradle      # AGP 8.7.0, Kotlin 2.1.0
│   ├── gradle/wrapper/      # gradle-wrapper.properties → Gradle 8.9
│   └── app/
│       ├── build.gradle     # compileSdk 36, minSdk 24, NDK 27, desugaring
│       ├── proguard-rules.pro
│       └── google-services.json   # Firebase config
├── ios/
│   ├── Runner.xcodeproj/
│   ├── Runner/Info.plist    # CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)
│   └── Flutter/Generated.xcconfig  # auto-generated
├── fastlane/
│   ├── Appfile
│   ├── Fastfile
│   ├── Pluginfile           # gem 'fastlane-plugin-firebase_app_distribution'
│   ├── .env                 # secrets (KHÔNG commit)
│   ├── release_ios.sh
│   ├── release_android.sh
│   └── patch.sh
└── scripts/
    └── sync_ios_generated_xcconfig.sh   # workaround Flutter 3.29.3 bug
```

---

## 3. Cấu hình `fastlane/.env`

```env
# ─── Firebase ───
FIREBASE_IOS_APP_ID=1:805564786756:ios:xxxxxxxxxxxxxxxx
FIREBASE_ANDROID_APP_ID=1:805564786756:android:xxxxxxxxxxxxxxxx
FIREBASE_TOKEN=1//0g...                  # lấy bằng: firebase login:ci

# ─── Shorebird ───
SHOREBIRD_TOKEN=...                       # lấy bằng: shorebird login:ci

# ─── iOS Enterprise Signing ───
IOS_BUNDLE_ID=com.fpt.isc.prod
IOS_TEAM_ID=7755R4CX4U
IOS_PROVISIONING_PROFILE_SPECIFIER=dis_prod

# ─── Android (nếu có keystore riêng) ───
ANDROID_KEYSTORE_PATH=../android/app/keystore.jks
ANDROID_KEYSTORE_PASSWORD=...
ANDROID_KEYALIAS_NAME=...
ANDROID_KEYALIAS_PASSWORD=...

# ─── bundletool (optional override) ───
BUNDLETOOL_JAR=/Users/me/Downloads/bundletool.jar
```

⚠️ **Tên file phải là `.env`** (không phải `.evn`). Fastlane chỉ auto-load `fastlane/.env` và `fastlane/.env.<lane>`.

---

## 4. `Fastfile` mẫu

```ruby
default_platform(:ios)

# ─────────────────────────────────────────
# iOS — Enterprise build từ Shorebird archive
# ─────────────────────────────────────────
platform :ios do
  desc "Enterprise Release"
  lane :enterprise do
    build_app(
      workspace: "ios/Runner.xcworkspace",
      scheme: "Runner",
      export_method: "enterprise",
      skip_build_archive: true,                                  # dùng archive Shorebird
      archive_path: "build/ios/archive/Runner.xcarchive",
      output_directory: "build/ios/ipa",
      export_team_id: ENV["IOS_TEAM_ID"],
      export_options: {
        method: "enterprise",
        teamID: ENV["IOS_TEAM_ID"],
        signingStyle: "manual",
        provisioningProfiles: {
          ENV["IOS_BUNDLE_ID"] => ENV["IOS_PROVISIONING_PROFILE_SPECIFIER"]
        }
      }
    )

    firebase_app_distribution(
      app: ENV["FIREBASE_IOS_APP_ID"],
      firebase_cli_token: ENV["FIREBASE_TOKEN"],
      groups: "testers",
      release_notes: "Enterprise build"
    )
  end

  desc "OTA Patch"
  lane :patch do
    sh("shorebird patch ios")
  end
end

# ─────────────────────────────────────────
# Android — Convert Shorebird AAB → APK qua bundletool, upload Firebase
# (Firebase App Distribution không upload AAB được nếu project chưa link Play)
# ─────────────────────────────────────────
platform :android do
  desc "Enterprise Android"
  lane :enterprise do
    aab_path = File.expand_path("../build/app/outputs/bundle/release/app-release.aab", __dir__)
    unless File.exist?(aab_path)
      UI.user_error!("Không tìm thấy AAB tại #{aab_path}. Hãy chạy shorebird release android trước.")
    end

    apk_path = File.expand_path("../build/app/outputs/apk/release/app-release.apk", __dir__)
    bundletool_jar = ENV["BUNDLETOOL_JAR"] || File.expand_path("~/Downloads/bundletool.jar")
    UI.user_error!("bundletool.jar không tồn tại tại #{bundletool_jar}") unless File.exist?(bundletool_jar)

    apks_path = "/tmp/app-release.apks"
    sh("java -jar #{bundletool_jar} build-apks --bundle=#{aab_path} --output=#{apks_path} --mode=universal --overwrite")
    sh("rm -rf /tmp/apks_extract && mkdir /tmp/apks_extract && unzip -o #{apks_path} -d /tmp/apks_extract")
    FileUtils.mkdir_p(File.dirname(apk_path))
    FileUtils.cp("/tmp/apks_extract/universal.apk", apk_path)

    firebase_app_distribution(
      app: ENV["FIREBASE_ANDROID_APP_ID"],
      firebase_cli_token: ENV["FIREBASE_TOKEN"],
      android_artifact_type: "APK",
      android_artifact_path: apk_path,
      groups: "tester",
      release_notes: "Enterprise Android"
    )
  end

  desc "OTA Patch"
  lane :patch do
    sh("shorebird patch android")
  end
end
```

---

## 5. Scripts

### 5.1 `fastlane/release_ios.sh`

```bash
#!/bin/bash
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Starting iOS Shorebird Release..."

# Sync Generated.xcconfig với pubspec.yaml (workaround bug Flutter 3.29.3 không tự regen)
bash scripts/sync_ios_generated_xcconfig.sh

if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
  shorebird release ios --flutter-version=$FLUTTER_VERSION --export-method enterprise --no-codesign
else
  shorebird release ios --flutter-version=3.29.3 --export-method enterprise --no-codesign
fi

bundle exec fastlane ios enterprise
echo "✅ iOS Release Pipeline Completed!"
```

### 5.2 `fastlane/release_android.sh`

```bash
#!/bin/bash
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Starting Android Shorebird Release..."

if [ -f .fvmrc ]; then
  FLUTTER_VERSION=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
  shorebird release android --flutter-version=$FLUTTER_VERSION
else
  shorebird release android
fi

bundle exec fastlane android enterprise
echo "✅ Android Release Pipeline Completed!"
```

### 5.3 `fastlane/patch.sh`

```bash
#!/bin/bash
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

PLATFORM=${1:-both}
[ "$PLATFORM" = "ios" ]     || [ "$PLATFORM" = "both" ] && shorebird patch ios     --flutter-version=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
[ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ] && shorebird patch android --flutter-version=$(grep -o '"flutter": "[^"]*' .fvmrc | cut -d'"' -f4)
```

### 5.4 `scripts/sync_ios_generated_xcconfig.sh`

Xem [scripts/sync_ios_generated_xcconfig.sh](../scripts/sync_ios_generated_xcconfig.sh). Mục đích: workaround bug Flutter 3.29.3 không regen `ios/Flutter/Generated.xcconfig` khi `flutter pub get`.

---

## 6. Cấu hình Android Gradle (đã được test với Flutter 3.29.3)

### 6.1 `android/settings.gradle`

```groovy
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.0" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

### 6.2 `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```

### 6.3 `android/build.gradle`

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://storage.googleapis.com/download.flutter.io' }   // Flutter engine
    }
}

// Inject namespace + align JVM target 17 cho tất cả plugin
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            def androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                if (androidExt.namespace == null) {
                    def manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        def matcher = manifestFile.text =~ /package\s*=\s*"([^"]+)"/
                        if (matcher.find()) androidExt.namespace = matcher.group(1)
                    }
                }
                androidExt.compileOptions {
                    sourceCompatibility JavaVersion.VERSION_17
                    targetCompatibility JavaVersion.VERSION_17
                }
            }
        }
        project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
            kotlinOptions { jvmTarget = "17" }
        }
    }
}

subprojects { project.evaluationDependsOn(":app") }

tasks.register("clean", Delete) { delete rootProject.layout.buildDirectory }
```

### 6.4 `android/app/build.gradle`

```groovy
android {
    namespace = "com.your.package"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17 }

    defaultConfig {
        applicationId = "com.your.package"
        minSdk = 24                          // Một số plugin như camerawesome cần ≥ 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release       // hoặc debug khi testing
            minifyEnabled false                          // bật khi cần obfuscate
            shrinkResources false
        }
    }
}

dependencies {
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"
}

flutter { source = "../.." }
```

### 6.5 `android/app/src/main/AndroidManifest.xml`

Thêm permission tối thiểu:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 7. Cấu hình iOS

### 7.1 Provisioning Profile

- Tạo Enterprise Distribution profile trong Apple Developer.
- Tải về và mở 2 lần (Xcode sẽ cài tự động) hoặc copy thủ công vào `~/Library/MobileDevice/Provisioning Profiles/`.
- Tên profile (field "Name") phải khớp với `IOS_PROVISIONING_PROFILE_SPECIFIER` trong `.env`.

### 7.2 Distribution Certificate

- Tải `.p12` về máy build, double-click để import vào Keychain.
- Đảm bảo certificate khớp với team ID `IOS_TEAM_ID`.

### 7.3 Info.plist

`CFBundleShortVersionString` và `CFBundleVersion` phải dùng biến từ Flutter:

```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```

---

## 8. ⚠️ Các bẫy đã gặp & cách tránh

### 8.1 Flutter 3.29.3 không regen `Generated.xcconfig`

`flutter pub get` không cập nhật `ios/Flutter/Generated.xcconfig` từ `pubspec.yaml`. `flutter build ios --config-only` lại gọi pod install trước khi ghi file → vòng luẩn quẩn.

**Fix:** Dùng script `scripts/sync_ios_generated_xcconfig.sh` để generate trực tiếp từ `pubspec.yaml` + `.fvmrc`. Đã được nhúng vào `release_ios.sh`.

### 8.2 `pubspec.yaml` có khối `flutter.module` → Flutter tìm AAB ở `build/host/` thay vì `build/app/`

Trong project được tạo dưới dạng add-to-app trước đó (hoặc copy-paste nhầm), `flutter.module:` block khiến `flutter build appbundle` thành công nhưng Flutter tool báo "Gradle build failed to produce an .aab file" vì check sai đường dẫn (`getBundleDirectory` rẽ nhánh module).

**Fix:** Xoá toàn bộ block `module:` trong `pubspec.yaml`:

```yaml
flutter:
  module:                                  # ← XOÁ HẾT BLOCK NÀY
    androidX: true
    androidPackage: ...
    iosBundleIdentifier: ...
```

### 8.3 Plugin v1 embedding bị Flutter 3.29 xoá

Các plugin sau dùng `PluginRegistry.Registrar` cũ → không build được:

| Plugin cũ | Thay bằng |
|-----------|-----------|
| `flutter_curl` | Xoá; dùng `dio` |
| `image_gallery_saver` / `_plus` | `gal` |
| `open_file_plus` | `open_filex` |
| `pdf_render` | `pdfrx` |
| `workmanager ^0.5` | `workmanager ^0.6` |

### 8.4 Firebase App Distribution không upload AAB

Lỗi `This project is not linked to a Google Play account.` xuất hiện khi upload AAB. Workaround: convert AAB → APK qua **bundletool**, upload APK. (Đã có sẵn trong Fastfile mẫu ở mục 4.)

### 8.5 Package ID đổi → Firebase báo `Invalid request`

Nếu đổi `applicationId` mà chưa add app mới trong Firebase Console, upload sẽ fail. Phải:
1. Add app Android mới với package mới trong Firebase Console.
2. Cập nhật `FIREBASE_ANDROID_APP_ID` trong `.env`.
3. Tải lại `google-services.json` mới.

### 8.6 CocoaPods missing → flutter tooling bị skip silently

Nếu `pod` không có, flutter sẽ in `Warning: CocoaPods not installed. Skipping pod install.` rồi tiếp tục — nhưng nhiều file iOS sẽ không được regen. Luôn cài `pod` trước.

### 8.7 `flutter` không có trong PATH khi dùng FVM

`fvm` không tự alias `flutter`. Thêm alias vào `~/.zshrc`:

```bash
alias flutter='fvm flutter'
alias dart='fvm dart'
```

---

## 9. Quy trình vận hành hàng ngày

### 9.1 Release mới (cần khi: đổi native code, đổi plugin, bump version)

```bash
# 1. Bump version trong pubspec.yaml (vd: 1.0.10+1 → 1.0.11+1)
# 2. Chạy release pipeline
bash fastlane/release_ios.sh
bash fastlane/release_android.sh
```

Kết quả:
- iOS: `.ipa` ở `build/ios/ipa/Runner.ipa` + uploaded lên Firebase App Distribution.
- Android: `.aab` ở `build/app/outputs/bundle/release/app-release.aab` + `.apk` ở `build/app/outputs/apk/release/app-release.apk` + uploaded lên Firebase App Distribution.

### 9.2 OTA Patch (cần khi: chỉ sửa Dart code, không đổi native/plugin)

```bash
bash fastlane/patch.sh ios
bash fastlane/patch.sh android
# hoặc:
bash fastlane/patch.sh both
```

User đã cài bản Release trước đó sẽ tự động nhận patch khi mở app (theo cấu hình `auto_update` trong `shorebird.yaml`).

### 9.3 Khi nào phải Release vs Patch?

| Thay đổi | Release | Patch |
|----------|:-------:|:-----:|
| Dart code (UI, business logic) | ✅ | ✅ (rẻ hơn) |
| Asset (image, font) | ✅ | ✅ |
| Thêm/sửa plugin (Dart-only) | ✅ | ✅ |
| Thêm/sửa plugin (native code) | ✅ | ❌ |
| Native code (Swift/Kotlin) | ✅ | ❌ |
| `AndroidManifest.xml` / `Info.plist` | ✅ | ❌ |
| Bump version | ✅ | ❌ |
| Đổi Flutter SDK version | ✅ | ❌ |

---

## 10. Verify & Troubleshoot

### 10.1 Verify build version

```bash
# iOS — sau khi release
unzip -p build/ios/ipa/Runner.ipa Payload/Runner.app/Info.plist | \
  plutil -extract CFBundleShortVersionString raw - && \
  plutil -extract CFBundleVersion raw -

# Android — sau khi release
aapt2 dump badging build/app/outputs/apk/release/app-release.apk | grep -E "versionCode|versionName"
```

### 10.2 Re-generate Pluginfile / Gemfile

```bash
rm Gemfile Gemfile.lock fastlane/Pluginfile
bundle install
bundle exec fastlane add_plugin firebase_app_distribution
```

### 10.3 Reset hoàn toàn build cache

```bash
fvm flutter clean
rm -rf build android/.gradle android/build android/app/build
rm ios/Flutter/Generated.xcconfig ios/Flutter/flutter_export_environment.sh
cd android && ./gradlew --stop && cd ..
fvm flutter pub get
bash scripts/sync_ios_generated_xcconfig.sh
```

### 10.4 Lỗi `Plugin 'firebase_app_distribution' was not properly loaded`

Quên dùng `bundle exec`. Sửa script: thay `fastlane ios enterprise` thành `bundle exec fastlane ios enterprise`.

### 10.5 Lỗi `Inconsistent JVM-target compatibility (1.8) and (21)`

Plugin nào đó pin Java 1.8 trong khi Kotlin chạy 21. Mục **6.3** đã inject JVM 17 cho mọi subproject → khắc phục.

### 10.6 Lỗi `Namespace not specified` (AGP 8+)

Plugin cũ chưa khai báo `namespace`. Mục **6.3** đã có block tự inject từ `<manifest package="...">`.

### 10.7 Lỗi `core library desugaring`

Đảm bảo `android/app/build.gradle` có:
```groovy
compileOptions { coreLibraryDesugaringEnabled true }
dependencies { coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4" }
```

### 10.8 Lỗi `It looks like you have an existing release for version X+Y`

Shorebird không cho release trùng version. Bump build number trong `pubspec.yaml`:
```yaml
version: 1.0.10+2          # ← bump số sau dấu +
```

---

## 11. CI/CD Note (tùy chọn)

Khi chạy trên CI (GitHub Actions / Bitrise / Codemagic), cần thêm vào environment:

```yaml
env:
  FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  FIREBASE_IOS_APP_ID: ${{ secrets.FIREBASE_IOS_APP_ID }}
  FIREBASE_ANDROID_APP_ID: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
  SHOREBIRD_TOKEN: ${{ secrets.SHOREBIRD_TOKEN }}
  MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
  FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.APPLE_APP_PASSWORD }}
```

Tip: `shorebird` đọc `SHOREBIRD_TOKEN` thay vì `shorebird login` interactive khi biến này được set.

---

## 12. Tham khảo

- [Shorebird Docs](https://docs.shorebird.dev)
- [Fastlane Actions](https://docs.fastlane.tools/actions/)
- [Firebase App Distribution Fastlane Plugin](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution)
- [bundletool](https://github.com/google/bundletool)
- [AGP Release Notes](https://developer.android.com/build/releases/gradle-plugin)

---

_Last validated: Flutter 3.29.3 · AGP 8.7.0 · Kotlin 2.1.0 · Gradle 8.9 · Shorebird CLI 1.x · Fastlane 2.235._
