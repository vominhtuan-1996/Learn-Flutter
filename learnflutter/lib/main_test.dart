import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Draggable Floating Button')),
        body: const Stack(
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
  const DraggableFloatingButton({super.key});

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
        feedback: FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.blue.withOpacity(0.7),
          child: const Icon(Icons.add),
        ),
        childWhenDragging: Container(), // Empty container to hide the original button when dragging
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          setState(() {
            _xPosition = offset.dx;
            _yPosition = offset.dy;
          });
        },
        child: FloatingActionButton(
          onPressed: () {
            // Xử lý sự kiện onPressed nếu cần
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
