import 'dart:async';

import 'package:flutter/material.dart';

/// Widget hiển thị notification dạng banner **trong app** (in-app),
/// không phụ thuộc vào OS-level notification.
///
/// Hữu ích cho các trường hợp:
/// - App đang foreground muốn show banner tuỳ biến UI (gradient, icon, action)
/// - Test UI nhanh không cần qua permission của OS
/// - Show toast-like notification trên web (nơi `flutter_local_notifications`
///   không hỗ trợ đầy đủ).
///
/// Cách dùng nhanh:
/// ```dart
/// LocalNotificationOverlay.show(
///   context,
///   title: 'Đã lưu',
///   body: 'Dữ liệu của bạn đã được đồng bộ.',
///   icon: Icons.cloud_done,
///   color: Colors.green,
///   onTap: () => debugPrint('tapped'),
/// );
/// ```
class LocalNotificationOverlay {
  LocalNotificationOverlay._();

  static OverlayEntry? _currentEntry;
  static Timer? _autoDismissTimer;

  /// Hiển thị banner notification trên cùng overlay.
  ///
  /// [duration] mặc định 3 giây; truyền [Duration.zero] để banner tự giữ
  /// đến khi gọi [dismiss].
  static void show(
    BuildContext context, {
    required String title,
    String? body,
    IconData icon = Icons.notifications,
    Color color = const Color(0xFF2563EB),
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _BannerWidget(
        title: title,
        body: body,
        icon: icon,
        color: color,
        onTap: () {
          onTap?.call();
          dismiss();
        },
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    if (duration > Duration.zero) {
      _autoDismissTimer = Timer(duration, dismiss);
    }
  }

  /// Đóng banner hiện tại (nếu có).
  static void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _BannerWidget extends StatefulWidget {
  const _BannerWidget({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onDismiss,
    this.body,
  });

  final String title;
  final String? body;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Positioned(
      top: mq.padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (d) {
                if ((d.primaryVelocity ?? 0) < -100) widget.onDismiss();
              },
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                          if (widget.body != null && widget.body!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.body!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkResponse(
                      onTap: widget.onDismiss,
                      radius: 18,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
