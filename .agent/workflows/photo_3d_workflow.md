---
description: Quy trình xây dựng widget xem ảnh 3D với hiệu ứng Tilt/Parallax mượt mà
---

# Photo 3D Viewer Workflow

> **Mục tiêu**: Tạo một widget xem ảnh có hiệu ứng chiều sâu (3D), tự động nghiêng (tilt) theo hướng chạm/kéo của người dùng, tạo cảm giác ảnh đang nổi trong không gian 3D.

---

## Bước 1 – Công thức Matrix4 (3D Math)

Để tạo hiệu ứng nghiêng, ta sử dụng `Matrix4.identity()` kết hợp:
1. `setEntry(3, 2, 0.001)`: Tạo hiệu ứng phối cảnh (perspective).
2. `rotateX`: Nghiêng theo trục X (dựa trên vị trí Y của ngón tay).
3. `rotateY`: Nghiêng theo trục Y (dựa trên vị trí X của ngón tay).

---

## Bước 2 – Widget Photo3DViewer

Tạo file `lib/shared/widgets/photo_3d_viewer.dart`:

```dart
import 'package:flutter/material.dart';

/// [Photo3DViewer] là một widget hiển thị hình ảnh với hiệu ứng nghiêng 3D.
/// Khi người dùng chạm và kéo trên bề mặt ảnh, widget sẽ tính toán vị trí
/// để xoay ảnh theo các trục X và Y, kết hợp với hiệu ứng đổ bóng động
/// tạo cảm giác vật thể đang nổi và nghiêng thật sự trong không gian.
class Photo3DViewer extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double maxTilt; // Độ nghiêng tối đa (radians)

  const Photo3DViewer({
    super.key,
    required this.imageUrl,
    this.width = 300,
    this.height = 400,
    this.maxTilt = 0.5,
  });

  @override
  State<Photo3DViewer> createState() => _Photo3DViewerState();
}

class _Photo3DViewerState extends State<Photo3DViewer> with SingleTickerProviderStateMixin {
  /// [_offset] lưu trữ vị trí ngón tay so với tâm của widget (từ -1.0 đến 1.0).
  /// Giá trị này sẽ quyết định góc nghiêng và hướng của hiệu ứng ánh sáng.
  Offset _offset = Offset.zero;

  /// [AnimationController] giúp mượt mà hóa quá trình quay về trạng thái cân bằng
  /// khi người dùng buông tay, tránh hiện tượng ảnh bị giật cục.
  late AnimationController _resetCtrl;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          _offset = Offset.lerp(_offset, Offset.zero, _resetCtrl.value)!;
        });
      });
  }

  @override
  void dispose() {
    _resetCtrl.dispose();
    super.dispose();
  }

  /// [_onPanUpdate] tính toán tọa độ tương đối từ -1 đến 1 dựa trên kích thước widget.
  /// Việc chuẩn hóa này giúp logic nghiêng không phụ thuộc vào kích thước ảnh cụ thể.
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      _offset += Offset(
        details.delta.dx / (constraints.maxWidth / 2),
        details.delta.dy / (constraints.maxHeight / 2),
      );
      _offset = Offset(
        _offset.dx.clamp(-1.0, 1.0),
        _offset.dy.clamp(-1.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: (_) => _resetCtrl.forward(from: 0),
          child: AnimatedBuilder(
            animation: _resetCtrl,
            builder: (context, child) {
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Cực kỳ quan trọng để tạo chiều sâu
                  ..rotateX(-_offset.dy * widget.maxTilt) // Nghiêng dọc
                  ..rotateY(_offset.dx * widget.maxTilt), // Nghiêng ngang
                child: _buildCard(),
              );
            },
          ),
        );
      },
    );
  }

  /// [_buildCard] kết hợp hình ảnh với hiệu ứng đổ bóng và ánh sáng giả lập.
  /// Lớp Shadow sẽ thay đổi dựa trên [_offset] để tạo cảm giác nguồn sáng cố định.
  Widget _buildCard() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(_offset.dx * 20, _offset.dy * 20),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.imageUrl, fit: BoxFit.cover),
            
            // Lớp phủ ánh sáng (Glare effect)
            _buildGlareOverlay(),
          ],
        ),
      ),
    );
  }

  /// [_buildGlareOverlay] tạo một lớp gradient mờ chạy theo hướng nghiêng.
  /// Đây là chi tiết nhỏ nhưng giúp "đánh lừa" thị giác, làm ảnh trông như có lớp kính.
  Widget _buildGlareOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-_offset.dx, -_offset.dy),
          end: Alignment(_offset.dx, _offset.dy),
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
```

---

## Bước 3 – Sử dụng (Usage)

Tích hợp vào bất kỳ màn hình nào:

```dart
Photo3DViewer(
  imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
  width: MediaQuery.of(context).size.width * 0.8,
)
```

---

## Ghi chú mở rộng

- **Parallax nhiều lớp**: Sử dụng Stack với nhiều lớp ảnh, mỗi lớp có `maxTilt` khác nhau để tạo cảm giác 3D thật sự (background nghiêng ít, foreground nghiêng nhiều).
- **Cảm biến Gyroscope**: Dùng package `sensors_plus` để lấy dữ liệu cảm biến thay vì chạm tay (nghiêng điện thoại ảnh tự nghiêng).
- **Border sáng**: Thêm `Border.all` với màu trắng mờ để làm nổi bật cạnh của ảnh khi nghiêng.
