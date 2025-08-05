import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_collapse_to_fab.dart';

class SliverCollapseToFABExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sliver Collapse to FAB Example"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverCollapseToFAB(
              child: Container(
                color: Colors.teal,
                alignment: Alignment.center,
                child: Text("Sliver Header", style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              fab: FloatingActionButton(
                onPressed: () => print("FAB tapped"),
                child: Icon(Icons.favorite),
              ),
              fabOffset: Offset(24, 24),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
