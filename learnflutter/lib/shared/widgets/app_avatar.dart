import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';
import 'package:learnflutter/shared/widgets/tap.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : null,
        color: AppColors.primaryLight,
      ),
      child: ClipOval(child: _buildContent()),
    );

    if (onTap == null) return avatar;
    return Tap(onTap: onTap, child: avatar);
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _initials,
        style: AppTextStyles.textStyleManrope(
          AppColors.primary,
          size * 0.38,
          FontWeight.w600,
        ),
      ),
    );
  }
}
