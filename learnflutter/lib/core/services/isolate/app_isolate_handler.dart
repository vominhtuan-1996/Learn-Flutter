import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart' show kIsWeb;

/* ============================================================================
 * 🛠 ADVANCED MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì nâng cao)
 * ============================================================================
 * 
 * 1. LỰA CHỌN CƠ CHẾ (Isolate.run vs Isolate.spawn):
 *    - QUY TẮC: Ưu tiên sử dụng `Isolate.run()` cho các tác vụ tính toán một lần (one-off tasks) 
 *      vì nó tự động quản lý vòng đời và có hiệu năng tốt hơn (zero-copy cho dữ liệu nhỏ).
 *    - ĐỊNH HƯỚNG: Chỉ sử dụng `Isolate.spawn()` thủ công (như trong json_parse.dart) 
 *      khi cần một Isolate chạy nền lâu dài (Long-lived worker) hoặc cần giao tiếp 2 chiều liên tục.
 * 
 * 2. GIỚI HẠN DỮ LIỆU TRUYỀN TẢI (Data Passing Limits):
 *    - QUY TẮC: TUYỆT ĐỐI KHÔNG truyền các object chứa `dart:ui` (Image, Canvas, v.v.) hoặc 
 *      các đối tượng có trạng thái phức tạp (Closures không tĩnh) qua Isolate.
 *    - CẢNH BÁO: Việc sao chép dữ liệu giữa các Isolate tốn chi phí CPU. Với dữ liệu cực lớn, 
 *      hãy cân nhắc sử dụng `TransferableTypedData` để tối ưu bộ nhớ.
 * 
 * 3. QUY TẮC VIẾT HÀM COMPUTE (Closure Rules):
 *    - QUY TẮC: Hàm được truyền vào `compute` nên là hàm Top-level hoặc hàm Static. 
 *      Tránh sử dụng hàm thuộc instance nếu hàm đó truy cập vào các biến thành viên 
 *      không thể serialize (non-serializable).
 * 
 * 4. QUẢN LÝ TẬP TRUNG (Centralized Management):
 *    - ĐỊNH HƯỚNG: Mọi tác vụ nặng trong tương lai (Xử lý ảnh, giải mã file lớn, 
 *      mã hóa dữ liệu) nên được đưa về `AppIsolateHandler` để quản lý tập trung, 
 *      tránh việc spawn Isolate bừa bãi gây tràn bộ nhớ RAM.
 * ============================================================================
 */

/// Lớp quản lý Isolate toàn ứng dụng giúp xử lý các tác vụ tiêu tốn nhiều CPU.
///
/// Trong Flutter, mọi hoạt động mặc định đều diễn ra trên Main Isolate hay còn gọi là UI Thread.
/// Khi có một tác vụ tính toán nặng như giải mã JSON lớn hoặc xử lý hình ảnh phức tạp,
/// nó sẽ chiếm dụng luồng này và gây ra hiện tượng giật lag cho ứng dụng của chúng ta.
/// Class này được thiết kế theo mô hình Singleton để cung cấp một giải pháp quản lý tập trung,
/// cho phép đẩy các tác vụ nặng sang một Isolate riêng biệt để bảo đảm hiệu năng giao diện cao nhất.
class AppIsolateHandler {
  static final AppIsolateHandler _instance = AppIsolateHandler._internal();

  /// Constructor Singleton đảm bảo chỉ có duy nhất một đối tượng quản lý Isolate trong app.
  ///
  /// Việc duy trì một instance duy nhất trong suốt vòng đời của ứng dụng giúp chúng ta
  /// kiểm soát chặt chẽ việc khởi tạo cũng như giải phóng tài nguyên của hệ điều hành.
  /// Nó ngăn chặn việc tạo ra quá nhiều Isolate cùng lúc gây lãng phí bộ nhớ không đáng có
  /// và giúp việc truy cập từ bất kỳ màn hình nào trong dự án trở nên dễ dàng và nhất quán hơn.
  factory AppIsolateHandler() => _instance;

  AppIsolateHandler._internal();

  /// Thực thi một hàm tính toán nặng trong một Isolate mới và trả lại kết quả sau khi xong.
  ///
  /// Phương thức này tận dụng hàm Isolate.run() vốn là một tính năng mạnh mẽ của ngôn ngữ Dart.
  /// Nó tự động hóa toàn bộ quy trình từ việc spawn một Isolate mới cho đến khi trả kết quả.
  /// Sau khi tác vụ hoàn tất, nó sẽ gửi dữ liệu về Main thread và tự động tiêu hủy Isolate đó.
  /// Cách làm này giúp mã nguồn của chúng ta ngắn gọn và an toàn hơn so với việc quản lý thủ công.
  Future<T> compute<T>(FutureOr<T> Function() computation) async {
    // Web không hỗ trợ dart:isolate (Isolate.run sẽ throw UnsupportedError).
    // Chạy trực tiếp trên main thread khi ở môi trường Web.
    if (kIsWeb) {
      return await computation();
    }
    try {
      return await Isolate.run(computation);
    } catch (e) {
      rethrow;
    }
  }

  /// Thực hiện giải mã JSON trong Isolate để tránh làm chậm luồng giao diện người dùng.
  ///
  /// Đây là một ví dụ điển hình cho việc áp dụng Isolate vào thực tế của dự án Flutter.
  /// Khi nhận được dữ liệu lớn từ API, việc parse JSON có thể tốn rất nhiều thời gian xử lý.
  /// Bằng cách đưa logic này vào Isolate, quá trình chuyển đổi dữ liệu thô sang các model
  /// sẽ diễn ra hoàn toàn độc lập giúp cho người dùng vẫn cảm thấy ứng dụng hoạt động mượt mà.
  Future<T> parseJson<T>(T Function() parseTask) async {
    return await compute(parseTask);
  }
}
