import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/sliver_animation/sliver_animation_coordinator.dart';
import 'package:learnflutter/core/animation/sliver_animation/sliver_animation_state.dart';
import 'package:learnflutter/core/animation/sliver_animation/sliver_effects.dart';
import 'package:learnflutter/core/animation/sliver_animation/sliver_animated_item.dart';

class SliverAnimationDemoScreen extends StatefulWidget {
  const SliverAnimationDemoScreen({super.key});

  @override
  State<SliverAnimationDemoScreen> createState() => _SliverAnimationDemoScreenState();
}

class _SliverAnimationDemoScreenState extends State<SliverAnimationDemoScreen> {
  final ScrollController _scrollController = ScrollController();
  late final SliverAnimationCoordinator _coordinator;

  late final SliverAnimationState _headerState;
  late final SliverAnimationState _item1State;
  late final SliverAnimationState _item2State;

  @override
  void initState() {
    super.initState();
    _coordinator = SliverAnimationCoordinator(_scrollController);

    // Đăng ký các state cho các item khác nhau
    _headerState = _coordinator.register("header", start: 0, end: 200);
    _item1State = _coordinator.register("item1", start: 200, end: 400);
    _item2State = _coordinator.register("item2", start: 400, end: 600);

    _coordinator.attach();
  }

  @override
  void dispose() {
    _coordinator.detach();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header với hiệu ứng kết hợp
          SliverAnimatedItem(
            state: _headerState,
            effect: CombinedEffect([
              FadeEffect(),
              ScaleEffect(minScale: 0.5),
              ParallaxEffect(offset: 150),
            ]),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "Sliver Animation\nFramework",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Item 1: Chỉ Fade & Parallax
          SliverAnimatedItem(
            state: _item1State,
            effect: CombinedEffect([
              FadeEffect(),
              ParallaxEffect(offset: 80),
            ]),
            child: _buildCard("Fade & Parallax Effect", Colors.orange),
          ),

          // Item 2: Chỉ Scale
          SliverAnimatedItem(
            state: _item2State,
            effect: ScaleEffect(minScale: 0.2),
            child: _buildCard("Deep Scale Effect", Colors.green),
          ),

          // Danh sách placeholder để có chỗ cuộn
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Item #$index",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Color color) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
