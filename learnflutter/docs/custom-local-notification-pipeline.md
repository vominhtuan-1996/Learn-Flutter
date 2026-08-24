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
```

### 1.2 CustomNotificationService

File: `lib/core/services/local_notification/custom_notification_service.dart`

iOS path dùng `flutter_local_notifications` với `categoryIdentifier` để trigger Content Extension.

**Quan trọng:** Phải đăng ký tất cả categories trong `DarwinInitializationSettings.notificationCategories` trước khi gửi notification. Nếu bỏ qua, iOS gọi `setNotificationCategories([])` → xóa sạch categories → long-press không load extension.

```dart
enum NotifType { info, success, warning, promo }

extension _NotifTypeExt on NotifType {
  String get categoryId {
    switch (this) {
      case NotifType.info:    return 'NOTIF_INFO';
      case NotifType.success: return 'NOTIF_SUCCESS';
      case NotifType.warning: return 'NOTIF_WARNING';
      case NotifType.promo:   return 'NOTIF_PROMO';
    }
  }
}

Future<void> _ensureInit() async {
  if (_initialized) return;
  const categories = [
    DarwinNotificationCategory('NOTIF_INFO'),
    DarwinNotificationCategory('NOTIF_SUCCESS'),
    DarwinNotificationCategory('NOTIF_WARNING'),
    DarwinNotificationCategory('NOTIF_PROMO'),
  ];
  const darwinInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    notificationCategories: categories,   // ← bắt buộc
  );
  await _plugin.initialize(const InitializationSettings(iOS: darwinInit));
  _initialized = true;
}
```

**Gọi:**

```dart
await CustomNotificationService.instance.show(
  title: 'Cảnh báo',
  body: 'Hệ thống phát hiện bất thường',
  type: NotifType.warning,
);
```

---

## 2. Android Setup

### 2.1 AndroidManifest.xml

```xml
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

> **Android 12+:** collapsed view dùng system template. Custom layout chỉ hiện khi user **expand** notification (swipe down → tap ▾).

---

## 3. iOS Setup

### 3.1 AppDelegate.swift

```swift
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Allow foreground notifications
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

> Không cần đăng ký categories trong AppDelegate. Categories được đăng ký qua `DarwinInitializationSettings.notificationCategories` trong `CustomNotificationService`.

### 3.2 Notification Content Extension

**Cấu trúc:**

```
ios/NotificationContent/
  ├── NotificationViewController.swift
  ├── Info.plist
  └── views/
        ├── BaseNotificationView.swift          ← protocol + shared helpers
        ├── InfoNotificationView.swift + .xib
        ├── SuccessNotificationView.swift + .xib
        ├── WarningNotificationView.swift + .xib
        └── PromoNotificationView.swift + .xib
```

**Info.plist — 4 categories:**

```xml
<key>NSExtension</key>
<dict>
  <key>NSExtensionAttributes</key>
  <dict>
    <key>UNNotificationExtensionCategory</key>
    <array>
      <string>NOTIF_INFO</string>
      <string>NOTIF_SUCCESS</string>
      <string>NOTIF_WARNING</string>
      <string>NOTIF_PROMO</string>
    </array>
    <key>UNNotificationExtensionInitialContentSizeRatio</key>
    <real>0.6</real>
    <key>UNNotificationExtensionDefaultContentHidden</key>
    <true/>
  </dict>
  <key>NSExtensionPointIdentifier</key>
  <string>com.apple.usernotifications.content-extension</string>
  <key>NSExtensionPrincipalClass</key>
  <string>$(PRODUCT_MODULE_NAME).NotificationViewController</string>
</dict>
```

**NotificationViewController.swift** — dispatch theo category:

```swift
func didReceive(_ notification: UNNotification) {
    contentView?.removeFromSuperview()
    let category = notification.request.content.categoryIdentifier
    let v = makeView(for: category)
    view.addSubview(v)
    v.frame = view.bounds
    v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    v.onSizeChanged = { [weak self] in self?.resizeToFit() }
    v.apply(notification: notification)
    contentView = v
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        self?.resizeToFit()
    }
}

private func makeView(for category: String) -> UIView & NotificationViewType {
    let open: () -> Void    = { [weak self] in self?.extensionContext?.performNotificationDefaultAction() }
    let dismiss: () -> Void = { [weak self] in self?.extensionContext?.dismissNotificationContentExtension() }

    switch category {
    case "NOTIF_SUCCESS":
        let v = SuccessNotificationView.fromXib(); v.onDismiss = dismiss; return v
    case "NOTIF_WARNING":
        let v = WarningNotificationView.fromXib(); v.onOpen = open; v.onDismiss = dismiss; return v
    case "NOTIF_PROMO":
        let v = PromoNotificationView.fromXib(); v.onOpen = open; return v
    default: // NOTIF_INFO
        let v = InfoNotificationView.fromXib(); v.onOpen = open; v.onDismiss = dismiss; return v
    }
}
```

### 3.3 XIB Setup — Quy tắc quan trọng

Mỗi view dùng pattern: `UIView subclass` + XIB file. `fromXib()` dùng `withOwner: nil`.

**`customClass` phải đặt trên root `<view>`, KHÔNG phải File's Owner.**

Nếu `customClass` trên File's Owner và `withOwner: nil` → outlets không connect → view trắng.

```xml
<!-- SAI: customClass trên File's Owner -->
<placeholder placeholderIdentifier="IBFilesOwner" id="-1"
    customClass="InfoNotificationView" customModule="NotificationContent" customModuleProvider="target">
    <connections>...</connections>
