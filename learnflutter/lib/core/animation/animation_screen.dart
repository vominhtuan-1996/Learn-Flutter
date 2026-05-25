import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/core/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/core/animation/widget/list_view_animation.dart';
import 'package:learnflutter/core/animation/widget/position_animation.dart';
import 'package:learnflutter/core/animation/widget/reload_button_widget.dart';
import 'package:learnflutter/core/animation/widget/ripple_animation_widget.dart';
import 'package:learnflutter/core/animation/widget/scale_translate.dart';

/// Màn hình demo tổng hợp các animation trong `core/animation/widget/` và
/// `core/animation/hero_animation/`. Mỗi section là 1 card độc lập có
/// preview trực quan + tên class để dễ tham chiếu source.
class TransitionsHomePage extends StatefulWidget {
  const TransitionsHomePage({super.key});

  @override
  State<TransitionsHomePage> createState() => _TransitionsHomePageState();
}

class _TransitionsHomePageState extends State<TransitionsHomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  final List<String> _listData = List.generate(8, (i) => 'Item ${i + 1}');

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'IconAnimationWidget',
            description: 'Heartbeat + rotate. Truyền `isRotate` và `icon` để tuỳ biến.',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Tile(
                  label: 'Heartbeat',
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: IconAnimationWidget(),
                  ),
                ),
                _Tile(
                  label: 'Rotate',
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: IconAnimationWidget(isRotate: true),
                  ),
                ),
                _Tile(
                  label: 'Custom icon',
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: IconAnimationWidget(
                      icon: Icons.notifications_active,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _Section(
            title: 'RippleAnimationWidget',
            description: 'Vòng tròn lan toả — dùng cho CTA hoặc trạng thái chờ.',
            child: const SizedBox(
              height: 180,
              child: Center(child: RippleAnimationWidget()),
            ),
          ),

          _Section(
            title: 'ReloadButtonWidget',
            description: 'Nút reload có hiệu ứng xoay khi tap.',
            child: Center(child: ReloadButtonWidget()),
          ),

          _Section(
            title: 'PositionedTransitionWidget',
            description: 'Di chuyển FlutterLogo bằng `RelativeRectTween` + repeat reverse.',
            child: const SizedBox(
              height: 220,
              child: PositionedTransitionWidget(),
            ),
          ),

          _Section(
            title: 'ScaleTranslateBuilder (PageView)',
            description:
                'Scale + translate item PageView theo offset — dùng cho carousel mượt.',
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ScaleTranslateBuilder(
                    index: index,
                    pageController: _pageController,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          _Section(
            title: 'ListViewAnimated',
            description:
                'Insert từng item vào `AnimatedList` theo Timer — slide-in chuyên nghiệp.',
            child: SizedBox(
              height: 260,
              child: ListViewAnimated(
                fullData: _listData,
                itemBuilder: (context, index, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(_listData[index]),
                        subtitle: const Text('Slide-in via AnimatedList'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          _Section(
            title: 'Hero Animation',
            description:
                'Hero transition với `CustomRectTween` (cung arc) — tap để mở demo.',
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Page1()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_takeoff),
                    SizedBox(width: 12),
                    Text('Open Hero demo (Page1 → Page2)'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
