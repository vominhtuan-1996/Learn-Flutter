import 'dart:io';
import 'package:flutter/material.dart';

/// [Photo3DViewer] là một widget hiển thị hình ảnh với hiệu ứng nghiêng 3D đặc trưng.
/// Khi người dùng chạm và kéo trên bề mặt ảnh, widget sẽ tính toán ma trận xoay
/// Transform Matrix4 để thay đổi góc nhìn của ảnh, kết hợp với hiệu ứng đổ bóng
/// và lớp phủ ánh sáng (glare) động để tạo cảm giác vật thể 3D thực thụ.
class Photo3DViewer extends StatefulWidget {
  /// [imagePath] có thể là một URL (network) hoặc đường dẫn file cục bộ (local).
  final String imagePath;
  final bool isNetworkImage;
  final double width;
  final double height;
  final double maxTilt;

  const Photo3DViewer({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
    this.width = 300,
    this.height = 400,
    this.maxTilt = 0.4,
  });

  @override
  State<Photo3DViewer> createState() => _Photo3DViewerState();
}

class _Photo3DViewerState extends State<Photo3DViewer>
    with SingleTickerProviderStateMixin {
  /// [_offset] lưu trữ vị trí tương đối của điểm chạm so với tâm widget (trong khoảng -1.0 đến 1.0).
  /// Giá trị này quyết định hướng và độ lớn của góc xoay Matrix4.
  Offset _offset = Offset.zero;

  /// [AnimationController] và [Animation] được sử dụng để tạo hiệu ứng "đàn hồi" (bounce back)
  /// khi người dùng thả tay, giúp ảnh quay về vị trí phẳng ban đầu một cách mượt mà.
  late AnimationController _resetCtrl;
  late Animation<Offset> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _resetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resetCtrl, curve: Curves.elasticOut));

    _resetCtrl.addListener(() {
      setState(() => _offset = _resetAnimation.value);
    });
  }

  @override
  void dispose() {
    _resetCtrl.dispose();
    super.dispose();
  }

  /// [_onPanUpdate] chuẩn hóa tọa độ chạm dựa trên kích thước thực tế của widget.
  /// Việc chuẩn hóa này đảm bảo hiệu ứng nghiêng đồng nhất dù kích thước widget thay đổi.
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_resetCtrl.isAnimating) _resetCtrl.stop();
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

  /// [_onPanEnd] kích hoạt animation đưa ảnh về trạng thái cân bằng.
  /// Sử dụng [Tween] động để mượt mà hóa từ vị trí hiện tại của ngón tay về [Offset.zero].
  void _onPanEnd(DragEndDetails details) {
    _resetAnimation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOutBack));
    _resetCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: Center(
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2,
                    0.0012) // Thiết lập Perspective (phối cảnh) cho không gian 3D
                ..rotateX(-_offset.dy *
                    widget.maxTilt) // Xoay quanh trục X (nghiêng dọc)
                ..rotateY(_offset.dx *
                    widget.maxTilt), // Xoay quanh trục Y (nghiêng ngang)
              child: _buildImageCard(),
            ),
          ),
        );
      },
    );
  }

  /// [_buildImageCard] xây dựng cấu trúc của tấm ảnh bao gồm ảnh gốc, lớp phủ ánh sáng
  /// và hiệu ứng đổ bóng động dựa trên độ nghiêng hiện tại.
  Widget _buildImageCard() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Đổ bóng thay đổi vị trí theo hướng nghiêng để tăng cảm giác vật thể nổi
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: Offset(_offset.dx * 25, _offset.dy * 25),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Hiển thị ảnh từ Network hoặc File tùy theo nguồn dữ liệu
            widget.isNetworkImage
                ? Image.network(widget.imagePath, fit: BoxFit.cover)
                : Image.file(File(widget.imagePath), fit: BoxFit.cover),

            // Lớp phủ Glare (ánh sáng chói) giả lập phản chiếu bề mặt kính
            _buildGlareOverlay(),

            // Border trang trí làm nổi bật cạnh của block 3D
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildGlareOverlay] tạo một lớp gradient tuyến tính thay đổi theo tọa độ chạm.
  /// Khi ảnh nghiêng, lớp ánh sáng này sẽ di chuyển ngược hướng, tạo hiệu ứng
  /// phản xạ ánh sáng cao cấp như trên các vật liệu bóng loáng.
  Widget _buildGlareOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-_offset.dx, -_offset.dy),
            end: Alignment(_offset.dx, _offset.dy),
            colors: [
              Colors.white.withOpacity(0.35),
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}
