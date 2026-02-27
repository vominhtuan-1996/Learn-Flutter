// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

class ProgressHubScreenTest extends StatelessWidget {
  // final result = FilePicker.platform.pickFiles(
  //   allowMultiple: true,
  //   type: FileType.custom,
  //   allowedExtensions: ['jpg', 'pdf', 'doc'],
  // );
  @override
  Widget build(BuildContext context) {
    //  final result = await FilePicker.platform.pickFiles(
    //           allowMultiple: true,
    //           type: FileType.custom,
    //           allowedExtensions: ['jpg', 'pdf', 'doc'],
    //         );
    return Container(
      color: Colors.white,
      child: SafeArea(
        maintainBottomViewPadding: false,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Center(
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Show for a second'),
                    onPressed: () {
                      final progress = ProgressHUD.of(context);
                      progress?.show();
                      Future.delayed(const Duration(seconds: 1), () {
                        progress?.dismiss();
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Show with text'),
                    onPressed: () {
                      final progress = ProgressHUD.of(context);
                      progress?.showWithText('Loading...');
                      Future.delayed(const Duration(seconds: 1), () {
                        progress?.dismiss();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
