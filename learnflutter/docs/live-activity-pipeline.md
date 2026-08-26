# Live Activity Pipeline

Quy trình tạo và cập nhật Live Activity real-time từ Flutter.
- **iOS 17+**: ActivityKit — Lock Screen banner + Dynamic Island
- **iOS 16**: app install OK, extension tự động bị skip bởi OS
- **Android**: Ongoing notification với RemoteViews update in-place

---

## Kiến trúc tổng quan

```
Flutter (Dart)
  └── LiveActivityService          → MethodChannel("live_activity")
        ├── iOS 17+:  AppDelegate.swift → ActivityKit + WidgetKit
        │               ├── LiveActivityAttributes  (static: title, subtitle)
        │               ├── ContentState            (dynamic: status, eta, progress)
        │               └── SwiftUI Views (Lock Screen + Dynamic Island)
        └── Android:  MainActivity.kt → LiveActivityHelper.kt
                        → NotificationManager.notify(sameId) in-place
                        → RemoteViews (title, progress bar, status, eta)
```

**Data flow:**
```
LiveActivityService.start(data)
  ├── iOS:     Activity<LiveActivityAttributes>.request(...) → Lock Screen + Dynamic Island
  └── Android: NotificationManager.notify(NOTIF_ID, buildNotification(...))

LiveActivityService.update(id, state)
  ├── iOS:     activity.update(ActivityContent(state: newState))
  └── Android: NotificationManager.notify(NOTIF_ID, buildNotification(...))  ← same ID = in-place

LiveActivityService.end(id)
  ├── iOS:     activity.end(dismissalPolicy: .immediate)
  └── Android: NotificationManager.cancel(NOTIF_ID)
```

---

## 1. Setup Flutter

### 1.1 Không cần thêm package

ActivityKit và NotificationManager đều là system API. Bridge thuần `MethodChannel`.

### 1.2 Data models

File: `lib/core/services/live_activity/live_activity_data.dart`

```dart
/// Static — set once khi start, không đổi suốt vòng đời activity.
class LiveActivityData {
  const LiveActivityData({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  Map<String, dynamic> toMap() => {'title': title, 'subtitle': subtitle};
}

/// Dynamic — cập nhật real-time qua LiveActivityService.update().
class LiveActivityState {
  const LiveActivityState({required this.status, required this.eta, required this.progress});
  final String status;
  final String eta;
  final double progress; // 0.0 → 1.0
  Map<String, dynamic> toMap() => {'status': status, 'eta': eta, 'progress': progress};
}
```

### 1.3 LiveActivityService

File: `lib/core/services/live_activity/live_activity_service.dart`

```dart
/// iOS 17+: ActivityKit — Lock Screen banner + Dynamic Island.
/// iOS < 17: areActivitiesEnabled() → false, extension không embed.
/// Android:  Ongoing notification (API 26+).
class LiveActivityService {
  LiveActivityService._();
  static final instance = LiveActivityService._();

  static const _channel = MethodChannel('live_activity');

  /// Trả activityId — lưu lại để update/end. Null nếu không hỗ trợ.
  Future<String?> start(LiveActivityData data) async {
    if (!Platform.isIOS && !Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<String>('start', data.toMap());
    } on PlatformException catch (e) {
      print('[LiveActivity] start failed: ${e.message}');
      return null;
    }
  }

  Future<void> update(String activityId, LiveActivityState state) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('update', {'id': activityId, ...state.toMap()});
  }

  Future<void> end(String activityId) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('end', {'id': activityId});
  }

  /// iOS 17+: check ActivityAuthorizationInfo. Android: luôn true (API 26+).
  Future<bool> areActivitiesEnabled() async {
    if (Platform.isAndroid) return true;
    if (Platform.isIOS) return await _channel.invokeMethod<bool>('areEnabled') ?? false;
    return false;
  }
}
```

### 1.4 Demo Screen

File: `lib/features/test_screen/live_activity_demo_screen.dart`

Route: `Routes.liveActivityDemo` → `/live_activity_demo`

Entry point trong test_screen: `⚡ Live Activity` card ngay dưới `🔔 Local Notification`.

---

## 2. iOS — Runner Setup

