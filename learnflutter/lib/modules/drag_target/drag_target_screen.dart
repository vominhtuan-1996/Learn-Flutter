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
  List colors = [Colors.red, Colors.blue, Colors.yellow, Colors.brown, Colors.deepPurple];
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
        child: Column(
          children: List.generate(
            5,
            (index) {
              bool accepted = false;
              Color color = colors[index];
              Color colorAccepted = Colors.black;
              Offset offset = Offset.zero;
              return Draggable(
                data: colors,
                feedback: Container(
                  width: context.mediaQuery.size.width / 2,
                  height: 100,
                  color: color,
                ),
                onDragStarted: () {
                  indexStarted = index;
                },
                childWhenDragging: Container(),
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return accepted
                        ? Positioned(
                            left: offset.dx,
                            top: offset.dy,
                            child: Container(
                              width: context.mediaQuery.size.width / 2,
                              height: 100,
                              color: colorAccepted,
                            ),
                          )
                        : Container(
                            width: context.mediaQuery.size.width / 2,
                            height: 100,
                            color: color,
                          );
                  },
                  onWillAcceptWithDetails: (DragTargetDetails details) {
                    offset = details.offset;
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    colorAccepted = (details.data as List)[indexStarted];
                    print(index);
                    offset = details.offset;
                    print('onAcceptWithDetails ${details.offset.dx}');
                    print('onAcceptWithDetails ${details.offset.dy}');
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
