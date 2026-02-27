---
description: Quy trình xây dựng hiệu ứng 3D Offline sử dụng Depth Map (Bản đồ độ sâu)
---

# Offline Depth Map 3D Workflow

> **Cơ chế**: Thay vì nghiêng toàn bộ tấm ảnh (2.5D), giải pháp này chia tấm ảnh thành hàng ngàn "điểm ảnh" có độ sâu khác nhau dựa trên một **Depth Map**. Khi nghiêng điện thoại, các vùng có độ sâu khác nhau sẽ dịch chuyển với biên độ khác nhau (Parallax), tạo ra cảm giác không gian 3D thực thụ mà không cần Cloud.

---

## Bước 1 – Chuẩn bị Dữ liệu (Offline ML)

Để chạy offline, bạn cần một mô hình AI nhẹ (ví dụ: **MiDaS v2.1 Small**) chuyển đổi từ ảnh 2D sang Depth Map.

- **Input**: Ảnh 2D (RGB).
- **ML Model**: Chạy qua `tflite_flutter`.
- **Output**: Một mảng giá trị từ 0 (xa) đến 255 (gần) cho mỗi pixel.

---

## Bước 2 – Widget Depth3DViewer (Logic hiển thị)

Tạo file `lib/shared/widgets/depth_3d_viewer.dart`. Do Flutter không hỗ trợ Shader phức tạp mặc định một cách dễ dàng, ta sẽ sử dụng kỹ thuật **Layer Displacement**.

```dart
import 'package:flutter/material.dart';

/// [Depth3DViewer] mô phỏng hiệu ứng Depth Map bằng cách chia ảnh thành 
/// 2 lớp (Foreground & Background) dựa trên thông tin độ sâu.
/// Khi người dùng tương tác, lớp Foreground sẽ dịch chuyển mạnh hơn lớp 
/// Background, tạo ra hiệu ứng Parallax (thị sai) chiều sâu cực kỳ chân thực.
class Depth3DViewer extends StatefulWidget {
  final Widget foreground;
  final Widget background;
  final double depthFactor; // Độ mạnh của hiệu ứng (mặc định 20.0)

  const Depth3DViewer({
    super.key,
    required this.foreground,
    required this.background,
    this.depthFactor = 20.0,
  });

  @override
  State<Depth3DViewer> createState() => _Depth3DViewerState();
}

class _Depth3DViewerState extends State<Depth3DViewer> with SingleTickerProviderStateMixin {
  Offset _pointer = Offset.zero;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    /// Sử dụng [LayoutBuilder] để xác định giới hạn dịch chuyển dựa trên kích thước màn hình.
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) {
            setState(() {
              _pointer += Offset(
                d.delta.dx / constraints.maxWidth,
                d.delta.dy / constraints.maxHeight,
              );
              _pointer = Offset(_pointer.dx.clamp(-1.0, 1.0), _pointer.dy.clamp(-1.0, 1.0));
            });
          },
          onPanEnd: (_) {
            final start = _pointer;
            final anim = Tween<Offset>(begin: start, end: Offset.zero).animate(
              CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
            );
            _ctrl.forward(from: 0).then((_) => _pointer = Offset.zero);
            _ctrl.addListener(() => _pointer = anim.value);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Lớp 1: Background - Dịch chuyển ít (xa camera)
              Transform.translate(
                offset: _pointer * (widget.depthFactor * 0.5),
                child: widget.background,
              ),
              
              // Lớp 2: Foreground - Dịch chuyển nhiều (gần camera)
              Transform.translate(
                offset: _pointer * (widget.depthFactor * 1.5),
                child: widget.foreground,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Bước 3 – Tích hợp Offline Depth Estimation

Để có được 2 lớp (Foreground/Background) tự động từ 1 tấm ảnh chụp:

1. **Sử dụng ML Kit Selfie Segmentation**: Tách người ra khỏi nền (Foreground).
2. **Xử lý ảnh**:
   - Ảnh gốc cắt bỏ phần người = **Background**.
   - Phần người đã tách = **Foreground**.
3. **Hiển thị**: Đưa 2 kết quả này vào `Depth3DViewer`.

---

## Ưu điểm của giải pháp này

- **100% Offline**: Không cần gửi ảnh lên server, đảm bảo quyền riêng tư tuyệt đối.
- **Tốc độ**: ML Kit Segmentation chạy cực nhanh trên chip NPU của điện thoại (Real-time).
- **Trải nghiệm**: Hiệu ứng Parallax cho cảm giác không gian 3D "sâu" hơn nhiều so với việc chỉ nghiêng ảnh phẳng (Tilt).

---

## Ghi chú nâng cao (Shader)

Đối với các thiết bị cao cấp, ta có thể dùng **Fragment Shader** (`.frag` file) để đọc file Depth Map (ảnh trắng đen):
- Shader sẽ đọc từng pixel.
- Nếu pixel tại tọa độ (x,y) của ảnh Depth Map có màu trắng (gần) -> Dịch chuyển Pixel (x,y) của ảnh RGB nhiều hơn.
- Nếu là màu đen (xa) -> Dịch chuyển ít hơn.
- Kết quả: Toàn bộ tấm ảnh uốn lượn mượt mà theo độ sâu của từng vật thể.