### 2.1 Info.plist

File: `ios/Runner/Info.plist`

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

> Bắt buộc trong Runner Info.plist. Thiếu → `Activity.request()` throw error.

### 2.2 AppDelegate.swift — MethodChannel bridge

File: `ios/Runner/AppDelegate.swift`

> **Gotchas thực tế khi implement:**
>
> 1. **`LiveActivityAttributes` phải định nghĩa lại trong Runner** — struct trong Extension target không visible với Runner. Trùng tên + layout, ActivityKit match theo Codable (2 binary khác nhau).
>
> 2. **Không dùng `@available` trên stored property** — `private var x: [String: Activity<...>]` báo lỗi. Thay bằng `[String: Any]` + cast khi dùng.
>
> 3. **Guard `iOS 17.0`** — extension deployment target là 17.0 để iOS 16 tự skip. Guard trong AppDelegate phải khớp.
>
> 4. **`ActivityContent` là iOS 16.2+** — dùng guard `iOS 16.2` nếu muốn hỗ trợ 16.x (không khuyến nghị, xem mục deployment target).
>
> 5. **`FlutterResult` phải `@escaping`** — `Task {}` là escaping closure, capture non-escaping `result` báo lỗi build.

```swift
import ActivityKit

// Định nghĩa trùng với Extension — ActivityKit match theo Codable layout.
@available(iOS 17.0, *)
struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var eta: String
        var progress: Double
    }
    var title: String
    var subtitle: String
}

// Trong AppDelegate class:
// [String: Any] — không thể @available trên stored property.
private var liveActivities: [String: Any] = [:]
```

**MethodChannel setup:**

```swift
if let controller = window?.rootViewController as? FlutterViewController {
    let channel = FlutterMethodChannel(name: "live_activity", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
        guard let self else { return }
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "start":    self.startLiveActivity(args: args, result: result)
        case "update":   self.updateLiveActivity(args: args, result: result)
        case "end":      self.endLiveActivity(args: args, result: result)
        case "areEnabled":
            if #available(iOS 17.0, *) { result(ActivityAuthorizationInfo().areActivitiesEnabled) }
            else { result(false) }
        default: result(FlutterMethodNotImplemented)
        }
    }
}
```

**startLiveActivity:**

```swift
private func startLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
    guard #available(iOS 17.0, *) else { result(nil); return }
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { result(nil); return }

    let attrs = LiveActivityAttributes(
        title: args?["title"] as? String ?? "",
        subtitle: args?["subtitle"] as? String ?? ""
    )
    let initialState = LiveActivityAttributes.ContentState(status: "Đang chuẩn bị", eta: "--", progress: 0.0)
    do {
        let activity = try Activity<LiveActivityAttributes>.request(
            attributes: attrs,
            content: ActivityContent(state: initialState, staleDate: nil),
            pushType: nil
        )
        liveActivities[activity.id] = activity
        result(activity.id)
    } catch {
        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
    }
}
```

**updateLiveActivity:**

```swift
private func updateLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
    guard #available(iOS 17.0, *) else { result(nil); return }
    guard let id = args?["id"] as? String,
          let activity = liveActivities[id] as? Activity<LiveActivityAttributes> else {
        result(nil); return
    }
    let newState = LiveActivityAttributes.ContentState(
        status: args?["status"] as? String ?? "",
        eta: args?["eta"] as? String ?? "",
        progress: args?["progress"] as? Double ?? 0.0
    )
    Task {
        await activity.update(ActivityContent(state: newState, staleDate: nil))
        result(nil)
    }
}
```

**endLiveActivity:**

```swift
private func endLiveActivity(args: [String: Any]?, result: @escaping FlutterResult) {
    guard #available(iOS 17.0, *) else { result(nil); return }
    guard let id = args?["id"] as? String,
          let activity = liveActivities[id] as? Activity<LiveActivityAttributes> else {
        result(nil); return
    }
    Task {
        await activity.end(dismissalPolicy: .immediate)
        self.liveActivities.removeValue(forKey: id)
        result(nil)
    }
}
```

---

## 3. iOS — LiveActivityExtension Target

### 3.1 Tạo target trong Xcode

