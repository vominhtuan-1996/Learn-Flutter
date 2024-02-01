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

class MaterialSegmentedScreenState extends State<MaterialSegmentedScreen> {
  @override
  void initState() {
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
          length: 3,
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    padding: EdgeInsets.zero,
                    child: SegmentedTabControl(
                      // Customization of widget
                      radius: const Radius.circular(8),
                      backgroundColor: Colors.grey.shade300,
                      indicatorColor: Colors.orange.shade200,
                      tabTextColor: Colors.black45,
                      selectedTabTextColor: Colors.white,
                      squeezeIntensity: 2,
                      height: 45,
                      tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: context.textTheme.bodyMedium,
                      selectedTextStyle: context.textTheme.bodyMedium,
                      // Options for selection
                      // All specified values will override the [SegmentedTabControl] setting
                      tabs: [
                        const SegmentTab(
                          label: 'ACCOUNT',
                          // For example, this overrides [indicatorColor] from [SegmentedTabControl]
                          // color: Colors.red.shade200,
                        ),
                        SegmentTab(
                          label: 'HOME',
                          backgroundColor: Colors.blue.shade100,
                          selectedTextColor: Colors.black45,
                          textColor: Colors.black26,
                        ),
                        const SegmentTab(label: 'NEW'),
                      ],
                    ),
                  ),
                  // Sample pages
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        SampleWidget(
                          label: 'FIRST PAGE',
                          color: Colors.red.shade200,
                        ),
                        SampleWidget(
                          label: 'SECOND PAGE',
                          color: Colors.blue.shade100,
                        ),
                        SampleWidget(
                          label: 'THIRD PAGE',
                          color: Colors.orange.shade200,
                        ),
                      ],
                    ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Text(label),
    );
  }
}
