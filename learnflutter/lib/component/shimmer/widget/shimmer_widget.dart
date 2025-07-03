import 'package:flutter/cupertino.dart';
import 'package:learnflutter/component/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/component/shimmer/widget/shimmer_loading_widget.dart';

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  const Shimmer({
    super.key,
    required this.linearGradient,
    this.child,
  });

  final LinearGradient linearGradient;
  final Widget? child;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
// code-excerpt-closing-bracket

  LinearGradient get gradient => LinearGradient(
        colors: widget.linearGradient.colors,
        stops: widget.linearGradient.stops,
        begin: widget.linearGradient.begin,
        end: widget.linearGradient.end,
        transform: SlidingGradientTransform(slidePercent: _shimmerController.value),
      );

  bool get isSized => (context.findRenderObject() as RenderBox).hasSize;
  Size get size => isSized ? (context.findRenderObject() as RenderBox).size : Size.zero;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true ,
      child:widget.child ?? const SizedBox() ,
    );
      
  }
}
