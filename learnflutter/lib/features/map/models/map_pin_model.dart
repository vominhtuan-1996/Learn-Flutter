import 'package:hive/hive.dart';

part 'map_pin_model.g.dart';

/// Class MapPinModel định nghĩa cấu trúc dữ liệu cho một điểm ghim trên bản đồ để hỗ trợ việc lưu trữ offline.
/// Lớp này sử dụng annotation HiveType với typeId là 2 để trình tạo mã Hive có thể nhận diện và xây dựng adapter tương ứng.
/// Việc đóng gói tọa độ vào một model giúp quản lý dữ liệu tập trung và dễ dàng mở rộng thêm các thuộc tính khác trong tương lai.
@HiveType(typeId: 2)
class MapPinModel {
  /// Trường latitude lưu trữ giá trị vĩ độ của điểm ghim dưới dạng số thực double để đảm bảo độ chính xác của vị trí.
  /// Nó được đánh dấu là HiveField thứ 0 để trình tạo mã ánh xạ đúng vị trí lưu trữ trong tệp tin nhị phân của Hive.
  @HiveField(0)
  final double latitude;

  /// Trường longitude lưu trữ giá trị kinh độ của điểm ghim giúp xác định vị trí địa lý cụ thể trên bản đồ thế giới.
  /// Việc sử dụng HiveField thứ 1 đảm bảo tính nhất quán trong cấu trúc dữ liệu khi thực hiện các thao tác đọc và ghi file.
  @HiveField(1)
  final double longitude;

  /// Trường title cung cấp một chuỗi ký tự mô tả hoặc tên gọi cho điểm ghim giúp người dùng dễ dàng nhận diện vị trí.
  /// Thuộc tính này có thể mang giá trị null nếu người dùng không cung cấp tên cụ thể cho điểm ghim đã tạo.
  @HiveField(2)
  final String? title;

  /// Hàm khởi tạo MapPinModel yêu cầu các giá trị vĩ độ và kinh độ bắt buộc để tạo ra một điểm ghim hợp lệ.
  /// Tham số title là tùy chọn giúp linh hoạt trong việc hiển thị thông tin bổ sung trên giao diện bản đồ khi được chọn.
  MapPinModel({
    required this.latitude,
    required this.longitude,
    this.title,
  });
}
