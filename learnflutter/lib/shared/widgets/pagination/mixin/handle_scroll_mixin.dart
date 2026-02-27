import 'package:flutter/cupertino.dart';

/// handle scroll listener
/// onScrollEnd
/// Don't use on [BouncingScrollPhysics], it will take a long time to react
mixin HandleScrollMixin {
  // put the controller into the scroll Widget (such as ListView, SingleChildScrollView)
  late final ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  // run it in initState
  void initScroll([ScrollController? scrollController]) {
    _scrollController = scrollController ?? ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void disposeScroll() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
  }

  _handleScroll() {
    // on scroll end
    if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
      onScrollEnd();
    } else if (_scrollController.offset == 0) {
      onScrollStart();
    }
  }

  // override it
  onScrollEnd() {}

  // override it
  onScrollStart() {}
}

class NormalScrollBehavior extends ScrollBehavior {
  ///Remove scroll glow
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  /// Remove bouncing on IOS
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => ClampingScrollPhysics();
}
