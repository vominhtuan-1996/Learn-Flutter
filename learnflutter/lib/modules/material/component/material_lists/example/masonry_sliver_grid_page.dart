import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() => runApp(const MaterialApp(home: MasonrySliverGridPage()));

class MasonrySliverGridPage extends StatelessWidget {
  const MasonrySliverGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(30, (i) => i);

    return Scaffold(
      appBar: AppBar(title: const Text('Pinterest SliverGrid')),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Gợi ý theo sở thích', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: items.length,
            itemBuilder: (context, index) {
              final height = (100 + (index % 5) * 40).toDouble();
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length].shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('Item $index'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
