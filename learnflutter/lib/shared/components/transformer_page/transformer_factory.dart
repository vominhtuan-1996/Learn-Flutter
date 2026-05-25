import 'package:another_transformer_page_view/another_transformer_page_view.dart';

import 'transformer_type.dart';
import 'transformers/transformers.dart';

/// Factory ánh xạ [TransformerType] → instance [PageTransformer] tương ứng.
///
/// ```dart
/// TransformerPageView(
///   transformer: transformerFor(TransformerType.cubeOut),
///   itemBuilder: ...,
/// )
/// ```
PageTransformer transformerFor(TransformerType type) {
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
