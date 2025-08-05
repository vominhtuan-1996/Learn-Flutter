import 'package:learnflutter/utils_helper/path_drawing/src/parse_path.dart';
import 'package:sdk_pms/general_import.dart';

class HomeRefreshPainter extends CustomPainter {
  final double progress;

  HomeRefreshPainter({required this.progress});

  final String rawPath =
      "M13 19H19V9.97815L12 4.53371L5 9.97815V19H11V13H13V19ZM21 20C21 20.5523 20.5523 21 20 21H4C3.44772 21 3 20.5523 3 20V9.48907C3 9.18048 3.14247 8.88917 3.38606 8.69972L11.3861 2.47749C11.7472 2.19663 12.2528 2.19663 12.6139 2.47749L20.6139 8.69972C20.8575 8.88917 21 9.18048 21 9.48907V20Z";
  // final String rawPath =
  //     "M 23.951172 4 A 1.50015 1.50015 0 0 0 23.072266 4.3222656 L 8.859375 15.519531 C 7.0554772 16.941163 6 19.113506 6 21.410156 L 6 40.5 C 6 41.863594 7.1364058 43 8.5 43 L 18.5 43 C 19.863594 43 21 41.863594 21 40.5 L 21 30.5 C 21 30.204955 21.204955 30 21.5 30 L 26.5 30 C 26.795045 30 27 30.204955 27 30.5 L 27 40.5 C 27 41.863594 28.136406 43 29.5 43 L 39.5 43 C 40.863594 43 42 41.863594 42 40.5 L 42 21.410156 C 42 19.113506 40.944523 16.941163 39.140625 15.519531 L 24.927734 4.3222656 A 1.50015 1.50015 0 0 0 23.951172 4 z M 24 7.4101562 L 37.285156 17.876953 C 38.369258 18.731322 39 20.030807 39 21.410156 L 39 40 L 30 40 L 30 30.5 C 30 28.585045 28.414955 27 26.5 27 L 21.5 27 C 19.585045 27 18 28.585045 18 30.5 L 18 40 L 9 40 L 9 21.410156 C 9 20.030807 9.6307412 18.731322 10.714844 17.876953 L 24 7.4101562 z";
  // final String rawPath =
  //     "M25.1552 34.2956C24.7167 34.2956 24.2781 34.1077 24.0275 33.7318L20.5192 29.2211C20.018 28.5946 20.1433 27.7175 20.7698 27.2163C21.3963 26.7151 22.2734 26.8404 22.7746 27.4669L25.1552 30.5367L30.4177 23.708C30.9189 23.0815 31.796 22.9562 32.4225 23.4574C33.049 23.9586 33.1743 24.8357 32.6731 25.4622L26.2829 33.7318C25.9697 34.045 25.5938 34.2956 25.1552 34.2956Z";
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24;
    final matrix = Matrix4.identity()..scale(scale, scale);
    final Path fullPath = parseSvgPathData(rawPath).transform(matrix.storage);

    final paintGray = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.grey.shade300;

    final paintBlack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.black;

    // Vẽ full path màu xám trước
    canvas.drawPath(fullPath, paintGray);

    // Vẽ path đen theo progress
    final pathMetrics = fullPath.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length * progress;
      final Path extractPath = metric.extractPath(0, length);
      canvas.drawPath(extractPath, paintBlack);
    }
  }

  @override
  bool shouldRepaint(covariant HomeRefreshPainter oldDelegate) => oldDelegate.progress != progress;
}
