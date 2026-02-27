import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/sliver_appbar/balance_bar.dart';

const double _kRadius = 12;

/// BalanceBarView là một widget phức tạp sử dụng CustomPainter để vẽ một nền thẻ ngân hàng/số dư tinh tế.
/// Nó kết hợp các hiệu ứng đổ bóng, gradient và các đường cong Bezier để tạo ra giao diện người dùng cao cấp.
/// Widget này bao gồm nhiều lớp vẽ khác nhau: vùng số dư, bóng đổ và vùng quản lý quỹ.
class BalanceBarView extends StatelessWidget {
  const BalanceBarView({
    super.key,
    required this.contentPadding,
    required this.borderRadius,
  });

  /// Khoảng cách đệm cho nội dung hiển thị trên thanh số dư.
  final EdgeInsetsGeometry contentPadding;

  /// Cấu hình bo góc cho vùng chứa thanh số dư.
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CardPainter(),
      child: Padding(
        padding: contentPadding,
        child: const BalanceBar(contentAlignment: Alignment.topCenter),
      ),
    );
  }
}

/// _CardPainter thực hiện việc vẽ thủ công các thành phần đồ họa của thẻ số dư.
/// Lớp này quản lý việc vẽ gradient cho vùng số dư, hiệu ứng đổ bóng và vùng quỹ phụ.
/// Các phương thức được chia nhỏ để dễ dàng tinh chỉnh từng phần của bản vẽ.
class _CardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    paintBalanceArea(canvas, size);
    paintBalanceShadow(canvas, size);
    paintFundsArea(canvas, size);
    // paintDotLine(canvas, size);
    // paintActionArea(canvas, size);
  }

  /// Vẽ vùng hiển thị số dư chính với hiệu ứng gradient từ đỏ sang hồng.
  /// Sử dụng quadraticBezierTo để tạo các góc bo mượt mà và chuyển tiếp hình học.
  void paintBalanceArea(Canvas canvas, Size size) {
    final stopY = size.height;
    final halfX = size.width / 2;
    final startY = stopY - BalanceBar.height;

    final rect = Rect.fromLTWH(0, startY, halfX, BalanceBar.height);
    final Shader shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.red,
        Colors.pink,
      ],
    ).createShader(rect);

    final path = Path()
      ..moveTo(0, startY)
      ..quadraticBezierTo(0, startY, _kRadius, startY)
      ..lineTo(halfX - _kRadius, startY)
      ..quadraticBezierTo(
          halfX, startY, halfX + 5, startY + BalanceBar.height / 2)
      ..quadraticBezierTo(
          halfX + 10, stopY, halfX + BalanceBar.height / 2, stopY)
      ..lineTo(_kRadius, stopY)
      ..quadraticBezierTo(0, stopY, 0, stopY)
      ..close();

    final paint = Paint()..shader = shader;

    canvas.drawPath(path, paint);
  }

  /// Vẽ hiệu ứng đổ bóng cho vùng số dư để tạo độ sâu cho giao diện.
  /// Sử dụng MaskFilter.blur để làm mềm các cạnh của bóng đổ.
  void paintBalanceShadow(Canvas canvas, Size size) {
    final stopY = size.height;
    final halfX = (size.width / 2);
    final startY = stopY - BalanceBar.height;

    final path = Path()
      ..moveTo(2, startY - _kRadius)
      ..quadraticBezierTo(0, startY, _kRadius, startY)
      ..lineTo(halfX - _kRadius, startY)
      ..quadraticBezierTo(
          halfX, startY, halfX + 2, startY + BalanceBar.height / 2)
      ..quadraticBezierTo(
          halfX + 10, stopY, halfX + BalanceBar.height / 2, stopY)
      ..lineTo(halfX + BalanceBar.height / 2, startY - _kRadius)
      ..lineTo(0, startY - _kRadius)
      ..close();

    final shadowPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    const shadowOffset = Offset(1, 2);
    canvas.drawPath(path.shift(shadowOffset), shadowPaint);
  }

  /// Vẽ vùng quản lý quỹ nằm ở phía bên phải của thẻ.
  /// Vùng này sử dụng gradient xanh để tạo sự phân biệt rõ ràng với phần số dư chính.
  void paintFundsArea(Canvas canvas, Size size) {
    final stopX = size.width;
    final stopY = size.height;
    final startY = size.height - BalanceBar.height;
    final halfX = size.width / 2;

    final rect = Rect.fromLTWH(halfX, startY, halfX, BalanceBar.height);
    final Shader shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue,
        Color(0xFFFAFAFA),
      ],
    ).createShader(rect);

    final paint = Paint()..shader = shader;

    final path = Path()
      ..moveTo(halfX - _kRadius, startY)
      ..quadraticBezierTo(
          halfX, startY, halfX + 5, startY + BalanceBar.height / 2)
      ..quadraticBezierTo(halfX + 10, stopY, halfX + 10 + _kRadius, stopY)
      ..lineTo(stopX - _kRadius, stopY)
      ..quadraticBezierTo(stopX, stopY, stopX, stopY - _kRadius)
      ..lineTo(stopX, startY)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
