import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/map_pin_model.dart';

/// Class MapOfflineState đóng vai trò là một đối tượng chứa trạng thái dữ liệu hiện tại của màn hình bản đồ offline.
/// Nó bao bọc danh sách các đối tượng MapPinModel giúp Cubit có thể truyền tải thông tin về các điểm ghim mới nhất tới giao diện người dùng.
/// Việc định nghĩa một lớp trạng thái riêng biệt giúp việc quản lý và cập nhật UI trở nên rõ ràng và tuân thủ mô hình BLoC pattern.
class MapOfflineState {
  /// Danh sách pins chứa tất cả các điểm tọa độ đã được ghim thành công trên bản đồ từ các phiên làm việc trước đó hoặc hiện tại.
  /// Biến này được khai báo là final để đảm bảo tính bất biến của trạng thái, một nguyên tắc cốt lõi trong việc quản lý state của ứng dụng.
  final List<MapPinModel> pins;

  /// Hàm khởi tạo MapOfflineState cho phép tạo ra một trạng thái mới với danh sách các điểm ghim mặc định hoặc được cung cấp.
  /// Nếu không có danh sách nào được truyền vào, nó sẽ mặc định khởi tạo một danh sách rỗng để tránh lỗi khi truy cập dữ liệu.
  MapOfflineState({this.pins = const []});
}

/// Class MapOfflineCubit chịu trách nhiệm điều phối toàn bộ logic nghiệp vụ liên quan đến việc ghim và lưu trữ tọa độ offline.
/// Nó kế thừa từ lớp Cubit của thư viện flutter_bloc và làm việc trực tiếp với Hive để đảm bảo dữ liệu luôn được lưu xuống bộ nhớ.
/// Lớp này đóng vai trò trung gian giữa tầng lưu trữ dữ liệu và tầng hiển thị, giúp tách biệt mã nguồn xử lý logic ra khỏi UI.
class MapOfflineCubit extends Cubit<MapOfflineState> {
  /// Hàm khởi tạo MapOfflineCubit thực hiện việc thiết lập trạng thái ban đầu và kích hoạt quá trình kết nối với cơ sở dữ liệu Hive.
  /// Việc gọi hàm _initHive ngay khi khởi tạo giúp ứng dụng có thể hiển thị các điểm ghim cũ ngay lập tức khi màn hình bản đồ được mở.
  MapOfflineCubit() : super(MapOfflineState()) {
    _initHive();
  }

  /// Hằng số boxName xác định tên định danh cho hộp lưu trữ của Hive nơi các đối tượng MapPinModel sẽ được cất giữ an toàn.
  /// Việc sử dụng một hằng số giúp tránh các lỗi gõ sai tên box trong quá trình thực hiện các thao tác mở hoặc truy vấn dữ liệu.
  static const String boxName = 'map_pins_box';

  /// Phương thức _initHive thực hiện việc mở hộp lưu trữ Hive tương ứng và đẩy dữ liệu hiện có lên trạng thái của Cubit.
  /// Sau khi hộp đã sẵn sàng, nó sẽ đọc toàn bộ giá trị có trong box và cập nhật vào danh sách pins giúp giao diện hiển thị đúng dữ liệu.
  /// Đây là bước quan trọng nhất để duy trì tính nhất quán của dữ liệu giữa các lần khởi động ứng dụng khác nhau của người dùng.
  Future<void> _initHive() async {
    final box = await Hive.openBox<MapPinModel>(boxName);
    emit(MapOfflineState(pins: box.values.toList()));
  }

  /// Hàm addPin thực hiện chức năng thêm một điểm tọa độ mới vào cả cơ sở dữ liệu Hive lẫn trạng thái hiện tại của ứng dụng.
  /// Nó tạo ra một đối tượng MapPinModel mới từ tọa độ nhận được và gán cho nó một tiêu đề tự động dựa trên số lượng pin hiện có.
  /// Bằng cách lưu vào box và phát ra trạng thái mới, giao diện người dùng sẽ ngay lập tức vẽ thêm một marker mới lên bản đồ thực tế.
  Future<void> addPin(double lat, double lng) async {
    final box = Hive.box<MapPinModel>(boxName);
    final newPin = MapPinModel(
      latitude: lat,
      longitude: lng,
      title: 'Vị trí ghim ${state.pins.length + 1}',
    );
    await box.add(newPin);
    emit(MapOfflineState(pins: box.values.toList()));
  }

  /// Phương thức clearAllPins cho phép người dùng xóa bỏ toàn bộ các điểm đã ghim trước đó để làm sạch dữ liệu trên bản đồ.
  /// Nó thực hiện lệnh xóa sạch các bản ghi trong hộp lưu trữ Hive và đồng thời phát đi một trạng thái mới với danh sách pin rỗng.
  /// Chức năng này rất hữu ích khi người dùng muốn bắt đầu lại quá trình đánh dấu các vị trí mới mà không bị ảnh hưởng bởi dữ liệu cũ.
  Future<void> clearAllPins() async {
    final box = Hive.box<MapPinModel>(boxName);
    await box.clear();
    emit(MapOfflineState(pins: []));
  }
}
