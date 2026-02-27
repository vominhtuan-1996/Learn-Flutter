import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Enum đại diện cho các loại transformer khác nhau có sẵn trong ví dụ này.
/// Mỗi giá trị trong học phần này tương ứng với một hiệu ứng chuyển trang vật lý cụ thể.
/// Các hiệu ứng này được thiết kế để mang lại trải nghiệm tương tác sinh động cho người dùng khi lướt qua các trang nội dung.
/// Việc sử dụng Enum giúp quản lý và chuyển đổi linh hoạt giữa các phong cách hoạt ảnh khác nhau trong ứng dụng.
enum TransformerType {
  /// Hiệu ứng Accordion giúp các trang co giãn như đàn accordion khi chuyển đổi.
  /// Nó tạo cảm giác các trang đang gập lại và mở ra một cách vật lý trong không gian.
  accordion,

  /// Hiệu ứng ThreeD tạo cảm giác không gian ba chiều khi lật trang.
  /// Hiệu ứng này mô phỏng việc quay một khối lập phương hoặc lật một tấm thẻ trong không gian 3D.
  threeD,

  /// Hiệu ứng ScaleAndFade kết hợp giữa việc thay đổi kích thước và độ mờ.
  /// Nó mang lại cảm giác các trang nội dung đang lùi xa hoặc tiến lại gần người xem một cách mượt mà.
  scaleAndFade,

  /// Hiệu ứng ZoomIn phóng to trang tiếp theo khi nó xuất hiện.
  /// Kiểu chuyển cảnh này tạo điểm nhấn mạnh mẽ vào nội dung mới đang được đưa lên phía trước.
  zoomIn,

  /// Hiệu ứng ZoomOut thu nhỏ trang hiện tại khi nó biến mất.
  /// Nó tạo ra một cái nhìn bao quát về sự lùi lại của trang cũ để nhường chỗ cho trang mới xuất hiện.
  zoomOut,

  /// Hiệu ứng Depth tạo chiều sâu cho các trang khi lướt qua.
  /// Các trang sẽ có cảm giác xếp chồng lên nhau trong một lớp không gian ảo đầy chiều sâu.
  depth,

  /// Hiệu ứng CubeIn mô phỏng việc lật mặt trong của một khối lập phương.
  /// Nó tạo cảm giác các trang đang áp sát vào nhau từ phía bên trong không gian 3D.
  cubeIn,

  /// Hiệu ứng CubeOut mô phỏng việc lật mặt ngoài của một khối lập phương.
  /// Đây là hiệu ứng 3D kinh điển tạo cảm giác ứng dụng như một khối rubik đang xoay tròn.
  cubeOut,

  /// Hiệu ứng FlipHorizontal lật trang theo trục ngang 180 độ.
  /// Mang lại cảm giác như đang lật một tấm danh thiếp hoặc thẻ bài trong không gian.
  flipHorizontal,

  /// Hiệu ứng FlipVertical lật trang theo trục dọc từ trên xuống hoặc dưới lên.
  /// Phù hợp cho các kiểu hiển thị nội dung dạng lịch hoặc bảng lật.
  flipVertical,

  /// Hiệu ứng Parallax tạo sự chênh lệch tốc độ di chuyển giữa phông nền và nội dung.
  /// Hiệu ứng này mang lại sự sinh động và chiều sâu tinh tế cho giao diện người dùng.
  parallax,

  /// Hiệu ứng RotateDown xoay trang xuống phía dưới khi chuyển đổi.
  /// Tạo cảm giác một trang đang rơi xuống để nhường chỗ cho trang tiếp theo xuất hiện.
  rotateDown,

  /// Hiệu ứng RotateUp xoay trang lên phía trên khi chuyển trang.
  /// Ngược lại với RotateDown, nó tạo cảm giác trang đang được kéo lên cao một cách nhẹ nhàng.
  rotateUp,

