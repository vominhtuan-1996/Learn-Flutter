import 'package:equatable/equatable.dart';

/// Định nghĩa trạng thái hiển thị của một bước (Step) trong Stepper.
enum AppStepState {
  pending,      // Chưa thực hiện (Gray Slate)
  active,       // Đang thực hiện (Orange/Blue pulse)
  success,      // Đã hoàn thành (Green check)
  warning,      // Cảnh báo (Orange/Amber exclamation)
  error,        // Lỗi (Red cross)
}

/// Data Model đại diện cho một bước (Step) trong Stepper.
class AppPaginationModel extends Equatable {
  /// Trạng thái bước này đã được hoàn thành hay chưa
  final bool isUploadedStep;

  /// Trạng thái tuỳ chỉnh hiển thị của bước (ví dụ: error, warning)
  final AppStepState state;

  const AppPaginationModel({
    this.isUploadedStep = false,
    this.state = AppStepState.pending,
  });

  AppPaginationModel copyWith({
    bool? isUploadedStep,
    AppStepState? state,
  }) {
    return AppPaginationModel(
      isUploadedStep: isUploadedStep ?? this.isUploadedStep,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [isUploadedStep, state];
}
