import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/metarial_dialog/dialog_utils.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PickFileScreen extends StatefulWidget {
  const PickFileScreen({super.key});

  @override
  State<PickFileScreen> createState() => _PickFileScreenState();
}

class _PickFileScreenState extends State<PickFileScreen> {
  List<FilePickerResult?> files = [];
  Uint8List? files1;
  bool isShow = false;
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          FilePickerResult? temp = await FilePicker.platform.pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);
         
          if (temp != null) {
            files.add(temp);
            setState(() {});
          }
        },
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            files.length,
            (index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      DialogUtils.showDialogWithHeroIcon(
                        context: context,
                        contentWidget: Container(
                          height: context.mediaQuery.size.height / 2,
                          width: context.mediaQuery.size.width,
                          child: PdfViewer.openFile(
                            files[index]?.files.first.path ?? "",
                            params: const PdfViewerParams(
                              pageNumber: 1,
                              panEnabled: true,
                              maxScale: 10,
                              padding: 0,
                              minScale: 1,
                            ),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: PdfViewer.openFile(
                        files[index]?.files.first.path ?? "",
                        params: const PdfViewerParams(
                          pageNumber: 1,
                          panEnabled: true,
                          maxScale: 1,
                          padding: 0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: DeviceDimension.padding / 2),
                      child: Text(
                        files[index]?.files.first.name ?? "",
                        style: context.textTheme.bodyMedium?.copyWith(
                          overflow: TextOverflow.visible,
                        ),
                        maxLines: 100,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