  /// Hiệu ứng Stack xếp chồng các trang lên nhau.
  /// Trang cũ đứng yên trong khi trang mới trượt đè lên trên.
  stack,

  /// Hiệu ứng Tablet mô phỏng việc lật trang trên máy tính bảng.
  /// Tạo cảm giác chuyên nghiệp và hiện đại cho ứng dụng.
  tablet,

  /// Hiệu ứng Convex (Thấu kính lồi).
  /// Trang bị bẻ cong lồi ra phía người dùng khi lướt qua.
  convex,

  /// Hiệu ứng Concave (Thấu kính lõm).
  /// Trang bị bẻ lõm vào trong, tạo chiều sâu thị giác độc đáo.
  concave,

  /// Hiệu ứng CoverFlow mô phỏng phong cách duyệt album của Apple.
  /// Các trang ở hai bên sẽ xoay nghiêng và đè nhẹ lên nhau.
  coverFlow,

  /// Hiệu ứng Tunnel mang lại cảm giác bay xuyên qua đường hầm.
  /// Trang cũ phóng to ra sau lưng, trang mới hiện ra từ tâm điểm.
  tunnel,

  /// Hiệu ứng Spin xoay tròn trang như một chiếc đĩa.
  /// Tạo cảm giác nghệ thuật và vui nhộn khi chuyển cảnh.
  spin,

  /// Hiệu ứng Wipe trượt và xóa bảng mượt mà.
  /// Sử dụng hiệu ứng làm mờ ở cạnh trượt để tạo sự chuyển tiếp tự nhiên.
  wipe,

  /// Hiệu ứng Curtain mô phỏng rèm sân khấu mở ra.
  /// Trang hiện tại tách đôi sang hai bên để lộ trang tiếp theo.
  curtain,

  /// Hiệu ứng BookFlip mô phỏng động tác lật trang sách.
  /// Trang xoay quanh trục dọc ở cạnh để tạo cảm giác lật sách thật.
  bookFlip,

  /// Hiệu ứng Fan bung ra giống như một chiếc quạt giấy.
  /// Các trang xoay quanh một điểm chốt ở góc dưới.
  fan,

  /// Hiệu ứng ScaleRotate kết hợp giữa việc xoay và nảy.
  /// Phù hợp cho các giao diện cần sự năng động và phá cách.
  scaleRotate,
}

/// Trang ví dụ minh họa cách sử dụng [TransformerPageView] với một bộ chuyển đổi tùy chỉnh.
/// Đây là nơi trình diễn khả năng tùy biến mạnh mẽ của việc chuyển đổi giao diện dựa trên vị trí của trang.
/// Người dùng có thể trực tiếp tương tác và quan sát sự thay đổi giữa các loại hiệu ứng hoạt ảnh khác nhau một cách tức thì.
class TransformerExamplePage extends StatefulWidget {
  const TransformerExamplePage({super.key});

  @override
  State<TransformerExamplePage> createState() => _TransformerExamplePageState();
}

class _TransformerExamplePageState extends State<TransformerExamplePage> {
  TransformerType _selectedType = TransformerType.accordion;

