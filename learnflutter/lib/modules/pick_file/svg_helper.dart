import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/utils_helper/path_drawing/src/parse_path.dart';
import 'package:xml/xml.dart';

class SvgElement {
  late List<SvgElementPath> pointPath;

  SvgElement(this.pointPath);
}

class SvgElementPath {
  double x1;
  double y1;
  double x2;
  double y2;
  double x3;
  double y3;
  late Color strokeColor;
  late double strokeWidth;
  late StrokeJoin strokeJoin;
  SvgElementPath(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);
}

class SvgUtilsHelper {
  static Future<SvgElement> getSvgElement(String filePath) async {
    final file = File(filePath);
    final document = XmlDocument.parse(await file.readAsString());

    SvgElement element = SvgElement([]);
    element.pointPath = await getSvgPoints(document);
    return element;
  }

  static Future<List<SvgElementPath>> getSvgPoints(XmlDocument document) async {
    List<SvgElementPath> pointsList = [];
    final namedColors = {
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
      'cyan': Colors.cyan,
      'magenta': Colors.pink, // Magenta is not directly available, using pink
      // Add more named colors as needed
    };
    // Extract points from <path> elements
    for (var path in document.findAllElements('path')) {
      final d = path.getAttribute('d');
      if (d != null) {
        pointsList.addAll(parsePathData(d));
      }
      final stroke = path.getAttribute('stroke');
      if (stroke != null) {
        if (namedColors.containsKey(stroke)) {
          for (var element in pointsList) {
            element.strokeColor = namedColors[stroke]!;
          }
        } else if (stroke.startsWith('#')) {
          // Handle hex color format
          String hexColor = stroke.replaceFirst('#', '');
          if (hexColor.length == 6) {
            for (var element in pointsList) {
              element.strokeColor = Color(int.parse('FF$hexColor', radix: 16));
            }
          } else if (hexColor.length == 8) {
            for (var element in pointsList) {
              element.strokeColor = Color(int.parse(hexColor, radix: 16));
            }
          }
        } else if (stroke.startsWith('rgb')) {
          // Handle rgb(r, g, b) format
          final rgbValues = stroke.replaceAll(RegExp(r'[^\d,]'), '').split(',');
          if (rgbValues.length == 3) {
            for (var element in pointsList) {
              element.strokeColor = Color.fromARGB(
                255,
                int.parse(rgbValues[0]),
                int.parse(rgbValues[1]),
                int.parse(rgbValues[2]),
              );
            }
          }
        }
      }

      final strokeWidth = path.getAttribute('stroke-width');
      if (strokeWidth != null) {
        for (var element in pointsList) {
          element.strokeWidth = double.parse(strokeWidth);
        }
      }

      final strokeLinecap = path.getAttribute('stroke-linecap');
      if (strokeLinecap != null) {
        switch (strokeLinecap) {
          case "miter":
            for (var element in pointsList) {
              element.strokeJoin = StrokeJoin.miter;
            }
            break;
          case "round":
            for (var element in pointsList) {
              element.strokeJoin = StrokeJoin.round;
            }
            break;
          case "bevel":
            for (var element in pointsList) {
              element.strokeJoin = StrokeJoin.bevel;
            }
            break;
          default:
            for (var element in pointsList) {
              element.strokeJoin = StrokeJoin.round;
            }
            break;
        }
      }
    }
    return pointsList;
  }

  static List<SvgElementPath> parsePathData(String d) {
    List<SvgElementPath> points = [];
    List<String> commands =
        d.split(RegExp(r'(?=[MLZmlzCHVQAhvq])')).where((s) => s.isNotEmpty).toList();

    double startX = 0;
    double startY = 0;
    double currentX = 0;
    double currentY = 0;

    for (String command in commands) {
      String type = command[0];
      List<String> params =
          command.substring(1).trim().split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();

      switch (type) {
        case 'M':
        case 'm':
          currentX = double.parse(params[0].trim());
          currentY = double.parse(params[1].trim());
          startX = currentX;
          startY = currentY;
          points.add(SvgElementPath(startX, startY, startX, startY, startX, startY));
          break;
        case 'L':
        case 'l':
          currentX = double.parse(params[0].trim());
          currentY = double.parse(params[1].trim());
          points.add(SvgElementPath(startX, startY, startX, startY, startX, startY));
          break;
        case 'H':
        case 'h':
          currentX = double.parse(params[0].trim());
          points.add(SvgElementPath(startX, startY, startX, startY, startX, startY));
          break;
        case 'V':
        case 'v':
          currentY = double.parse(params[0].trim());
          points.add(SvgElementPath(startX, startY, startX, startY, startX, startY));
          break;
        case 'C':
        case 'c':
          double x1 = double.parse(params[0].trim());
          double y1 = double.parse(params[1].trim());
          double x2 = double.parse(params[2].trim());
          double y2 = double.parse(params[3].trim());
          currentX = double.parse(params[4].trim());
          currentY = double.parse(params[5].trim());
          points.add(SvgElementPath(x1, y1, x2, y2, currentX, currentY));
          break;
        case 'Q':
        case 'q':
          double x1 = double.parse(params[0].trim());
          double y1 = double.parse(params[1].trim());
          currentX = double.parse(params[2].trim());
          currentY = double.parse(params[3].trim());
          points.add(SvgElementPath(x1, y1, x1, x1, currentX, currentY));
          break;
        case 'A':
        case 'a':
          // Elliptical Arc: A rx ry x-axis-rotation large-arc-flag sweep-flag x y
          // For simplicity, we only add the end point of the arc
          currentX = double.parse(params[5].trim());
          currentY = double.parse(params[6].trim());
          points.add(SvgElementPath(currentX, currentY, currentX, currentY, currentX, currentY));
          break;
        case 'Z':
        case 'z':
          currentX = startX;
          currentY = startY;
          points.add(SvgElementPath(currentX, currentY, currentX, currentY, currentX, currentY));
          break;
        default:
          // Handle other commands if necessary
          break;
      }
    }

    return points;
  }

  static List<double> parsePoints(String points) {
    return points.split(RegExp(r'\s+|,')).map(double.parse).toList();
  }

  static Future<String> loadSvgPathFromAsset(String assetPath) async {
    final svgString = await rootBundle.loadString(assetPath);

    // Tìm tất cả path từ thuộc tính `d="..."` trong SVG
    final pathRegExp = RegExp(r'd="([^"]+)"');
    final matches = pathRegExp.allMatches(svgString);
    String d = "";
    for (final match in matches) {
      d = match.group(1) ?? "";
    }

    return d;
  }
}
