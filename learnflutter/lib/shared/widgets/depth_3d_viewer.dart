import 'package:flutter/material.dart';

/// [Depth3DViewer] là một widget chuyên dụng để mô phỏng không gian 3D thông qua
/// hiệu ứng Parallax (thị sai). Thay vì xoay toàn bộ ảnh, widget này chia nội dung
/// thành nhiều lớp (Layer) và dịch chuyển chúng với biên độ khác nhau khi người dùng
/// tương tác, tạo ra cảm giác vật thể có độ sâu thực sự (Depth Perception).
class Depth3DViewer extends StatefulWidget {
  /// [backgroundImage]: Thường là cảnh vật ở xa, sẽ dịch chuyển ít hơn.
  final Widget backgroundImage;

  /// [foregroundImage]: Thường là chủ thể ở gần, sẽ dịch chuyển nhiều hơn.
  final Widget foregroundImage;

  /// [depth]: Hệ số độ sâu, càng cao thì hiệu ứng Parallax càng mạnh.
  final double depth;

  const Depth3DViewer({
    super.key,
    required this.backgroundImage,
    required this.foregroundImage,
    this.depth = 25.0,
  });

  @override
  State<Depth3DViewer> createState() => _Depth3DViewerState();
}

class _Depth3DViewerState extends State<Depth3DViewer>
    with SingleTickerProviderStateMixin {
  /// [_pointer] lưu tọa độ tương đối của điểm chạm (từ -1.0 đến 1.0).
  Offset _pointer = Offset.zero;

  /// [AnimationController] giúp đưa các lớp ảnh về trạng thái cân bằng mượt mà
  /// sau khi người dùng ngừng tương tác.
  late AnimationController _restoreCtrl;
  late Animation<Offset> _restoreAnim;

  @override
  void initState() {
    super.initState();
    _restoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _restoreAnim = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _restoreCtrl, curve: Curves.easeOutBack),
    );

    _restoreCtrl.addListener(() {
      setState(() => _pointer = _restoreAnim.value);
    });
  }

  @override
  void dispose() {
    _restoreCtrl.dispose();
    super.dispose();
  }

  /// [_onPanUpdate] tính toán delta dịch chuyển và chuẩn hóa tọa độ.
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_restoreCtrl.isAnimating) _restoreCtrl.stop();
    setState(() {
      _pointer += Offset(
        details.delta.dx / (constraints.maxWidth / 2),
        details.delta.dy / (constraints.maxHeight / 2),
      );
      _pointer =
          Offset(_pointer.dx.clamp(-1.0, 1.0), _pointer.dy.clamp(-1.0, 1.0));
    });
  }

  /// [_onPanEnd] kích hoạt animation trả về vị trí gốc.
  void _onPanEnd(DragEndDetails details) {
    _restoreAnim = Tween<Offset>(
      begin: _pointer,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _restoreCtrl, curve: Curves.easeOutBack));
    _restoreCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Lớp NỀN (Background): Dịch chuyển NGƯỢC hướng và biên độ NHỎ (0.4x)
              // Tạo cảm giác nền ở rất xa phía sau.
              Transform.translate(
                offset: Offset(-_pointer.dx * widget.depth * 0.4,
                    -_pointer.dy * widget.depth * 0.4),
                child: widget.backgroundImage,
              ),

              // Lớp CHỦ THỂ (Foreground): Dịch chuyển THUẬN hướng và biên độ LỚN (1.2x)
              // Tạo cảm giác chủ thể nổi hẳn lên phía trước mặt người xem.
              Transform.translate(
                offset: Offset(_pointer.dx * widget.depth * 1.2,
                    _pointer.dy * widget.depth * 1.2),
                child: widget.foregroundImage,
              ),

              // Lớp PHỦ ÁNH SÁNG (Dynamic Light): Tăng cường hiệu ứng bóng đổ khi nghiêng.
              _buildDynamicShadow(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicShadow() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-_pointer.dx, -_pointer.dy),
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.black.withOpacity(0.05),
            ],
          ),
        ),
      ),
    );
  }
}
