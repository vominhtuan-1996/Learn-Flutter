# NotificationCenter Service

Wrapper mỏng quanh package [`notification_center`](https://pub.dev/packages/notification_center) — cung cấp một **event bus pub/sub trong app** để các màn hình / cubit giao tiếp với nhau mà không cần biết về nhau (loose coupling).

> 📌 Không liên quan tới push notification của hệ thống — đó là `flutter_local_notifications` (file `notification_center.dart` trong cùng folder hiện đang stub, dùng cho local push).

## Import

```dart
import 'package:learnflutter/core/services/notification_center/notification_center_service.dart';
```

## API

```dart
class NotificationCenterService {
  // 1. Đăng ký nhận event
  static void subscribeCenterNotification({
    required String nameNotification,
    required Function(dynamic) callback,
  });

  // 2. Huỷ đăng ký
  static void unsubscribeCenterNotification({
    required String nameNotification,
  });

  // 3. Phát event (có/không kèm data)
  static void postCenterNotification({
    required String nameNotification,
    dynamic data,
  });
}

class ConstantsNotificationCenterName {
  static const String getCheckListComponent = 'getCheckListComponent';
  // ... thêm tên ở đây để tránh hard-code
}
```

## Pattern sử dụng

### 1. Cặp `initState` ↔ `dispose` (bắt buộc)

```dart
class MyScreen extends StatefulWidget { ... }

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    NotificationCenterService.subscribeCenterNotification(
      nameNotification: ConstantsNotificationCenterName.getCheckListComponent,
      callback: (data) {
        // data có thể null hoặc bất kỳ kiểu nào — cast trước khi dùng
        if (data is Map) reloadList(data);
      },
    );
  }

  @override
  void dispose() {
    NotificationCenterService.unsubscribeCenterNotification(
      nameNotification: ConstantsNotificationCenterName.getCheckListComponent,
    );
    super.dispose();
  }
}
```

### 2. Phát event từ nơi khác

```dart
NotificationCenterService.postCenterNotification(
  nameNotification: ConstantsNotificationCenterName.getCheckListComponent,
  data: {'screen': 'EditScreen', 'updated': true},
);
```

### 3. Không có data

```dart
NotificationCenterService.postCenterNotification(
  nameNotification: 'refresh_home',
);
```

## Use case điển hình

| Tình huống | Cách dùng |
|---|---|
| Màn A submit form → màn B (đang trong stack) cần reload | A `post(...)`, B subscribe ở `initState` |
| Cubit / Repository báo event cho UI (không inject context) | Service `post(...)`, screen subscribe |
| Trigger cross-tab refresh sau khi user thực hiện thao tác | Tab nguồn `post`, các tab khác subscribe |

## Lưu ý quan trọng ⚠️

1. **Mỗi `nameNotification` chỉ giữ 1 callback** (giới hạn của package). Nếu 2 màn cùng subscribe 1 tên, callback đăng ký sau **ghi đè** callback trước.
2. **Luôn unsubscribe** trong `dispose` — nếu không, callback giữ closure → memory leak + crash khi `setState` trên widget đã unmount.
3. **`data` là `dynamic`** — luôn cast hoặc kiểm tra type trước khi sử dụng để tránh runtime error.
4. **Tên event** nên đặt trong `ConstantsNotificationCenterName` để dễ refactor và tránh typo.

## Demo trực quan

Mở **Test Screen** → mục **Notification Center** để xem 4 case test trực quan:

1. Post event không data — counter tăng dần.
2. Post kèm data (String / int / Map / null) — log hiển thị data + runtime type.
3. Subscribe / Unsubscribe runtime — verify callback ngưng nhận sau khi unsubscribe.
4. Constant name từ `ConstantsNotificationCenterName`.

Mỗi event được log realtime ở panel terminal đen phía dưới.
