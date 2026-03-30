
/// GiftCouponRepository chịu trách nhiệm thực hiện các yêu cầu mạng liên quan đến quy trình tạo phiếu quà tặng.
/// Nó tương tác trực tiếp với ApiClient để gửi dữ liệu và nhận phản hồi từ máy chủ.
/// Lớp này tuân thủ mô hình Repository giúp tách biệt logic truy cập dữ liệu khỏi logic nghiệp vụ của ứng dụng.
class GiftCouponRepository {
  /// Sử dụng pattern Singleton hoặc khởi tạo thông qua Service Locator tùy theo cấu trúc dự án.
  /// Ở đây tôi sử dụng instance nội bộ để đơn giản hóa việc tích hợp.
  static final GiftCouponRepository instance = GiftCouponRepository._internal();
  GiftCouponRepository._internal();

  /// createPMSCoupon gửi yêu cầu tạo một phiếu triển khai PMS mới lên hệ thống.
  /// Hiện tại đang ở chế độ giả lập (Mock) để phục vụ kiểm thử giao diện.
  Future<Map<String, dynamic>> createPMSCoupon({required Map<String, dynamic> data}) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'success',
      'pmsCode': 'PMS-${DateTime.now().millisecondsSinceEpoch % 10000}',
    };
  }

  /// createInsideCoupon gửi thông tin để tạo phiếu thi công Inside sau khi đã có phiếu PMS.
  /// Hiện tại đang ở chế độ giả lập (Mock) để phục vụ kiểm thử giao diện.
  Future<Map<String, dynamic>> createInsideCoupon({required Map<String, dynamic> data}) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'success',
      'insideCode': 'INSIDE-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'staff': 'handtn8 (Nguyễn Văn Hân)',
    };
  }
}
