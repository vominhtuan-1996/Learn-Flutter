# Custom Local Notification Pipeline

Quy trình tạo và hiển thị local notification với custom native UI trên Android và iOS.

---

## Kiến trúc tổng quan

```
Flutter (Dart)
  ├── LocalNotificationService      → standard notifications (flutter_local_notifications)
  └── CustomNotificationService     → custom native view
        ├── Android: MethodChannel → CustomNotificationHelper.kt (RemoteViews XML)
        └── iOS:     flutter_local_notifications + categoryIdentifier → NotificationContent.appex
```

---

## 1. Setup Flutter

### 1.1 pubspec.yaml

```yaml
dependencies:
  flutter_local_notifications: ^17.2.2

# Không cần firebase_messaging nếu chỉ dùng local
```

### 1.2 LocalNotificationService (singleton)

File: `lib/core/services/local_notification/local_notification_service.dart`

```dart
await LocalNotificationService.instance.init(
  onTap: (payload) => handleTap(payload),           // foreground tap
  onBackgroundTap: onNotificationTapBackground,      // background tap (top-level fn)
);
```

**Background handler** phải là top-level function + `@pragma`:

```dart
@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse response) {
  debugPrint('[Notif BG] payload=${response.payload}');
}
```

Gọi trong `main()` trước `runApp()`:

```dart
await LocalNotificationService.instance.show(
  title: 'Hello',
  body: 'World',
  payload: '/screen_route',
);
```

---

## 2. Android Setup

### 2.1 AndroidManifest.xml

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

<application ...>
  <!-- flutter_local_notifications receivers (bắt buộc) -->
  <receiver android:exported="false"
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
  <receiver android:exported="false"
      android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"/>
  <receiver android:exported="false"
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
      <action android:name="android.intent.action.BOOT_COMPLETED"/>
      <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    </intent-filter>
  </receiver>

  <!-- Custom dismiss receiver -->
  <receiver android:exported="false" android:name=".NotificationDismissReceiver">
    <intent-filter>
      <action android:name="com.learnflutter.DISMISS_NOTIFICATION"/>
    </intent-filter>
  </receiver>
</application>
```

### 2.2 Notification Icon

Tạo `android/app/src/main/res/drawable/ic_notification.xml`:

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
  <path android:fillColor="#FFFFFF"
      android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.9,2 2,2zm6,-6v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32V4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
```

> Android 5.0+: small icon **phải** là alpha-only (trắng/transparent). `@mipmap/ic_launcher` màu → hiện grey square.

### 2.3 Custom Native View (RemoteViews)

**Layout files:**

```
android/app/src/main/res/layout/
  ├── notification_custom_collapsed.xml   ← collapsed view (Android < 12)
  └── notification_custom_expanded.xml    ← expanded view (all versions)
```

**Kotlin helper:** `CustomNotificationHelper.kt`

```kotlin
val notification = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_notification)
    .setContentTitle(title)           // fallback Android 12+
    .setContentText(body)
    .setCustomContentView(collapsed)
    .setCustomBigContentView(expanded)
    .setStyle(NotificationCompat.DecoratedCustomViewStyle())
    .addAction(icon, "Mở", openPendingIntent)
    .addAction(icon, "Bỏ qua", dismissPendingIntent)
    .build()
```

**MethodChannel:** `com.learnflutter/custom_notification`

```kotlin
// MainActivity.kt
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "showCustomNotification" -> {
                CustomNotificationHelper.show(this, id, title, body, payload)
                result.success(id)
            }
        }
    }
```

**Dart service:**

```dart
await CustomNotificationService.instance.show(
  title: 'Custom',
  body: 'Expand to see full UI',
  payload: 'my_route',
);
```

> **Android 12+:** collapsed view dùng system template. Custom layout chỉ hiện khi user **expand** notification (swipe down → tap ▾).

---

## 3. iOS Setup

### 3.1 AppDelegate.swift

```swift
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    // 1. Set delegate trước super (quan trọng)
    UNUserNotificationCenter.current().delegate = self

    // 2. Register category cho Content Extension
    let openAction = UNNotificationAction(
      identifier: "ACTION_OPEN", title: "Mở", options: [.foreground])
    let dismissAction = UNNotificationAction(
      identifier: "ACTION_DISMISS", title: "Bỏ qua", options: [.destructive])
    let category = UNNotificationCategory(
      identifier: "CUSTOM_NOTIFICATION",
      actions: [openAction, dismissAction],
      intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 3. Allow foreground notifications
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge, .list])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}
```

### 3.2 Notification Content Extension

**Cấu trúc:**

```
ios/NotificationContent/
  ├── NotificationViewController.swift    ← UI lập trình (không storyboard)
  └── Info.plist
```

**Info.plist key quan trọng:**

