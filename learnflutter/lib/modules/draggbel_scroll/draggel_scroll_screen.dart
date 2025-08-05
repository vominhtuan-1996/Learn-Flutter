import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

class DraggbleScrollScreen extends StatelessWidget {
  const DraggbleScrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: const Text('DraggableScrollableSheet'),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 10,
            child: DraggableScrollableActuator(
              child: ListView.builder(
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 2) {
                    return ListView.builder(
                      itemCount: 25,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(title: Text('Item $index'));
                      },
                    );
                  }
                  return ListTile(title: Text('Item $index'));
                },
              ),
            ),
          ),
          // Expanded(
          //   child: DraggableScrollableActuator(
          //     child: Container(
          //       color: Colors.blue[500],
          //       child: ListView.builder(
          //         itemCount: 25,
          //         itemBuilder: (BuildContext context, int index) {
          //           return ListTile(title: Text('Item $index'));
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: DraggableScrollableActuator(
          //     child: Container(
          //       color: Colors.red[500],
          //       child: ListView.builder(
          //         itemCount: 25,
          //         itemBuilder: (BuildContext context, int index) {
          //           return ListTile(title: Text('Item $index'));
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: DraggableScrollableActuator(
          //     child: Container(
          //       color: Colors.white,
          //       child: ListView.builder(
          //         itemCount: 25,
          //         itemBuilder: (BuildContext context, int index) {
          //           return ListTile(title: Text('Item $index'));
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: DraggableScrollableActuator(
          //     child: Container(
          //       color: Colors.yellow[500],
          //       child: ListView.builder(
          //         itemCount: 25,
          //         itemBuilder: (BuildContext context, int index) {
          //           return ListTile(title: Text('Item $index'));
          //         },
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
