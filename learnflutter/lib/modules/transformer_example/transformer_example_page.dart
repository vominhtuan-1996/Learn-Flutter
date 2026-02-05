import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Enum đại diện cho các loại transformer khác nhau có sẵn trong ví dụ này.
/// Mỗi giá trị trong enum này tương ứng với một hiệu ứng chuyển trang cụ thể.
enum TransformerType {
  /// Hiệu ứng Accordion giúp các trang co giãn như đàn accordion khi chuyển đổi.
  accordion,

  /// Hiệu ứng ThreeD tạo cảm giác không gian ba chiều khi lật trang.
  threeD,

  /// Hiệu ứng ScaleAndFade kết hợp giữa việc thay đổi kích thước và độ mờ.
  scaleAndFade,

  /// Hiệu ứng ZoomIn phóng to trang tiếp theo khi nó xuất hiện.
  zoomIn,

  /// Hiệu ứng ZoomOut thu nhỏ trang hiện tại khi nó biến mất.
  zoomOut,

  /// Hiệu ứng Depth tạo chiều sâu cho các trang khi lướt qua.
  depth,
}

/// Trang ví dụ minh họa cách sử dụng [TransformerPageView] với một enum tùy chỉnh.
/// Trang này cho phép người dùng chọn các hiệu ứng chuyển cảnh khác nhau từ một danh sách.
class TransformerExamplePage extends StatefulWidget {
  const TransformerExamplePage({super.key});

  @override
  State<TransformerExamplePage> createState() => _TransformerExamplePageState();
}

class _TransformerExamplePageState extends State<TransformerExamplePage> {
  TransformerType _selectedType = TransformerType.accordion;

  /// Bản đồ ánh xạ từ [TransformerType] sang đối tượng [PageTransformer] tương ứng.
  PageTransformer _getTransformer(TransformerType type) {
    switch (type) {
      case TransformerType.accordion:
        return AccordionTransformer();
      case TransformerType.threeD:
        return ThreeDTransformer();
      case TransformerType.scaleAndFade:
        return ScaleAndFadeTransformer();
      case TransformerType.zoomIn:
        return ZoomInPageTransformer();
      case TransformerType.zoomOut:
        return ZoomOutPageTransformer();
      case TransformerType.depth:
        return DepthPageTransformer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformer Page View Example'),
        actions: [
          PopupMenuButton<TransformerType>(
            onSelected: (type) {
              setState(() {
                _selectedType = type;
              });
            },
            itemBuilder: (context) => TransformerType.values
                .map((type) => PopupMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    ))
                .toList(),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: TransformerPageView(
        loop: true,
        transformer: _getTransformer(_selectedType),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.primaries[index % Colors.primaries.length],
            child: Center(
              child: Text(
                'Page $index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Các lớp Transformer được triển khai thủ công ---

class AccordionTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position < 0.0) {
      return Transform.scale(
        scale: 1 + position,
        alignment: Alignment.topRight,
        child: child,
      );
    } else {
      return Transform.scale(
        scale: 1 - position,
        alignment: Alignment.bottomLeft,
        child: child,
      );
    }
  }
}

class ThreeDTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double width = info.width!;
    double pivotX = 0.0;
    if (position < 0 && position >= -1) {
      pivotX = width;
    }
    return Transform(
      transform: Matrix4.identity()
        ..rotate(vector.Vector3(0.0, 2.0, 0.0), position * 1.5),
      origin: Offset(pivotX, height / 2),
      child: child,
    );
  }
}

class ZoomInPageTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position > 0 && position <= 1) {
      return Transform.translate(
        offset: Offset(-width * position, 0.0),
        child: Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}

class ZoomOutPageTransformer extends PageTransformer {
  static const double minScale = 0.85;
  static const double minAlpha = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double pageWidth = info.width!;
    double pageHeight = info.height!;

    if (position < -1) {
      return child;
    } else if (position <= 1) {
      double scaleFactor = math.max(minScale, 1 - position.abs());
      double vertMargin = pageHeight * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      double opacity =
          minAlpha + (scaleFactor - minScale) / (1 - minScale) * (1 - minAlpha);

      return Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(dx, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}

class DepthPageTransformer extends PageTransformer {
  DepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0) {
      return Opacity(
        opacity: 1.0,
        child: Transform.translate(
          offset: const Offset(0.0, 0.0),
          child: Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    } else if (position <= 1) {
      const double minScale = 0.75;
      double scaleFactor = minScale + (1 - minScale) * (1 - position);

      return Opacity(
        opacity: 1.0 - position,
        child: Transform.translate(
          offset: Offset(info.width! * -position, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double scale;
  final double fade;

  ScaleAndFadeTransformer({this.fade = 0.3, this.scale = 0.8});

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double scaleFactor = (1 - position.abs()) * (1 - scale);
    double fadeFactor = (1 - position.abs()) * (1 - fade);
    double opacity = fade + fadeFactor;
    double scaleVal = scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scaleVal,
        child: child,
      ),
    );
  }
}
