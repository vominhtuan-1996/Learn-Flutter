import 'package:flutter/material.dart';

class ParallaxImage extends StatefulWidget {
  final String imageUrl;
  final double height;

  const ParallaxImage({super.key, required this.imageUrl, required this.height});

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage> {
  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOffset());
  }

  void _updateOffset() {
    final scrollable = Scrollable.of(context);
    final scrollPosition = scrollable.position;

    scrollPosition.addListener(() {
      final renderBox = context.findRenderObject();
      if (renderBox is RenderBox && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero).dy;
        setState(() => offset = position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final percent = (offset / screenHeight).clamp(0.0, 1.0);
    final translateY = percent * 50;

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Image.network(
        widget.imageUrl,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