  /// Bản đồ ánh xạ từ [TransformerType] sang đối tượng [PageTransformer] tương ứng.
  /// Phương thức này đảm bảo việc khởi tạo đúng lớp xử lý hoạt ảnh dựa trên lựa chọn hiện tại của người dùng.
  /// Nó đóng vai trò là một factory đơn giản để cung cấp các logic biến đổi hình học cho từng trang.
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
      case TransformerType.cubeIn:
        return CubeInTransformer();
      case TransformerType.cubeOut:
        return CubeOutTransformer();
      case TransformerType.flipHorizontal:
        return FlipHorizontalTransformer();
      case TransformerType.flipVertical:
        return FlipVerticalTransformer();
      case TransformerType.parallax:
        return ParallaxTransformer();
      case TransformerType.rotateDown:
        return RotateDownTransformer();
      case TransformerType.rotateUp:
        return RotateUpTransformer();
      case TransformerType.stack:
        return StackTransformer();
      case TransformerType.tablet:
        return TabletTransformer();
      case TransformerType.convex:
        return ConvexTransformer();
      case TransformerType.concave:
        return ConcaveTransformer();
      case TransformerType.coverFlow:
        return CoverFlowTransformer();
      case TransformerType.tunnel:
        return TunnelTransformer();
      case TransformerType.spin:
        return SpinTransformer();
      case TransformerType.wipe:
        return WipeTransformer();
      case TransformerType.curtain:
        return CurtainTransformer();
      case TransformerType.bookFlip:
        return BookFlipTransformer();
      case TransformerType.fan:
        return FanTransformer();
      case TransformerType.scaleRotate:
        return ScaleRotateTransformer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocaleTranslate.transformerExampleTitle.getString(context)),
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
                AppLocaleTranslate.pageIndex
                    .getString(context)
                    .replaceAll('%a', index.toString()),
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

/// AccordionTransformer triển khai hiệu ứng co giãn giống như nhạc cụ accordion.
/// Nó sử dụng phép biến đổi tỷ lệ (scale) dựa trên vị trí âm hoặc dương của trang so với tâm nhìn.
/// Các trang sẽ có cảm giác như đang được nén lại hoặc kéo giãn ra từ các góc đối diện nhau.
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

/// ThreeDTransformer cung cấp hiệu ứng xoay ba chiều độc đáo khi chuyển trang.
/// Nó tính toán ma trận xoay quanh trục Y và điểm xoay (pivot) dựa trên chiều rộng của trang.
/// Kết quả là một hoạt ảnh mượt mà giống như việc lật một khối rubik hoặc các tấm bảng xoay trong không gian 3D.
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

/// ZoomInPageTransformer tạo hiệu ứng phóng to trang mới khi nó đang tiến dần vào vùng hiển thị.
/// Bằng cách kết hợp phép tịnh tiến (translate) và tỷ lệ (scale), trang mới sẽ xuất hiện như đang lao nhanh về phía người dùng.
/// Hiệu ứng này mang lại cảm giác năng động và thu hút sự chú ý trực tiếp vào nội dung mới xuất hiện.
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

/// ZoomOutPageTransformer thực hiện hiệu ứng thu nhỏ và làm mờ trang khi nó rời khỏi tâm điểm.
/// Nó tính toán các lề (margin) và độ mờ (opacity) một cách tinh vi để tạo cảm giác trang đang lùi sâu vào hậu cảnh.
/// Hoạt ảnh này thường được thấy trong các trình quản lý tab hoặc thư viện ảnh cao cấp để biểu đạt sự chuyển tiếp logic giữa các mục.
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

/// DepthPageTransformer tạo ra hiệu ứng các trang xếp chồng có chiều sâu khác nhau.
/// Trang cũ sẽ đứng yên trong khi trang mới trượt lên trên với sự thay đổi về độ mờ và tỷ lệ thu phóng.
/// Đây là phong cách chuyển cảnh mang tính phân lớp rõ rệt, giúp người dùng dễ dàng nhận diện cấu trúc trước sau của các nội dung.
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

/// ScaleAndFadeTransformer là một bộ chuyển đổi cơ bản kết hợp giữa việc thay đổi kích thước và độ trong suốt.
/// Nó mang lại sự mượt mà tối đa cho việc chuyển đổi bằng cách làm trang cũ mờ dần và nhỏ đi trong khi trang mới làm ngược lại.
/// Sự đơn giản nhưng hiệu quả của nó giúp ứng dụng giữ được vẻ tinh tế và không gây mỏi mắt cho người dùng khi sử dụng lâu.
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

