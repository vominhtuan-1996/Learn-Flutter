# LuxuryCardStack

Stack thẻ kiểu "Tinder/Apple Card" với physics thật: drag ngang để swipe, drag dọc để drop, thả ra dùng `SpringSimulation` để snap back; vượt ngưỡng → card top rớt xuống và đẩy ra sau cùng.

```
lib/shared/components/luxury_card_stack/
├── luxury_card_stack.dart                 -> barrel export
├── src/
│   ├── luxury_card_stack_view.dart        -> LuxuryCardStackView (widget chính)
│   ├── luxury_card_controller.dart        -> LuxuryCardStackController (state + animations)
│   ├── luxury_card_item.dart              -> LuxuryCardItem (model image/title/subtitle/tag)
│   └── luxury_card_widget.dart            -> LuxuryCardWidget (card mẫu dùng Image.asset)
├── luxury_card_stack_test_screen.dart     -> demo trực quan
└── README.md
```

Chỉ cần `import 'package:.../luxury_card_stack/luxury_card_stack.dart';` là có đầy đủ.

---

## 1. Dùng nhanh

```dart
import 'package:learnflutter/shared/components/luxury_card_stack/luxury_card_stack.dart';

LuxuryCardStackView(
  items: cards, // List<LuxuryCardItem>
  cardBuilder: (context, item, index) => LuxuryCardWidget(item: item),
  onSwipeEnd: (i) => print('swiped card $i'),
)
```

> ⚠️ `LuxuryCardWidget` mặc định dùng `Image.asset(item.image)` — bạn cần khai báo asset trong `pubspec.yaml` hoặc viết `cardBuilder` riêng (xem ví dụ "Custom builder" bên dưới).

---

## 2. `LuxuryCardStackView`

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `items` | `List<LuxuryCardItem>` | bắt buộc | Danh sách thẻ |
| `cardBuilder` | `Widget Function(context, item, index)` | bắt buộc | Render từng thẻ |
| `controller` | `LuxuryCardStackController?` | tự tạo | Inject để điều khiển từ ngoài |
| `visibleCount` | `int` | `3` | Số thẻ hiển thị cùng lúc (top + dưới) |
| `onSwipeEnd` | `ValueChanged<int>?` | `null` | Callback khi 1 thẻ được tiễn ra sau |

### Hành vi gesture (hardcoded threshold)

| Gesture | Hành vi |
|---|---|
| Drag ngang | Card top dịch theo cursor, các card dưới scale nhẹ |
| Thả với `|dx| > 120` hoặc `|velocity| > 900` | Drop animation → card top ra cuối stack |
| Thả không đủ ngưỡng | `SpringSimulation` (stiffness 360, damping 32) đưa về 0 |
| Drag dọc xuống | Card top trượt xuống tối đa 300px |
| Thả với `dy > 100` hoặc `velocityY > 900` | Drop → card top ra cuối |

> Card top dùng `dropY/dropScale/dropShadow`, card dưới dùng offset `index * 26` và scale `1 - index * 0.06`.

---

## 3. `LuxuryCardItem`

```dart
const LuxuryCardItem({
  required String image,    // asset path
  String? title,
  String? subtitle,
  String? tag,              // có field nhưng `LuxuryCardWidget` mẫu chưa render
});
```

Là dữ liệu thuần — bạn có thể bỏ qua nếu viết `cardBuilder` lấy data từ class khác.

---

## 4. `LuxuryCardStackController`

State + 2 `AnimationController`:
- `_dragAnim` (unbounded) → `dragX`
- `_dropAnim` (420ms easeIn) → `dropY`, `dropScale`, `dropShadow`

API public hữu ích:

| Method | Mục đích |
|---|---|
| `updateDrag(double dx)` | Cộng dồn `dragX` (gọi trong `onHorizontalDragUpdate`) |
| `updateVerticalDrag(double dy)` | Cộng dồn `dropY`, clamp [0, 300] |
| `snapBack(double velocity)` | Spring về `dragX = 0` |
| `snapBackVertical(double velocity)` | Spring về `dropY = 0` |
| `dropDown()` | Chạy drop animation đầy đủ + reset state |

Tự tạo controller nếu muốn auto-swipe từ ngoài:

```dart
class _MyState extends State<MyPage> with TickerProviderStateMixin {
  late final controller = LuxuryCardStackController(vsync: this);

  void _autoSwipe() async {
    await controller.dropDown();
  }
}
```

---

## 5. `LuxuryCardWidget` (card mẫu)

Card width = 80% màn hình, aspect 1.6, bo 28px, shadow đậm. Image render ở bên phải, text title/subtitle ở góc trên trái.

```dart
LuxuryCardWidget(
  item: LuxuryCardItem(
    image: 'assets/cars/porsche.png',
    title: 'Porsche 911',
    subtitle: 'GT3 RS · 525 hp',
  ),
)
```

Đây là **template gợi ý**, không bắt buộc — bạn có thể tự viết card khác và truyền vào `cardBuilder`.

---

## 6. Custom builder (không cần asset)

```dart
LuxuryCardStackView(
  items: [
    LuxuryCardItem(image: '', title: 'Card 1'),
    LuxuryCardItem(image: '', title: 'Card 2'),
    LuxuryCardItem(image: '', title: 'Card 3'),
  ],
  cardBuilder: (context, item, index) {
    final colors = [Colors.indigo, Colors.deepOrange, Colors.teal];
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 220,
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Text(item.title ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 28)),
    );
  },
)
```

---

## 7. Demo trực quan

Mở `LuxuryCardStackTestScreen` ([luxury_card_stack_test_screen.dart](luxury_card_stack_test_screen.dart)) — 3 tab:
- **Gradient** (custom builder, không cần asset)
- **Network** (cardBuilder dùng `Image.network`)
- **Controlled** (nút "Swipe next" gọi `controller.dropDown()` từ ngoài)
