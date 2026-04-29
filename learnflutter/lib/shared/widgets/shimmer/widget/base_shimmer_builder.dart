import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/shared/widgets/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/shared/widgets/shimmer/widget/shimmer_widget.dart';

/// Widget dùng chung cho shimmer loading.
///
/// Tự động bọc [Shimmer] + [ShimmerLoading], chỉ cần truyền:
/// - [isLoading]: true/false
/// - [shimmerContent]: widget placeholder khi đang loading
/// - [child]: widget thật khi load xong
///
/// Ví dụ:
/// ```dart
/// BaseShimmerBuilder(
///   isLoading: _isLoading,
///   shimmerContent: Column(
///     children: [
///       ShimmerListTile(),
///       ShimmerListTile(),
///       ShimmerCard(),
///     ],
///   ),
///   child: MyRealContent(),
/// )
/// ```
class BaseShimmerBuilder extends StatelessWidget {
  const BaseShimmerBuilder({
    super.key,
    required this.isLoading,
    required this.shimmerContent,
    required this.child,
    this.gradient,
  });

  /// Trạng thái loading.
  final bool isLoading;

  /// Widget placeholder hiển thị khi [isLoading] = true.
  /// Sử dụng [ShimmerBox], [ShimmerListTile], [ShimmerCard] để xây dựng.
  final Widget shimmerContent;

  /// Widget thật hiển thị khi [isLoading] = false.
  final Widget child;

  /// Custom gradient. Mặc định dùng [ShimmerUtils.shimmerGradient].
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer(
      linearGradient: gradient ?? ShimmerUtils.shimmerGradient,
      child: ShimmerLoading(
        isLoading: true,
        child: shimmerContent,
      ),
    );
  }
}

/// Bọc trực tiếp widget thật, tự shimmer dựa trên render của child.
///
/// Cách hoạt động:
/// - Khi [isLoading] = true: render child bình thường nhưng phủ shimmer lên,
///   tất cả pixel có màu sẽ thành placeholder shimmer.
/// - Khi [isLoading] = false: hiển thị child bình thường.
///
/// Ví dụ:
/// ```dart
/// BaseShimmerList(
///   isLoading: _isLoading,
///   child: ListView.builder(
///     itemCount: 5,
///     itemBuilder: (_, i) => ListTile(
///       leading: CircleAvatar(child: Text('$i')),
///       title: Text('Item $i'),
///       subtitle: Text('Subtitle'),
///     ),
///   ),
/// )
/// ```
class BaseShimmerList extends StatelessWidget {
  const BaseShimmerList({
    super.key,
    required this.isLoading,
    required this.child,
    this.gradient,
    this.baseColor = const Color(0xFFE0E0E0),
  });

  final bool isLoading;
  final Widget child;
  final LinearGradient? gradient;

  /// Màu nền placeholder trước khi shimmer chạy qua.
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer(
      linearGradient: gradient ?? ShimmerUtils.shimmerGradient,
      child: ShimmerLoading(
        isLoading: true,
        child: IgnorePointer(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(baseColor, BlendMode.srcATop),
            child: child,
          ),
        ),
      ),
    );
  }
}
