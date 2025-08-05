import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

/// Flutter code sample for [NestedScrollView].

class NestedScrollViewExample extends StatelessWidget {
  const NestedScrollViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        // Setting floatHeaderSlivers to true is required in order to float
        // the outer slivers over the inner scrollable.
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Container(
                color: Colors.red,
                height: 100,
                child: const Text('title'),
              ),
              floating: true,
              expandedHeight: 120.0,
              forceElevated: innerBoxIsScrolled,
              leading: const BackButton(color: Colors.transparent),
            ),
          ];
        },
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 30,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 50,
              child: Center(child: Text('Item $index')),
            )
                .padding(
                  EdgeInsets.all(3),
                )
                .annotateRegion(
                  context,
                )
                .background(
                  Colors.red,
                );
          },
        ),
      ),
    );
  }
}
