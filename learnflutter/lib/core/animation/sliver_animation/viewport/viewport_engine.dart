/// Config hệ thống animation - tránh hardcode giá trị
class ViewportAnimationConfig {
  final double minScale;
  final double minOpacity;
  final double maxTranslateY;
  final double progressThreshold;

  const ViewportAnimationConfig({
    this.minScale = 0.85,
    this.minOpacity = 0.3,
    this.maxTranslateY = 40.0,
    this.progressThreshold = 0.01,
  });

  static const ViewportAnimationConfig defaultConfig = ViewportAnimationConfig();
}
