import 'package:equatable/equatable.dart';
import 'package:learnflutter/features/gift_coupon/model/process_step_model.dart';

/// GiftCouponState lưu trữ trạng thái hiện tại của quá trình xử lý tạo phiếu triển khai quà tặng.
/// Nó quản lý danh sách các trạng thái của từng bước riêng lẻ trong tiến trình.
/// Trạng thái chung bao quát việc xử lý lỗi (errorMessage) và dữ liệu tóm tắt (summaryNotes).
/// Lớp này tuân thủ tính bất biến (immutability) để dễ dàng đồng bộ với UI hệ thống Bloc.
class GiftCouponState extends Equatable {
  final List<ProcessStepModel> steps;
  final bool isLoading;
  final String? errorMessage;
  final String summaryTitle;
  final List<String> summaryNotes;

  const GiftCouponState({
    required this.steps,
    this.isLoading = false,
    this.errorMessage,
    this.summaryTitle = '',
    this.summaryNotes = const [],
  });

  /// factory initial khởi tạo trạng thái bắt đầu.
  /// Nếu cung cấp [pmsCode], Bước 1 sẽ được đánh dấu là Completed ngay từ đầu.
  factory GiftCouponState.initial({String? pmsCode}) {
    final steps = [
      ProcessStepModel(
        title: 'Tạo phiếu triển khai PMS',
        status: pmsCode != null ? ProcessStepStatus.completed : ProcessStepStatus.pending,
        subtitle: pmsCode != null ? 'Mã phiếu: $pmsCode' : null,
      ),
      const ProcessStepModel(title: 'Tạo phiếu thi công Inside'),
    ];

    return GiftCouponState(
      steps: steps,
      summaryTitle: pmsCode != null ? 'Hoàn tất tạo phiếu triển khai - phiếu thi công quà tặng' : '',
      summaryNotes: pmsCode != null ? ['Mã phiếu triển khai PMS: $pmsCode'] : const [],
    );
  }

  /// cloneWith giúp tạo một bản sao mới của trạng thái với một số thay đổi cụ thể.
  /// Phương pháp này cực kỳ hiệu quả trong việc duy trì tính nhất quán khi cập nhật từng thuộc tính nhỏ.
  /// Nó giúp framework Flutter nhận biết chính xác sự thay đổi để vẽ lại giao diện một cách tối ưu.
  GiftCouponState cloneWith({
    List<ProcessStepModel>? steps,
    bool? isLoading,
    String? errorMessage,
    String? summaryTitle,
    List<String>? summaryNotes,
  }) {
    return GiftCouponState(
      steps: steps ?? this.steps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      summaryTitle: summaryTitle ?? this.summaryTitle,
      summaryNotes: summaryNotes ?? this.summaryNotes,
    );
  }

  @override
  List<Object?> get props => [steps, isLoading, errorMessage, summaryNoteTitle, summaryNotes];

  // Helper getter để xác định trạng thái hoàn tất cuối cùng
  bool get isAllCompleted => steps.every((s) => s.status == ProcessStepStatus.completed);
  bool get hasAnyError => steps.any((s) => s.status == ProcessStepStatus.failed);
  
  // ignore: recursive_getters
  String get summaryNoteTitle => summaryTitle;
}
