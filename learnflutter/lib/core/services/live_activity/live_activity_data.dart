/// Static data — defined once when activity starts, không thay đổi.
class LiveActivityData {
  const LiveActivityData({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
      };
}

/// Dynamic data — cập nhật qua [LiveActivityService.update].
class LiveActivityState {
  const LiveActivityState({
    required this.status,
    required this.eta,
    required this.progress,
  });

  final String status;
  final String eta;

  /// 0.0 → 1.0
  final double progress;

  Map<String, dynamic> toMap() => {
        'status': status,
        'eta': eta,
        'progress': progress,
      };
}