/// CubeInTransformer mô phỏng hiệu ứng lật mặt trong của một khối lập phương.
/// Phép biến đổi này sử dụng ma trận 4x4 để xoay trang quanh trục Y với một góc 90 độ.
/// Khi trang di chuyển, nó sẽ tạo ra cảm giác các bề mặt đang khép lại vào bên trong trung tâm.
class CubeInTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double width = info.width!;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Thêm phối cảnh (perspective)
        ..rotateY(position * math.pi / 2),
      origin: Offset(position <= 0 ? width : 0, height / 2),
      child: child,
    );
  }
}

/// CubeOutTransformer tạo hiệu ứng như đang xoay mặt ngoài của một khối hộp rubik.
/// Trang hiện tại sẽ xoay ra phía sau trong khi trang mới xoay từ phía sau ra phía trước.
/// Việc kết hợp điểm xoay (pivot) ở hai cạnh đối diện giúp tạo ra một chuyển động liên hoàn mượt mà.
class CubeOutTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double width = info.width!;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(-position * math.pi / 2),
      origin: Offset(position <= 0 ? width : 0, height / 2),
      child: child,
    );
  }
}

/// FlipHorizontalTransformer thực hiện hiệu ứng lật trang 180 độ theo chiều ngang.
/// Khi di chuyển, trang sẽ co lại theo trục X và lật ngược sang phía bên kia.
/// Hiệu ứng này mô phỏng chân thực việc lật một tấm thẻ cứng trong không gian hai chiều được mô phỏng 3D.
class FlipHorizontalTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double rotation = position * math.pi;

    if (rotation > math.pi / 2 || rotation < -math.pi / 2) {
      return Container(); // Ẩn trang khi nó đang lật ở mặt sau
    }

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// FlipVerticalTransformer mang đến hiệu ứng lật trang theo chiều dọc (từ trên xuống hoặc từ dưới lên).
/// Tương tự như FlipHorizontal, nhưng trục xoay được chuyển sang trục X để tạo cảm giác lật lịch.
/// Phối cảnh được điều chỉnh để đảm bảo hình ảnh không bị biến dạng quá mức khi lật.
class FlipVerticalTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double rotation = position * math.pi;

    if (rotation > math.pi / 2 || rotation < -math.pi / 2) {
      return Container();
    }

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// ParallaxTransformer tạo hiệu ứng thị sai tinh tế bằng cách dịch chuyển nội dung chậm hơn tốc độ chuyển trang.
/// Nó sử dụng phép tịnh tiến (translation) để giữ cho các thành phần con có vẻ như đang trôi nổi độc lập.
/// Giúp tạo nên một giao diện người dùng có chiều sâu mang đậm phong cách nghệ thuật hiện đại.
class ParallaxTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position >= -1 && position <= 1) {
      return Transform.translate(
        offset: Offset(position * width / 2, 0),
        child: child,
      );
    }
    return child;
  }
}

/// RotateDownTransformer xoay trang một góc nhỏ hướng xuống dưới khi chuyển đổi.
/// Điểm xoay được đặt cố định ở cạnh dưới của trang để tạo hiệu ứng "rơi" tự nhiên.
/// Mang lại cảm giác trang giấy đang được xếp gọn xuống dưới để nhường chỗ cho nội dung mới.
class RotateDownTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    const double rotation = -math.pi / 4;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(position * rotation),
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}

/// StackTransformer tạo hiệu ứng trang cũ đứng yên trong khi trang mới trượt lên trên.
/// Hiệu ứng này mô phỏng các lớp thẻ bài được xếp chồng lên nhau.
class StackTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0) {
      return Transform.translate(
        offset: Offset(-info.width! * position, 0),
        child: child,
      );
    }
    return child;
  }
}

/// TabletTransformer mô phỏng giao diện máy tính bảng với góc xoay 3D nhẹ nhàng.
class TabletTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double rotation = position * math.pi / 4;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// ConvexTransformer tạo hiệu ứng thấu kính lồi.
class ConvexTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(position * math.pi / 2),
      alignment: position > 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: child,
    );
  }
}

