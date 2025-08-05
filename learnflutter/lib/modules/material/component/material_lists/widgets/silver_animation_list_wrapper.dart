import 'package:flutter/material.dart';

class SliverAnimatedListWrapper<T> extends StatefulWidget {
  final List<T> initialItems;
  final Widget Function(BuildContext context, T item, int index, Animation<double> animation) itemBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool enableDelete;

  const SliverAnimatedListWrapper({
    super.key,
    required this.initialItems,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.enableDelete = false,
  });

  @override
  State<SliverAnimatedListWrapper<T>> createState() => _SliverAnimatedListWrapperState<T>();
}

class _SliverAnimatedListWrapperState<T> extends State<SliverAnimatedListWrapper<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _items.addAll(widget.initialItems);

    _scrollController.addListener(() {
      if (widget.onLoadMore != null && !_isLoadingMore && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoadingMore = true);
    final newItems = await widget.onLoadMore?.call() ?? [];
    for (final item in newItems) {
      _items.add(item);
      _listKey.currentState?.insertItem(_items.length - 1);
    }
    setState(() => _isLoadingMore = false);
  }

  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => widget.itemBuilder(context, removedItem, index, animation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAnimatedList(
            key: _listKey,
            initialItemCount: _items.length,
            itemBuilder: (context, index, animation) {
              final itemWidget = widget.itemBuilder(context, _items[index], index, animation);
              if (widget.enableDelete) {
                return Dismissible(
                  key: ValueKey(_items[index]),
                  onDismissed: (_) => _removeItem(index),
                  child: itemWidget,
                );
              } else {
                return itemWidget;
              }
            },
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
