import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/component/material_textfield/material_textfield.dart';
import 'package:path_provider/path_provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});
  @override
  State<LogScreen> createState() => LogScreenState();
}

class LogScreenState extends State<LogScreen> {
  TextEditingController controller = TextEditingController();
  String log = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    bool fileExists = FileSystemEntity.isFileSync('$path/log.json');
    if (!fileExists) {
      return File(path).create();
    }
    // String filePath = '$path/DB'; // 3
    // await Directory(filePath).create(recursive: true).then(
    //   (value) {
    //     return File('$filePath/log.json');
    //   },
    // );
    return File('$path/log.json');
  }

  Future<File> writeCounter(String text) async {
    final file = await _localFile;
    String textBeforeLog = await file.readAsString();
    textBeforeLog = "$textBeforeLog\n$text";
    // Write the file
    return file.writeAsString(textBeforeLog);
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return '';
    }
  }

  Future<File> clearLog() async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('');
  }

  @override
  Widget build(BuildContext context) {
    final loadingCubit = getLoadingCubit(context);
    return BaseLoading(
        isLoading: true,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                // loadingCubit.showLoading();
                log = await readCounter();
                setState(() {});
              },
              child: Text('Print Log'),
            ),
            MaterialTextField(
              hintText: 'write log',
              onChanged: (value) {},
              decorationBorderColor: Colors.amberAccent,
              controller: controller,
            ),
            TextButton(
              onPressed: () async {
                await writeCounter(controller.text);
              },
              child: Text('Write text into log file json'),
            ),
            TextButton(
              onPressed: () async {
                await clearLog();
                log = await readCounter();
                setState(() {});
              },
              child: Text('Clear Log'),
            ),
            Text(log)
          ],
        ));
  }
}
