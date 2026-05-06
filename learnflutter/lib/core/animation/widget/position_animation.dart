import 'package:flutter/material.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì Widget)
 * ============================================================================
 * 
 * 1. TƯƠNG THÍCH LAYOUT (Layout Responsiveness):
 *    - QUY TẮC: Luôn sử dụng `LayoutBuilder` để lấy kích thước thực tế của parent 
 *      (`constraints.biggest`) trước khi tính toán `RelativeRect`. Điều này đảm 
 *      bảo animation hoạt động đúng trên mọi kích thước màn hình.
 * 
 * 2. LỰA CHỌN WIDGET (PositionedTransition vs AnimatedPositioned):
 *    - QUY TẮC: Sử dụng `PositionedTransition` khi cần kiểm soát chính xác 
 *      qua `AnimationController` (VD: repeat, reverse). Nếu chỉ cần di chuyển 
 *      một lần dựa trên state, hãy cân nhắc dùng `AnimatedPositioned` (Implicit) 
 *      để giảm bớt code boilerplate.
 * 
 * 3. TÍNH LINH HOẠT (Child Customization):
 *    - ĐỊNH HƯỚNG: Chuyển `FlutterLogo` thành một tham số `child` trong Constructor 
 *      để widget có thể di chuyển bất kỳ thành phần nào (Avatar, Button, v.v.).
 * 
 * 4. QUẢN LÝ TICKER:
 *    - QUY TẮC: Sử dụng `TickerProviderStateMixin` thay vì `SingleTickerProviderStateMixin` 
 *      nếu trong tương lai bổ sung thêm các controller khác cho cùng một widget.
 * ============================================================================
 */

class PositionedTransitionWidget extends StatefulWidget {
  const PositionedTransitionWidget({super.key});

  @override
  State<PositionedTransitionWidget> createState() => _PositionedTransitionWidgetState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _PositionedTransitionWidgetState extends State<PositionedTransitionWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double smallLogo = 100;
    const double bigLogo = 200;
    // _controller.repeat(reverse: true);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size biggest = constraints.biggest;
        return Stack(
          children: <Widget>[
            PositionedTransition(
              rect: RelativeRectTween(
                begin: RelativeRect.fromSize(
                  const Rect.fromLTWH(0, 0, smallLogo, smallLogo),
                  biggest,
                ),
                end: RelativeRect.fromSize(
                  Rect.fromLTWH(
                      biggest.width - bigLogo, biggest.height - bigLogo, bigLogo, bigLogo),
                  biggest,
                ),
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticInOut,
              )),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: FlutterLogo(),
              ),
            ),
          ],
        );
      },
    );
  }
}
