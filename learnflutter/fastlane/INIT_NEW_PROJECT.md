# 🆕 Init New Flutter Project — Production-Ready Workflow

Bootstrap một project Flutter mới với toàn bộ cấu hình đã được verify trong [SHOREBIRD_PIPELINE.md](SHOREBIRD_PIPELINE.md), kèm các module `core/`, `engines/`, `services/` tái sử dụng từ project `learnflutter`.

> Stack: **Flutter 3.29.3 · FVM · AGP 8.7.0 · Kotlin 2.1.0 · Gradle 8.9 · Shorebird · Fastlane · Firebase App Distribution**

---

## 0. Biến môi trường dùng trong tài liệu

```bash
NEW_APP=mobimap_v2                                 # tên Flutter project
NEW_ORG=com.isc.mobimap                            # reverse-DNS org (sẽ thành com.isc.mobimap.mobimap_v2)
SOURCE_PROJECT=/Users/tuanios_su12/learn_flutter/learnflutter
WORKSPACE=$HOME/projects                           # nơi tạo project mới
TEAM_ID=7755R4CX4U                                 # Apple Team ID
```

---

## 1. PHASE 1 — Khởi tạo skeleton

### 1.1 Set Flutter version qua FVM

```bash
cd $WORKSPACE
fvm install 3.29.3                                 # nếu chưa có
fvm use 3.29.3 --force
```

### 1.2 Create project

```bash
fvm flutter create \
  --org $NEW_ORG \
  --project-name $NEW_APP \
  --platforms=android,ios \
  --android-language=kotlin \
  --ios-language=swift \
  $NEW_APP

cd $NEW_APP
echo '{"flutter": "3.29.3"}' > .fvmrc
```

### 1.3 Verify

```bash
fvm flutter doctor -v
fvm flutter --version
```

> ⚠️ **Quan trọng:** Nếu pubspec.yaml có khối `flutter.module:` thì xoá ngay. Block này khiến Flutter coi project như add-to-app và Flutter 3.29 tool sẽ tìm AAB sai chỗ (`build/host/` thay vì `build/app/`).

---

## 2. PHASE 2 — Copy core modules từ project nguồn

### 2.1 Sao chép core/engines/services

```bash
mkdir -p lib/core lib/shared lib/app

# Core foundations
cp -R $SOURCE_PROJECT/lib/core/animation        lib/core/
cp -R $SOURCE_PROJECT/lib/core/config           lib/core/
cp -R $SOURCE_PROJECT/lib/core/constants        lib/core/
cp -R $SOURCE_PROJECT/lib/core/cubit            lib/core/
cp -R $SOURCE_PROJECT/lib/core/extensions       lib/core/
cp -R $SOURCE_PROJECT/lib/core/global           lib/core/
cp -R $SOURCE_PROJECT/lib/core/network          lib/core/
cp -R $SOURCE_PROJECT/lib/core/repositories     lib/core/
cp -R $SOURCE_PROJECT/lib/core/state            lib/core/
cp -R $SOURCE_PROJECT/lib/core/storage          lib/core/
cp -R $SOURCE_PROJECT/lib/core/utils            lib/core/
cp $SOURCE_PROJECT/lib/core/debound.dart        lib/core/

# Engines (UI helpers)
cp -R $SOURCE_PROJECT/lib/core/engines          lib/core/

# Services (tích hợp 3rd-party + native bridge)
cp -R $SOURCE_PROJECT/lib/core/services         lib/core/

# Shared widgets/components (nếu cần)
cp -R $SOURCE_PROJECT/lib/shared                lib/   2>/dev/null || true

# App-level theme/routes
cp -R $SOURCE_PROJECT/lib/app                   lib/   2>/dev/null || true
```

### 2.2 Đổi import path

Tất cả file vừa copy import qua `package:learnflutter/...`. Cần đổi sang `package:$NEW_APP/...`:

```bash
find lib -type f -name "*.dart" -exec \
  sed -i '' "s|package:learnflutter/|package:$NEW_APP/|g" {} \;
```

### 2.3 Map các module có sẵn

