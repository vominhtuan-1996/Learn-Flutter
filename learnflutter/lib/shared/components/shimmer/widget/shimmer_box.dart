import 'package:flutter/material.dart';

/// Placeholder shape dùng chung cho shimmer loading.
/// Hỗ trợ: rectangle, circle, rounded rectangle.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox.rect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  }) : shape = BoxShape.rectangle;

  const ShimmerBox.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = 0.0,
        shape = BoxShape.circle;

  const ShimmerBox.line({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 4.0,
    this.margin,
  }) : shape = BoxShape.rectangle;

  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
      ),
    );
  }
}

/// Pre-built shimmer skeleton cho list item phổ biến:
/// [avatar] + [2 dòng text]
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({
    super.key,
    this.avatarSize = 48,
    this.lineHeight = 14,
    this.lineSpacing = 8,
    this.secondLineWidthFactor = 0.6,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.hasAvatar = true,
    this.lineCount = 2,
  });

  final double avatarSize;
  final double lineHeight;
  final double lineSpacing;
  final double secondLineWidthFactor;
  final EdgeInsetsGeometry padding;
  final bool hasAvatar;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (hasAvatar) ...[
            ShimmerBox.circle(size: avatarSize),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lineCount, (index) {
                final isLast = index == lineCount - 1 && lineCount > 1;
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : lineSpacing),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isLast ? secondLineWidthFactor : 1.0,
                    child: ShimmerBox.line(height: lineHeight),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-built shimmer skeleton cho card phổ biến:
/// [image placeholder] + [2 dòng text]
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.imageAspectRatio = 16 / 9,
    this.imageBorderRadius = 12.0,
    this.lineCount = 2,
    this.lineHeight = 14,
    this.lineSpacing = 10,
    this.secondLineWidthFactor = 0.65,
    this.padding = const EdgeInsets.all(16),
  });

  final double imageAspectRatio;
  final double imageBorderRadius;
  final int lineCount;
  final double lineHeight;
  final double lineSpacing;
  final double secondLineWidthFactor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: imageAspectRatio,
            child: ShimmerBox.rect(
              width: double.infinity,
              height: double.infinity,
              borderRadius: imageBorderRadius,
            ),
          ),
          SizedBox(height: lineSpacing + 4),
          ...List.generate(lineCount, (index) {
            final isLast = index == lineCount - 1 && lineCount > 1;
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : lineSpacing),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: isLast ? secondLineWidthFactor : 1.0,
                child: ShimmerBox.line(height: lineHeight),
              ),
            );
          }),
        ],
      ),
    );
  }
}
