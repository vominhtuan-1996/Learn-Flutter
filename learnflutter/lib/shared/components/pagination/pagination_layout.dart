import 'package:flutter/material.dart';

/// [PaginationLayout] cung cấp các hiệu ứng chuyển cảnh và layout bổ trợ cho hệ thống phân trang.
class PaginationLayout {
  /// Tạo hiệu ứng thu phóng và mờ dần (Scale & Opacity) dựa trên khoảng cách cuộn (offset).
  /// [offset] là giá trị chênh lệch giữa vị trí hiện tại của PageController và index của item.
  static Widget animatedItem({
    required double offset,
    required Widget child,
    double minScale = 0.95,
  }) {
    // Giá trị t từ 0.0 (xa) đến 1.0 (ngay giữa màn hình)
    final t = (1 - offset.abs()).clamp(0.0, 1.0);

    return Transform.scale(
      scale: minScale + ((1 - minScale) * t),
      child: Opacity(
        opacity: t,
        child: child,
      ),
    );
  }

  /// Tạo hiệu ứng Parallax (phông nền chuyển động chậm hơn nội dung).
  static Widget parallaxItem({
    required double offset,
    required Widget child,
    double parallaxFactor = 0.5,
  }) {
    return Transform.translate(
      offset: Offset(0, offset * 100 * parallaxFactor),
      child: child,
    );
  }

  /// Layout cho Header có khả năng thu gọn linh hoạt.
  static Widget collapsibleHeader({
    required double t, // 0.0 to 1.0
    required double maxHeight,
    required Widget child,
  }) {
    return SizedBox(
      height: maxHeight * t,
      child: Opacity(
        opacity: t,
        child: child,
      ),
    );
  }

  /// Hiệu ứng 3D Cube (Khối lập phương xoay).
  /// Thường dùng cho scrollDirection: Axis.horizontal.
  static Widget cube3D({
    required double offset,
    required Widget child,
  }) {
    final isLeaving = offset <= 0 && offset > -1;
    final isEntering = offset > 0 && offset < 1;

    // Tính toán góc xoay (90 độ = PI/2)
    final double rotation = (offset * (3.1415926535897932 / 2));

    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateY(rotation),
      child: child,
    );
  }

  /// Hiệu ứng Depth (Chiều sâu).
  /// Trang đang rời đi sẽ mờ và nhỏ dần, trang mới sẽ đè lên.
  static Widget depthEffect({
    required double offset,
    required Widget child,
  }) {
    if (offset <= 0) {
      // Trang hiện tại đang ở giữa hoặc đang trượt sang trái
      return child;
    } else if (offset <= 1) {
      // Trang mới đang trượt vào từ bên phải
      final double scale = 0.75 + (0.25 * (1 - offset));
      final double opacity = 1 - offset;

      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    }
    return child;
  }

  /// Hiệu ứng Stack (Xếp chồng).
  /// Trang cũ đứng yên, trang mới trượt đè lên.
  static Widget stackEffect({
    required double offset,
    required Widget child,
  }) {
    if (offset <= 0) {
      // Đứng yên
      return Transform.translate(
        offset: Offset.zero,
        child: child,
      );
    } else {
      // Trượt vào
      return child;
    }
  }

  /// Hiệu ứng Zoom & Rotate.
  static Widget zoomRotate({
    required double offset,
    required Widget child,
  }) {
    final t = (1 - offset.abs()).clamp(0.0, 1.0);
    final scale = 0.5 + (0.5 * t);
    final rotation = (1 - t) * 0.5;

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(opacity: t, child: child),
      ),
    );
  }

  /// Hiệu ứng Wheel (Vòng quay hình trụ).
  static Widget wheel({
    required double offset,
    required Widget child,
  }) {
    // Xoay quanh trục Y với perspective
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(offset * 0.8),
      child: child,
    );
  }

  /// Hiệu ứng Flip (Lật thẻ 3D).
  static Widget flip({
    required double offset,
    required Widget child,
  }) {
    final angle = offset * 3.14159; // PI
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle),
      child: Opacity(
        opacity: (1 - offset.abs().clamp(0.0, 0.5) * 2),
        child: child,
      ),
    );
  }

  /// Hiệu ứng Skew (Nghiêng phối cảnh).
  static Widget skew({
    required double offset,
    required Widget child,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..setEntry(0, 1, offset * 0.3), // Thay thế skewX bằng setEntry
      child: child,
    );
  }

  /// Hiệu ứng Cover Flow (Phong cách Apple classic).
  static Widget coverFlow({
    required double offset,
    required Widget child,
  }) {
    final double t = offset.abs();
    final double scale = 1 - (t * 0.2);
    final double rotation = offset.clamp(-1.0, 1.0) * -0.5;
    final double translate = offset * 40;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(translate)
        ..scale(scale)
        ..rotateY(rotation),
      child: child,
    );
  }

  /// Hiệu ứng Accordion (Gấp như đàn phong cầm).
  static Widget accordion({
    required double offset,
    required Widget child,
  }) {
    return Transform(
      alignment: offset < 0 ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..scale(1 - offset.abs(), 1.0),
      child: child,
    );
  }

  /// Hiệu ứng Door (Cánh cửa 3D).
  static Widget door3D({
    required double offset,
    required Widget child,
  }) {
    final double t = offset.abs();
    final double rotation = offset.clamp(-1.0, 1.0) * (3.14159 / 2); // 90 deg

    return Transform(
      alignment: offset < 0 ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      child: Opacity(
        opacity: (1 - t).clamp(0.0, 1.0),
        child: child,
      ),
    );
  }

  /// Hiệu ứng Perspective Vertical (Nghiêng dọc theo phương ngang).
  static Widget perspectiveVertical({
    required double offset,
    required Widget child,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(offset * 0.5),
      child: child,
    );
  }

  /// Hiệu ứng Fan (Xòe quạt 3D).
  static Widget fan3D({
    required double offset,
    required Widget child,
  }) {
    final double t = offset.abs();
    final double rotation = offset * 0.4;
    final double translationY = t * 50;

    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(rotation)
        ..translate(0.0, translationY, 0.0),
      child: Opacity(
        opacity: (1 - t * 0.5).clamp(0.0, 1.0),
        child: child,
      ),
    );
  }

  /// Hiệu ứng Tunnel (Đường hầm 3D).
  static Widget tunnel3D({
    required double offset,
    required Widget child,
  }) {
    final double t = offset.abs();
    final double scale = 1 - (t * 0.8);
    final double opacity = 1 - t;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..scale(scale.clamp(0.1, 1.0)),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: child,
      ),
    );
  }
}