| Module | Mục đích | Phụ thuộc chính |
|--------|----------|-----------------|
| `core/animation/` | Animation primitives, performance widgets | flutter SDK |
| `core/config/` | App config, environment | — |
| `core/constants/` | API endpoints, design tokens | — |
| `core/cubit/` | Base Cubit/Bloc patterns | `flutter_bloc` |
| `core/extensions/` | Dart/Flutter extension methods | — |
| `core/global/` | Global keys, navigators | — |
| `core/network/` | `ApiClient` (Dio singleton), cache store, interceptors | `dio`, `dio_cache_interceptor` |
| `core/repositories/` | Repository pattern base | — |
| `core/state/` | App-level state | `flutter_bloc` |
| `core/storage/` | SharedPreferences, secure storage wrappers | `shared_preferences`, `flutter_secure_storage` |
| `core/utils/` | Helpers, dialog utils, extensions | — |
| `core/engines/engine_bottom_sheet/` | Bottom sheet engine | — |
| `core/engines/engine_dialog/` | Dialog engine (AppDialogEngine) | — |
| `core/engines/engine_google_map/` | Google Maps wrapper | `google_maps_flutter` |
| `core/engines/engine_pagination/` | Pagination patterns | — |
| `core/engines/engine_particle/` | Particle effects | — |
| `core/engines/engine_queue/` | Task queue | — |
| `core/engines/engine_rendering/` | Custom rendering | — |
| `core/engines/engine_viewport_transform/` | Viewport optimization | — |
| `core/services/camera/` | Camera wrapper | `camerawesome` |
| `core/services/firebase_message/` | FCM | `firebase_messaging` |
| `core/services/isolate/` | Background isolate APIs | — |
| `core/services/keyboard/` | Keyboard visibility/utils | `flutter_keyboard_visibility` |
| `core/services/local_notification/` | Local push | `flutter_local_notifications` |
| `core/services/log/` | Daily log scheduler → Google Chat | `workmanager` |
| `core/services/notification_center/` | App-internal pub/sub | — |
| `core/services/qr_code/` | QR scan + capture | `mobile_scanner`, `gal` |
| `core/services/shorebird/` | OTA update flow (xem [SHOREBIRD_PIPELINE.md](SHOREBIRD_PIPELINE.md)) | `shorebird_code_push` |
| `core/services/talker/` | Logging (Talker) | `talker_flutter` |

---

## 3. PHASE 3 — Pubspec & dependencies

### 3.1 Lấy dependencies từ project nguồn

```bash
# Copy phần dependencies (đã được verify)
fvm flutter pub remove flutter_lints   # nếu muốn dùng custom analysis_options

# Thay vì copy nguyên pubspec, lựa từng package cần (tránh copy package legacy):
cat <<'EOF' > /tmp/required_deps.txt
flutter_bloc
dio
dio_cache_interceptor
shared_preferences
flutter_secure_storage
talker
talker_flutter
talker_dio_logger
shorebird_code_push
permission_handler
firebase_core
firebase_messaging
flutter_local_notifications
workmanager: ^0.6.0
google_maps_flutter
mobile_scanner
camerawesome
gal: ^2.3.1
open_filex: ^4.5.0
share_plus
url_launcher
path_provider
flutter_keyboard_visibility
flutter_svg
intl
EOF
```

### 3.2 Add dependencies

```bash
fvm flutter pub add \
  flutter_bloc dio dio_cache_interceptor \
  shared_preferences flutter_secure_storage \
  talker talker_flutter talker_dio_logger \
  shorebird_code_push permission_handler \
  firebase_core firebase_messaging \
  flutter_local_notifications \
  google_maps_flutter mobile_scanner camerawesome \
  share_plus url_launcher path_provider \
  flutter_keyboard_visibility flutter_svg intl

fvm flutter pub add 'workmanager:^0.6.0' 'gal:^2.3.1' 'open_filex:^4.5.0'
```

### 3.3 Add dev_dependencies

```bash
fvm flutter pub add --dev \
  build_runner \
  flutter_lints \
  mockito
```

> ⚠️ **KHÔNG** thêm các plugin v1 embedding sau (đã bị Flutter 3.29 phá): `flutter_curl`, `image_gallery_saver`, `image_gallery_saver_plus`, `open_file_plus`, `pdf_render`, `workmanager <0.6`.

---

## 4. PHASE 4 — Android configuration

### 4.1 `android/settings.gradle`

Thay block `plugins`:

```groovy
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.0" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

### 4.2 `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```

### 4.3 `android/build.gradle`

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://storage.googleapis.com/download.flutter.io' }
    }
}

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

### 4.4 `android/app/build.gradle`

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace = "com.isc.mobimap.mobimap_v2"            // đổi theo $NEW_ORG.$NEW_APP
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17 }

    defaultConfig {
        applicationId = "com.isc.mobimap.mobimap_v2"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

dependencies {
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"
}

flutter { source = "../.." }
```

### 4.5 `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>

    <application
        android:label="MobimapV2"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data android:name="flutterEmbedding" android:value="2"/>
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

### 4.6 `android/app/proguard-rules.pro`

```pro
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn javax.imageio.**
-dontwarn com.github.jaiimageio.**
-dontwarn java.awt.**
-dontwarn javax.swing.**
-keepattributes Signature, *Annotation*, SourceFile, LineNumberTable
-keep class com.google.gson.** { *; }
-ignorewarnings
```

---

## 5. PHASE 5 — iOS configuration

### 5.1 Bundle identifier & team

Mở `ios/Runner.xcodeproj/project.pbxproj` (hoặc qua Xcode):

- `PRODUCT_BUNDLE_IDENTIFIER = com.isc.mobimap.mobimap_v2`
- `"DEVELOPMENT_TEAM[sdk=iphoneos*]" = $TEAM_ID`

Hoặc dùng `sed` nhanh:

```bash
sed -i '' "s|com.example.$NEW_APP|com.isc.mobimap.mobimap_v2|g" ios/Runner.xcodeproj/project.pbxproj
```

### 5.2 `ios/Runner/Info.plist`

Đảm bảo:

```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>

<!-- Permissions cho services đã có -->
<key>NSCameraUsageDescription</key><string>Camera để quét QR và chụp ảnh</string>
<key>NSPhotoLibraryAddUsageDescription</key><string>Lưu ảnh QR vào thư viện</string>
<key>NSPhotoLibraryUsageDescription</key><string>Chọn ảnh từ thư viện</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Hiển thị vị trí trên bản đồ</string>
<key>NSUserTrackingUsageDescription</key><string>Personalize trải nghiệm</string>
```

### 5.3 Podfile

Mặc định Flutter create đã ổn. Verify `platform :ios, '13.0'` trở lên (Shorebird/plugin cần 12+).

---

## 6. PHASE 6 — Shorebird init

```bash
shorebird init                           # tạo shorebird.yaml + flag plugin
shorebird login                          # nếu chưa
```

Kết quả: `shorebird.yaml` với `app_id` mới.

> Verify: chạy thử local
> ```bash
> shorebird preview            # chạy app từ Shorebird build
> ```

---

## 7. PHASE 7 — Fastlane setup

### 7.1 Tạo Gemfile + Pluginfile

```bash
cat > Gemfile <<'EOF'
source "https://rubygems.org"
gem "fastlane"
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
EOF

bundle install
bundle exec fastlane add_plugin firebase_app_distribution
```

### 7.2 Copy fastlane setup từ project nguồn

```bash
mkdir -p fastlane scripts
cp $SOURCE_PROJECT/fastlane/Appfile           fastlane/
cp $SOURCE_PROJECT/fastlane/Fastfile          fastlane/
cp $SOURCE_PROJECT/fastlane/release_ios.sh    fastlane/
cp $SOURCE_PROJECT/fastlane/release_android.sh fastlane/
cp $SOURCE_PROJECT/fastlane/patch.sh          fastlane/
cp $SOURCE_PROJECT/fastlane/.env.example      fastlane/
cp $SOURCE_PROJECT/scripts/sync_ios_generated_xcconfig.sh scripts/
chmod +x fastlane/*.sh scripts/*.sh
```

### 7.3 Sửa Fastfile theo project mới

- `IOS_BUNDLE_ID` trong export_options → `com.isc.mobimap.mobimap_v2`
- `export_team_id` / `teamID` → `$TEAM_ID`
- Provisioning profile name → tên thật của profile enterprise

### 7.4 Tạo `fastlane/.env`

```bash
cp fastlane/.env.example fastlane/.env
# Sửa tay các giá trị FIREBASE_*, IOS_*, SHOREBIRD_TOKEN
```

---