```
File → New → Target → Widget Extension
Name:    LiveActivityExtension
Bundle:  com.fpt.isc.prod.LiveActivity
✅ Include Live Activity
❌ Include Configuration App Intent
```

Xcode tạo boilerplate → **xóa hết**, dùng files đã có:

```
ios/LiveActivityExtension/
  ├── LiveActivityBundle.swift          ← @main entry
  ├── LiveActivityAttributes.swift      ← ActivityAttributes struct
  ├── LiveActivityExtension.swift       ← SwiftUI views + Widget config
  ├── LiveActivityExtension.entitlements
  └── Info.plist
```

### 3.2 LiveActivityAttributes.swift

```swift
import ActivityKit

// Extension deployment = 17.0 → không cần @available
struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var eta: String
        var progress: Double  // 0.0 → 1.0
    }
    var title: String
    var subtitle: String
}
```

> Struct định nghĩa ở **2 nơi** (Extension + AppDelegate.swift). ActivityKit match bằng Codable decode — tên + field layout phải giống hệt.

### 3.3 LiveActivityExtension.swift — SwiftUI Views

**Lock Screen view:**

```swift
struct LiveActivityLockScreenView: View {
    let attributes: LiveActivityAttributes
    let state: LiveActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bicycle.circle.fill").foregroundStyle(.blue).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(attributes.title).font(.headline)
                    Text(attributes.subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(state.eta).font(.headline).foregroundStyle(.blue)
                    Text("còn lại").font(.caption2).foregroundStyle(.secondary)
                }
            }
            ProgressView(value: state.progress).tint(.blue).scaleEffect(x: 1, y: 1.5)
            Text(state.status).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}
```

**Dynamic Island:**

```swift
struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LiveActivityLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bicycle.circle.fill").foregroundStyle(.blue).font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eta).font(.headline).foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title).font(.headline).lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        ProgressView(value: context.state.progress).tint(.blue)
                        Text(context.state.status).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "bicycle.circle.fill").foregroundStyle(.blue)
            } compactTrailing: {
                Text(context.state.eta).font(.caption2).bold().foregroundStyle(.blue)
            } minimal: {
                Image(systemName: "bicycle.circle.fill").foregroundStyle(.blue)
            }
        }
    }
}
```

### 3.4 LiveActivityBundle.swift

```swift
@main
struct LiveActivityBundle: WidgetBundle {
    var body: some Widget { LiveActivityWidget() }
}
```

> **Chỉ một `@main`** — trong `LiveActivityBundle.swift`, KHÔNG có trong `LiveActivityExtension.swift`.

### 3.5 Info.plist (Extension)

File: `ios/LiveActivityExtension/Info.plist`

```xml
<dict>
    <!-- standard CFBundle keys -->
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
    <key>NSSupportsLiveActivities</key>
    <true/>
</dict>
```

> **iOS 18+ yêu cầu `NSSupportsLiveActivities = YES` trong extension** (không chỉ main app) để register extension là Live Activity provider. Thiếu → "Failed to create promise" khi install.
>
> **Không** để `NSSupportsLiveActivitiesFrequentUpdates` trong extension — chỉ Runner Info.plist.

### 3.6 Entitlements

File: `ios/LiveActivityExtension/LiveActivityExtension.entitlements`

```xml
<plist version="1.0">
<dict/>
</plist>
```

> Extension không cần App Group — data truyền qua ActivityKit attributes/ContentState, không qua UserDefaults.

### 3.7 Build Settings (pbxproj)

```
IPHONEOS_DEPLOYMENT_TARGET = 17.0   ← iOS 16 tự skip extension, app install OK
PRODUCT_BUNDLE_IDENTIFIER  = com.fpt.isc.prod.LiveActivity
GENERATE_INFOPLIST_FILE    = NO
INFOPLIST_FILE             = LiveActivityExtension/Info.plist
SKIP_INSTALL               = YES
ENABLE_PREVIEWS            = NO     ← tắt SwiftUI preview injection debug build
```

> **Tại sao 17.0?** Extension built bằng Xcode 26 SDK không install được trên iOS 16 (`0xE8000067`). Đặt deployment 17.0 → iOS 16 device bỏ qua extension khi install, app vẫn chạy. iOS 17+ nhận extension đầy đủ.

