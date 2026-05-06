import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/sliver_animation/sliver_animation.dart';

class TikTokAnimationDemoScreen extends StatelessWidget {
  const TikTokAnimationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'TikTok Viewport Animation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: TikTokViewportList(
        itemCount: 200,
        config: const ViewportAnimationConfig(
          minScale: 0.88,
          minOpacity: 0.25,
          maxTranslateY: 35.0,
        ),
        onItemVisibilityChanged: (index, visible) {
          // Hook để play/pause video hoặc preload asset
          debugPrint('Item $index → visible: $visible');
        },
        itemBuilder: (context, index) => _TikTokCard(index: index),
      ),
    );
  }
}

class _TikTokCard extends StatelessWidget {
  final int index;
  static final List<Color> _palette = [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6584),
    const Color(0xFF43D8C9),
    const Color(0xFFFFA07A),
    const Color(0xFF98D8C8),
  ];

  const _TikTokCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final color = _palette[index % _palette.length];
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.white, size: 52),
                const SizedBox(height: 12),
                Text(
                  'Item #$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'TikTok-style Viewport Animation',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '60fps',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
