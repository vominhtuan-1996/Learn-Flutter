import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class BitmapUtils {
  Future<Uint8List> generateImagePngAsBytes(String text) async {
    ByteData? image = await generateSquareWithText(text);
    return image!.buffer.asUint8List();
  }

  Future<ByteData?> generateSquareWithText(String text) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(300.0, 100.0)));

    final stroke = Paint()
      ..color = Colors.grey
      ..colorFilter = const ui.ColorFilter.linearToSrgbGamma()
      ..style = PaintingStyle.stroke;

    canvas.drawRect(const Rect.fromLTWH(0.0, 0.0, 100.0, 100.0), stroke);
    final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();

    final textPainterABC = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainterABC.layout();

// Draw the text centered around the point (50, 100) for instance
    // MyCustomPainter().paint(canvas, Size(300, 200));
    MyCustomPainter().paint(canvas, const Size(100, 100));
    textPainter.paint(canvas, const Offset(110, 0));
    textPainterABC.paint(canvas, const Offset(110, 80));

    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(100, 100);
    final ByteData? pngBytes = await img.toByteData(format: ImageByteFormat.png);
    return pngBytes;
  }
}

class Sky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const RadialGradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: <Color>[Color(0xFFddFF00), Color(0xFF0099FF)],
      stops: <double>[0.4, 1.0],
    );
    final container = Container(
      color: Colors.red,
      height: 300,
    );
    final paint = Paint();
    paint.color = Colors.red;
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    // canvas.drawRect(rect, paint);
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(Sky oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => false;
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw your custom widget using the Canvas object.
    // Here's an example of drawing a simple rectangle.
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Return true if your widget should repaint, otherwise false.
  }
}

// To use your custom painter as a Paint object, simply create an instance of your custom painter and pass it to the Paint constructor.

final myPaint = Paint()..shader = LinearGradient(colors: [Colors.red, Colors.yellow]).createShader(Rect.fromLTRB(0, 0, 100, 100));

final myCustomPainter = MyCustomPainter();

final myPaint2 = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..color = Colors.black;

@override
void paint(Canvas canvas, Size size) {
  // Draws a blue rectangle using the custom painter.
  myCustomPainter.paint(canvas, size);

  // Use your custom painter as a Paint object.
  canvas.drawCircle(const Offset(150, 150), 50, myCustomPainter as Paint);

  // Use additional paints.
  canvas.drawCircle(Offset(300, 300), 50, myPaint);
  canvas.drawRect(Rect.fromLTWH(250, 100, 100, 50), myPaint2);
}

// WidgetTextNumberRatingComponent(MTCpTextNumberRatingCriteria textNumberatingComponentModel) {
//   return BlocProvider<SwitchCompoentTypeViewCubit>(
//     create: (context) => SwitchCompoentTypeViewCubit(SwitchCompoentTypeViewState.initial()),
//     child: BlocBuilder<SwitchCompoentTypeViewCubit, SwitchCompoentTypeViewState>(
//       builder: (context, state) {
//         return EnableWidget(
//           enable: state.enableAll,
//           child: Column(
//             children: <Widget>[
//               Row(
//                 crossAxisAlignment: state.isShowFullTitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: TitleView<SwitchCompoentTypeViewCubit, SwitchCompoentTypeViewState>(
//                       widthText: widthTextTitle,
//                       title: switchComponentModel.title!,
//                       textStyle: AppTextStyles.bodyLargeW600,
//                     ),
//                   ),
//                   SwitchComponent(
//                     textSwitchOn: textSwitchOnOff.first,
//                     textSwitchOff: textSwitchOnOff.last,
//                     onChangeSwitch: (value) {
//                       // switchComponentModel.value = value;
//                     },
//                   ),
//                 ],
//               ),
//               SpaceVertical(height: 15),
//               Visibility(
//                 visible: state.hiddenNote,
//                 child: NoteComponent(
//                   noteValue: switchComponentModel.note!,
//                   onTextChange: (value) {
//                     print(value);
//                   },
//                 ),
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Visibility(
//                     visible: switchComponentModel.hasImage!,
//                     child: ImageComponent(
//                       imageModel: bb,
//                     ),
//                   )
//                 ],
//               ),
//               SpaceVertical(height: 15),
//               Visibility(
//                 visible: switchComponentModel.isMaintenance == ConstantsComponent.IS_MAINTENANCE_ON,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: TPKTCommentComponent(
//                     evaluation: switchComponentModel.evaluation!,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     ),
//   )
// }
