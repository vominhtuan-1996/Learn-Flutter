import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/engine_dialog/engine_dialog.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:learnflutter/features/gift_coupon/repos/gift_coupon_repository.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/cubit/base_loading_cubit.dart';

/// Tập hợp các flow dialog đặc thù cho **Gift Coupon**.
///
/// Trước đây nằm trong `AppDialogManager`, đã tách ra feature để không gây
/// phụ thuộc ngược từ core (`engine_dialog`) vào feature.
class GiftCouponDialog {
  GiftCouponDialog._();

  static BuildContext get _context => UtilsHelper.navigatorKey.currentContext!;

  /// Hiển thị popup tiến trình (config-driven steps) tạo phiếu PMS → Inside.
  static void showAction({String? pmsCode}) {
    AppDialogEngine.showStepper(
      _context,
      title: 'Tiến trình tạo phiếu triển khai quà tặng',
      steps: [
        AppProcessStepConfig(
          title: 'Tạo phiếu triển khai PMS',
          processingSubtitle: 'Đang tạo phiếu...',
          initialStatus: pmsCode != null
              ? AppProcessStepStatus.completed
              : AppProcessStepStatus.pending,
          initialResult:
              pmsCode != null ? {'status': 'success', 'pmsCode': pmsCode} : null,
          action: () => GiftCouponRepository.instance
              .createPMSCoupon(data: {'type': 'GIFT_PMS'}),
          subtitleBuilder: (result) => 'Mã phiếu: ${result['pmsCode'] ?? ''}',
        ),
        AppProcessStepConfig(
          title: 'Tạo phiếu thi công Inside',
          processingSubtitle: 'Đang tạo phiếu thi công Inside...',
          action: () => GiftCouponRepository.instance
              .createInsideCoupon(data: {'type': 'GIFT_INSIDE'}),
          subtitleBuilder: (result) =>
              'Mã phiếu: ${result['insideCode'] ?? ''} - Nhân sự thi công: ${result['staff'] ?? ''}',
        ),
      ],
      summaryTitleBuilder: (results) =>
          'Hoàn tất tạo phiếu triển khai - phiếu thi công quà tặng',
      summaryNotesBuilder: (results) {
        final pmsRes = results[0];
        final insideRes = results[1];
        return [
          if (pmsRes != null) 'Mã phiếu triển khai PMS: ${pmsRes['pmsCode'] ?? ''}',
          if (insideRes != null)
            'Mã phiếu thi công: ${insideRes['insideCode'] ?? ''} - Nhân sự: ${insideRes['staff'] ?? ''}',
        ];
      },
    );
  }

  /// Luồng nghiệp vụ:
  /// 1. Gọi API tạo phiếu PMS ngầm (loading overlay).
  /// 2. Khi có `pmsCode`, mới mở popup "Tạo phiếu thi công Inside".
  static void startFlow() {
    _context.read<BaseLoadingCubit>().showLoading(
          message: 'Đang khởi tạo phiếu triển khai PMS...',
          func: () async => GiftCouponRepository.instance
              .createPMSCoupon(data: {'type': 'GIFT_PMS'}),
          onSuccess: (response) {
            final pmsCode = response['pmsCode'] ?? 'PMS-888';
            showAction(pmsCode: pmsCode);
          },
          onFailed: (error) {
            AppDialogEngine.error('Không thể khởi tạo phiếu PMS: $error');
          },
        );
  }
}
