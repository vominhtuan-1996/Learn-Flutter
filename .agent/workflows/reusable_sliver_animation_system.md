---
description: Build a reusable Sliver animation system
---

#kiến trúc tổng thể 

ScrollView
   ↓
SliverAnimationCoordinator  (core)
   ↓
SliverAnimationController   (state)
   ↓
SliverAnimatedWidget        (UI layer)
   ↓
Effects (Fade / Scale / Parallax / Blur...)

#2. Core: SliverAnimationCoordinator
class SliverAnimationCoordinator {
  final ScrollController scrollController;

  final Map<String, SliverAnimationState> _states = {};

  SliverAnimationCoordinator(this.scrollController);

  double getScrollOffset() => scrollController.offset;

  SliverAnimationState register(String id, {
    required double start,
    required double end,
  }) {
    final state = SliverAnimationState(start: start, end: end);
    _states[id] = state;
    return state;
  }

  void update() {
    final offset = getScrollOffset();

    for (final state in _states.values) {
      state.update(offset);
    }
  }
}
#3. Animation State (progress engine)
class SliverAnimationState {
  final double start;
  final double end;

  double progress = 0;

  SliverAnimationState({
    required this.start,
    required this.end,
  });

  void update(double offset) {
    progress = ((offset - start) / (end - start))
        .clamp(0.0, 1.0);
  }
}
#4. SliverAnimatedBuilder (UI layer)

class SliverAnimatedBuilder extends StatefulWidget {
  final SliverAnimationState state;
  final Widget Function(BuildContext, double progress) builder;

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
    // bạn có thể attach listener global
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.state.progress);
  }
}
#5. Effect system (quan trọng)
abstract class SliverEffect {
  Widget build(BuildContext context, Widget child, double progress);
}
#Fade Effect
class FadeEffect extends SliverEffect {
  @override
  Widget build(context, child, progress) {
    return Opacity(
      opacity: progress,
      child: child,
    );
  }
}
#Scale Effect

class ScaleEffect extends SliverEffect {
  final double minScale;

  ScaleEffect({this.minScale = 0.8});

  @override
  Widget build(context, child, progress) {
    final scale = minScale + (1 - minScale) * progress;

    return Transform.scale(
      scale: scale,
      child: child,
    );
  }
}
#Parallax Effect
class ParallaxEffect extends SliverEffect {
  final double offset;

  ParallaxEffect({this.offset = 100});

  @override
  Widget build(context, child, progress) {
    return Transform.translate(
      offset: Offset(0, (1 - progress) * offset),
      child: child,
    );
  }
}
#6. Compose multiple effects
class CombinedEffect extends SliverEffect {
  final List<SliverEffect> effects;

  CombinedEffect(this.effects);

  @override
  Widget build(context, child, progress) {
    Widget current = child;

    for (final effect in effects) {
      current = effect.build(context, current, progress);
    }

    return current;
  }
}
#7. SliverAnimatedItem (reusable widget)
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
#8. Usage (rất clean)
final coordinator = SliverAnimationCoordinator(scrollController);

final headerState = coordinator.register(
  "header",
  start: 0,
  end: 200,
);
CustomScrollView(
  controller: scrollController,
  slivers: [
    SliverAnimatedItem(
      state: headerState,
      effect: CombinedEffect([
        FadeEffect(),
        ScaleEffect(minScale: 0.9),
        ParallaxEffect(offset: 80),
      ]),
      child: HeaderWidget(),
    ),
  ],
)
#9. Auto update (quan trọng, đừng quên)
scrollController.addListener(() {
  coordinator.update();
});
