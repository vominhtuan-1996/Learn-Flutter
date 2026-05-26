import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/render_layer_controller.dart';

/// Widget wrapper (LeafRenderObjectWidget) để gắn [RenderLayerController] vào Flutter Widget Tree.
class RenderLayerView extends LeafRenderObjectWidget {
  final RenderLayerController controller;

  const RenderLayerView({
    super.key,
    required this.controller,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayerBox(controller);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderLayerBox renderObject) {
    renderObject.controller = controller;
  }
}

/// [RenderBox] tuỳ chỉnh, override hàm paint để chuyển quyền điều khiển canvas
/// cho [RenderLayerController]. Đảm bảo cấu trúc render không gây rebuild widget.
class RenderLayerBox extends RenderBox {
  RenderLayerController _controller;

  RenderLayerBox(this._controller);

  RenderLayerController get controller => _controller;

  set controller(RenderLayerController value) {
    if (_controller == value) return;
    _controller.removeListener(markNeedsPaint);
    _controller = value;
    _controller.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _controller.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    // SizedByParent = true nên layout chỉ phụ thuộc vào parent constraints.
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Nếu có offset từ parent, ta di chuyển canvas (translate) đến vị trí đó
    // để các layer có thể vẽ từ toạ độ (0,0) tương đối.
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    // Gọi controller thực hiện vẽ toàn bộ layer
    _controller.paint(context.canvas, size);

    context.canvas.restore();
  }
}
