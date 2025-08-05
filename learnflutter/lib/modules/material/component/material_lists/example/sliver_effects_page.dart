import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_effects.dart';

class SliverEffectsPage extends StatefulWidget {
  const SliverEffectsPage({super.key});

  @override
  State<SliverEffectsPage> createState() => _SliverEffectsPageState();
}

class _SliverEffectsPageState extends State<SliverEffectsPage> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliver Effects'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          // 🎯 Hero banner: fade + scale + translate
          SliverHeroBanner(
            controller: _controller,
            fadeEnd: 200,
            scaleEnd: 0.7,
            translateY: -60,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.blueAccent,
              alignment: Alignment.center,
              child: const Text(
                'SliverHeroBanner',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🎯 Fade-only effect
          SliverFadeOnScroll(
            controller: _controller,
            fadeStart: 100,
            fadeEnd: 300,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.amber,
              child: const Text('SliverFadeOnScroll', style: TextStyle(fontSize: 22)),
            ),
          ),

          // 🎯 Fade + Scale effect
          SliverFadeScaleOnScroll(
            controller: _controller,
            fadeStart: 200,
            fadeEnd: 400,
            scaleStart: 1.0,
            scaleEnd: 0.8,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(24),
              color: Colors.greenAccent,
              child: const Text('SliverFadeScaleOnScroll', style: TextStyle(fontSize: 22)),
            ),
          ),

          // 📜 Fake list content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 30,
            ),
          )
        ],
      ),
    );
  }
}
