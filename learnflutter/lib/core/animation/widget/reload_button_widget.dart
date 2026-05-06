import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì Widget)
 * ============================================================================
 * 
 * 1. TRÁNG MUTATING WIDGET (Don't Mutate Widget Properties):
 *    - QUY TẮC: TUYỆT ĐỐI KHÔNG gán lại giá trị cho các thuộc tính của `widget` 
 *      (VD: `widget.isRotate = true`). Các thuộc tính này phải là `final`. 
 *      Hãy sử dụng một biến trạng thái nội bộ trong `State` để quản lý.
 * 
 * 2. KÍCH HOẠT ANIMATION (Animation Triggering):
 *    - QUY TẮC: Không bao giờ gọi `controller.repeat()` hoặc `forward()` trực tiếp 
 *      trong hàm `build`. Hàm `build` có thể được hệ thống gọi lại bất cứ lúc nào, 
 *      dẫn đến việc animation bị khởi tạo lại liên tục. 
 *    - GIẢI PHÁP: Kích hoạt trong `initState`, `didUpdateWidget` hoặc các hàm xử lý sự kiện.
 * 
 * 3. TÁCH BIỆT LOGIC (Logic Separation):
 *    - ĐỊNH HƯỚNG: Tách logic tính toán `Tween` ra khỏi hàm `build` và đưa vào 
 *      `initState` hoặc sử dụng `memoization` để tránh khởi tạo lại Object mỗi frame.
 * 
 * 4. TÙY BIẾN GIAO DIỆN:
 *    - ĐỊNH HƯỚNG: Cho phép truyền `loadingColor` và `successColor` để widget 
 *      có thể dùng cho nhiều loại trạng thái khác nhau.
 * ============================================================================
 */

class ReloadButtonWidget extends StatefulWidget {
  const ReloadButtonWidget({super.key, this.isRotate = false, this.icon = Icons.refresh});
  final bool isRotate;
  final IconData icon;
  @override
  State<ReloadButtonWidget> createState() => ReloadButtonWidgetState();
}

class ReloadButtonWidgetState extends State<ReloadButtonWidget>
    with SingleTickerProviderStateMixin {
  late bool _isRotating;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isRotating = widget.isRotate;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    if (_isRotating) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ReloadButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRotate != oldWidget.isRotate) {
      setState(() {
        _isRotating = widget.isRotate;
        if (_isRotating) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.primary),
        color: AppColors.primary,
      ),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: IconButton(
          icon: Icon(
            widget.icon,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isRotating = !_isRotating;
              if (_isRotating) {
                _animationController.repeat();
              } else {
                _animationController.stop();
              }
            });
          },
        ),
      ),
    );
  }
}
