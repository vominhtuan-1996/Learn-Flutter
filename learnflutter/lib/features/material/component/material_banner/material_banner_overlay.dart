import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _BannerRequest – Data class đại diện một yêu cầu hiển thị banner trong Queue
// ─────────────────────────────────────────────────────────────────────────────

class _BannerRequest {
  final Widget content;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final double ratioScreenHeight;
  // Overlay được capture tại thời điểm gọi show() để đảm bảo đúng context.
  final OverlayState overlay;

  const _BannerRequest({
    required this.content,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.ratioScreenHeight,
    required this.overlay,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TopOverlayBanner – Quản lý hiển thị banner với hàng đợi (Queue)
// ─────────────────────────────────────────────────────────────────────────────

/// Hiển thị banner overlay ở đầu màn hình với cơ chế **Queue**.
///
/// - Nếu chưa có banner nào đang hiện → hiển thị ngay lập tức.
/// - Nếu đang có banner → đưa vào hàng đợi, tự động hiển thị sau khi
///   banner hiện tại dismiss xong (slide out hoàn toàn).
/// - Dùng [clearQueue] để xóa toàn bộ hàng đợi + đóng banner đang hiện.
class TopOverlayBanner {
  TopOverlayBanner._();

  static OverlayEntry? _currentEntry;

  /// Hàng đợi các yêu cầu banner chưa được hiển thị.
  static final Queue<_BannerRequest> _queue = Queue();

  /// `true` khi một banner đang được hiển thị trên màn hình.
  static bool _isShowing = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Thêm banner vào hàng đợi. Nếu chưa có banner nào đang hiện thì hiển thị ngay.
  static void show({
    required BuildContext context,
    required Widget content,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    double ratioScreenHeight = 0.5,
  }) {
    final overlay = Overlay.of(context);
    // ignore: unnecessary_null_comparison
    if (overlay == null) return;

    _queue.addLast(_BannerRequest(
      content: content,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      ratioScreenHeight: ratioScreenHeight,
      overlay: overlay,
    ));

    if (!_isShowing) _showNext();
  }

  /// Số banner đang chờ trong hàng đợi (không tính banner đang hiển thị).
  static int get queueLength => _queue.length;

  /// Xóa toàn bộ hàng đợi và dismiss banner đang hiện (nếu có).
  static void clearQueue() {
    _queue.clear();
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// Lấy yêu cầu tiếp theo từ queue và hiển thị.
  static void _showNext() {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final request = _queue.removeFirst();

    final entry = OverlayEntry(
      builder: (context) => _AnimatedBannerOverlay(
        ratioScreenHeight: request.ratioScreenHeight,
        content: request.content,
        backgroundColor: request.backgroundColor,
        textColor: request.textColor,
        duration: request.duration,
        onDismiss: _onCurrentDismissed,
      ),
    );

    _currentEntry = entry;
    request.overlay.insert(entry);
  }

  /// Callback khi banner hiện tại đã slide-out hoàn toàn.
  static void _onCurrentDismissed() {
    _currentEntry?.remove();
    _currentEntry = null;
    // Hiển thị banner tiếp theo trong queue (nếu có).
    _showNext();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedBannerOverlay – Widget nội bộ thực hiện slide animation + auto-dismiss
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedBannerOverlay extends StatefulWidget {
  final Widget content;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback onDismiss;
  final double ratioScreenHeight;

  const _AnimatedBannerOverlay({
    required this.content,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.onDismiss,
    this.ratioScreenHeight = 0.5,
  });

  @override
  State<_AnimatedBannerOverlay> createState() => _AnimatedBannerOverlayState();
}

class _AnimatedBannerOverlayState extends State<_AnimatedBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward();

    // Auto-dismiss sau [duration].
    Future.delayed(widget.duration, () {
      if (mounted) dismiss();
    });
  }

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.backgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: widget.content,
            ),
          ),
        ),
      ),
    );
  }
}
