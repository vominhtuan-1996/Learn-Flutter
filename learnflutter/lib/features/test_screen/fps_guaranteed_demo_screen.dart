import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/performance/performance_animated_item.dart';

class FPSGuaranteedDemoScreen extends StatelessWidget {
  const FPSGuaranteedDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("60FPS Guaranteed Demo"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Zero Rebuild Animation",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Danh sách 1000 items này sử dụng Custom RenderObject để tính toán animation trực tiếp trong layer paint. Không có setState nào được gọi khi cuộn.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PerformanceAnimatedItem(
                  child: _buildListItem(index),
                );
              },
              childCount: 1000,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    final color = Colors.primaries[index % Colors.primaries.length];
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "#$index",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "High Performance Item $index",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "GPU Accelerated Transform",
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt, color: Colors.yellow, size: 32),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
