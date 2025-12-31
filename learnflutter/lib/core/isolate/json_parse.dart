import 'dart:convert';
import 'dart:isolate';

/// Class để đóng gói dữ liệu truyền vào Isolate
class ParseJsonMessage {
  final String rawJson;
  final SendPort sendPort;

  ParseJsonMessage(this.rawJson, this.sendPort);
}

/// Hàm xử lý JSON trong Isolate
void parseJsonInIsolate(ParseJsonMessage message) {
  final List<dynamic> parsedItems = jsonDecode(message.rawJson);
  for (final item in parsedItems) {
    // Gửi từng item về main thread
    print(item);
    message.sendPort.send(item);
  }
  // Đánh dấu kết thúc
  message.sendPort.send(null);
}

/// Hàm parse JSON bằng Isolate và gửi từng item
Stream<dynamic> parseJson(String rawJson) async* {
  final receivePort = ReceivePort();

  // Tạo Isolate để xử lý JSON
  await Isolate.spawn(
    parseJsonInIsolate,
    ParseJsonMessage(rawJson, receivePort.sendPort),
  );

  // Nhận từng item từ Isolate
  await for (final item in receivePort) {
    if (item == null) {
      // Nếu nhận null, dừng stream
      break;
    } else {
      yield item; // Trả về từng item
    }
  }
}
