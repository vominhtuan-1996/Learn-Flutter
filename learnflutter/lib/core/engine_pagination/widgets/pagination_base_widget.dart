import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/engine_pagination/controller/pagination_cubit.dart';
import 'package:learnflutter/core/engine_pagination/controller/pagination_state.dart';
import 'package:learnflutter/core/engine_pagination/widgets/pagination_bottom_bar_widget.dart';
import 'package:learnflutter/core/engine_pagination/widgets/pagination_item_widget.dart';

/// Bộ Stepper/Pagination Widget trung tâm của hệ thống (Core Engine).
///
/// Hỗ trợ:
/// 1. **Dark Mode**: Thích ứng màu Slate/Neon dynamic.
/// 2. **Vector Dividers**: Tự động vẽ đường nối nét đứt / nét liền bằng CustomPainter.
/// 3. **Smooth Scroll**: Tự động cuộn tập trung vào Step đang thực hiện.
/// 4. **Tương thích ngược**: Ánh xạ tham số 100% khớp với module cũ.
class AppPaginationWidget extends StatefulWidget {
  final Widget content;
  final int numbStep;
  final String tabType;
  final bool hasCompleteStep;
  final Future<bool> Function(int indexCurrentStep, int indexNextStep)? onNextStep;
  final Future<bool> Function(int index)? onPreviousStep;
  final Future<bool> Function(int index)? onCompleteStep;
  final Future<bool> Function(int index)? goToThisStep;

  const AppPaginationWidget({
    super.key,
    required this.content,
    required this.numbStep,
    required this.tabType,
    this.hasCompleteStep = false,
    this.onNextStep,
    this.onPreviousStep,
    this.onCompleteStep,
    this.goToThisStep,
  });

  @override
  State<AppPaginationWidget> createState() => _AppPaginationWidgetState();
}

class _AppPaginationWidgetState extends State<AppPaginationWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<AppPaginationCubit>(
      create: (context) => AppPaginationCubit(
        _scrollController,
        widget.numbStep,
        widget.tabType == "1", // maintained tab
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Step Indicators
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 72,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: BlocBuilder<AppPaginationCubit, AppPaginationState>(
                builder: (context, state) {
                  final children = <Widget>[];

                  for (int index = 1; index <= widget.numbStep; index++) {
                    // Step Circle
                    children.add(
                      AppPaginationItemWidget(
                        goToThisStep: widget.goToThisStep,
                        currentStep: state.currentStep,
                        indexStep: index,
                        paginationModel: state.paginationModel[index - 1],
                        isCompleteStep: state.currentStep == widget.numbStep + 1,
                        tabType: widget.tabType,
                      ),
                    );

                    // Vạch nối giữa các Step (Divider)
                    if (index < widget.numbStep) {
                      final isActive = state.currentStep > index || widget.tabType == "1";
                      children.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: 32,
                            height: 2,
                            child: CustomPaint(
                              painter: _StepLinePainter(
                                isActive: isActive,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  );
                },
              ),
            ),
          ),

          // 2. Main Content Area (Thích ứng co giãn bàn phím)
          Expanded(
            child: widget.content,
          ),

          // 3. Footer Navigation Buttons
          BlocBuilder<AppPaginationCubit, AppPaginationState>(
            builder: (context, state) {
              return AppPaginationBottomBarWidget(
                tabType: widget.tabType,
                onNextStep: widget.onNextStep,
                onCompleteStep: widget.onCompleteStep,
                onPreviousStep: widget.onPreviousStep,
                isFirstStep: state.currentStep == 1,
                isLastStep: widget.hasCompleteStep
                    ? state.currentStep == widget.numbStep + 1
                    : state.currentStep == widget.numbStep,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// CustomPainter vẽ đường nối động (nét đứt / nét liền)
class _StepLinePainter extends CustomPainter {
  final bool isActive;
  final bool isDark;

  _StepLinePainter({
    required this.isActive,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isActive) {
      // Đường nét liền màu cam rực rỡ (Active/Success)
      paint.color = isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    } else {
      // Đường nét đứt (Dotted Line) màu xám (Pending)
      paint.color = isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB);
      const dashWidth = 4.0;
      const dashSpace = 3.0;
      double startX = 0;
      final y = size.height / 2;

      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, y),
          Offset((startX + dashWidth).clamp(0, size.width), y),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StepLinePainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.isDark != isDark;
  }
}
