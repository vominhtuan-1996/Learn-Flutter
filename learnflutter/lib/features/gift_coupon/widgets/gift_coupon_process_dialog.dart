import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/core/utils/extension/extension_widget.dart';
import 'package:learnflutter/features/gift_coupon/cubit/gift_coupon_cubit.dart';
import 'package:learnflutter/features/gift_coupon/model/process_step_model.dart';
import 'package:learnflutter/features/gift_coupon/state/gift_coupon_state.dart';

/// GiftCouponProcessDialog phản hồi linh hoạt các thay đổi trạng thái từ GiftCouponCubit.
/// Nó sử dụng BlocBuilder để tự động vẽ lại giao diện khi tiến trình tạo phiếu PMS hoặc Inside có cập nhật mới.
/// Các tương tác từ phía người dùng như nhấn nút "Thử lại" hoặc "Đóng" được chuyển tiếp trực tiếp tới Cubit xử lý.
/// Toàn bộ logic hiển thị phức tạp được đồng bộ hóa chặt chẽ với kiến trúc BLoC của dự án.
class GiftCouponProcessDialog extends StatelessWidget {
  const GiftCouponProcessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GiftCouponCubit, GiftCouponState>(
      builder: (context, state) {
        final isProcessing = state.steps.any((s) => s.status == ProcessStepStatus.processing);
        final hasError = state.steps.any((s) => s.status == ProcessStepStatus.failed);
        final isAllCompleted = state.isAllCompleted;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: AppBoxDecoration.boxDecorationBorderRadius(
              borderRadiusValue: 12,
              colorBackground: Colors.white,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tiêu đề quy trình
                  Text(
                    'Tiến trình xử lý tạo phiếu triển khai quà tặng',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ).paddingOnly(bottom: 12),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.shade600,
                  ),

                  // Danh sách các bước Stepper
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.steps.length,
                      itemBuilder: (context, index) {
                        return _buildStepItem(context, state.steps[index], index, index == state.steps.length - 1);
                      },
                    ).paddingSymmetric(horizontal: 24, vertical: 12),
                  ),

                  // if (!isProcessing)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.shade600,
                  ).paddingSymmetric(horizontal: 12),

                  // Chân trang hiển thị linh hoạt với hiệu ứng mượt mà
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildFooterSection(context, state, isProcessing, hasError, isAllCompleted),
                  ).paddingSymmetric(horizontal: 24, vertical: 12),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.shade600,
                  ).paddingSymmetric(horizontal: 12),
                  if (!isProcessing) ...[
                    _buildCloseButton(context).paddingOnly(top: 12),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// _buildAnimatedIcon tạo icon tương ứng với trạng thái để AnimatedSwitcher xử lý.
  Widget _buildAnimatedIcon(ProcessStepModel step, int index) {
    switch (step.status) {
      case ProcessStepStatus.completed:
        return const Icon(Icons.check, key: ValueKey('completed'), size: 16, color: Colors.blue);
      case ProcessStepStatus.processing:
        return Stack(
          key: const ValueKey('processing'),
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              child: Center(
                child: Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      case ProcessStepStatus.failed:
        return const Icon(Icons.close, key: ValueKey('failed'), size: 16, color: Colors.red);
      case ProcessStepStatus.pending:
        return Container(
          key: const ValueKey('pending'),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        );
    }
  }

  /// _buildStepItem hỗ trợ hiển thị 4 trạng thái hình ảnh khác nhau thông qua ProcessStepStatus.
  Widget _buildStepItem(BuildContext context, ProcessStepModel step, int index, bool isLast) {
    Color stepColor = step.status == ProcessStepStatus.failed ? Colors.red : (step.status == ProcessStepStatus.pending ? Colors.grey.shade600 : Colors.blue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.status == ProcessStepStatus.processing ? Colors.transparent : (step.status == ProcessStepStatus.failed ? Colors.red : Colors.blue.withOpacity(0.5)),
                  width: 1,
                ),
                color: Colors.transparent,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildAnimatedIcon(step, index),
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 20,
                color: stepColor.withOpacity(0.5),
              ).paddingSymmetric(vertical: 4),
          ],
        ).paddingOnly(right: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: step.status == ProcessStepStatus.failed ? Colors.red.shade400 : Colors.black87,
                      ),
                    ),
                  ),
                  if (step.status == ProcessStepStatus.failed)
                    GestureDetector(
                      onTap: () {
                        context.read<GiftCouponCubit>().retryStep(index);
                      },
                      child: Text(
                        ' Thử lại',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (step.subtitle != null || step.status == ProcessStepStatus.processing)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step.status == ProcessStepStatus.processing ? 'Đang tạo phiếu...' : step.subtitle ?? '',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  /// _buildFooterSection trả về widget tương ứng với trạng thái hiện tại để AnimatedSwitcher xử lý.
  Widget _buildFooterSection(BuildContext context, GiftCouponState state, bool isProcessing, bool hasError, bool isAllCompleted) {
    if (isProcessing) {
      return _buildProcessingFooter(context, key: const ValueKey('processing'));
    } else if (hasError) {
      return _buildErrorFooter(context, state.errorMessage, key: const ValueKey('error'));
    } else if (isAllCompleted) {
      return _buildSummarySection(context, state.summaryTitle, state.summaryNotes, key: const ValueKey('summary'));
    }
    return const SizedBox.shrink();
  }

  Widget _buildProcessingFooter(BuildContext context, {Key? key}) {
    return Center(
      key: key,
      child: Text(
        'Vui lòng không tắt popup xử lý.',
        style: context.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildErrorFooter(BuildContext context, String? errorMessage, {Key? key}) {
    return Center(
      key: key,
      child: Text(
        errorMessage ?? 'Hiển thị thông tin lỗi tại đây',
        style: context.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.red.shade400,
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, String title, List<String> notes, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ...notes.asMap().entries.map((entry) {
          final index = entry.key;
          final note = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: _parseNote(note),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: (index * 150).ms).slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  List<TextSpan> _parseNote(String note) {
    final parts = note.split(':');
    if (parts.length > 1) {
      return [
        TextSpan(text: parts[0], style: const TextStyle(fontStyle: FontStyle.italic)),
        TextSpan(
          text: ':${parts.sublist(1).join(':')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ];
    }
    return [
      TextSpan(text: note, style: const TextStyle(fontStyle: FontStyle.italic)),
    ];
  }

  Widget _buildCloseButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            shadowColor: Colors.grey,
          ),
          child: Text(
            'Đóng',
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
