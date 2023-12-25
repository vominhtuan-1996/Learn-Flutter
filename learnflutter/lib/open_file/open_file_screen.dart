import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learnflutter/Helpper/images/images_helper.dart';
import 'package:learnflutter/open_file/widget_item/item_widget.dart';
import 'package:learnflutter/src/app_box_decoration.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

class OpenFileScreen extends StatefulWidget {
  OpenFileScreen({super.key, this.isVisible = false});
  bool isVisible;
  @override
  State<OpenFileScreen> createState() => _MyOpenFileScreen();
}

class _MyOpenFileScreen extends State<OpenFileScreen> {
  @override
  void initState() {
    _listofFiles();
    super.initState();
  }

  var _openResult = 'Unknown';
  var listPath = [];
  var listDirectory = [];
  void createFolder(String folderName) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/${folderName}'; // 3
    Directory(filePath).create(recursive: true).then(
      (value) {
        print(value.path);
      },
    );
  }

  void _requestAppDocumentsDirectory() {
    setState(() {
      final filePath = getApplicationDocumentsDirectory();
    });
  }

  void _requestAppLibraryDirectory() {
    getLibraryDirectory();
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/Picture'; // 3
    var directory = await Directory(filePath).create(recursive: true);
    return directory.path;
  }

  void saveFile() async {
    File file = File(await getFilePath()); // 1
    file.writeAsString("This is my demo text that will be saved to : demoTextFile.txt"); // 2
  }

  Future<void> openFile(String path) async {
    final result = await OpenFile.open('${path}');
    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }

  void _listofFiles() async {
    listDirectory = [];
    listPath = [];
    final directory = (await getApplicationDocumentsDirectory());
    final directorys = (await getTemporaryDirectory());
    final directoryss = (await getApplicationSupportDirectory());
    final directorysss = (await getLibraryDirectory());
    final directoryssss = (await getApplicationCacheDirectory());
    // final directorysssss = (await getDownloadsDirectory());

    // listDirectory = Directory("$directory").listSync(); //use your folder name insted of resume.
    for (var element in directory.listSync()) {
      listDirectory.add(element);
    }
    for (var element in directorys.listSync()) {
      listDirectory.add(element);
    }
    for (var element in directoryss.listSync()) {
      listDirectory.add(element);
    }
    for (var element in directorysss.listSync()) {
      listDirectory.add(element);
    }
    for (var element in directoryssss.listSync()) {
      listDirectory.add(element);
    }
  }

  String _pathDirectory(BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    String path = "";
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        path = snapshot.error.toString();
      } else if (snapshot.hasData) {
        path = snapshot.data!.path;
      } else {
        path = 'path unavailable';
      }
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Test Share file'),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              widget.isVisible = !widget.isVisible;
            });
          },
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('open result: $_openResult\n'),
                  TextButton(
                    child: Text('Tap to get list file'),
                    onPressed: () {
                      setState(() {
                        _listofFiles();
                      });
                    },
                  ),
                  TextButton(
                    child: Text('Tap to save file'),
                    onPressed: () {
                      createFolder('Camerra_${DateTime.now()}');
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: listDirectory.length,
                      itemBuilder: (context, index) {
                        return ItemOpenFileWidget(
                          listDirectory: listDirectory,
                          index: index,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: widget.isVisible,
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ListView.builder(
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 40,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: SvgPicture.asset(
                                AssetNameImageSvg.ic_folder,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
