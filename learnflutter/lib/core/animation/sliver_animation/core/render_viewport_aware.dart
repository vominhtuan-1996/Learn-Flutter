import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'viewport_engine.dart';

typedef VisibilityCallback = void Function(bool visible);

/// Widget wrapper - bọc child với [RepaintBoundary] và [ViewportAware].
class ViewportAwareItem extends StatelessWidget {
  final Widget child;
  final ViewportAnimationConfig config;
  final VisibilityCallback? onVisibilityChanged;

  const ViewportAwareItem({
    super.key,
    required this.child,
    this.config = ViewportAnimationConfig.defaultConfig,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ViewportAware(
        config: config,
        onVisibilityChanged: onVisibilityChanged,
        child: child,
      ),
    );
  }
}

/// Widget sử dụng Custom RenderObject để paint animation
/// mà không gây rebuild widget tree khi cuộn.
class ViewportAware extends SingleChildRenderObjectWidget {
  final ViewportAnimationConfig config;
  final VisibilityCallback? onVisibilityChanged;

  const ViewportAware({
    super.key,
    super.child,
    this.config = ViewportAnimationConfig.defaultConfig,
    this.onVisibilityChanged,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderViewportAware(
      config: config,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderViewportAware renderObject) {
    renderObject
      ..config = config
      ..onVisibilityChanged = onVisibilityChanged;
  }
}

/// Custom RenderObject - tính progress dựa trên khoảng cách tới tâm viewport.
/// Áp dụng scale, opacity, translateY trực tiếp trên Paint layer (GPU accelerated).
class RenderViewportAware extends RenderProxyBox {
  ViewportAnimationConfig _config;
  VisibilityCallback? onVisibilityChanged;

  double _lastProgress = -1.0;
  bool _lastVisible = false;

  RenderViewportAware({
    required ViewportAnimationConfig config,
    this.onVisibilityChanged,
  }) : _config = config;

  ViewportAnimationConfig get config => _config;
  set config(ViewportAnimationConfig value) {
    if (_config == value) return;
    _config = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final viewportDimension = _getViewportDimension();
    if (viewportDimension == null) {
      super.paint(context, offset);
      return;
    }

    final globalTop = localToGlobal(Offset.zero).dy;
    final itemCenter = globalTop + size.height / 2;
    final viewportCenter = viewportDimension / 2;

    final distance = (itemCenter - viewportCenter).abs();
    final normalized = (distance / viewportDimension).clamp(0.0, 1.0);
    final progress = (1.0 - normalized).clamp(0.0, 1.0);

    // Cache: bỏ qua nếu progress thay đổi không đáng kể
    if ((progress - _lastProgress).abs() < _config.progressThreshold) {
      super.paint(context, offset);
      return;
    }
    _lastProgress = progress;

    // Visibility lifecycle callback
    final isVisible = progress > _config.progressThreshold;
    if (isVisible != _lastVisible) {
      _lastVisible = isVisible;
      onVisibilityChanged?.call(isVisible);
    }

    // Tính các giá trị hiệu ứng
    final scale = _config.minScale + (1.0 - _config.minScale) * progress;
    final opacity = (_config.minOpacity + (1.0 - _config.minOpacity) * progress)
        .clamp(0.0, 1.0);
    final translateY = (1.0 - progress) * _config.maxTranslateY;

    final matrix = Matrix4.identity()
      ..translate(offset.dx, offset.dy + translateY)
      ..scale(scale);

    context.pushOpacity(
      offset,
      (opacity * 255).round(),
      (ctx, off) {
        ctx.pushTransform(
          needsCompositing,
          Offset.zero,
          matrix,
          (ctx, off) {
            ctx.paintChild(child!, off);
          },
        );
      },
    );
  }

  /// Duyệt lên cây Render để tìm [RenderViewport] gần nhất,
  /// sau đó lấy [viewportDimension] từ ScrollPosition của nó.
  double? _getViewportDimension() {
    RenderObject? node = parent;
    while (node != null) {
      if (node is RenderViewport) {
        final viewportOffset = node.offset;
        if (viewportOffset is ScrollPosition) {
          return viewportOffset.viewportDimension;
        }
        break;
      }
      node = node.parent;
    }
    return null;
  }
}
