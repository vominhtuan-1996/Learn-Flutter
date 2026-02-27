import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/features/material/component/material_lists/widgets/sliver_map_preview.dart';

class SliverMapPreviewExample extends StatelessWidget {
  const SliverMapPreviewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SliverMapPreview Example')),
      body: CustomScrollView(
        slivers: [
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (context, index) => ListTile(
          //       title: Text('Trước bản đồ: Item $index'),
          //     ),
          //     childCount: 5,
          //   ),
          // ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📍 Vị trí nổi bật',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMapPreview(
              center: const LatLng(10.762622, 106.660172), // Ví dụ: Sài Gòn
              height: 280,
              zoom: 15,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Sau bản đồ: Item $index'),
              ),
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}
