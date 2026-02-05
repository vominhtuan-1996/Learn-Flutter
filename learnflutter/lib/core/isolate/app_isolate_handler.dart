import 'dart:async';
import 'dart:isolate';

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
