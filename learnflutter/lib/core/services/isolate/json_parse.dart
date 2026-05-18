import 'dart:convert';
import 'dart:isolate';

/// Lớp ParseJsonMessage được sử dụng để đóng gói dữ liệu và cổng gửi tin nhắn (SendPort) khi làm việc với Isolate.
/// Nó cho phép chúng ta truyền dữ liệu chuỗi JSON thô kèm theo kênh liên lạc để Isolate có thể phản hồi kết quả về luồng chính.
/// Cấu trúc này giúp việc trao đổi thông tin giữa các luồng xử lý trở nên tường minh (explicit) và an toàn hơn.
class ParseJsonMessage {
  final String rawJson;
  final SendPort sendPort;

  ParseJsonMessage(this.rawJson, this.sendPort);
}

/// Hàm parseJsonInIsolate thực hiện việc giải mã chuỗi JSON trực tiếp bên trong một Isolate riêng biệt.
/// Nó lặp qua danh sách các đối tượng đã được giải mã và gửi từng phần tử về luồng chính thông qua cổng giao tiếp được cung cấp.
/// Việc xử lý từng mục một giúp giảm thiểu việc dồn nén dữ liệu lớn cùng lúc, đồng thời đánh dấu kết thúc quá trình bằng một giá trị null.
void parseJsonInIsolate(ParseJsonMessage message) {
  final List<dynamic> parsedItems = jsonDecode(message.rawJson);
  for (final item in parsedItems) {
    // Gửi từng item về main thread
    message.sendPort.send(item);
  }
  // Đánh dấu kết thúc để luồng chính biết quá trình đã hoàn tất
  message.sendPort.send(null);
}

/// Hàm parseJson cung cấp một luồng dữ liệu (Stream) các đối tượng đã được giải mã từ chuỗi JSON thô.
/// Nó tự động khởi tạo và quản lý vòng đời của Isolate, giúp tách biệt hoàn toàn quá trình giải mã nặng nề khỏi luồng giao diện người dùng.
/// Thông qua cơ chế async*, hàm này trả về kết quả từng bước ngay khi chúng sẵn sàng, mang lại hiệu suất cao cho các dữ liệu lớn.
Stream<dynamic> parseJson(String rawJson) async* {
  final receivePort = ReceivePort();

  // Tạo Isolate để xử lý JSON một cách độc lập
  await Isolate.spawn(
    parseJsonInIsolate,
    ParseJsonMessage(rawJson, receivePort.sendPort),
  );

  // Nhận và trả về từng phần tử từ Isolate cho đến khi kết thúc
  await for (final item in receivePort) {
    if (item == null) {
      // Dừng luồng dữ liệu khi nhận được tín hiệu kết thúc
      break;
    } else {
      yield item; // Trả về từng đối tượng cho lớp gọi sử dụng
    }
  }
}
