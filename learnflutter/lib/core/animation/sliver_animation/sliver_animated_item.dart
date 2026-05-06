import 'package:flutter/widgets.dart';
import 'sliver_animated_builder.dart';
import 'sliver_animation_state.dart';
import 'sliver_effects.dart';

class SliverAnimatedItem extends StatelessWidget {
  final SliverAnimationState state;
  final SliverEffect effect;
  final Widget child;

  const SliverAnimatedItem({
    super.key,
    required this.state,
    required this.effect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SliverAnimatedBuilder(
        state: state,
        builder: (context, progress) {
          return effect.build(context, child, progress);
        },
      ),
    );
  }
}
