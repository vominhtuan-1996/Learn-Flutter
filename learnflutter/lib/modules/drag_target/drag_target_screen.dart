import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';

class DragTargetScreen extends StatefulWidget {
  const DragTargetScreen({super.key});
  @override
  State<DragTargetScreen> createState() => DragTargetScreenState();
}

class DragTargetScreenState extends State<DragTargetScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<Color> colors = [Colors.red, Colors.blue, Colors.yellow, Colors.brown, Colors.deepPurple];
  List<Color> shuffledColors = []; // Tạo bản sao

  int indexStarted = 0;
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
      child: SingleChildScrollView(
        child: Row(
          children: List.generate(
            5,
            (index) {
              bool accepted = false;
              Color color = shuffledColors.isNotEmpty ? shuffledColors[index] : colors[index];
              Offset offset = Offset.zero;
              return Draggable(
                data: colors,
                feedback: Container(
                  width: 50,
                  height: 50,
                  color: color,
                ),
                onDragStarted: () {
                  indexStarted = index;
                  shuffledColors = List.from(colors);
                },
                childWhenDragging: Container(),
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    if (accepted) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: shuffledColors[indexStarted],
                      );
                    }
                    return Container(
                      width: 50,
                      height: 50,
                      color: color,
                    );
                  },
                  onWillAcceptWithDetails: (DragTargetDetails details) {
                    offset = details.offset;
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    Color temp = shuffledColors[index]; // Lưu tạm màu blue
                    shuffledColors[indexStarted] = shuffledColors[index]; // Hoán đổi blue và deepPurple
                    shuffledColors[index] = temp; // Gán
                    print(shuffledColors);
                    print(colors);
                    print(index);
                    offset = details.offset;
                    print('onAcceptWithDetails ${details.offset.dx}');
                    print('onAcceptWithDetails ${details.offset.dy}');
                    colors = shuffledColors;
                    accepted = true;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
