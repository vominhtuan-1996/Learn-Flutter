import 'package:flutter/material.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì Widget)
 * ============================================================================
 * 
 * 1. TÍNH TÁI SỬ DỤNG (High Reusability):
 *    - QUY TẮC: Các thuộc tính như `Duration`, `Color`, `Curve` nên được truyền qua 
 *      Constructor thay vì hardcode. Điều này giúp Widget linh hoạt hơn.
 * 
 * 2. TỐI ƯU REBUILD (AnimatedBuilder Optimization):
 *    - QUY TẮC: Luôn sử dụng `AnimatedBuilder` để chỉ vẽ lại những phần thực sự 
 *      thay đổi (như kích thước, màu sắc). Tránh gọi `setState` cho toàn bộ widget 
 *      lớn nếu chỉ có một icon đang chuyển động.
 * 
 * 3. QUẢN LÝ TÀI NGUYÊN (Resource Disposal):
 *    - QUY TẮC: Bắt buộc phải có `_animationController.dispose()`. Các widget 
 *      animation lặp lại (repeat) nếu không được dispose sẽ chạy ngầm vĩnh viễn.
 * 
 * 4. HỖ TRỢ ACCESSIBILITY (Screen Reader Support):
 *    - ĐỊNH HƯỚNG: Bổ sung nhãn `semanticLabel` cho các icon đang animation để 
 *      người khiếm thị vẫn hiểu được trạng thái (VD: "Đang xoay", "Đã thích").
 * 
 * 5. TƯƠNG THÍCH THEME (Theme Integration):
 *    - ĐỊNH HƯỚNG: Màu sắc mặc định nên lấy từ `Theme.of(context).primaryColor` 
 *      thay vì `Colors.red` để tự động khớp với brand của ứng dụng.
 * ============================================================================
 */

class IconAnimationWidget extends StatefulWidget {
  const IconAnimationWidget({super.key, this.isRotate = false, this.icon = Icons.favorite_sharp});
  final bool isRotate;
  final IconData icon;
  @override
  State<IconAnimationWidget> createState() => IconAnimationWidgetState();
}

class IconAnimationWidgetState extends State<IconAnimationWidget>
    with SingleTickerProviderStateMixin {
  bool isFav = false;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    if (widget.isRotate) {
      _animationController.repeat(reverse: true);
      _animationController.duration = const Duration(milliseconds: 600);
    }

    _colorAnimation =
        ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_animationController);

    if (widget.isRotate) {
      _sizeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.decelerate,
        ),
      );
    } else {
      _sizeAnimation = TweenSequence(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween(begin: 30, end: 50),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween(begin: 50, end: 30),
            weight: 50,
          )
        ],
      ).animate(_animationController);
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isFav = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isFav = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRotate
        ? Container(
            alignment: Alignment.topCenter,
            child: RotationTransition(
              turns: _sizeAnimation,
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_on_rounded,
                  size: 60,
                  color: Colors.red,
                ),
                onPressed: () {},
              ),
            ))
        : AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    isFav ? _animationController.reverse() : _animationController.forward();
                  },
                  icon: Icon(
                    widget.icon,
                    color: _colorAnimation.value,
                    size: _sizeAnimation.value,
                  ));
            },
          );
  }
}
