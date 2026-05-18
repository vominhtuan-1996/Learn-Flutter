import 'package:learnflutter/core/engine_pagination/models/pagination_model.dart';
import 'package:learnflutter/core/state/base_state.dart';

/// Trạng thái quản lý tiến trình Stepper/Pagination.
class AppPaginationState extends BaseState {
  /// Danh sách các data model của từng Step
  final List<AppPaginationModel> paginationModel;

  /// Vị trí bước hiện tại (1-indexed)
  final int currentStep;

  /// Đã ở bước cuối cùng chưa
  final bool isLastStep;

  AppPaginationState({
    required this.paginationModel,
    required this.currentStep,
    required this.isLastStep,
  });

  /// Khởi tạo trạng thái ban đầu của Stepper
  factory AppPaginationState.initial(int? numbStep, bool isMaintainedTab) {
    return AppPaginationState(
      currentStep: 1,
      isLastStep: false,
      paginationModel: numbStep == null
          ? const []
          : List.generate(
              numbStep,
              (index) => AppPaginationModel(
                isUploadedStep: isMaintainedTab,
                state: isMaintainedTab ? AppStepState.success : AppStepState.pending,
              ),
            ),
    );
  }

  /// Sao chép trạng thái với dữ liệu cập nhật mới
  AppPaginationState cloneWith({
    List<AppPaginationModel>? paginationModel,
    int? currentStep,
    bool? isLastStep,
  }) {
    return AppPaginationState(
      paginationModel: paginationModel ?? this.paginationModel,
      currentStep: currentStep ?? this.currentStep,
      isLastStep: isLastStep ?? this.isLastStep,
    );
  }

  /// Đánh dấu bước hiện tại đã được thực hiện/upload dữ liệu
  AppPaginationState setUploadedStep() {
    final list = List<AppPaginationModel>.from(paginationModel);
    if (currentStep - 1 >= 0 && currentStep - 1 < list.length) {
      list[currentStep - 1] = list[currentStep - 1].copyWith(
        isUploadedStep: true,
        state: AppStepState.success,
      );
    }
    return cloneWith(paginationModel: list);
  }

  @override
  List<Object?> get props => [paginationModel, currentStep, isLastStep];
}
