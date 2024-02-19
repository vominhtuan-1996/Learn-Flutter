import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';

class AweseomSnackBarExample extends StatelessWidget {
  const AweseomSnackBarExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Show Awesome SnackBar'),
              onPressed: () {
                final snackBar = SnackBar(
                  action: SnackBarAction(
                    label: 'aaa',
                    onPressed: () {
                      print('object');
                    },
                  ),

                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  behavior: SnackBarBehavior.fixed,
                  backgroundColor: Colors.transparent,

                  content: AwesomeSnackbarContent(
                    title: 'Thông báo!',
                    message: ' change contentType to ContentType.success, ContentType.warning or ContentType.help for variants body of snackbar!',
                    color: Colors.red,

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.success,
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
            ),
            ElevatedButton(
              child: const Text('Show Awesome SnackBar floating'),
              onPressed: () {
                final snackBar = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'Thông báo!',
                    message: ' body of snackbar!',
                    color: Colors.orange,

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.help,
                  ),
                );
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Show Awesome Material Banner'),
              onPressed: () {
                final materialBanner = MaterialBanner(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  forceActionsBelow: true,
                  content: AwesomeSnackbarContent(
                    title: 'Oh Hey!!',
                    message: 'This is an example error message that will be shown in the body of materialBanner!',

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.warning,
                    // to configure for material banner
                    inMaterialBanner: true,
                  ),
                  actions: const [SizedBox.shrink()],
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showMaterialBanner(materialBanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}
