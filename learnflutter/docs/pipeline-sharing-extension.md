# Pipeline: iOS Share Extension + Android Share Intent

Quy trình chuẩn để thêm một platform sharing feature vào app Flutter.  
Dùng làm checklist khi implement mới hoặc debug.

---

## Tổng quan kiến trúc

```
iOS                                     Android
─────────────────────────────────────   ────────────────────────────────────
Safari/Photos                           Chrome/Gallery
  │ Share sheet                           │ Share intent
  ▼                                       ▼
ShareExtension (.appex)                 MainActivity (ACTION_SEND)
  │ ShareViewController.swift             │ receive_sharing_intent plugin
  │ ShareView.swift (SwiftUI preview)     │
  │ Writes → App Group UserDefaults       │
  │ Opens → ShareMedia-<bundleId>:share   │
  ▼                                       ▼
Flutter App (AppDelegate handles URL)   Flutter App (intent handled by plugin)
  │                                       │
  ▼                                       ▼
ShareExtensionCubit (global, main.dart)
  │ getInitialMedia() / getMediaStream()
  ▼
ShareExtensionScreen
```

---

## Giai đoạn 1 — iOS Native Extension

### 1.1 Tạo files

```
ios/ShareExtension/
├── ShareViewController.swift   # UIViewController + data loader
├── ShareView.swift             # SwiftUI preview UI
├── Info.plist                  # Extension config
└── ShareExtension.entitlements # App Group
```

### 1.2 Info.plist — bắt buộc có

```xml
<key>AppGroupId</key>
<string>group.com.fpt.isc.prod.HomeWidget</string>   <!-- PHẢI khớp Runner -->

<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key><integer>1</integer>
            <key>NSExtensionActivationSupportsImageWithMaxCount</key><integer>10</integer>
            <key>NSExtensionActivationSupportsText</key><true/>
            <key>NSExtensionActivationSupportsFileWithMaxCount</key><integer>5</integer>
        </dict>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
</dict>
```

### 1.3 Entitlements

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.fpt.isc.prod.HomeWidget</string>
</array>
```

### 1.4 ShareViewController.swift — pattern chuẩn

```swift
// Constants — PHẢI match SwiftReceiveSharingIntentPlugin.swift
private let kSchemePrefix    = "ShareMedia"
private let kUserDefaultsKey = "ShareKey"
private let kAppGroupIdKey   = "AppGroupId"

// Flow:
// viewDidLoad → loadIds() → loadSharedItems()
// loadSharedItems() → parse attachments → showUI()
// User tap Gửi → saveAndRedirect()
//   → UserDefaults(suiteName: appGroupId).set(data, forKey: "ShareKey")
//   → open URL: "ShareMedia-com.fpt.isc.prod:share"
```

**Lưu ý quan trọng:**
- KHÔNG dùng `SLComposeServiceViewController` — dùng `UIViewController` + SwiftUI hosting
- KHÔNG import `receive_sharing_intent` pod vào extension (có API cấm trong extension)
- Tự copy constants + model từ plugin, viết standalone

### 1.5 SwiftUI ShareView.swift — pattern chuẩn

```swift
struct SharePreviewItem {
    let type: ShareItemType   // url, text, image, file, location, ...
    let value: String
    var coordinate: CLLocationCoordinate2D?  // nếu có location
    enum ShareItemType { ... }
}

