import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Draggable Floating Button')),
        body: Stack(
          children: [
            // Thêm các widget khác trong widget tree nếu cần
            DraggableFloatingButton(),
          ],
        ),
      ),
    );
  }
}

class DraggableFloatingButton extends StatefulWidget {
  @override
  _DraggableFloatingButtonState createState() => _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState extends State<DraggableFloatingButton> {
  double _xPosition = 20.0; // Vị trí ngang ban đầu của nút
  double _yPosition = 20.0; // Vị trí dọc ban đầu của nút

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: Draggable(
        child: FloatingActionButton(
          onPressed: () {
            // Xử lý sự kiện onPressed nếu cần
          },
          child: Icon(Icons.add),
        ),
        feedback: FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.blue.withOpacity(0.7),
          child: Icon(Icons.add),
        ),
        childWhenDragging: Container(), // Empty container to hide the original button when dragging
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          setState(() {
            _xPosition = offset.dx;
            _yPosition = offset.dy;
          });
        },
      ),
    );
  }
}
