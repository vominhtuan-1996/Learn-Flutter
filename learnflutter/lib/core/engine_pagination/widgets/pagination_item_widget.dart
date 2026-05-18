import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/engine_pagination/controller/pagination_cubit.dart';
import 'package:learnflutter/core/engine_pagination/models/pagination_model.dart';

/// Widget đại diện cho từng vòng tròn chỉ báo bước (Step Circle Indicator)
class AppPaginationItemWidget extends StatelessWidget {
  final int currentStep;
  final int indexStep;
  final bool isCompleteStep;
  final String tabType;
  final AppPaginationModel paginationModel;
  final Future<bool> Function(int index)? goToThisStep;

  const AppPaginationItemWidget({
    super.key,
    required this.currentStep,
    required this.indexStep,
    required this.paginationModel,
    required this.isCompleteStep,
    required this.goToThisStep,
    required this.tabType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tokens màu dynamic thích ứng Dark Mode
    final activeBgColor = isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6); // HSL Neon Blue
    final successBgColor = isDark ? const Color(0xFF059669) : const Color(0xFF10B981); // HSL Emerald Green
    final pendingBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6); // Slate Gray
    final pendingBorderColor = isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB);
    final textActiveColor = Colors.white;
    final textPendingColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    // Xác định trạng thái của bước này so với bước hiện tại
    final isActive = isCompleteStep
        ? (currentStep - 1 == indexStep)
        : (currentStep == indexStep);

    final isSuccess = paginationModel.isUploadedStep || 
        (tabType == "1" && !isActive);

    return InkWell(
      onTap: () async {
        final cubit = context.read<AppPaginationCubit>();
        final isUploaded = cubit.state.paginationModel[indexStep - 1].isUploadedStep;
        
        if (!isUploaded && tabType != "1") return;

        if (goToThisStep != null) {
          if (await goToThisStep!(indexStep)) {
            cubit.goToThisStep(indexStep);
          }
        } else {
          cubit.goToThisStep(indexStep);
        }
      },
      borderRadius: BoxShape.circle.borderRadius,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 44 : 36,
          height: isActive ? 44 : 36,
          decoration: BoxDecoration(
            color: isSuccess 
                ? successBgColor 
                : (isActive ? activeBgColor : pendingBgColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive 
                  ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                  : (isSuccess ? Colors.transparent : pendingBorderColor),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: activeBgColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildStepIconOrText(
                isActive: isActive,
                isSuccess: isSuccess,
                textActiveColor: textActiveColor,
                textPendingColor: textPendingColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIconOrText({
    required bool isActive,
    required bool isSuccess,
    required Color textActiveColor,
    required Color textPendingColor,
  }) {
    if (isSuccess) {
      return const Icon(
        Icons.done_rounded,
        color: Colors.white,
        size: 20,
        key: ValueKey('icon-success'),
      );
    }

    if (isActive) {
      return Icon(
        tabType == "1" ? Icons.visibility_rounded : Icons.edit_note_rounded,
        color: Colors.white,
        size: 24,
        key: const ValueKey('icon-active'),
      );
    }

    // Pending Step - hiển thị số thứ tự bước (01, 02, v.v.)
    final stepStr = indexStep < 10 ? "0$indexStep" : "$indexStep";
    return Text(
      stepStr,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: textPendingColor,
      ),
      key: ValueKey('text-$indexStep'),
    );
  }
}

extension on BoxShape {
  BorderRadius get borderRadius => const BorderRadius.all(Radius.circular(999));
}
