# Home Widget Pipeline

Quy trình tạo và cập nhật Home Screen Widget trên Android và iOS từ Flutter.

---

## Kiến trúc tổng quan

```
Flutter (Dart)
  └── HomeWidgetService          → bridge Dart → native (home_widget package)
        ├── Android: SharedPreferences (App Group) → AppHomeWidgetProvider.kt (RemoteViews XML)
        └── iOS:     App Group UserDefaults → HomeWidgetExtension (SwiftUI WidgetKit)
```

**Data flow:**
```
HomeWidgetService.update(data)
  → HomeWidget.saveWidgetData()   [home_widget package]
  → HomeWidget.updateWidget()     [sends broadcast/reload]
      ├── Android: AppHomeWidgetProvider.onUpdate() → RemoteViews → Launcher
      └── iOS:     Provider.getTimeline() → SwiftUI view → Home Screen
```

---

## 1. Setup Flutter

### 1.1 pubspec.yaml

```yaml
dependencies:
  home_widget: ^0.7.0
```

### 1.2 HomeWidgetService

File: `lib/core/services/home_widget/home_widget_service.dart`

```dart
class HomeWidgetService {
  static const _appGroupId       = 'group.com.fpt.isc.prod.HomeWidget';
  static const _iOSWidgetName    = 'HomeWidget';
  static const _androidWidgetName = 'AppHomeWidgetProvider';

  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _ready = true;
  }

  // Tự gọi init nếu chưa ready — không cần gọi init() thủ công
  Future<void> _ensureReady() async {
    if (!_ready) await init();
  }

  Future<void> update(WidgetUserData data) async { ... }
  Future<void> clear() async { ... }
}
```

**Data model:**

```dart
class WidgetUserData {
  final String userName;
  final String balance;
  final List<Map<String, String>> stats; // [{'label': '...', 'value': '...'}]
}
```

**Gọi:**

```dart
await HomeWidgetService.instance.update(WidgetUserData(
  userName: 'Nguyễn Văn A',
  balance: '1,234,567 ₫',
  stats: [
    {'label': 'Đơn hàng', 'value': '12'},
    {'label': 'Điểm thưởng', 'value': '850'},
    {'label': 'Voucher', 'value': '3'},
    {'label': 'Thông báo', 'value': '5'},
  ],
));

// Khi logout
await HomeWidgetService.instance.clear();
```

### 1.3 Demo UI

File: `lib/features/test_screen/local_notification_demo_screen.dart`

Section **🏠 Home Widget** với form nhập liệu:
- Tên người dùng, số dư
- Stats tối đa 6 items (label + value), thêm/xóa dynamic
- Button **📊 Cập nhật Widget** → ghi data + trigger reload
- Button **🗑️** → clear data
- Button **➕** → bottom sheet hướng dẫn thêm widget

---

## 2. Android Setup

### 2.1 AndroidManifest.xml

```xml
<receiver
    android:name=".AppHomeWidgetProvider"
    android:exported="true"
    android:label="Tổng quan">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/home_widget_info" />
</receiver>
```

### 2.2 Widget Metadata

File: `android/app/src/main/res/xml/home_widget_info.xml`

```xml
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="250dp"
    android:targetCellWidth="4"
    android:targetCellHeight="4"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/home_widget"
    android:widgetCategory="home_screen"
    android:resizeMode="horizontal|vertical"
    android:description="@android:string/ok" />
```

### 2.3 Layout

File: `android/app/src/main/res/layout/home_widget.xml`

**RemoteViews — các view được phép:**
- `LinearLayout`, `RelativeLayout`, `FrameLayout`, `GridLayout`
- `TextView`, `ImageView`, `Button`, `ImageButton`, `ProgressBar`
- ❌ `android.view.View` (plain `<View>`) — **KHÔNG được phép**, dùng `<FrameLayout>` thay thế

```xml
<!-- Divider — ĐÚNG -->
<FrameLayout android:layout_width="match_parent" android:layout_height="1dp"
    android:background="@color/widget_divider" ... />

<!-- Divider — SAI -->
<View android:layout_width="match_parent" android:layout_height="1dp" ... />
```

**Colors:** Dùng `@color/` resource thay vì inline hex (`#FFFFFF`) để tránh inflate fail trên một số launcher.

File: `android/app/src/main/res/values/colors.xml`

```xml
<resources>
    <color name="widget_bg">#FFFFFF</color>
    <color name="widget_avatar_bg">#4F8EF7</color>
    <color name="widget_stat_bg">#F9FAFB</color>
    <color name="widget_text_primary">#111827</color>
    <color name="widget_text_secondary">#9CA3AF</color>
    <color name="widget_text_muted">#D1D5DB</color>
    <color name="widget_divider">#F3F4F6</color>
</resources>
```

