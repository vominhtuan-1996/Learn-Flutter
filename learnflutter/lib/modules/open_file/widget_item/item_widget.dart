import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learnflutter/custom_widget/custom_snackbar.dart';
import 'package:learnflutter/helpper/images/images_helper.dart';
import 'package:learnflutter/modules/open_file/model/item_directory_model.dart';
import 'package:learnflutter/modules/open_file/widget_item/detail_file_screen.dart';
import 'package:learnflutter/modules/open_file/widget_item/get_file_screen.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:xml/xml.dart';

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
    if (model.path?.split('.').last == "gpx") {
      List<LatLng> coordinates = await extractCoordinatesFromGpx(model.path ?? "");

      double totalDistance = 0;
      for (int i = 0; i < coordinates.length - 1; i++) {
        totalDistance += haversineDistance(coordinates[i], coordinates[i + 1]);
      }
      showBottomSheet(
        context: context,
        builder: (context) {
          return Center(
            child: Text('Quãng đường chạy được là: ${totalDistance} km'),
          );
        },
      );
    } else if (model.type == TypeDirectory.File.name) {
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

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

double haversineDistance(LatLng point1, LatLng point2) {
  const double R = 6371; // bán kính Trái Đất tính bằng km
  double lat1 = point1.latitude;
  double lon1 = point1.longitude;
  double lat2 = point2.latitude;
  double lon2 = point2.longitude;

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c;
  return distance;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

Future<List<LatLng>> extractCoordinatesFromGpx(String filePath) async {
  var file = File(filePath);
  var document = XmlDocument.parse(await file.readAsString());
  var trkpts = document.findAllElements('trkpt');

  return trkpts.map((trkpt) {
    var lat = double.parse(trkpt.getAttribute('lat') ?? '0');
    var lon = double.parse(trkpt.getAttribute('lon') ?? '0');
    return LatLng(lat, lon);
  }).toList();
}
