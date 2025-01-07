import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/graphics_widget.dart';

class GraphicsScreen extends StatefulWidget {
  const GraphicsScreen({super.key});
  @override
  State<GraphicsScreen> createState() => GraphicsScreenState();
}

class GraphicsScreenState extends State<GraphicsScreen> {
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
      child: GraphicsWidget(
        barColor: Color(0xFF6750A4),
        thumbColor: Color(0xFF6750A4),
        thumbSize: context.mediaQuery.size.height,
        strokeWidth: 10,
        strokeCap: StrokeCap.square,
        min: 0,
        max: 1000,
        showLabel: false,
        backGroundLabel: Colors.yellow,
        onChanged: (value) {
          print(value);
        },
      ),
    );
  }
}
