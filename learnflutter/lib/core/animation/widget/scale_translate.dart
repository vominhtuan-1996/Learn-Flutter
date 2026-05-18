import 'package:flutter/material.dart';
import 'package:learnflutter/core/utils/device_dimension.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì Widget)
 * ============================================================================
 * 
 * 1. KIỂM TRA TRẠNG THÁI (PageController Safety):
 *    - QUY TẮC: Luôn kiểm tra `pageController.position.haveDimensions` trước khi 
 *      truy cập vào thuộc tính `page`. Nếu không, ứng dụng sẽ crash khi 
 *      `PageController` chưa được gắn (attach) vào bất kỳ PageView nào.
 * 
 * 2. HIỆU NĂNG TRANSFORM (Efficient Transformations):
 *    - QUY TẮC: Sử dụng `Transform` để thực hiện các biến đổi về Scale và Rotation 
 *      vì nó được thực hiện ở mức layer vẽ, không làm thay đổi layout của các 
 *      widget xung quanh, giúp tối ưu hiệu năng.
 * 
 * 3. TÍNH LINH HOẠT (Custom Transformation Logic):
 *    - ĐỊNH HƯỚNG: Trong tương lai, có thể cung cấp một `transformationBuilder` 
 *      (callback) để người dùng tự định nghĩa logic biến đổi (Fade, 3D Flip, 
 *      v.v.) dựa trên giá trị `value` thay vì hardcode `scale` và `rotateY`.
 * ============================================================================
 */

class ScaleTranslateBuilder extends StatefulWidget {
  const ScaleTranslateBuilder(
      {super.key, required this.index, required this.pageController, required this.child});
  final int index;
  final PageController pageController;
  final Widget child;
  @override
  State<ScaleTranslateBuilder> createState() => _ScaleTranslateBuilderState();
}

class _ScaleTranslateBuilderState extends State<ScaleTranslateBuilder> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double value = 1.0;
        if (widget.pageController.position.haveDimensions) {
          value = widget.pageController.page! - widget.index;
          value = (1 - (value.abs())).clamp(0.0, 1.0);
        }
        return Container(
          padding: EdgeInsets.all(DeviceDimension.padding / 2),
          child: Transform(
            transform: Matrix4.identity()
              ..scale(value)
              ..rotateY(value * 0.2),
            child: widget.child,
          ),
        );
      },
    );
  }
}
