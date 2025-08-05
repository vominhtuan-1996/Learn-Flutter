import 'package:flutter/material.dart';

class PullUpLoadMoreWrapper extends StatefulWidget {
  final List<Widget> children;
  final Future<void> Function() onLoadMore;
  final bool hasMore;

  const PullUpLoadMoreWrapper({
    required this.children,
    required this.onLoadMore,
    required this.hasMore,
  });

  @override
  State<PullUpLoadMoreWrapper> createState() => _PullUpLoadMoreWrapperState();
}

class _PullUpLoadMoreWrapperState extends State<PullUpLoadMoreWrapper> {
  final ScrollController _scrollController = ScrollController();
  double _overScrollExtent = 0.0;
  bool _isLoading = false;

  static const double _triggerThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final overscroll = _scrollController.position.pixels - _scrollController.position.maxScrollExtent;
    if (overscroll > 0) {
      setState(() => _overScrollExtent = overscroll);
    } else {
      setState(() => _overScrollExtent = 0);
    }

    if (!_isLoading && _overScrollExtent > _triggerThreshold && widget.hasMore) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    setState(() => _isLoading = true);
    await widget.onLoadMore();
    setState(() {
      _isLoading = false;
      _overScrollExtent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (n) {
        n.disallowIndicator(); // Tắt glow
        return true;
      },
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        children: [
          ...widget.children,
          _buildLoadMoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: (_isLoading || _overScrollExtent > 0) ? 60.0 : 0,
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator()
          : Icon(
              Icons.arrow_upward,
              size: 24 + (_overScrollExtent * 0.2).clamp(0, 16),
              color: Colors.grey.shade700,
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
