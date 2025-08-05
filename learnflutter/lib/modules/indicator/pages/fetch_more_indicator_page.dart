import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/indicator/extendsion/fetch_more_indicator.dart';
import 'package:learnflutter/modules/indicator/widget/example_list.dart';

class FetchMoreIndicatorPage extends StatefulWidget {
  const FetchMoreIndicatorPage({super.key});

  @override
  State<FetchMoreIndicatorPage> createState() => _FetchMoreScreenState();
}

class _FetchMoreScreenState extends State<FetchMoreIndicatorPage> {
  int _itemsCount = 10;

  Future<void> _fetchMore() async {
    // Simulate fetch time
    await Future<void>.delayed(const Duration(seconds: 2));
    // make sure that the widget is still mounted.
    if (!mounted) return;
    // Add more fake elements
    setState(() {
      _itemsCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: FetchMoreIndicator(
        onAction: _fetchMore,
        child: ExampleList(
          leading: const ListHelpBox(
            child: Text(
              "Scroll to the end of the list "
              "and pull up to retrieve more rows.",
            ),
          ),
          itemCount: _itemsCount,
          countElements: true,
        ),
      ),
    );
  }
}