**Drawables:** Shape drawable (`oval`, `rectangle` với `corners`) hoạt động bình thường trong RemoteViews.

```
android/app/src/main/res/drawable/
  ├── widget_avatar_bg.xml   ← oval gradient (circle avatar)
  └── widget_stat_bg.xml     ← rectangle với corners radius 10dp
```

### 2.4 AppHomeWidgetProvider.kt

```kotlin
// QUAN TRỌNG: Đặt tên khác với class của package để tránh conflict
class AppHomeWidgetProvider : es.antonborri.home_widget.HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,  // ← package inject SharedPreferences đúng
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            val userName = widgetData.getString("user_name", "—") ?: "—"
            val balance  = widgetData.getString("balance",   "—") ?: "—"
            // ... set text, parse stats JSON ...
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
```

> **Quan trọng:** Extend `es.antonborri.home_widget.HomeWidgetProvider` (không phải `AppWidgetProvider` trực tiếp) để nhận `SharedPreferences` đúng từ package. Class name phải **khác** với `HomeWidgetProvider` để tránh Kotlin name conflict.

### 2.5 SharedPreferences keys

Package `home_widget` lưu data vào `"HomeWidgetPreferences"` với key trực tiếp:

| Dart key | Android read |
|----------|-------------|
| `'user_name'` | `widgetData.getString("user_name", "—")` |
| `'balance'` | `widgetData.getString("balance", "—")` |
| `'stats'` | `widgetData.getString("stats", null)` → parse JSON |
| `'last_updated'` | `widgetData.getString("last_updated", "—")` |

**Thêm widget Android:**
```
Home screen → Long press vùng trống → Widgets
→ Tìm app → Kéo widget "Tổng quan" vào màn hình
```

---

## 3. iOS Setup

### 3.1 App Group

Cả **Runner** và **HomeWidgetExtension** phải cùng App Group:

```
Runner target → Signing & Capabilities → App Groups → ✅ group.com.fpt.isc.prod.HomeWidget
HomeWidgetExtension target → Signing & Capabilities → App Groups → ✅ group.com.fpt.isc.prod.HomeWidget
```

Entitlements file: `ios/HomeWidget/HomeWidgetExtension.entitlements`

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.fpt.isc.prod.HomeWidget</string>
</array>
```

> Runner entitlements: `ios/Runner/Runner.entitlements` và `ios/Runner/RunnerProfile.entitlements` cũng phải có cùng App Group.

### 3.2 Xcode Target Setup

Target name: `HomeWidgetExtension`  
Bundle ID: `com.fpt.isc.prod.HomeWidget`

**Build Settings (pbxproj):**

```
CODE_SIGN_ENTITLEMENTS = HomeWidget/HomeWidgetExtension.entitlements
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = HomeWidget/Info.plist
IPHONEOS_DEPLOYMENT_TARGET = 16.0   ← KHÔNG để 26.x, widget không load trên iOS cũ
PRODUCT_BUNDLE_IDENTIFIER = com.fpt.isc.prod.HomeWidget
SKIP_INSTALL = YES
```

### 3.3 Info.plist

File: `ios/HomeWidget/Info.plist`

```xml
<dict>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <!-- ... standard bundle keys ... -->
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
```

> **Bắt buộc** phải có `CFBundleIdentifier`. Thiếu key này → Xcode không nhận bundle ID → lỗi "Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier".

### 3.4 Widget Extension Structure

```
ios/HomeWidget/
  ├── HomeWidgetBundle.swift       ← @main entry point
  ├── HomeWidgetExtension.swift    ← Provider + Views + Widget struct
  ├── HomeWidgetExtension.entitlements
  └── Info.plist
```

**HomeWidgetBundle.swift** — entry point:

```swift
@main
struct HomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWidget()
    }
}
```

**HomeWidgetExtension.swift** — đọc App Group UserDefaults:

```swift
private let appGroupId = "group.com.fpt.isc.prod.HomeWidget"

private func load() -> WidgetData {
    let d = UserDefaults(suiteName: appGroupId)
    let userName    = d?.string(forKey: "user_name")    ?? "—"
    let balance     = d?.string(forKey: "balance")      ?? "—"
    let lastUpdated = d?.string(forKey: "last_updated") ?? "—"

    var stats: [StatItem] = []
    if let raw = d?.string(forKey: "stats"),
       let data = raw.data(using: .utf8),
       let decoded = try? JSONDecoder().decode([StatItem].self, from: data) {
        stats = decoded
    }
    return WidgetData(userName: userName, balance: balance, stats: stats, lastUpdated: lastUpdated)
}
```

**iOS 16/17 compatibility:**

```swift
// containerBackground iOS 17+ only
struct WidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(.background, for: .widget)
        } else {
            content
        }
    }
}