</placeholder>
<view id="rootView">...</view>

<!-- ĐÚNG: customClass trên root view -->
<placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner"/>
<view id="rootView"
    customClass="InfoNotificationView" customModule="NotificationContent" customModuleProvider="target">
    <connections>
        <outlet property="titleLabel" destination="titleLbl" id="..."/>
        ...
    </connections>
    ...
</view>
```

**Action `destination`** phải trỏ vào root view ID (không phải `-1`):

```xml
<!-- SAI -->
<action selector="didTapOpen:" destination="-1" id="..."/>

<!-- ĐÚNG -->
<action selector="didTapOpen:" destination="rootView" id="..."/>
```

**`fromXib()` pattern:**

```swift
static func fromXib() -> InfoNotificationView {
    let nib = UINib(nibName: "InfoNotificationView", bundle: Bundle(for: InfoNotificationView.self))
    return nib.instantiate(withOwner: nil, options: nil).first as! InfoNotificationView
}
```

### 3.4 XIB — Xcode 26 Compatibility

Xcode 26 (toolchain 17C+) thay đổi giá trị `targetRuntime` hợp lệ.

| Xcode version | targetRuntime hợp lệ |
|---------------|----------------------|
| Xcode ≤ 15    | `AppleCocoa` hoặc `AppleCocoaTouch` |
| Xcode 26+     | `iOS.CocoaTouch` |

Nếu dùng sai value → ibtool lỗi `"Unknown target runtime"` → build fail với `com.apple.InterfaceBuilder error -1`.

```xml
<!-- ĐÚNG cho Xcode 26+ -->
<document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0"
    toolsVersion="21507" targetRuntime="iOS.CocoaTouch" ...>
```

Verify bằng ibtool:

```bash
xcrun ibtool --errors ios/NotificationContent/views/InfoNotificationView.xib 2>&1
# OK nếu output chỉ có <dict/> rỗng trong com.apple.ibtool.document.errors
```

### 3.5 Podfile

```ruby
target 'NotificationContent' do
  use_frameworks!
  use_modular_headers!
end
```

Sau khi thêm: `pod install`

### 3.6 Code Signing

Extension cần bundle ID riêng: `<parentBundleId>.NotificationContent`

| Config   | Style     | Team         | Certificate         |
|----------|-----------|--------------|---------------------|
| Debug    | Automatic | `TEAM_ID`    | Apple Development   |
| Profile  | Automatic | `TEAM_ID`    | Apple Development   |
| Release  | Manual    | `TEAM_ID`    | iPhone Distribution |

> Extension và Runner phải dùng **cùng loại certificate**. Nếu Runner Profile dùng Manual+Distribution, extension cũng phải có provisioning profile riêng cho bundle ID của nó.

**Build phases — "Embed App Extensions" phải TRƯỚC Thin Binary:**

```
Build Phases (Runner):
  1. [CP] Check Pods Manifest.lock
  2. Run Script
  3. Sources
  4. Frameworks
  5. Resources
  6. Embed Frameworks
  7. Embed App Extensions   ← trước Thin Binary
  8. Thin Binary
  9. [CP] Embed Pods Frameworks
  10. [CP] Copy Pods Resources
```

---

## 4. Notification Styles

| Style | Android | iOS |
|-------|---------|-----|
| Simple | ✅ | ✅ |
| Big Text | ✅ `BigTextStyleInformation` | ✅ body dài |
| Inbox | ✅ `InboxStyleInformation` | ✅ (dạng list) |
| Progress bar | ✅ `showProgress: true` | ❌ |
| Action buttons | ✅ `addAction()` | ✅ `categoryIdentifier` |
| Custom XML layout | ✅ `RemoteViews` | ✅ Content Extension + XIB |
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
- [ ] `DarwinInitializationSettings.notificationCategories` gồm đủ 4 categories trong `CustomNotificationService`
- [ ] `NotificationContent` target trong `project.pbxproj`
- [ ] `Info.plist` với `UNNotificationExtensionCategory` array 4 values
- [ ] XIB files: `targetRuntime="iOS.CocoaTouch"` (Xcode 26+)
- [ ] XIB files: `customClass` trên root `<view>`, KHÔNG trên File's Owner
- [ ] XIB files: `<connections>` trong root `<view>`, action `destination` trỏ root view ID
- [ ] `target 'NotificationContent'` trong Podfile → `pod install`
- [ ] "Embed App Extensions" phase đúng thứ tự trong build phases
- [ ] Code signing cho extension (Automatically manage signing)

---

## 6. Debug

### Android
```bash
adb logcat -s CustomNotif
# Expected: D CustomNotif: Shown id=9000 api=34
```

### iOS
```bash
# Validate xib không lỗi
xcrun ibtool --errors ios/NotificationContent/views/WarningNotificationView.xib 2>&1

# Console.app: filter theo bundle ID extension
# com.learnflutter.NotificationContent
```

- Long press notification → hiện Content Extension UI
- Nếu vẫn thấy default UI: kiểm tra `categoryIdentifier` trong Dart có khớp `UNNotificationExtensionCategory` trong Info.plist không
- Nếu view trắng: kiểm tra `customClass` đặt trên root view, không phải File's Owner
- `UNNotificationExtensionInitialContentSizeRatio` điều chỉnh chiều cao initial (0.6 = 60% screen width)

### Flutter
```dart
onTap: (payload) {
  if (payload != null) {
    navigatorKey.currentState?.pushNamed(payload);
  }
},
```