### 3.8 Podfile

```ruby
target 'LiveActivityExtension' do
  use_frameworks!
  use_modular_headers!
end
```

### 3.9 Flutter migration bug

Flutter's "Upgrading project.pbxproj" tự động corrupt bundle ID của LiveActivityExtension:
- `com.fpt.isc.prod.LiveActivity` → `group.com.fpt.isc.prod.LiveActivity`
- Hoặc thêm invalid App Group vào Runner.entitlements

**Fix sau mỗi lần Flutter migration chạy:**

```bash
# Fix bundle ID
sed -i '' 's/PRODUCT_BUNDLE_IDENTIFIER = group\.com\.fpt\.isc\.prod\.LiveActivity;/PRODUCT_BUNDLE_IDENTIFIER = com.fpt.isc.prod.LiveActivity;/g' \
  ios/Runner.xcodeproj/project.pbxproj

# Verify Runner.entitlements chỉ có HomeWidget group
plutil -p ios/Runner/Runner.entitlements
```

---

## 4. Android — Ongoing Notification

### 4.1 Kiến trúc

```
MainActivity.kt
  └── LiveActivityHelper (singleton)
        ├── init()    → tạo NotificationChannel IMPORTANCE_LOW
        ├── start()   → lưu title, notify(NOTIF_ID, build(...))
        ├── update()  → notify(NOTIF_ID, build(...))   ← same ID = in-place, no sound
        └── end()     → cancel(NOTIF_ID)
```

### 4.2 LiveActivityHelper.kt

File: `android/app/src/main/kotlin/.../LiveActivityHelper.kt`

```kotlin
object LiveActivityHelper {
    private const val CHANNEL_ID = "live_activity_channel"
    private const val NOTIF_ID   = 9001

    private var currentTitle = ""

    fun init(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "Live Activity",
                NotificationManager.IMPORTANCE_LOW   // no sound/vibrate on update
            ).apply { setShowBadge(false) }
            context.getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    fun start(context: Context, title: String, subtitle: String) {
        currentTitle = title
        manager(context).notify(NOTIF_ID, build(context, title, "Đang chuẩn bị", "--", 0))
    }

    fun update(context: Context, status: String, eta: String, progress: Int) {
        // Same NOTIF_ID = update in-place, no flicker, no alert
        manager(context).notify(NOTIF_ID, build(context, currentTitle, status, eta, progress))
    }

    fun end(context: Context) {
        manager(context).cancel(NOTIF_ID)
        currentTitle = ""
    }

    private fun build(context: Context, title: String, status: String, eta: String, progress: Int): Notification {
        val views = RemoteViews(context.packageName, R.layout.live_activity).apply {
            setTextViewText(R.id.tv_title,  title)
            setTextViewText(R.id.tv_eta,    eta)
            setTextViewText(R.id.tv_status, status)
            setProgressBar(R.id.progress_bar, 100, progress, false)
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0,
            context.packageManager.getLaunchIntentForPackage(context.packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setCustomContentView(views)
            .setCustomBigContentView(views)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setOngoing(true)          // không swipe-dismiss
            .setOnlyAlertOnce(true)   // không sound/vibrate khi update
            .setSilent(true)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun manager(context: Context) =
        context.getSystemService(NotificationManager::class.java)
}
```

### 4.3 Layout RemoteViews

File: `android/app/src/main/res/layout/live_activity.xml`

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="12dp"
    android:background="@color/live_activity_bg">

    <LinearLayout android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical">
        <TextView android:id="@+id/tv_title"
            android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1"
            android:textStyle="bold" android:textSize="14sp"
            android:textColor="@color/live_text_primary" />
        <TextView android:id="@+id/tv_eta"
            android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:textSize="13sp" android:textColor="@color/live_accent"
            android:textStyle="bold" />
    </LinearLayout>

    <ProgressBar android:id="@+id/progress_bar"
        style="?android:attr/progressBarStyleHorizontal"
        android:layout_width="match_parent" android:layout_height="6dp"
        android:layout_marginTop="8dp"
        android:max="100"
        android:progressTint="@color/live_accent" />

    <TextView android:id="@+id/tv_status"
        android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:textSize="12sp" android:textColor="@color/live_text_secondary" />