## 8. PHASE 8 — Firebase setup

### 8.1 Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com) → tạo project (hoặc dùng existing).
2. **Add app** → Android: package = `com.isc.mobimap.mobimap_v2`. Tải `google-services.json` → đặt vào `android/app/`.
3. **Add app** → iOS: bundle id = `com.isc.mobimap.mobimap_v2`. Tải `GoogleService-Info.plist` → drag vào Xcode (target Runner).
4. Copy 2 App ID vào `fastlane/.env`:
   ```
   FIREBASE_ANDROID_APP_ID=1:xxx:android:yyy
   FIREBASE_IOS_APP_ID=1:xxx:ios:yyy
   ```

### 8.2 Firebase CLI token

```bash
firebase login:ci
# Copy token vào FIREBASE_TOKEN trong fastlane/.env
```

### 8.3 Android Gradle plugin

Thêm vào `android/settings.gradle`:

```groovy
plugins {
    // ...
    id "com.google.gms.google-services" version "4.4.2" apply false
}
```

Thêm vào đầu `android/app/build.gradle`:

```groovy
plugins {
    // ...
    id "com.google.gms.google-services"
}
```

---

## 9. PHASE 9 — Tích hợp services vào `main.dart`

Template `lib/main.dart` tối thiểu:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$NEW_APP/core/services/shorebird/shorebird_service.dart';
import 'package:$NEW_APP/core/services/log/daily_log_scheduler.dart';
import 'package:$NEW_APP/core/network/api_client/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Network
  ApiClient.instance.init(baseUrl: 'https://api.example.com');

  // 2. Shorebird check (xem chi tiết: SHOREBIRD_PIPELINE.md mục 9)
  unawaited(ShorebirdService.instance.checkUpdate());

  // 3. Workmanager init (xem core/services/log/daily_log_scheduler.dart)
  await DailyLogScheduler.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: const Scaffold(body: Center(child: Text('Hello'))));
}
```

---

## 10. PHASE 10 — Verify pipeline

### 10.1 Smoke build local

```bash
fvm flutter clean
fvm flutter pub get
bash scripts/sync_ios_generated_xcconfig.sh

# Android
fvm flutter build appbundle --release
ls build/app/outputs/bundle/release/app-release.aab     # phải tồn tại

# iOS (yêu cầu Xcode + provisioning)
fvm flutter build ipa --release --export-method=enterprise
```

### 10.2 Full pipeline test

```bash
bash fastlane/release_android.sh
bash fastlane/release_ios.sh

# OTA patch test
bash fastlane/patch.sh both
```

---

## 11. Script bootstrap one-shot

Lưu thành `bootstrap_new_project.sh` để dùng cho lần sau:

```bash
#!/bin/bash
set -e

# === EDIT THESE ===
NEW_APP=${1:?"Usage: $0 <app_name> <org> [team_id]"}
NEW_ORG=${2:?}
TEAM_ID=${3:-7755R4CX4U}
SOURCE_PROJECT=/Users/tuanios_su12/learn_flutter/learnflutter
# ===================

echo "🚀 Bootstrapping $NEW_ORG.$NEW_APP from $SOURCE_PROJECT"

# 1. Create
fvm install 3.29.3 || true
fvm flutter create --org "$NEW_ORG" --project-name "$NEW_APP" \
  --platforms=android,ios --android-language=kotlin --ios-language=swift "$NEW_APP"
cd "$NEW_APP"
echo '{"flutter": "3.29.3"}' > .fvmrc

# 2. Copy core modules
for d in animation config constants cubit extensions global network repositories state storage utils engines services; do
  cp -R "$SOURCE_PROJECT/lib/core/$d" lib/core/ 2>/dev/null || true
done
cp -R "$SOURCE_PROJECT/lib/shared" lib/ 2>/dev/null || true
cp -R "$SOURCE_PROJECT/lib/app"    lib/ 2>/dev/null || true

# 3. Fix imports
find lib -type f -name "*.dart" -exec sed -i '' "s|package:learnflutter/|package:${NEW_APP}/|g" {} \;

