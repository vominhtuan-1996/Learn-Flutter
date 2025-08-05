import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_header_animation.dart';

class HeaderAnimationPage extends StatelessWidget {
  const HeaderAnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HeaderAnimationPage')),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderAnimation(
              maxHeight: 200,
              minHeight: 80,
              builder: (context, progress) {
                final scale = 1.0 - (0.3 * progress); // 1.0 → 0.7
                final opacity = 1.0 - progress; // 1.0 → 0.0

                return Container(
                  color: Colors.white,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 16 + 40 * (1 - progress),
                        child: Opacity(
                          opacity: opacity,
                          child: const Text(
                            'Chào bạn!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.scale(
                          scale: scale,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.indigo,
                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