/// ConcaveTransformer tạo hiệu ứng thấu kính lõm.
class ConcaveTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(-position * math.pi / 2),
      alignment: position > 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: child,
    );
  }
}

/// RotateUpTransformer xoay trang hướng lên phía trên, đối lập với RotateDown.
/// Hiệu ứng này gợi liên tưởng đến việc lật mở một nắp hộp hoặc kéo một bức rèm lên cao.
/// Kết hợp với sự thay đổi vị trí, nó tạo ra một luồng tương tác thống nhất và trực quan.
class RotateUpTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    const double rotation = math.pi / 4;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(position * rotation),
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}

/// CoverFlowTransformer mô phỏng phong cách duyệt album kinh điển.
class CoverFlowTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    double rotation = position.clamp(-1.0, 1.0) * -math.pi / 4;
    double scale = 1.0 - position.abs() * 0.2;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation)
        ..scale(scale),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(position * width * 0.5, 0),
        child: child,
      ),
    );
  }
}

/// TunnelTransformer tạo cảm giác bay xuyên không gian.
class TunnelTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0 && position > -1) {
      return Opacity(
        opacity: 1 + position,
        child: Transform.scale(
          scale: 1 - position.abs() * 5, // Phóng to cực nhanh
          child: child,
        ),
      );
    } else if (position > 0 && position <= 1) {
      return Opacity(
        opacity: 1 - position,
        child: Transform.scale(
          scale: 0.1 + (1 - position) * 0.9, // Hiện ra từ tâm
          child: child,
        ),
      );
    }
    return child;
  }
}

/// SpinTransformer xoay tròn trang như một đĩa nhạc.
class SpinTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform.rotate(
      angle: position * math.pi * 2,
      child: Transform.scale(
        scale: 1 - position.abs(),
        child: Opacity(
          opacity: 1 - position.abs(),
          child: child,
        ),
      ),
    );
  }
}

/// WipeTransformer tạo hiệu ứng xóa bảng mượt mà.
class WipeTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position <= 0) {
      return child;
    } else {
      return ClipRect(
        child: Transform.translate(
          offset: Offset(width * (1 - position), 0),
          child: child,
        ),
      );
    }
  }
}

/// CurtainTransformer mô phỏng rèm sân khấu mở ra.
class CurtainTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;

    if (position <= 0 && position > -1) {
      // Trang cũ (rèm) mở ra
      return Stack(
        children: [
          // Nửa trái
          ClipRect(
            clipper: _CurtainClipper(isLeft: true, position: position),
            child: Transform.translate(
              offset: Offset(width * position * 0.5, 0),
              child: child,
            ),
          ),
          // Nửa phải
          ClipRect(
            clipper: _CurtainClipper(isLeft: false, position: position),
            child: Transform.translate(
              offset: Offset(-width * position * 0.5, 0),
              child: child,
            ),
          ),
        ],
      );
    }
    return child;
  }
}

class _CurtainClipper extends CustomClipper<Rect> {
  final bool isLeft;
  final double position;

  _CurtainClipper({required this.isLeft, required this.position});

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTWH(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
    }
  }

  @override
  bool shouldReclip(_CurtainClipper oldClipper) => true;
}

/// BookFlipTransformer mô phỏng động tác lật trang sách.
class BookFlipTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(position.clamp(-1.0, 0.0) * math.pi),
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: Offset(position < 0 ? width * -position : 0, 0),
        child: child,
      ),
    );
  }
}

/// FanTransformer bung ra giống như một chiếc quạt giấy.
class FanTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(position * math.pi / 2),
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}

/// ScaleRotateTransformer kết hợp giữa việc xoay và nảy.
class ScaleRotateTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform.rotate(
      angle: position * math.pi * 2,
      child: Transform.scale(
        scale: 1 - position.abs().clamp(0.0, 0.5),
        child: Opacity(
          opacity: 1 - position.abs(),
          child: child,
        ),
      ),
    );
  }
}