struct ShareView: View {
    let items: [SharePreviewItem]
    let onShare: () -> Void    // gọi saveAndRedirect()
    let onCancel: () -> Void   // gọi extensionContext.completeRequest()
}
```

Thêm content type mới:
1. Add case vào `ShareItemType` enum
2. Add `icon`, `typeLabel`, `iconBg` cho case đó
3. Tạo row view riêng nếu cần preview đặc biệt (vd: `LocationRow` dùng MapKit)

---

## Giai đoạn 2 — pbxproj Injection

Xcode không cho sửa file bằng UI khi file đã có target — phải inject thủ công hoặc bằng script.

### 2.1 Các sections cần inject (theo thứ tự)

| Section | Nội dung |
|---------|---------|
| `PBXBuildFile` | `NewFile.swift in Sources`, `NewExt.appex in Embed`, framework |
| `PBXContainerItemProxy` | Proxy từ Runner → extension target |
| `PBXCopyFilesBuildPhase` (Embed App Extensions) | Thêm `.appex` vào Runner |
| `PBXFileReference` | File refs cho mọi source file + framework |
| `PBXFrameworksBuildPhase` | Framework list của extension |
| `PBXGroup` | Group folder + children |
| `PBXNativeTarget` | Target definition |
| `PBXProject.targets` | Thêm target vào list |
| `PBXProject.TargetAttributes` | Thêm target attributes |
| `PBXResourcesBuildPhase` | Resources (có thể rỗng) |
| `PBXSourcesBuildPhase` | Swift source files |
| `PBXTargetDependency` | Runner depends on extension |
| `XCBuildConfiguration` (Debug/Release/Profile) | Build settings |
| `XCConfigurationList` | Config list cho target |

### 2.2 Build settings bắt buộc cho extension

```
CODE_SIGN_ENTITLEMENTS = ShareExtension/ShareExtension.entitlements
CODE_SIGN_STYLE = Manual
GENERATE_INFOPLIST_FILE = NO
INFOPLIST_FILE = ShareExtension/Info.plist
IPHONEOS_DEPLOYMENT_TARGET = 16.0
PRODUCT_BUNDLE_IDENTIFIER = com.fpt.isc.prod.ShareExtension
SKIP_INSTALL = YES
SWIFT_VERSION = 5.0
```

### 2.3 Thêm file mới vào extension target đã có

```
PBXBuildFile  → thêm "NewFile.swift in Sources"
PBXFileReference → thêm file ref
PBXGroup (ShareExtension) → thêm vào children
PBXSourcesBuildPhase (ShareExtension Sources) → thêm build file ref
```

### 2.4 Thêm framework vào extension

```
PBXBuildFile  → "MapKit.framework in Frameworks"
PBXFileReference → MapKit.framework (path = System/Library/Frameworks/...)
PBXGroup (Frameworks) → thêm fileRef
PBXFrameworksBuildPhase (ShareExtension) → thêm buildFile ref
```

### 2.5 Validate sau khi inject

```bash
xcodebuild -list -workspace ios/Runner.xcworkspace 2>/dev/null | grep -E "Runner|ShareExtension"
fvm flutter build ios --no-codesign
```

---

## Giai đoạn 3 — Runner Config

### 3.1 Runner/Info.plist — bắt buộc

```xml
<!-- PHẢI có để plugin đọc đúng App Group -->
<key>AppGroupId</key>
<string>group.com.fpt.isc.prod.HomeWidget</string>

<!-- URL scheme để extension callback mở app -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ShareMedia-com.fpt.isc.prod</string>
        </array>
    </dict>
</array>
```

> **Lỗi hay gặp:** Nếu thiếu `AppGroupId` trong Runner → plugin dùng fallback  
> `group.com.fpt.isc.prod` (không có suffix) → không đọc được data từ extension.

### 3.2 Podfile

```ruby
target 'ShareExtension' do
  use_frameworks!
  use_modular_headers!
  # Chỉ thêm pod nếu thực sự cần — phần lớn extension dùng system frameworks
end
```

---

## Giai đoạn 4 — Android

### 4.1 AndroidManifest.xml

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Intent filters trong MainActivity -->
<intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="text/plain"/>
</intent-filter>
<intent-filter>
    <action android:name="android.intent.action.SEND"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="image/*"/>
</intent-filter>
<intent-filter>
    <action android:name="android.intent.action.SEND_MULTIPLE"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:mimeType="*/*"/>
</intent-filter>

<!-- FileProvider (bắt buộc Android 7+) -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths"/>
</provider>
```

### 4.2 res/xml/file_paths.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <cache-path name="cache" path="." />
    <external-cache-path name="external_cache" path="." />
    <files-path name="files" path="." />
    <external-files-path name="external_files" path="." />
    <external-path name="external" path="." />
</paths>
```

---

## Giai đoạn 5 — Flutter

### 5.1 Package

```yaml
receive_sharing_intent: ^1.8.1  # iOS + Android
```

> Version ^2.x không tương thích với Flutter 3.29.3 — dùng ^1.8.1.

### 5.2 Cubit — global, không đặt trong screen

```dart
// main.dart → MultiBlocProvider
BlocProvider(create: (_) => ShareExtensionCubit()),

