import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AvatarSide { top, bottom, left, right }

class TabRenderWidget extends StatefulWidget {
  const TabRenderWidget({
    super.key,
    required this.tabColor,
    required this.thumbColor,
    this.tagColor,
    this.thumbSize = 40.0,
    this.avatarSize = 44.0,
    this.avatarUrls = const [],
    this.left = 0.0,
    this.right = 0.0,
    this.avatarSide = AvatarSide.top,
  });

  final Color tabColor;
  final Color thumbColor;

  /// Màu của hình Tag và viền Avatar (nếu null sẽ lấy theo thumbColor)
  final Color? tagColor;

  final double thumbSize;
  final double avatarSize;
  final double left;
  final double right;

  /// Vị trí xuất hiện của Avatar so với thanh trượt
  final AvatarSide avatarSide;

  /// Danh sách đường dẫn ảnh Avatar dùng để phân hạng người dùng.
  /// Khi di chuyển thanh trượt, avatar sẽ tự động thay đổi dựa trên phần trăm (%).
  final List<String> avatarUrls;

  @override
  State<TabRenderWidget> createState() => _TabRenderWidgetState();
}

class _TabRenderWidgetState extends State<TabRenderWidget> {
  double _currentThumbValue = 0.0;

  void _updateThumbPosition(Offset localPosition, double trackWidth) {
    const trackPadding = 4.0;
    final safeThumbRadius = widget.thumbSize / 2;

    // Giới hạn vùng di chuyển của tâm Thumb theo left/right
    final thumbCenterMinX = safeThumbRadius + trackPadding + widget.left;
    final thumbCenterMaxX =
        trackWidth - safeThumbRadius - trackPadding - widget.right;

    if (thumbCenterMaxX <= thumbCenterMinX) return;

    // Giới hạn giá trị X dựa trên vị trí chạm
    var dx = localPosition.dx.clamp(thumbCenterMinX, thumbCenterMaxX);

    setState(() {
      _currentThumbValue =
          (dx - thumbCenterMinX) / (thumbCenterMaxX - thumbCenterMinX);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackHeight = math.max(widget.thumbSize, widget.thumbSize + 16);
    const trackPadding = 4.0;
    final avatarSize = widget.avatarSize; // Kích thước của Avatar nổi phía trên
    const spacing = 16.0; // Tăng khoảng cách để thấy rõ Path hình tag

    final Color finalTagColor = widget.tagColor ?? widget.thumbColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        // Vị trí render mép trái của Thumb bị giới hạn bởi left/right
        final thumbMinX = trackPadding + widget.left;
        final thumbMaxX =
            trackWidth - widget.thumbSize - trackPadding - widget.right;

        // Tính toán tọa độ X hiện tại của Thumb
        final thumbLeftPosition =
            thumbMinX + _currentThumbValue * (thumbMaxX - thumbMinX);

        // Xác định Avatar hiện tại dựa trên _currentThumbValue
        String? currentAvatar;
        if (widget.avatarUrls.isNotEmpty) {
          int index = (_currentThumbValue * widget.avatarUrls.length).floor();
          if (index >= widget.avatarUrls.length) {
            index = widget.avatarUrls.length - 1;
          }
          currentAvatar = widget.avatarUrls[index];
        }

        // Xác định kích thước Stack tùy thuộc vào AvatarSide
        final isVerticalSide = widget.avatarSide == AvatarSide.top ||
            widget.avatarSide == AvatarSide.bottom;
        final stackHeight =
            isVerticalSide ? (avatarSize + spacing + trackHeight) : trackHeight;
        final trackBottom = widget.avatarSide == AvatarSide.top ? 0.0 : null;
        final trackTop = widget.avatarSide == AvatarSide.bottom
            ? 0.0
            : (isVerticalSide ? null : 0.0);

        // Tính toán tâm của Thumb và Avatar để vẽ đường nối
        final thumbCenterX = thumbLeftPosition + widget.thumbSize / 2;
        final trackCenterY = trackTop != null
            ? trackTop + trackHeight / 2
            : stackHeight - (trackBottom ?? 0) - trackHeight / 2;
        final thumbCenter = Offset(thumbCenterX, trackCenterY);

        Offset avatarCenter;
        switch (widget.avatarSide) {
          case AvatarSide.top:
            avatarCenter = Offset(thumbCenterX, avatarSize / 2);
            break;
          case AvatarSide.bottom:
            avatarCenter = Offset(thumbCenterX, stackHeight - avatarSize / 2);
            break;
          case AvatarSide.left:
            avatarCenter = Offset(
                thumbLeftPosition - spacing - avatarSize / 2, trackCenterY);
            break;
          case AvatarSide.right:
            avatarCenter = Offset(
                thumbLeftPosition + widget.thumbSize + spacing + avatarSize / 2,
                trackCenterY);
            break;
        }

        return GestureDetector(
          // Bắt sự kiện chạm và kéo thả trên toàn bộ khu vực widget
          onHorizontalDragDown: (details) =>
              _updateThumbPosition(details.localPosition, trackWidth),
          onHorizontalDragUpdate: (details) =>
              _updateThumbPosition(details.localPosition, trackWidth),
          child: SizedBox(
            height: stackHeight,
            width: trackWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Background Track (Thanh trượt)
                Positioned(
                  left: widget.left,
                  right: widget.right,
                  bottom: trackBottom,
                  top: trackTop,
                  height: trackHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.tabColor,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),
                ),

                // 2. Đường nối (Path) giữa Thumb và Avatar hình Tag
                if (currentAvatar != null && currentAvatar.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConnectionPainter(
                        p1: thumbCenter,
                        p2: avatarCenter,
                        color: finalTagColor,
                        avatarSize: avatarSize,
                      ),
                    ),
                  ),

                // 2. Nút Thumb
                Positioned(
                  left: thumbLeftPosition,
                  bottom: trackBottom != null
                      ? (trackHeight - widget.thumbSize) / 2
                      : null,
                  top: trackTop != null
                      ? (trackHeight - widget.thumbSize) / 2
                      : null,
                  child: Container(
                    width: widget.thumbSize,
                    height: widget.thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Avatar nổi đi theo Thumb
                if (currentAvatar != null && currentAvatar.isNotEmpty)
                  Positioned(
                    left: widget.avatarSide == AvatarSide.left
                        ? (thumbLeftPosition - avatarSize - spacing)
                        : widget.avatarSide == AvatarSide.right
                            ? (thumbLeftPosition + widget.thumbSize + spacing)
                            : (thumbLeftPosition +
                                (widget.thumbSize - avatarSize) / 2),
                    top: widget.avatarSide == AvatarSide.top
                        ? 0
                        : widget.avatarSide == AvatarSide.bottom
                            ? (trackHeight + spacing)
                            : (trackHeight - avatarSize) / 2,
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: finalTagColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipOval(
                        child: RotatedBox(
                          quarterTurns: widget.avatarSide == AvatarSide.right
                              ? 1
                              : widget.avatarSide == AvatarSide.bottom
                                  ? 3
                                  : widget.avatarSide == AvatarSide.left
                                      ? 1
                                      : 0,
                          child: Image.network(
                            currentAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person, color: widget.tabColor),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final Offset p1; // Mũi nhọn (tâm Thumb)
  final Offset p2; // Đáy (tâm Avatar)
  final Color color;
  final double avatarSize;

  _ConnectionPainter({
    required this.p1,
    required this.p2,
    required this.color,
    required this.avatarSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final delta = p1 - p2;
    final distance = delta.distance;
    if (distance == 0) return;

    // Vector hướng từ Avatar tới Thumb
    final dir = delta / distance;
    // Vector vuông góc để lấy chiều rộng
    final perp = Offset(-dir.dy, dir.dx);

    // Bề rộng của hình chữ nhật được thu nhỏ lại (cố định 16.0) để đảm bảo góc chữ nhật
    // không bị thò ra ngoài đường cong của hình tròn Avatar, giúp Avatar che khuất hoàn toàn.
    final thickness = 16.0;

    // Độ dài phần mũi nhọn tam giác
    final triangleLength = 12.0;

    // Độ dài phần hình chữ nhật
    final rectLength = math.max(0.0, distance - triangleLength);

    // 2 góc của hình chữ nhật ở phía tâm Avatar
    final pRect1 = p2 + perp * (thickness / 2);
    final pRect2 = p2 - perp * (thickness / 2);

    // 2 góc của hình chữ nhật ở điểm bắt đầu hình tam giác
    final pBase1 = pRect2 + dir * rectLength;
    final pBase2 = pRect1 + dir * rectLength;

    path.moveTo(pRect1.dx, pRect1.dy);
    path.lineTo(pRect2.dx, pRect2.dy);
    path.lineTo(pBase1.dx, pBase1.dy);

    // Điểm nhọn của tam giác trỏ tới tâm Thumb
    path.lineTo(p1.dx, p1.dy);

    path.lineTo(pBase2.dx, pBase2.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) {
    return oldDelegate.p1 != p1 ||
        oldDelegate.p2 != p2 ||
        oldDelegate.color != color ||
        oldDelegate.avatarSize != avatarSize;
  }
}
