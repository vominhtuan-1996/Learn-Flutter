import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';

class DropWaterRefreshDemo extends StatefulWidget {
  const DropWaterRefreshDemo({super.key});

  @override
  _DropWaterRefreshDemoState createState() => _DropWaterRefreshDemoState();
}

class _DropWaterRefreshDemoState extends State<DropWaterRefreshDemo> {
  List<String> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Giả lập một request đến server
    await Future.delayed(const Duration(seconds: 2));

    // Giả lập dữ liệu nhận được từ server
    final List<String> newItems = List.generate(20, (index) => 'Item ${index + 1}');

    setState(() {
      items = newItems;
      isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop Water Refresh Demo'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverOverlapAbsorber(
                  handle: SliverOverlapAbsorberHandle(),
                  sliver: SliverRefreshControl(
                    onRefresh: _onRefresh,
                    indicatorBuilder: (BuildContext context, RefreshIndicatorMode refreshState, double pulledExtent, double refreshTriggerPullDistance, double refreshIndicatorExtent) {
                      if (refreshState == RefreshIndicatorMode.drag) {
                        double percentage = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
                        return Center(
                          child: Opacity(
                            opacity: percentage,
                            child: SpinKitRipple(
                              color: Colors.blue,
                              size: 50 * percentage,
                            ),
                          ),
                        );
                      } else if (refreshState == RefreshIndicatorMode.refresh) {
                        return const Center(
                          child: SpinKitRipple(
                            color: Colors.blue,
                            size: 50,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return ListTile(
                        title: Text(items[index]),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ],
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DropWaterRefreshDemo(),
  ));
}

typedef RefreshCallback = Future<void> Function();

enum RefreshIndicatorMode {
  drag,
  refresh,
}

class SliverRefreshControl extends StatelessWidget {
  final RefreshCallback onRefresh;
  final Widget Function(BuildContext, RefreshIndicatorMode, double, double, double) indicatorBuilder;

  const SliverRefreshControl({super.key, 
    required this.onRefresh,
    required this.indicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      color: Colors.red,
    )
        // BlocBuilder<RefreshBloc, RefreshIndicatorMode>(
        //   builder: (context, refreshState) {
        //     return StreamBuilder<double>(
        //       stream: context.read<RefreshBloc>().pulledExtentStream,
        //       builder: (context, snapshot) {
        //         double pulledExtent = snapshot.data ?? 0;
        //         return indicatorBuilder(
        //           context,
        //           refreshState,
        //           pulledExtent,
        //           100.0, // refreshTriggerPullDistance
        //           100.0, // refreshIndicatorExtent
        //         );
        //       },
        //     );
        //   },
        // ),
        );
  }
}

class RefreshBloc extends BaseCubit {
  RefreshBloc(super.initialState);

  // Implement your RefreshBloc here. This is just a placeholder.
  Stream<double> get pulledExtentStream => Stream.value(0);
}
