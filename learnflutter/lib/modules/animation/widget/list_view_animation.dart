import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/shimmer/widget/shimmer_loading_widget.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, int index, Animation<double> animation);

class ListViewAnimated<T> extends StatefulWidget {
  const ListViewAnimated({super.key, required this.fullData, this.itemBuilder});
  final List<dynamic> fullData;
  final ItemBuilder<T>? itemBuilder;
  @override
  _ListViewAnimatedState createState() => _ListViewAnimatedState();
}

class _ListViewAnimatedState extends State<ListViewAnimated> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<dynamic> _items = [];
  // final List<String> _fullData = List.generate(10, (i) => 'Item ${i + 1}');
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startInsertingItems();
  }

  @override
  void didUpdateWidget(covariant ListViewAnimated oldWidget) {
    _startInsertingItems();
    super.didUpdateWidget(oldWidget);
  }

  void _startInsertingItems() {
    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_currentIndex >= widget.fullData.length) {
        timer.cancel();
        return;
      }
      final newItem = widget.fullData[_currentIndex++];
      _items.insert(_currentIndex - 1, newItem);
      _listKey.currentState?.insertItem(_currentIndex - 1);
    });
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0), // Start from right
        end: Offset(0.0, 0.0), // Slide to normal
      ).animate(CurvedAnimation(parent: animation, curve: Curves.decelerate)),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: ListTile(
          title: Text(_items[index]['title'] ?? 'No Title'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: widget.itemBuilder ?? _buildItem,
    );
  }
}
