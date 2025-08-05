// import 'package:docscan/docscan.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  List<String> _imgPaths = [];
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
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          bool isCameraGranted = await Permission.camera.request().isGranted;
          if (!isCameraGranted) {
            isCameraGranted = await Permission.camera.request() == PermissionStatus.granted;
          }
          if (!isCameraGranted) {
            // Have not permission to camera
            return;
          }
// Use below code for live camera.
          // try {
          //   //Make sure to await the call to scan document
          //   // List<String>? imgPaths = await DocScan.scanDocument();
          //   // If the widget was removed from the tree while the asynchronous platform
          //   // message was in flight, we want to discard the reply rather than calling
          //   // setState to update our non-existent appearance.
          //   if (!mounted) return;
          //   if (imgPaths == null || imgPaths.isEmpty) {
          //     return;
          //   }
          //   _imgPaths = imgPaths;
          // } catch (e) {
          //   print(e);
          // }
        },
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            _imgPaths.length,
            (index) {
              return Text(_imgPaths[index]);
            },
          ),
        ),
      ),
    );
  }
}
