import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/engine_pagination/controller/pagination_cubit.dart';
import 'package:learnflutter/core/engine_pagination/controller/pagination_state.dart';

/// Widget đại diện cho thanh điều hướng dưới đáy (Footer Navigation Bar) của Stepper.
class AppPaginationBottomBarWidget extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final String tabType;
  final Future<bool> Function(int indexCurrentStep, int indexNextStep)? onNextStep;
  final Future<bool> Function(int index)? onPreviousStep;
  final Future<bool> Function(int index)? onCompleteStep;

  const AppPaginationBottomBarWidget({
    super.key,
    required this.isFirstStep,
    required this.isLastStep,
    required this.tabType,
    this.onNextStep,
    this.onPreviousStep,
    this.onCompleteStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastStepMaintained = tabType == "1" && isLastStep;

    // Màu dynamic cho nút
    final nextBtnColor = isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6);
    final backBtnColor = isDark ? const Color(0xFF475569) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: BlocBuilder<AppPaginationCubit, AppPaginationState>(
        builder: (context, state) {
          return Row(
            children: [
              // Nút Trở về (Back Button)
              if (!isFirstStep)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: OutlinedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        bool allow = true;
                        if (onPreviousStep != null) {
                          allow = await onPreviousStep!(state.currentStep - 1);
                        }
                        if (allow) {
                          context.read<AppPaginationCubit>().previousStep();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: backBtnColor,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left_rounded, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "Trở về",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Nút Tiếp tục / Hoàn tất (Next/Complete Button)
              if (!isLastStepMaintained)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final cubit = context.read<AppPaginationCubit>();
                      
                      if (isLastStep) {
                        if (onCompleteStep != null) {
                          await onCompleteStep!(state.currentStep);
                        }
                      } else {
                        bool allow = true;
                        if (onNextStep != null) {
                          allow = await onNextStep!(state.currentStep, state.currentStep + 1);
                        }
                        if (allow) {
                          cubit.nextStep(isLastStep);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nextBtnColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? "Hoàn tất" : "Tiếp tục",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLastStep ? Icons.done_all_rounded : Icons.chevron_right_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
