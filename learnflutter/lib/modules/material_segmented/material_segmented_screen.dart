import 'dart:math';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';

class MaterialSegmentedScreen extends StatefulWidget {
  const MaterialSegmentedScreen({super.key});
  @override
  State<MaterialSegmentedScreen> createState() => MaterialSegmentedScreenState();
}

class MaterialSegmentedScreenState extends State<MaterialSegmentedScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late int _indexTab = 0;
  List colors = [Colors.red.shade200, Colors.blue.shade100, Colors.orange.shade200];
  List title = ['ACCOUNT', 'HOME', 'NEW'];

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this, initialIndex: _indexTab);
    tabController.addListener(() {
      _indexTab = tabController.index;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        isLoading: false,
        child: DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    padding: EdgeInsets.zero,
                    child: SegmentedTabControl(
                        controller: tabController,
                        // Customization of widget
                        // radius: const Radius.circular(8),
                        // backgroundColor: Colors.grey.shade200,
                        // indicatorColor: colors[tabController.index],
                        tabTextColor: Colors.black45,
                        selectedTabTextColor: Colors.white,
                        squeezeIntensity: 2,
                        height: 45,
                        tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: context.textTheme.bodyMedium,
                        selectedTextStyle: context.textTheme.bodyMedium,
                        // Options for selection
                        // All specified values will override the [SegmentedTabControl] setting
                        tabs: List.generate(
                          tabController.length,
                          (index) {
                            return SegmentTab(
                              label: title[index],
                              color: colors[index],
                            );
                          },
                        )),
                  ),
                  // Sample pages
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: tabController,
                        children: List.generate(
                          tabController.length,
                          (index) {
                            return SampleWidget(
                              label: title[index],
                              color: colors[index],
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Map<int, Widget> _children = {0: Text('Flutter'), 1: Text('Dart'), 2: Text('Desktop'), 3: Text('Mobile'), 4: Text('Web')};

  // Holds all indices of children to be disabled.
  // Set this list either null or empty to have no children disabled.
  List<int> _disabledIndices = [];

  int _randomInt() {
    return Random.secure().nextInt(_children.length);
  }
}

class SampleWidget extends StatelessWidget {
  const SampleWidget({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Text(label),
    );
  }
}
