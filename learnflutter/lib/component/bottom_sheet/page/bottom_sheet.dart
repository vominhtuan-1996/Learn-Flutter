import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';

class VMTBottomSheet extends StatefulWidget {
  const VMTBottomSheet({super.key, required this.child, this.heightBottomSheet = 0.86});
  final Widget child;
  final double heightBottomSheet;
  @override
  State<VMTBottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<VMTBottomSheet> with SingleTickerProviderStateMixin {
  double heightDropAction = 0.0;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  @override
  void initState() {
    heightDropAction = (6 + DeviceDimension.padding / 4 + DeviceDimension.padding / 2 + 2);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _heightAnimation = Tween<double>(begin: widget.heightBottomSheet, end: widget.heightBottomSheet).animate(_controller);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(36 * 0.8), topRight: Radius.circular(36 * 0.8)),
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.grey,
              ),
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(-2, 1), blurRadius: 1),
            ],
          ),
          height: _heightAnimation.value,
          child: SizedBox(
            height: _heightAnimation.value - heightDropAction,
            child: widget.child,
          ),
        );
      },
    );
  }
}
