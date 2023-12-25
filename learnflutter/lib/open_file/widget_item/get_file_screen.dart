import 'package:flutter/material.dart';
import 'package:learnflutter/open_file/widget_item/item_widget.dart';

class GetFileScreen extends StatefulWidget {
  GetFileScreen({super.key, required this.title, required this.listDirectory});
  String title;
  List listDirectory;
  @override
  State<GetFileScreen> createState() => _GetFileScreenState();
}

class _GetFileScreenState extends State<GetFileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.visible),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.listDirectory.length,
              itemBuilder: (context, index) {
                return ItemOpenFileWidget(
                  listDirectory: widget.listDirectory,
                  index: index,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