// Preview iOS 17+ only
@available(iOS 17.0, *)
#Preview(as: .systemLarge) { ... }
```

**Thêm widget iOS:**
```
Home screen → Long press vùng trống → [+] góc trên trái
→ Search tên app ("Market") → Chọn "Tổng quan" → Add Widget
```

### 3.5 Podfile

```ruby
target 'HomeWidgetExtension' do
  use_frameworks!
  use_modular_headers!
end
```

---

## 4. Checklist

### Android
- [ ] `home_widget: ^0.7.0` trong pubspec
- [ ] `AppHomeWidgetProvider` extends `es.antonborri.home_widget.HomeWidgetProvider`
- [ ] Class name **khác** `HomeWidgetProvider` (tránh conflict với package)
- [ ] Receiver trong AndroidManifest với `android:exported="true"`
- [ ] `res/xml/home_widget_info.xml` — `android:description="@android:string/ok"` (không dùng `@string/app_name` nếu chưa định nghĩa)
- [ ] Layout dùng `<FrameLayout>` cho divider, KHÔNG dùng `<View>`
- [ ] Colors dùng `@color/` resource, không dùng inline hex
- [ ] Shape drawables (`oval`, `rectangle`) OK trong RemoteViews

### iOS
- [ ] App Group `group.com.fpt.isc.prod.HomeWidget` trên cả Runner + HomeWidgetExtension target
- [ ] `HomeWidgetExtension.entitlements` với `com.apple.security.application-groups`
- [ ] `Runner.entitlements` + `RunnerProfile.entitlements` cũng có App Group
- [ ] `CODE_SIGN_ENTITLEMENTS` wired trong pbxproj cho cả 3 configs (Debug/Release/Profile)
- [ ] `GENERATE_INFOPLIST_FILE = NO`
- [ ] `IPHONEOS_DEPLOYMENT_TARGET = 16.0` (không để 26.x)
- [ ] `Info.plist` có `CFBundleIdentifier = $(PRODUCT_BUNDLE_IDENTIFIER)`
- [ ] `HomeWidgetBundle.swift` là `@main`, **không** có `@main` trong `HomeWidgetExtension.swift`
- [ ] `containerBackground` và `#Preview` wrap với `@available(iOS 17.0, *)`
- [ ] `target 'HomeWidgetExtension'` trong Podfile → `pod install`

---

## 5. Debug

### Android
```bash
# Filter lỗi inflate trong launcher process (không filter theo PID app)
adb logcat | grep -iE 'AppWidgetHostView|inflate|RemoteViews|NotFoundException'

# Lỗi thường gặp:
# "Class not allowed to be inflated android.view.View" → dùng FrameLayout thay View
# "Error inflating RemoteViews" → kiểm tra resource references trong layout XML
```

### iOS
```bash
# Verify App Group trong entitlements sau khi build
codesign -d --entitlements - \
  build/ios/iphoneos/Runner.app/PlugIns/HomeWidgetExtension.appex 2>&1 \
  | grep -A3 'app-groups'

# Phải thấy: group.com.fpt.isc.prod.HomeWidget
```

### Flutter
```dart
// HomeWidgetService log khi update thành công
// [HomeWidget] updated for Nguyễn Văn A
```

---

## 6. Lưu ý quan trọng

| Vấn đề | Nguyên nhân | Fix |
|--------|------------|-----|
| Widget không xuất hiện trong gallery (iOS) | `IPHONEOS_DEPLOYMENT_TARGET` quá cao | Set về `16.0` |
| Widget không xuất hiện trong gallery (iOS) | App Group thiếu hoặc sai ID | Verify entitlements sau build |
| "Không thể thêm tiện ích" (Android) | `<View>` trong layout | Thay bằng `<FrameLayout>` |
| "Không thể thêm tiện ích" (Android) | Inline hex color | Dùng `@color/` resource |
| Widget hiện data `—` | App Group ID không khớp | Kiểm tra `_appGroupId` trong Dart và Swift |
| `PlatformException(-7)` | `init()` chưa gọi | Dùng `_ensureReady()` tự động trong service |
| iOS build lỗi bundle prefix | `CFBundleIdentifier` thiếu trong `Info.plist` | Thêm `$(PRODUCT_BUNDLE_IDENTIFIER)` |
| Class conflict Kotlin | Class đặt tên `HomeWidgetProvider` | Đổi tên thành `AppHomeWidgetProvider` |
