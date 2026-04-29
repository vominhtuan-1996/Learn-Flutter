import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/shimmer/widget/base_shimmer_builder.dart';
import 'package:learnflutter/shared/widgets/shimmer/widget/shimmer_box.dart';

class ShimmerBaseTestScreen extends StatefulWidget {
  const ShimmerBaseTestScreen({super.key});

  @override
  State<ShimmerBaseTestScreen> createState() => _ShimmerBaseTestScreenState();
}

class _ShimmerBaseTestScreenState extends State<ShimmerBaseTestScreen> {
  bool _isLoading = true;

  void _toggle() => setState(() => _isLoading = !_isLoading);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Base Shimmer Test')),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggle,
        child: Icon(_isLoading ? Icons.visibility : Icons.visibility_off),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('1. BaseShimmerList (auto from real widget)'),
            BaseShimmerList(
              isLoading: _isLoading,
              child: Column(
                children: List.generate(
                  4,
                  (i) => ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text('Item ${i + 1}'),
                    subtitle: const Text('Subtitle content here'),
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            _sectionTitle('2. BaseShimmerList (card layout)'),
            BaseShimmerList(
              isLoading: _isLoading,
              child: Column(
                children: [
                  _buildRealCard('Card Title 1', 'Description for the first card'),
                  _buildRealCard('Card Title 2', 'Description for the second card'),
                ],
              ),
            ),
            const Divider(height: 32),
            _sectionTitle('3. BaseShimmerList (profile)'),
            BaseShimmerList(
              isLoading: _isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nguyen Van A', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Senior Developer', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        FilledButton.tonal(onPressed: () {}, child: const Text('Follow')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            _sectionTitle('4. BaseShimmerBuilder (custom skeleton)'),
            BaseShimmerBuilder(
              isLoading: _isLoading,
              shimmerContent: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ShimmerCard(),
                    ShimmerListTile(),
                    ShimmerListTile(hasAvatar: false, lineCount: 3),
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Real content loaded successfully!'),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildRealCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.image, size: 48)),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