</LinearLayout>
```

> **RemoteViews rules** (từ Custom Notification Pipeline):
> - `<FrameLayout>` cho divider, KHÔNG dùng `<View>`
> - `@color/` resource, KHÔNG inline hex
> - `<ProgressBar>` dùng `progressTint` không phải `tint`

### 4.4 Colors

File: `android/app/src/main/res/values/colors.xml` — thêm vào:

```xml
<color name="live_activity_bg">#FFFFFF</color>
<color name="live_text_primary">#111827</color>
<color name="live_text_secondary">#6B7280</color>
<color name="live_accent">#3B82F6</color>
```

### 4.5 MainActivity.kt

```kotlin
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LiveActivityHelper.init(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "live_activity")
            .setMethodCallHandler { call, result ->
                val args = call.arguments as? Map<*, *>
                when (call.method) {
                    "start" -> {
                        LiveActivityHelper.start(
                            this,
                            args?.get("title") as? String ?: "",
                            args?.get("subtitle") as? String ?: ""
                        )
                        result.success("android_live_activity")
                    }
                    "update" -> {
                        LiveActivityHelper.update(
                            this,
                            args?.get("status") as? String ?: "",
                            args?.get("eta") as? String ?: "",
                            ((args?.get("progress") as? Double ?: 0.0) * 100).toInt()
                        )
                        result.success(null)
                    }
                    "end"        -> { LiveActivityHelper.end(this); result.success(null) }
                    "areEnabled" -> result.success(true)
                    else         -> result.notImplemented()
                }
            }
    }
}
```

### 4.6 AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

> Đã có sẵn trong project (từ Local Notification setup).

---

## 5. So sánh iOS vs Android

| Aspect | iOS 17+ (ActivityKit) | Android (Notification) |
|--------|-----------------------|------------------------|
| UI location | Lock Screen + Dynamic Island | Lock Screen + Notification Shade |
| Không dismiss | System-managed | `setOngoing(true)` |
| Update | `activity.update()` async | `notify(sameId)` in-place |
| Update sound | Không | `setOnlyAlertOnce(true)` + `setSilent(true)` |
| Custom UI | SwiftUI | RemoteViews XML |
| Permission | `NSSupportsLiveActivities` plist | `POST_NOTIFICATIONS` (API 33+) |
| Min OS | iOS 17.0 (extension) | Android 8.0 (API 26) |
| activityId | Dynamic từ `Activity.request()` | Fixed `"android_live_activity"` |

---

## 6. Remote Push Updates (iOS — Advanced)

```json
{
  "aps": {
    "timestamp": 1234567890,
    "event": "update",
    "content-state": {
      "status": "Shipper đang đến",
      "eta": "5 phút",
      "progress": 0.85
    }
  }
}
```

---

## 7. Checklist

### Flutter
- [x] `lib/core/services/live_activity/live_activity_data.dart`
- [x] `lib/core/services/live_activity/live_activity_service.dart`
- [x] `Platform.isIOS` / `Platform.isAndroid` guard
- [x] `areActivitiesEnabled()` check trước khi show UI
- [x] Lưu `activityId` từ `start()` cho `update()`/`end()`

### iOS — Runner
- [x] `NSSupportsLiveActivities + FrequentUpdates` trong `ios/Runner/Info.plist`
- [x] MethodChannel name `"live_activity"` khớp Dart
- [x] `LiveActivityAttributes` redefine trong AppDelegate với `@available(iOS 17.0, *)`
- [x] `liveActivities: [String: Any]` (không thể `@available` stored property)
- [x] Cast: `liveActivities[id] as? Activity<LiveActivityAttributes>`
- [x] Guard `#available(iOS 17.0, *)` trong tất cả ActivityKit calls
- [x] `@escaping FlutterResult` cho handlers dùng `Task {}`
- [x] `activity.end(dismissalPolicy: .immediate)` không có content param

