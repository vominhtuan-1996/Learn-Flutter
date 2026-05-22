import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/shimmer/widget/base_shimmer_builder.dart';
import 'package:learnflutter/shared/components/shimmer/widget/shimmer_box.dart';

/// Demo trực quan shimmer: bật/tắt loading, hiển thị nhiều preset placeholder
/// (Box / Circle / ListTile / Card) và một list dữ liệu giả lập gọi API.
class ShimmerDemoScreen extends StatefulWidget {
  const ShimmerDemoScreen({super.key});

  @override
  State<ShimmerDemoScreen> createState() => _ShimmerDemoScreenState();
}

class _ShimmerDemoScreenState extends State<ShimmerDemoScreen> {
  bool _isLoading = true;
  Timer? _autoTimer;

  final _items = List.generate(
    8,
    (i) => _DemoItem(
      title: 'Bài viết #${i + 1}',
      subtitle: 'Đây là mô tả ngắn cho item số ${i + 1}.',
    ),
  );

  @override
  void initState() {
    super.initState();
    _simulateFetch();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _simulateFetch() {
    setState(() => _isLoading = true);
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Shimmer Demo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _isLoading ? 'Đang tải...' : 'Reload',
            icon: Icon(_isLoading ? Icons.hourglass_top : Icons.refresh),
            onPressed: _isLoading ? null : _simulateFetch,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: '🧱 ShimmerBox (rect / circle / rounded)',
            child: Row(
              children: [
                BaseShimmerList(
                  isLoading: true,
                  child: const ShimmerBox.rect(width: 80, height: 80),
                ),
                const SizedBox(width: 12),
                BaseShimmerList(
                  isLoading: true,
                  child: const ShimmerBox.circle(size: 64),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BaseShimmerList(
                    isLoading: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox.rect(width: double.infinity, height: 14),
                        SizedBox(height: 8),
                        ShimmerBox.rect(width: 140, height: 14),
                        SizedBox(height: 8),
                        ShimmerBox.rect(width: 80, height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: '🧑 ShimmerListTile (avatar + 2 lines)',
            child: BaseShimmerList(
              isLoading: true,
              child: Column(
                children: const [
                  ShimmerListTile(),
                  ShimmerListTile(lineCount: 3),
                ],
              ),
            ),
          ),
          _Section(
            title: '🖼 ShimmerCard (image + text)',
            child: BaseShimmerList(
              isLoading: true,
              child: const ShimmerCard(),
            ),
          ),
          _Section(
            title:
                '📡 Real use-case — tải dữ liệu (toggle bằng icon refresh ở appbar)',
            child: BaseShimmerList(
              isLoading: _isLoading,
              child: Column(
                children: _items
                    .map(
                      (item) => _ItemTile(
                        title: item.title,
                        subtitle: item.subtitle,
                        loading: _isLoading,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DemoItem {
  const _DemoItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

/// Một row có thể chuyển giữa skeleton (shimmer) và nội dung thật dựa vào
/// [loading]. Khi loading, các text/avatar sẽ được bọc trong [ShimmerBox] để
/// gradient của shimmer chạy qua.
class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.title,
    required this.subtitle,
    required this.loading,
  });

  final String title;
  final String subtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const ShimmerListTile();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFDBEAFE),
            child: Text(
              title.characters.last,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
