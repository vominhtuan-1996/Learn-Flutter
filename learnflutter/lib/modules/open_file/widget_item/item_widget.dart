import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learnflutter/helpper/images/images_helper.dart';
import 'package:learnflutter/helpper/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/modules/open_file/model/item_directory_model.dart';
import 'package:learnflutter/modules/open_file/widget_item/detail_file_screen.dart';
import 'package:learnflutter/modules/open_file/widget_item/get_file_screen.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:popover/popover.dart';

class ItemOpenFileWidget extends StatefulWidget {
  ItemOpenFileWidget({super.key, required this.index, required this.listDirectory});
  final List listDirectory;
  final int index;
  List<ItemDirectoryModel> listFile = [];
  @override
  State<ItemOpenFileWidget> createState() => _ItemOpenFileWidgetState();
}

class _ItemOpenFileWidgetState extends State<ItemOpenFileWidget> {
  @override
  void initState() {
    widget.listFile = convertListFile(widget.listDirectory);
    super.initState();
  }

  List<ItemDirectoryModel> convertListFile(List listDirectory) {
    List<ItemDirectoryModel> listTest = [];
    for (var element in listDirectory) {
      if (element is File) {
        final values = element.path.split('/');
        listTest.add(ItemDirectoryModel(path: element.path, title: values.last, type: TypeDirectory.File.name));
      } else if (element is Directory) {
        final values = element.path.split('/');
        listTest.add(ItemDirectoryModel(absolute: element.absolute, title: values.last, type: TypeDirectory.Directory.name, listDirectory: element.absolute.listSync()));
      }
    }
    return listTest;
  }

  Future<void> openFile(ItemDirectoryModel model) async {
    if (model.type == TypeDirectory.File.name) {
      await OpenFile.open('${model.path}');
    } else {
      List listDirectory = model.absolute!.listSync();
      print(listDirectory);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GetFileScreen(title: model.title ?? "", listDirectory: listDirectory),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              openFile(widget.listFile[widget.index]);
            },
            onLongPress: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailFileScreen()),
              );
              // showPopover(
              //   context: context,
              //   bodyBuilder: (context) => Container(
              //     color: Colors.amberAccent,
              //   ),
              //   onPop: () => print('Popover was popped!'),
              //   direction: PopoverDirection.bottom,
              //   backgroundColor: Colors.amberAccent,
              //   width: MediaQuery.of(context).size.width / 1.5,
              //   height: MediaQuery.of(context).size.height / 2,
              //   arrowDxOffset: (MediaQuery.of(context).size.width / 1.5),
              // );
              // if (widget.listFile[widget.index].type == TypeDirectory.Directory.name) {
              //   widget.listFile[widget.index].absolute!.deleteSync(recursive: true);
              // } else if (widget.listFile[widget.index].type == TypeDirectory.File.name) {
              //   await File(widget.listFile[widget.index].path!).delete();
              // }
            },
            child: Row(
              children: [
                Container(
                  child: SvgPicture.asset(
                    widget.listFile[widget.index].type == TypeDirectory.File.name ? AssetNameImageSvg.ic_file : AssetNameImageSvg.ic_folder,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.listFile[widget.index].title ?? "",
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(width: 10),
                    Visibility(
                      visible: widget.listFile[widget.index].listDirectory != null,
                      child: Text(
                        widget.listFile[widget.index].listDirectory != null ? "${widget.listFile[widget.index].listDirectory!.length} Mục" : "",
                        overflow: TextOverflow.visible,
                      ),
                    )
                  ],
                )),
              ],
            ),
          ),
          // Visibility(
          //     visible: false,
          //     child: Expanded(
          //       child: ListView.builder(
          //         itemCount: 10,
          //         itemBuilder: (context, index1) {
          //           return GestureDetector(
          //             onTap: () {
          //               openFile(widget.listDirectory[index1]);
          //             },
          //             child: const Expanded(
          //               child: Text("data"),
          //             ),
          //           );
          //         },
          //       ),
          //     ),),
        ],
      ),
    );
  }
}
