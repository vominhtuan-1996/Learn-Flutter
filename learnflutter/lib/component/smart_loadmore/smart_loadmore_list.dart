import 'package:flutter/material.dart';
import 'package:learnflutter/modules/animation/widget/list_view_animation.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef FetchItems<T> = Future<List<T>> Function(int offset, int limit);

class SmartLoadMoreList<T> extends StatefulWidget {
  final FetchItems<T> fetchItems;
  final ItemBuilder<T> itemBuilder;
  final int prefetchSize;
  final int pageSize;

  const SmartLoadMoreList({
    Key? key,
    required this.fetchItems,
    required this.itemBuilder,
    this.prefetchSize = 20,
    this.pageSize = 10,
  }) : super(key: key);

  @override
  State<SmartLoadMoreList<T>> createState() => _SmartLoadMoreListState<T>();
}

class _SmartLoadMoreListState<T> extends State<SmartLoadMoreList<T>> {
  List<T> _items = [];
  int _visibleCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    final items = await widget.fetchItems(0, widget.prefetchSize);
    setState(() {
      _items = items;
      _visibleCount = widget.pageSize;
      _isLoading = false;
      _hasMore = items.length >= widget.prefetchSize;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    if (_visibleCount < _items.length) {
      setState(() {
        _visibleCount += widget.pageSize;
        _isLoading = false;
      });
    } else {
      final newItems = await widget.fetchItems(_items.length, widget.pageSize);
      setState(() {
        _items.addAll(newItems);
        _visibleCount += widget.pageSize;
        _isLoading = false;
        _hasMore = newItems.length == widget.pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListViewAnimated(
      fullData: _items,
      itemBuilder: (context, index, animation) {
        if ((index < _visibleCount && index < _items.length)) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0), // Start from right
              end: Offset(0.0, 0.0), // Slide to normal
            ).animate(CurvedAnimation(parent: animation, curve: Curves.decelerate)),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: ListTile(
                title: Text((_items[index]).toString()),
              ),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
        }
        return Container();
      },
    );
  }
}