# 4. Copy Gradle/iOS/Fastlane skeleton
cp "$SOURCE_PROJECT/android/build.gradle"                                android/
cp "$SOURCE_PROJECT/android/settings.gradle"                             android/
cp "$SOURCE_PROJECT/android/gradle/wrapper/gradle-wrapper.properties"    android/gradle/wrapper/
cp "$SOURCE_PROJECT/android/app/build.gradle"                            android/app/
cp "$SOURCE_PROJECT/android/app/proguard-rules.pro"                      android/app/
cp "$SOURCE_PROJECT/android/app/src/main/AndroidManifest.xml"            android/app/src/main/

# Replace package id in copied gradle/manifest/kotlin
PKG="${NEW_ORG}.${NEW_APP}"
find android lib -type f \( -name "*.gradle" -o -name "*.xml" -o -name "*.kt" \) -exec \
  sed -i '' "s|com.isc.mobimap.mobimapFlutter|$PKG|g; s|com.fpt.isc.pms.sdk_pms.learnflutter|$PKG|g" {} \;

# 5. Fastlane
mkdir -p fastlane scripts
cp "$SOURCE_PROJECT/fastlane/Fastfile"                  fastlane/
cp "$SOURCE_PROJECT/fastlane/Appfile"                   fastlane/
cp "$SOURCE_PROJECT/fastlane/release_ios.sh"            fastlane/
cp "$SOURCE_PROJECT/fastlane/release_android.sh"        fastlane/
cp "$SOURCE_PROJECT/fastlane/patch.sh"                  fastlane/
cp "$SOURCE_PROJECT/fastlane/.env.example"              fastlane/
cp "$SOURCE_PROJECT/fastlane/Pluginfile"                fastlane/
cp "$SOURCE_PROJECT/Gemfile"                            ./
cp "$SOURCE_PROJECT/scripts/sync_ios_generated_xcconfig.sh" scripts/
chmod +x fastlane/*.sh scripts/*.sh

# 6. Pub get + Bundle install
fvm flutter pub get
bundle install

# 7. Shorebird
shorebird init || true

echo "✅ Done! Next steps:"
echo "   1. Edit fastlane/.env (FIREBASE_*, IOS_TEAM_ID, provisioning profile)"
echo "   2. Add google-services.json into android/app/"
echo "   3. Add GoogleService-Info.plist into ios/Runner/ via Xcode"
echo "   4. cd $NEW_APP && bash fastlane/release_android.sh"
```

Cách dùng:

```bash
bash bootstrap_new_project.sh mobimap_v2 com.isc.mobimap 7755R4CX4U
```

---

## 12. Checklist cuối

- [ ] `.fvmrc` đúng version (3.29.3)
- [ ] `pubspec.yaml` **KHÔNG** có `flutter.module:` block
- [ ] `pubspec.yaml` không dùng plugin v1 embedding cũ
- [ ] `android/app/build.gradle`: `compileSdk = 36`, `minSdk = 24`, `ndkVersion = "27.0.12077973"`, desugaring on
- [ ] `android/build.gradle`: namespace inject + JVM 17 + Flutter Maven repo
- [ ] `android/settings.gradle`: AGP 8.7.0, Kotlin 2.1.0
- [ ] `android/gradle/wrapper/`: Gradle 8.9
- [ ] `android/app/google-services.json` đã có
- [ ] `ios/Runner/GoogleService-Info.plist` đã add qua Xcode
- [ ] `ios/Runner.xcodeproj`: Bundle ID + Team ID đúng
- [ ] Provisioning profile + certificate đã cài
- [ ] `fastlane/.env` đầy đủ FIREBASE_*, SHOREBIRD_TOKEN, IOS_*
- [ ] `Gemfile` + `fastlane/Pluginfile` + `bundle install` xong
- [ ] `shorebird.yaml` có `app_id` mới
- [ ] `bundletool.jar` ở `~/Downloads/` (hoặc set `BUNDLETOOL_JAR`)
- [ ] Test: `fvm flutter build appbundle --release` thành công
- [ ] Test: `bash fastlane/release_android.sh` upload Firebase thành công
- [ ] Test: `bash fastlane/release_ios.sh` upload Firebase thành công
- [ ] Test: `bash fastlane/patch.sh` push OTA thành công

---

_Verified stack: Flutter 3.29.3 · AGP 8.7.0 · Kotlin 2.1.0 · Gradle 8.9 · Shorebird CLI 1.x · Fastlane 2.235 · bundletool 1.18.3._
