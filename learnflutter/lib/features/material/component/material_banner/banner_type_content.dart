import 'package:flutter/material.dart';
import 'package:learnflutter/features/material/component/material_banner/material_banner_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BannerType – Phân loại hiển thị banner theo trạng thái nghiệp vụ
// ─────────────────────────────────────────────────────────────────────────────

enum BannerType { success, error, warning }

/// Extension cung cấp theme (màu, icon, tiêu đề) tương ứng với mỗi [BannerType].
extension BannerTypeTheme on BannerType {
  Color get backgroundColor {
    switch (this) {
      case BannerType.success:
        return const Color(0xFF1B8A5A); // Green 700
      case BannerType.error:
        return const Color(0xFFCC3333); // Red 700
      case BannerType.warning:
        return const Color(0xFFE07C00); // Orange 700
    }
  }

  Color get onColor => Colors.white;

  IconData get icon {
    switch (this) {
      case BannerType.success:
        return Icons.check_circle;
      case BannerType.error:
        return Icons.error;
      case BannerType.warning:
        return Icons.warning;
    }
  }

  String get defaultTitle {
    switch (this) {
      case BannerType.success:
        return 'Thành công';
      case BannerType.error:
        return 'Có lỗi xảy ra';
      case BannerType.warning:
        return 'Cảnh báo';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TypedBanner – Static helper bọc TopOverlayBanner với BannerType
// ─────────────────────────────────────────────────────────────────────────────

/// Wrapper tiện dụng quanh [TopOverlayBanner] với giao diện được xây sẵn theo [BannerType].
///
/// Sử dụng:
/// ```dart
/// TypedBanner.show(
///   context: context,
///   type: BannerType.success,
///   message: 'Lưu thành công!',
/// );
/// ```
class TypedBanner {
  TypedBanner._();

  /// Hiển thị banner có kiểu [type] với [message] và tuỳ chọn [title].
  ///
  /// - [ratioScreenHeight] tỉ lệ chiều cao banner so với màn hình (mặc định 0.22).
  /// - [duration] thời gian tự dismiss (mặc định 3 giây).
  static void show({
    required BuildContext context,
    required BannerType type,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    double ratioScreenHeight = 0.22,
  }) {
    TopOverlayBanner.show(
      context: context,
      backgroundColor: type.backgroundColor,
      textColor: type.onColor,
      duration: duration,
      ratioScreenHeight: ratioScreenHeight,
      content: _BannerTypeContent(
        type: type,
        title: title ?? type.defaultTitle,
        message: message,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BannerTypeContent – Widget nội dung bên trong banner
// ─────────────────────────────────────────────────────────────────────────────

class _BannerTypeContent extends StatelessWidget {
  final BannerType type;
  final String title;
  final String message;

  const _BannerTypeContent({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.onColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                type.icon,
                size: 24,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content (Title + Message)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                // Cấu trúc cho phần Action (Upgrade · Learn More)
                // Có thể mở rộng sau này nếu cần truyền vào từ bên ngoài
                /*
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Upgrade',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: color,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '·',
                        style: TextStyle(color: color, fontSize: 14),
                      ),
                    ),
                    Text(
                      'Learn More',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                */
              ],
            ),
          ),

          // Close Button
          InkWell(
            onTap: () {
              TopOverlayBanner.clearQueue();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                size: 20,
                color: color.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
