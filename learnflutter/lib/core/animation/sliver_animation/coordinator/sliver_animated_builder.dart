import 'package:flutter/widgets.dart';
import 'sliver_animation_state.dart';

class SliverAnimatedBuilder extends StatefulWidget {
  final SliverAnimationState state;
  final Widget Function(BuildContext context, double progress) builder;

  const SliverAnimatedBuilder({
    super.key,
    required this.state,
    required this.builder,
  });

  @override
  State<SliverAnimatedBuilder> createState() => _SliverAnimatedBuilderState();
}

class _SliverAnimatedBuilderState extends State<SliverAnimatedBuilder> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(SliverAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_onStateChanged);
      widget.state.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.state.progress);
  }
}
