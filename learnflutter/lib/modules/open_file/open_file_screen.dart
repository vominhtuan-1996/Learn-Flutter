// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/modules/open_file/model/item_directory_model.dart';
import 'package:learnflutter/modules/open_file/widget_item/item_widget.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
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
    String filePath = '$appDocumentsPath/$folderName'; // 3
    Directory(filePath).create(recursive: true).then(
      (value) {
        print(value.path);
      },
    );
  }

  Future<String> saveFolder(String folderName) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/DownLoadFile'; // 3
    Directory(filePath).create(recursive: true).then(
      (value) {
        print(value.path);
      },
    );
    return '$filePath/$folderName';
  }

  Future<String> downLoadFolder() async {
    Directory appDocumentsDirectory = await getApplicationCacheDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/DownLoadFile'; // 3
    Directory(filePath).create(recursive: true).then(
      (value) {
        print(value.path);
      },
    );
    return filePath;
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
    final result = await OpenFile.open(path);
    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }

  void _listofFiles() async {
    final listDirectoryTemp = [];
    listPath = [];
    final directory = (await getApplicationDocumentsDirectory());
    final directorys = (await getTemporaryDirectory());
    final directoryss = (await getApplicationSupportDirectory());
    final directorysss = (await getLibraryDirectory());
    final directoryssss = (await getApplicationCacheDirectory());
    // final directorysssss = (await getDownloadsDirectory());

    // listDirectory = Directory("$directory").listSync(); //use your folder name insted of resume.
    for (var element in directory.listSync()) {
      listDirectoryTemp.add(element);
    }
    for (var element in directorys.listSync()) {
      listDirectoryTemp.add(element);
    }
    for (var element in directoryss.listSync()) {
      listDirectoryTemp.add(element);
    }
    for (var element in directorysss.listSync()) {
      listDirectoryTemp.add(element);
    }
    for (var element in directoryssss.listSync()) {
      listDirectoryTemp.add(element);
    }
    setState(() {
      listDirectory = listDirectoryTemp;
    });
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
    return BaseLoading(
        isLoading: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              widget.isVisible = !widget.isVisible;
            });
          },
          child: const Icon(Icons.add),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('open result: $_openResult\n'),
                  TextButton(
                    child: const Text('Tap to get list file'),
                    onPressed: () {
                      UtilsHelper.logDebug(ItemDirectoryModel()..title = '312312312');
                      _listofFiles();
                    },
                  ),
                  TextButton(
                    child: const Text('Tap to save file'),
                    onPressed: () {
                      createFolder('downLoadFile');
                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        String link = "https://apis-stag.fpt.vn/resource/internet-infra/user-management/api/v1/helpers/storages/getContent?key=659dfa9412b7409efc7a0560";
                        // String link = "https://apis-stag.fpt.vn/resource/internet-infra/user-management/api/v1/helpers/storages/getContent?key=659e55ee12b7409efc7b2b6a";
                        // String link = "https://i.stack.imgur.com/MMtcX.png";

                        // downLoadFileWithLink(link, await saveFolder('659e55ee12b7409efc7b2b6a.zip'));
                        final path = await downloadFile(link, await downLoadFolder());
                        await OpenFile.open(path);
                      },
                      child: const Text('DownLoad File')),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        const Expanded(
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
