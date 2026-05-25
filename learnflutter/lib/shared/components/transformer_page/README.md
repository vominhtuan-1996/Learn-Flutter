# TransformerPage

Component bọc sẵn [`TransformerPageView`](https://pub.dev/packages/another_transformer_page_view) với **25+ hiệu ứng chuyển trang vật lý** (3D, parallax, cube, coverflow, book flip, curtain…). Chỉ cần chọn `TransformerType` là dùng.

```
lib/shared/components/transformer_page/
├── transformer_page.dart              -> TransformerPage widget + re-export tất cả
├── transformer_type.dart              -> enum TransformerType
├── transformer_factory.dart           -> transformerFor(TransformerType) helper
├── transformers/
│   ├── transformers.dart              -> barrel export 25 class
│   ├── accordion_transformer.dart
│   ├── three_d_transformer.dart
│   ├── ... (23 file còn lại, mỗi class 1 file)
│   └── scale_rotate_transformer.dart
├── transformer_page_test_screen.dart  -> TransformerPageTestScreen (demo trực quan)
└── README.md
```

> Chỉ cần `import 'package:.../transformer_page/transformer_page.dart';` là có sẵn `TransformerPage`, `TransformerType`, `transformerFor` và mọi class transformer concrete (đã re-export).

---

## 1. Cách dùng nhanh

```dart
import 'package:learnflutter/shared/components/transformer_page/transformer_page.dart';

TransformerPage(
  type: TransformerType.coverFlow,
  itemCount: items.length,
  itemBuilder: (context, index) => MyCard(items[index]),
)
```

Đó là tất cả những gì cần. Component sẽ tự khởi tạo `PageTransformer` tương ứng và truyền vào `TransformerPageView`.

---

## 2. API

```dart
TransformerPage({
  required TransformerType type,
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  bool loop = false,
  IndexController? controller,
  ValueChanged<int?>? onPageChanged,
  Axis scrollDirection = Axis.horizontal,
  ScrollPhysics? physics,
})
```

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `type` | `TransformerType` | bắt buộc | Chọn hiệu ứng (xem bảng bên dưới) |
| `itemCount` | `int` | bắt buộc | Số trang |
| `itemBuilder` | `IndexedWidgetBuilder` | bắt buộc | Render từng trang |
| `loop` | `bool` | `false` | Loop vô hạn |
| `controller` | `IndexController?` | `null` | Jump tới index bất kỳ |
| `onPageChanged` | `ValueChanged<int?>?` | `null` | Callback khi đổi trang |
| `scrollDirection` | `Axis` | `horizontal` | Hướng cuộn |
| `physics` | `ScrollPhysics?` | `null` | Custom physics |

### Điều khiển bằng `IndexController`

```dart
final controller = IndexController();

TransformerPage(
  type: TransformerType.cubeOut,
  controller: controller,
  itemCount: 5,
  itemBuilder: ...,
);

// Sau đó:
controller.move(2, animation: true);  // tới trang 2
controller.next(animation: true);
controller.previous(animation: true);
```

---

## 3. Bảng hiệu ứng (`TransformerType`)

| Type | Mô tả |
|---|---|
| `accordion` | Co giãn như đàn accordion |
| `threeD` | Xoay 3D quanh trục Y |
| `scaleAndFade` | Scale + fade mượt |
| `zoomIn` | Phóng to trang mới |
| `zoomOut` | Thu nhỏ & mờ trang cũ |
| `depth` | Xếp chồng có chiều sâu |
| `cubeIn` | Lật mặt trong khối lập phương |
| `cubeOut` | Lật mặt ngoài khối lập phương |
| `flipHorizontal` | Lật thẻ 180° ngang |
| `flipVertical` | Lật thẻ 180° dọc |
| `parallax` | Parallax thị sai |
| `rotateDown` | Xoay nghiêng xuống |
| `rotateUp` | Xoay nghiêng lên |
| `stack` | Trang mới trượt đè |
| `tablet` | Lật nhẹ kiểu tablet |
| `convex` | Thấu kính lồi |
| `concave` | Thấu kính lõm |
| `coverFlow` | Phong cách album Apple |
| `tunnel` | Bay xuyên đường hầm |
| `spin` | Xoay tròn như đĩa nhạc |
| `wipe` | Trượt + cắt |
| `curtain` | Rèm tách đôi |
| `bookFlip` | Lật trang sách |
| `fan` | Bung kiểu quạt giấy |
| `scaleRotate` | Xoay + nảy |

> Cần custom riêng? Bỏ qua `TransformerPage` và dùng trực tiếp `TransformerPageView` + `transformerFor(type)` hoặc viết `PageTransformer` riêng.

---

## 4. Helper `transformerFor()`

Khi cần truy cập `PageTransformer` thuần (ví dụ dùng với `TransformerPageView` gốc):

```dart
TransformerPageView(
  transformer: transformerFor(TransformerType.bookFlip),
  itemBuilder: ...,
)
```

---

## 5. Ví dụ thực tế

### Onboarding

```dart
TransformerPage(
  type: TransformerType.parallax,
  itemCount: slides.length,
  itemBuilder: (_, i) => OnboardingSlide(slide: slides[i]),
  onPageChanged: (i) => analytics.log('onboarding_$i'),
)
```

### Banner carousel loop

```dart
TransformerPage(
  type: TransformerType.coverFlow,
  loop: true,
  itemCount: banners.length,
  itemBuilder: (_, i) => BannerCard(banners[i]),
)
```

### Photo album lật sách

```dart
TransformerPage(
  type: TransformerType.bookFlip,
  itemCount: photos.length,
  itemBuilder: (_, i) => Image.network(photos[i]),
)
```

---

## 6. Demo trực quan

Mở `TransformerPageTestScreen` ([transformer_page_test_screen.dart](transformer_page_test_screen.dart)) — có 4 tab demo (Gradient, Photo Cards, Onboarding, Mini Row) và 1 chip selector ngang để đổi `TransformerType` realtime, so sánh trực tiếp.
