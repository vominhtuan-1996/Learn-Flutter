import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';

class TopOverlayBanner {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required Widget content,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    double ratioScreenHeight = 0.5,
  }) {
    // Remove overlay cũ nếu còn
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => _AnimatedBannerOverlay(
        ratioScreenHeight: ratioScreenHeight,
        content: content,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

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

class _AnimatedBannerOverlayState extends State<_AnimatedBannerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _controller.forward();

    // Auto dismiss
  }

  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;

    _controller.reverse().then((_) {
      widget.onDismiss();
    });
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
      top: topPadding,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: DeviceDimension.screenHeight * widget.ratioScreenHeight,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: widget.content,
                ),
                OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.3,
                        )),
                  ),
                  child: const Text('Đóng'),
                  onPressed: () {
                    dismiss();
                  },
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
