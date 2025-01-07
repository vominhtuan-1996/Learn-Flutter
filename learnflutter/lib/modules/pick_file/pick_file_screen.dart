import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/pick_file/svg_helper.dart';
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
  SvgElement svgElement = SvgElement([]);

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          FilePickerResult? temp = await FilePicker.platform.pickFiles(allowedExtensions: ['pdf', 'svg'], type: FileType.custom);
          svgElement = await SvgUtilsHelper.getSvgElement(temp?.files.first.path ?? "");
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
              return SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: WidgetPainter(svgElement: svgElement),
                ),
                // PdfViewer.openFile(
                //   files[index]?.files.first.path ?? "",
                //   params: const PdfViewerParams(
                //     pageNumber: 1,
                //     panEnabled: true,
                //     maxScale: 1,
                //     padding: 0,
                //   ),
                // ),
              );
              // return Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         DialogUtils.showDialogWithHeroIcon(
              //           context: context,
              //           contentWidget: Container(
              //             height: context.mediaQuery.size.height / 2,
              //             width: context.mediaQuery.size.width,
              //             child: PdfViewer.openFile(
              //               files[index]?.files.first.path ?? "",
              //               params: const PdfViewerParams(
              //                 pageNumber: 1,
              //                 panEnabled: true,
              //                 maxScale: 10,
              //                 padding: 0,
              //                 minScale: 1,
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //       child: SizedBox(
              //         width: 120,
              //         height: 120,
              //         child: CustomPaint(
              //           painter: WidgetPainter(svgElement: svgElement),
              //         ),
              //         // PdfViewer.openFile(
              //         //   files[index]?.files.first.path ?? "",
              //         //   params: const PdfViewerParams(
              //         //     pageNumber: 1,
              //         //     panEnabled: true,
              //         //     maxScale: 1,
              //         //     padding: 0,
              //         //   ),
              //         // ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Padding(
              //         padding: EdgeInsets.only(left: DeviceDimension.padding / 2),
              //         child: Text(
              //           files[index]?.files.first.name ?? "",
              //           style: context.textTheme.bodyMedium?.copyWith(
              //             overflow: TextOverflow.visible,
              //           ),
              //           maxLines: 100,
              //         ),
              //       ),
              //     ),
              //   ],
              // );
            },
          ),
        ),
      ),
    );
  }
}

class WidgetPainter extends CustomPainter {
  WidgetPainter({
    required this.svgElement,
  });
  final SvgElement svgElement;
  @override
  void paint(Canvas canvas, Size size) {
    // TouchyCanvas touchyCanvas = TouchyCanvas(context, canvas);
    canvas.save(); // var point1 = pointsMove.isNotEmpty ? pointsMove.first : Offset.zero;
    final path = Path()..moveTo(svgElement.pointPath.first.x3, svgElement.pointPath.first.y3);
    final barPaint = Paint();

    for (var point in svgElement.pointPath) {
      barPaint.color = point.strokeColor;
      barPaint.strokeJoin = point.strokeJoin;
      barPaint.strokeWidth = point.strokeWidth;
      barPaint.style = PaintingStyle.stroke;
      barPaint.strokeCap = StrokeCap.round;
      barPaint.isAntiAlias = true;
      barPaint.filterQuality = FilterQuality.high;

      path.cubicTo(
        point.x1,
        point.y1,
        point.x2,
        point.y2,
        point.x3,
        point.y3,
      );
    }

    canvas.drawPath(path, barPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