### iOS — LiveActivityExtension target
- [x] Target riêng, bundle `com.fpt.isc.prod.LiveActivity`
- [x] `IPHONEOS_DEPLOYMENT_TARGET = 17.0`
- [x] `NSSupportsLiveActivities = YES` trong Extension Info.plist
- [x] **Không** có `NSSupportsLiveActivitiesFrequentUpdates` trong Extension Info.plist
- [x] Entitlements file **empty** (không cần App Group)
- [x] `ENABLE_PREVIEWS = NO` (tắt debug preview dylib injection)
- [x] Chỉ một `@main` trong `LiveActivityBundle.swift`
- [x] `target 'LiveActivityExtension'` trong Podfile → pod install

### Android
- [x] `LiveActivityHelper.kt` singleton
- [x] `live_activity.xml` RemoteViews layout
- [x] `IMPORTANCE_LOW` cho NotificationChannel
- [x] `setOngoing(true)` + `setOnlyAlertOnce(true)` + `setSilent(true)`
- [x] `setStyle(DecoratedCustomViewStyle())` — bắt buộc cho custom view
- [x] Same `NOTIF_ID` cho start + update → in-place, no flicker
- [x] `POST_NOTIFICATIONS` trong AndroidManifest
- [x] `PendingIntent.FLAG_IMMUTABLE` (Android 12+)
- [x] Layout: `@color/` resource, `<FrameLayout>` cho divider

---

## 8. Debug

```bash
# iOS — Stream ActivityKit logs
xcrun simctl spawn booted log stream \
  --predicate 'subsystem == "com.apple.ActivityKit"'

# iOS — Simulator cần iPhone 14 Pro+ cho Dynamic Island
# iOS 17+ simulator: iPhone 15 Pro, iPhone 16 Pro

# iOS — Verify extension Info.plist trong build
plutil -p build/ios/iphoneos/Runner.app/PlugIns/LiveActivityExtension.appex/Info.plist

# Android — Filter live activity notification logs
adb logcat | grep -iE "LiveActivity|NotificationManager|NOTIF_ID"
```

---

## 9. Lưu ý quan trọng

| Vấn đề | Nguyên nhân | Fix |
|--------|------------|-----|
| `0xE8000067` install fail trên iOS 16 | Extension built Xcode 26 SDK không compatible với iOS 16 `installd` | Set extension `IPHONEOS_DEPLOYMENT_TARGET = 17.0` → iOS 16 tự skip |
| `Failed to create promise` (simulator) | `NSSupportsLiveActivities` thiếu trong Extension Info.plist | Thêm vào Extension Info.plist (iOS 18+ requirement) |
| `areActivitiesEnabled` = false | iOS < 17 hoặc user tắt trong Settings | Expected — extension không embed trên iOS 16 |
| Build fail "Cannot find type 'LiveActivityAttributes'" | Struct trong Extension, Runner không thấy | Redefine trong AppDelegate với `@available(iOS 17.0, *)` |
| Build fail "Stored properties cannot be marked potentially unavailable" | `@available` trên stored property | Dùng `[String: Any]`, cast khi lấy |
| Build fail "Escaping closure captures non-escaping parameter 'result'" | `FlutterResult` non-escaping capture trong `Task {}` | `result: @escaping FlutterResult` |
| Build fail "'ActivityContent' is only available in iOS 16.2" | Guard `iOS 16.1` nhưng API là 16.2+ | Guard `#available(iOS 17.0, *)` |
| Flutter migration corrupt bundle ID | Flutter "Upgrading project.pbxproj" thêm `group.` prefix | Fix thủ công sau migration, xem mục 3.9 |
| Flutter migration thêm App Group vào Runner.entitlements | Flutter đọc extension và tạo App Group | Remove `HomeLiveActivity` group khỏi entitlements |
| CocoaPods "Unable to find target" | Target chưa có trong xcodeproj trước pod install | Thêm target vào pbxproj hoặc Xcode GUI trước |
| Android: sound mỗi lần update | `IMPORTANCE_DEFAULT` thay vì `LOW` | `IMPORTANCE_LOW` + `setOnlyAlertOnce(true)` |
| Android: notification dismiss được | Thiếu `setOngoing(true)` | Thêm `setOngoing(true)` vào builder |