// ShareExtensionCubit._init()
_sub = ReceiveSharingIntent.instance.getMediaStream().listen(_handle);
ReceiveSharingIntent.instance.getInitialMedia().then(_handle);
```

**Tại sao global:** URL scheme callback (iOS) hoặc share intent (Android) có thể đến  
trước khi user navigate vào ShareExtensionScreen — cubit phải sống từ đầu.

### 5.3 Thêm content type mới

1. `SharedItemType` enum trong `shared_item.dart` — thêm case
2. `cubit._handle()` — thêm detection logic (vd: parse URL pattern)
3. `ShareExtensionScreen` — thêm card widget cho type mới
4. iOS `SharePreviewItem.ShareItemType` — thêm case tương ứng
5. iOS `ShareViewController.swift` — thêm detection + preview item creation
6. iOS `ShareView.swift` — thêm row view

### 5.4 Auto-navigate khi nhận share (Android)

```dart
// Trong root screen (TestScreen) initState:
WidgetsBinding.instance.addPostFrameCallback((_) {
  final cubit = context.read<ShareExtensionCubit>();
  if (cubit.state.status == ShareExtensionStatus.loaded) {
    Navigator.of(context).pushNamed(Routes.shareExtension);
  }
  cubit.stream.listen((state) {
    if (state.status == ShareExtensionStatus.loaded && mounted) {
      Navigator.of(context).pushNamed(Routes.shareExtension);
    }
  });
});
```

---

## Giai đoạn 6 — Provisioning (iOS only)

| Profile | Bundle ID | Capability |
|---------|-----------|------------|
| `dev_shareextension` | `com.fpt.isc.prod.ShareExtension` | App Groups |
| `dis_shareextension` | `com.fpt.isc.prod.ShareExtension` | App Groups |

App Group `group.com.fpt.isc.prod.HomeWidget` phải được enable trên cả:
- Runner (Debug/Release/Profile entitlements)
- ShareExtension entitlements

---

## Checklist debug

| Triệu chứng | Nguyên nhân | Fix |
|-------------|-------------|-----|
| Extension không hiện trong share sheet | `Info.plist` thiếu `NSExtensionActivationRule` | Thêm activation rule |
| App mở nhưng không nhận data | `AppGroupId` mismatch giữa extension và Runner | Đảm bảo cả hai cùng group ID |
| `getInitialMedia()` trả về rỗng | Cubit tạo sau khi URL scheme đã fire | Chuyển cubit lên global MultiBlocProvider |
| Build fail: "API unavailable in extension" | Import pod có code dùng `addApplicationDelegate` | Không link pod vào extension — viết standalone |
| `PBXFileSystemSynchronizedBuildFileExceptionSet` lỗi | Script inject group nhầm vào `fileSystemSynchronizedGroups` | Kiểm tra string replacement không bị duplicate match |
| Pod install fail: objectVersion 70 | CocoaPods 1.16.x chưa support Xcode 26 | Dùng `fvm flutter build` thay vì `pod install` trực tiếp |

---

## Thêm content type mới — ví dụ: Video

```
1. SharedItemType.video trong shared_item.dart
2. cubit._handle(): SharedMediaType.video → SharedItemType.video
3. ShareExtensionScreen: _VideoCard widget (thumbnail + duration)
4. iOS SharePreviewItem: case .video, icon "video", iconBg .pink
5. iOS ShareView: VideoRow dùng AVFoundation thumbnail
6. iOS ShareViewController: handleFile với type == .video đã có sẵn
```

---

## Files liên quan

| File | Vai trò |
|------|---------|
| `ios/ShareExtension/ShareViewController.swift` | Native extension entry, data loader |
| `ios/ShareExtension/ShareView.swift` | SwiftUI preview UI |
| `ios/ShareExtension/Info.plist` | Extension manifest |
| `ios/ShareExtension/ShareExtension.entitlements` | App Group capability |
| `ios/Runner/Info.plist` | AppGroupId + URL scheme |
| `ios/Runner/AppDelegate.swift` | URL scheme handler (pass-through) |
| `ios/Podfile` | Extension target declaration |
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode project structure |
| `android/app/src/main/AndroidManifest.xml` | Intent filters + FileProvider |
| `android/app/src/main/res/xml/file_paths.xml` | FileProvider paths |
| `lib/features/share_extension/models/shared_item.dart` | Data models + URL parsers |
| `lib/features/share_extension/cubit/share_extension_cubit.dart` | Business logic |
| `lib/features/share_extension/cubit/share_extension_state.dart` | State |
| `lib/features/share_extension/screens/share_extension_screen.dart` | UI |
| `lib/shared/widgets/routes/route.dart` | Route `/share_extension` |
| `lib/main.dart` | Global BlocProvider |
