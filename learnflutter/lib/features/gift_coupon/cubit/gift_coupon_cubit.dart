import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/features/gift_coupon/model/process_step_model.dart';
import 'package:learnflutter/features/gift_coupon/repos/gift_coupon_repository.dart';
import 'package:learnflutter/features/gift_coupon/state/gift_coupon_state.dart';

/// GiftCouponCubit điều phối quy trình tạo phiếu quà tặng qua các bước khác nhau.
/// Nó quản lý trình tự xử lý (PMS trước, Inside sau), ghi nhận trạng thái và kết quả từ API.
/// Các trạng thái lỗi được xử lý thông qua cơ chế retry thông minh để không gián đoạn trải nghiệm người dùng.
class GiftCouponCubit extends Cubit<GiftCouponState> {
  final GiftCouponRepository _repository = GiftCouponRepository.instance;

  GiftCouponCubit({String? pmsCode}) : super(GiftCouponState.initial(pmsCode: pmsCode));

  /// startProcess bắt đầu quy trình tạo phiếu tuần tự từ đầu hoặc từ bước hiện tại.
  /// Nó kiểm tra trạng thái của từng bước để quyết định việc kích hoạt các luồng gọi API tương ứng.
  /// Quy trình đảm bảo tính toàn vẹn dư liệu khi chuyển giao thông tin từ bước PMS sang bước Inside.
  Future<void> startProcess() async {
    // Luôn bắt đầu từ bước đầu tiên chưa hoàn thành
    if (state.steps[0].status != ProcessStepStatus.completed) {
      await _executeStep1();
    }

    // Chỉ tiếp tục bước 2 nếu bước 1 đã thành công
    if (state.steps[0].status == ProcessStepStatus.completed && state.steps[1].status != ProcessStepStatus.completed) {
      await _executeStep2();
    }
  }

  /// _executeStep1 thực hiện logic tạo phiếu triển khai PMS và cập nhật kết quả vào danh sách.
  /// Quá trình này bao gồm việc cập nhật trạng thái "đang xử lý" và bắt các ngoại lệ từ mạng.
  /// Kết quả thành công sẽ được trích xuất để ghi nhận mã phiếu vào phần thông tin chung.
  Future<void> _executeStep1() async {
    try {
      final updatedSteps = List<ProcessStepModel>.from(state.steps);
      updatedSteps[0] = updatedSteps[0].copyWith(status: ProcessStepStatus.processing);
      emit(state.cloneWith(steps: updatedSteps, isLoading: true, errorMessage: null));
      await Future.delayed(Duration(seconds: 2)); // Mô phỏng thời gian xử lý
      final response = await _repository.createPMSCoupon(data: {'type': 'GIFT_PMS'});
      final String pmsCode = response['pmsCode'] ?? '1234'; // Giá trị mẫu

      updatedSteps[0] = updatedSteps[0].copyWith(
        status: ProcessStepStatus.completed,
        subtitle: 'Mã phiếu: $pmsCode',
      );

      final List<String> currentNotes = List<String>.from(state.summaryNotes);
      currentNotes.add('Mã phiếu triển khai PMS: $pmsCode');

      emit(state.cloneWith(
        steps: updatedSteps,
        isLoading: false,
        summaryTitle: 'Hoàn tất tạo phiếu triển khai - phiếu thi công quà tặng',
        summaryNotes: currentNotes,
      ));
    } catch (e) {
      _handleError(0, e.toString());
    }
  }

  /// _executeStep2 thực hiện tạo phiếu thi công Inside bằng cách gọi API của hệ thống Inside.
  /// Bước này đòi hỏi phải hiển thị thông tin nhân sự và mã phiếu thi công tương ứng.
  /// Kết quả cuối cùng sẽ kích hoạt việc hiển thị Summary Box hoàn chỉnh cho người dùng.
  Future<void> _executeStep2() async {
    try {
      final updatedSteps = List<ProcessStepModel>.from(state.steps);
      updatedSteps[1] = updatedSteps[1].copyWith(status: ProcessStepStatus.processing);
      emit(state.cloneWith(steps: updatedSteps, isLoading: true, errorMessage: null));
      await Future.delayed(Duration(seconds: 2)); // Mô phỏng thời gian xử lý
      final response = await _repository.createInsideCoupon(data: {'type': 'GIFT_INSIDE'});
      final String insideCode = response['insideCode'] ?? '456789'; // Giá trị mẫu
      final String staff = response['staff'] ?? 'handtn8'; // Giá trị mẫu

      updatedSteps[1] = updatedSteps[1].copyWith(
        status: ProcessStepStatus.completed,
        subtitle: 'Mã phiếu: $insideCode - Nhân sự thi công: $staff',
      );

      final List<String> currentNotes = List<String>.from(state.summaryNotes);
      currentNotes.add('Mã phiếu thi công: $insideCode - Nhân sự thi công: $staff');

      emit(state.cloneWith(
        steps: updatedSteps,
        isLoading: false,
        summaryNotes: currentNotes,
      ));
    } catch (e) {
      _handleError(1, e.toString());
    }
  }

  /// retryStep thực hiện việc thử lại một bước cụ thể mà người dùng yêu cầu sau khi có lỗi.
  /// Cơ chế này giúp khôi phục quy trình xử lý mà không cần phải thực hiện lại toàn bộ từ đầu.
  /// Nó nâng cao hiệu suất và sự tiện dụng bằng cách duy trì các dữ liệu đã xử lý thành công trước đó.
  Future<void> retryStep(int index) async {
    if (index == 0) {
      await _executeStep1();
      if (state.steps[0].status == ProcessStepStatus.completed) {
        await _executeStep2();
      }
    } else if (index == 1) {
      await _executeStep2();
    }
  }

  /// _handleError quản lý việc cập nhật trạng thái thất bại cho một bước cụ thể trong hệ thống.
  /// Nó đồng bộ lỗi (errorMessage) lên cấp độ state chung để hiển thị thông báo dưới dòng Footer của Dialog.
  void _handleError(int index, String message) {
    final updatedSteps = List<ProcessStepModel>.from(state.steps);
    updatedSteps[index] = updatedSteps[index].copyWith(
      status: ProcessStepStatus.failed,
      onRetry: () => retryStep(index),
    );
    emit(state.cloneWith(
      steps: updatedSteps,
      isLoading: false,
      errorMessage: 'Lỗi thực thi: $message',
    ));
  }
}
