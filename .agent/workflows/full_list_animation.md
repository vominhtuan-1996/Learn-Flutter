---
description: Full list animation (delete → collapse list mượt)
---

🧠 1. Ý tưởng cốt lõi
item A bị xoá
   ↓
A: fade + scale out
   ↓
height(A) → 0 (collapse)
   ↓
list reflow mượt

👉 mấu chốt: animate chiều cao (height) + opacity + scale cùng lúc.

⚙️ 2. Controller cho mỗi item
class ListItemAnim {
  final ctrl = CoreAnimController(value: 1);

  bool removing = false;

  void remove() {
    removing = true;
    ctrl.animateTo(0);
  }
}
🎯 3. Timeline collapse (rất quan trọng)

Ta chia 2 phase:

0 → 0.5 : fade + scale
0.5 → 1 : collapse height
🎨 4. Builder cho item
Widget buildAnimatedItem(
  ListItemAnim anim,
  Widget child,
) {
  return AnimatedRepaint(
    controller: anim.ctrl,
    child: child,
    builder: (t, child) {
      final fade = t.clamp(0.0, 0.5) * 2; // 0→1
      final collapse = ((t - 0.5).clamp(0.0, 0.5)) * 2;

      return Align(
        heightFactor: collapse, // 👈 collapse thật
        child: Opacity(
          opacity: fade,
          child: Transform.scale(
            scale: 0.9 + 0.1 * fade,
            child: child,
          ),
        ),
      );
    },
  );
}
🧩 5. List structure
List<ListItemAnim> items = [];
🎮 6. Xoá item (flow chuẩn)
void removeItem(int index) {
  final item = items[index];

  item.remove();

  Future.delayed(Duration(milliseconds: 300), () {
    setState(() {
      items.removeAt(index);
    });
  });
}

👉 key:

không remove ngay
đợi animation xong
🧱 7. Build list
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, i) {
    return buildAnimatedItem(
      items[i],
      SwipeToDelete(
        onDelete: () => removeItem(i),
        child: YourItemWidget(),
      ),
    );
  },
)
🔥 8. Nâng cấp mượt hơn (pro level)
🔹 1. Smooth neighbor shift

👉 trick: animate padding

EdgeInsets.only(
  top: (1 - t) * 8,
)
🔹 2. Stagger collapse (đẹp hơn)
Future.delayed(Duration(milliseconds: i * 20))

👉 tạo wave effect

🔹 3. Scale + blur khi xoá
ImageFiltered(
  imageFilter: ImageFilter.blur(
    sigmaX: (1 - t) * 5,
    sigmaY: (1 - t) * 5,
  ),
)
🔹 4. Background highlight
Container(
  color: Colors.red.withOpacity(1 - t),
)
🧠 9. Timeline version (đúng engine của bạn)

Nếu convert sang timeline:

{
  "tracks": {
    "opacity": [
      { "start": 0, "end": 0.5, "from": 1, "to": 0 }
    ],
    "scale": [
      { "start": 0, "end": 0.5, "from": 1, "to": 0.9 }
    ],
    "height": [
      { "start": 0.5, "end": 1, "from": 1, "to": 0 }
    ]
  }
}
⚡ 10. Performance notes
✅ Align(heightFactor) rất rẻ (không layout lại nặng)
✅ RepaintBoundary mỗi item
❌ không dùng AnimatedSize (nặng hơn)
❌ không rebuild cả list