import 'package:flutter/material.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy trì bảo trì Widget)
 * ============================================================================
 * 
 * 1. TỐI ƯU VẼ (Repaint Optimization):
 *    - QUY TẮC: Với các animation chạy liên tục và có nhiều layer đè lên nhau 
 *      như Ripple, luôn bọc bằng `RepaintBoundary`. Điều này giúp Flutter tách 
 *      phần animation này thành một layer riêng, tránh repaint lại toàn bộ 
 *      các thành phần tĩnh khác trên màn hình.
 * 
 * 2. CẤU HÌNH LINH HOẠT (Customizable Ripples):
 *    - ĐỊNH HƯỚNG: Chuyển các giá trị hardcode (50, 100, 150...) và số lượng 
 *      vòng tròn thành tham số để người dùng có thể điều chỉnh độ rộng và 
 *      mật độ của Ripple.
 * 
 * 3. QUẢN LÝ TRẠNG THÁI (Auto-start Control):
 *    - ĐỊNH HƯỚNG: Thêm thuộc tính `animate` (bool) để cho phép dừng/chạy 
 *      animation từ bên ngoài (ví dụ: chỉ chạy khi Widget đang hiển thị).
 * 
 * 4. TƯƠNG THÍCH THEME:
 *    - QUY TẮC: Màu sắc mặc định nên lấy từ `ThemeData` để đảm bảo tính nhất quán.
 * ============================================================================
 */

class RippleAnimationWidget extends StatefulWidget {
  const RippleAnimationWidget({super.key});
  @override
  State<RippleAnimationWidget> createState() => RippleAnimationWidgetState();
}

class RippleAnimationWidgetState extends State<RippleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 1500),
    );
    // ..repeat();

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_controller);

    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 50, end: 30),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 30, end: 50),
          weight: 50,
        )
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0.0, 0.2, 1.0)),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildContainer(50 * _controller.value),
              _buildContainer(100 * _controller.value),
              _buildContainer(150 * _controller.value),
              _buildContainer(200 * _controller.value),
              _buildContainer(250 * _controller.value),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContainer(double radius) {
    return ClipOval(
      child: Container(
        width: radius,
        height: radius / 2,
        color: _colorAnimation.value?.withOpacity(1 - _controller.value),
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   color: _colorAnimation.value?.withOpacity(1 - _controller.value),
        // ),
      ),
    );
  }
}