```xml
<key>NSExtension</key>
<dict>
  <key>NSExtensionAttributes</key>
  <dict>
    <key>UNNotificationExtensionCategory</key>
    <string>CUSTOM_NOTIFICATION</string>           <!-- phải khớp với category đăng ký -->
    <key>UNNotificationExtensionInitialContentSizeRatio</key>
    <real>0.55</real>
    <key>UNNotificationExtensionDefaultContentHidden</key>
    <true/>
  </dict>
  <key>NSExtensionPointIdentifier</key>
  <string>com.apple.usernotifications.content-extension</string>
</dict>
```

**NotificationViewController.swift** — implement `UNNotificationContentExtension`:

```swift
func didReceive(_ notification: UNNotification) {
  titleLabel.text = notification.request.content.title
  bodyLabel.text  = notification.request.content.body
}

func didReceive(_ response: UNNotificationResponse,
                completionHandler: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
  if response.actionIdentifier == "ACTION_OPEN" {
    completionHandler(.dismissAndForwardAction)
  } else {
    completionHandler(.dismiss)
  }
}
```

### 3.3 Podfile

```ruby
# Khai báo extension target để CocoaPods fix build phase ordering
target 'NotificationContent' do
  use_frameworks!
  use_modular_headers!
end
```

Sau khi thêm: `pod install`

### 3.4 Gửi notification kèm category (iOS)

```dart
// CustomNotificationService iOS path
await _flnPlugin.show(
  id, title, body,
  const NotificationDetails(
    iOS: DarwinNotificationDetails(
      categoryIdentifier: 'CUSTOM_NOTIFICATION',  // trigger Content Extension
      presentBanner: true,
      presentSound: true,
    ),
  ),
);
```

### 3.5 Code Signing (project.pbxproj)

Extension cần bundle ID riêng: `<parentBundleId>.NotificationContent`

| Config   | Style     | Team         | Certificate         |
|----------|-----------|--------------|---------------------|
| Debug    | Automatic | `TEAM_ID`    | Apple Development   |
| Profile  | Automatic | `TEAM_ID`    | Apple Development   |
| Release  | Manual    | `TEAM_ID`    | iPhone Distribution |

> **Quan trọng:** Extension và Runner phải dùng **cùng loại certificate**. Nếu Runner Profile dùng Manual+Distribution, extension cũng phải có provisioning profile riêng cho bundle ID của nó.

**Fix build cycle** — đặt "Embed App Extensions" phase **TRƯỚC** Thin Binary và CocoaPods phases:

```
Build Phases (Runner):
  1. [CP] Check Pods Manifest.lock
  2. Run Script
  3. Sources
  4. Frameworks
  5. Resources
  6. Embed Frameworks
  7. Embed App Extensions   ← PHẢI Ở ĐÂY (trước Thin Binary)
  8. Thin Binary
  9. [CP] Embed Pods Frameworks
  10. [CP] Copy Pods Resources
```

---

## 4. Notification Styles (flutter_local_notifications)

| Style | Android | iOS |
|-------|---------|-----|
| Simple | ✅ | ✅ |
| Big Text | ✅ `BigTextStyleInformation` | ✅ body dài |
| Inbox | ✅ `InboxStyleInformation` | ✅ (dạng list) |
| Progress bar | ✅ `showProgress: true` | ❌ |
| Action buttons | ✅ `addAction()` | ✅ `categoryIdentifier` |
| Custom XML layout | ✅ `RemoteViews` | ✅ Content Extension |
| Big Picture | ✅ `BigPictureStyleInformation` | ❌ |

---

## 5. Checklist

### Android
- [ ] `POST_NOTIFICATIONS` permission trong manifest
- [ ] 3 receivers của `flutter_local_notifications` trong manifest
- [ ] `NotificationDismissReceiver` + intent-filter
- [ ] `ic_notification.xml` drawable trắng (không dùng mipmap)
- [ ] Layout XML trong `res/layout/`
- [ ] `CustomNotificationHelper.kt` + `MainActivity.kt` MethodChannel
- [ ] `CustomNotificationService.dart` Dart wrapper

### iOS
- [ ] `UNUserNotificationCenter.current().delegate = self` trong AppDelegate
- [ ] `willPresent` override để show foreground banner
- [ ] `UNNotificationCategory` + actions đăng ký trong AppDelegate
- [ ] `NotificationContent` target trong `project.pbxproj`
- [ ] `NotificationContent/Info.plist` với `UNNotificationExtensionCategory`
- [ ] `NotificationViewController.swift` implement `UNNotificationContentExtension`
- [ ] `target 'NotificationContent'` trong Podfile → `pod install`
- [ ] "Embed App Extensions" phase đúng thứ tự trong build phases
- [ ] Code signing cho extension trong Xcode (Automatically manage signing)

---

## 6. Debug

### Android
```bash
adb logcat -s CustomNotif
# Expected: D CustomNotif: Shown id=9000 api=34
```

### iOS
- Long press notification → hiện Content Extension UI
- Check Console.app filter theo bundle ID của extension
- `UNNotificationExtensionInitialContentSizeRatio` điều chỉnh chiều cao initial

### Flutter
```dart
// Trong onTap callback
onTap: (payload) {
  if (payload != null) {
    navigatorKey.currentState?.pushNamed(payload);
  }
},
```
