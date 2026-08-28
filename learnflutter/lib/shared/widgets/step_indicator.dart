import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';

enum StepIndicatorType { dot, bar, number }

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final StepIndicatorType type;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.type = StepIndicatorType.dot,
  }) : assert(currentStep >= 0 && currentStep < totalSteps);

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? AppColors.lightGrey;

    switch (type) {
      case StepIndicatorType.dot:
        return _buildDots(active, inactive);
      case StepIndicatorType.bar:
        return _buildBar(active, inactive);
      case StepIndicatorType.number:
        return _buildNumbers(active, inactive);
    }
  }

  Widget _buildDots(Color active, Color inactive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? active : inactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildBar(Color active, Color inactive) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final total = constraints.maxWidth == double.infinity
            ? 200.0
            : constraints.maxWidth;
        final gap = 4.0 * (totalSteps - 1);
        final segW = (total - gap) / totalSteps;
        return Row(
          children: List.generate(totalSteps, (i) {
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: segW,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= currentStep ? active : inactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 4),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildNumbers(Color active, Color inactive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        final circleColor = isDone || isActive ? active : inactive;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: AppColors.white, size: 16)
                    : Text(
                        '${i + 1}',
                        style: AppTextStyles.textStyleManrope(
                          isActive ? AppColors.white : AppColors.white,
                          12,
                          FontWeight.w700,
                        ),
                      ),
              ),
            ),
            if (i < totalSteps - 1)
              Container(
                width: 24,
                height: 2,
                color: i < currentStep ? active : inactive,
              ),
          ],
        );
      }),
    );
  }
}
