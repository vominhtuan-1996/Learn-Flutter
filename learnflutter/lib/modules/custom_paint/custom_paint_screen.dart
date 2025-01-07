import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/color_picker/color_picker.dart';
import 'package:learnflutter/modules/custom_paint/custom_paint.dart';
import 'package:learnflutter/modules/popover/popover_scren.dart';

class CustomPainterScreen extends StatefulWidget {
  const CustomPainterScreen({super.key});

  @override
  State<CustomPainterScreen> createState() => _CustomPainterScreenState();
}

class _CustomPainterScreenState extends State<CustomPainterScreen> with TickerProviderStateMixin {
  final List<PointDrag> pointsMove = [];
  bool isMove = false;
  Color currentColor = Colors.red;
  double currentstrokeWidth = 3;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                pointsMove.add(PointDrag()
                  ..offset = details.globalPosition
                  ..strokeWidth = currentstrokeWidth
                  ..color = currentColor
                  ..isMove = true);
              },
              onPanUpdate: (details) {
                pointsMove.add(PointDrag()
                  ..offset = details.globalPosition
                  ..strokeWidth = currentstrokeWidth
                  ..color = currentColor
                  ..isMove = true);
                setState(() {});
              },
              onPanEnd: (details) {
                pointsMove.add(PointDrag()
                  ..offset = pointsMove.last.offset
                  ..strokeWidth = currentstrokeWidth
                  ..color = currentColor
                  ..isMove = false);
                setState(() {});
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DragWidgetPainter(
                  isMove: isMove,
                  pointsMove: pointsMove,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                BarColorPicker(
                    initialColor: currentColor,
                    width: 120,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.Color,
                    colorListener: (int value) {
                      setState(() {
                        currentstrokeWidth = 3;
                        currentColor = Color(value);
                      });
                    }),
                TextButton(
                  onPressed: () {
                    pointsMove.clear();
                    setState(() {});
                  },
                  child: Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    currentColor = Colors.white;
                    currentstrokeWidth = 24;
                    setState(() {});
                  },
                  child: Icon(Icons.pentagon_rounded),
                ),
                TextButton(
                  onPressed: () {
                    pointsMove.clear();
                    setState(() {});
                  },
                  child: Icon(Icons.pest_control_rodent),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
