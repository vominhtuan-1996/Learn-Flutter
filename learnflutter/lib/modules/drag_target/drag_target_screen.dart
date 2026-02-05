import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

/// Lớp String define trung tâm cho màn hình DragTarget.
///
/// Việc tách biệt các hằng số chuỗi ra một lớp riêng biệt giúp chúng ta quản lý tài nguyên hệ thống một cách khoa học và dễ dàng thực hiện đa ngôn ngữ sau này.
/// Thay vì nhúng trực tiếp văn bản vào mã nguồn giao diện, lớp này đóng vai trò như một kho chứa tập trung để mọi thành phần trong module đều có thể truy cập thống nhất.
/// Cách làm này giúp giảm thiểu sai sót khi cần cập nhật nội dung hàng loạt và giúp mã nguồn trở nên sạch sẽ, tuân thủ tốt các nguyên tắc kiến trúc phần mềm hiện đại.
class DragTargetStrings {
  /// Thông báo debug khi quá trình kéo thả bắt đầu và được hệ thống ghi nhận thành công.
  ///
  /// Chuỗi này được sử dụng trong các lệnh print hoặc log để lập trình viên có thể theo dõi luồng dữ liệu của tọa độ X và Y ngay tại thời điểm xảy ra sự kiện.
  /// Nó giúp xác định chính xác vị trí mà người dùng đã thả vật thể trên màn hình, từ đó hỗ trợ việc kiểm tra tính đúng đắn của logic tính toán khoảng cách.
  /// Việc định nghĩa một chuỗi chuẩn cho debug log còn giúp quá trình lọc thông tin trong console của các công cụ phát triển như VSCode hay Android Studio trở nên thuận tiện hơn.
  static const String onAcceptWithDetails = 'onAcceptWithDetails';
}

class DragTargetScreen extends StatefulWidget {
  const DragTargetScreen({super.key});
  @override
  State<DragTargetScreen> createState() => DragTargetScreenState();
}

class DragTargetScreenState extends State<DragTargetScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  /// Danh sách các màu tiêu chuẩn được sử dụng làm dữ liệu gốc cho các khối hình trong màn hình.
  ///
  /// Các giá trị màu sắc này được định nghĩa cố định để tạo ra sự ổn định cho giao diện ứng dụng và làm cơ sở tham chiếu cho mọi phép tính toán logic về sau.
  /// Flutter sử dụng các hằng số từ lớp Colors để đảm bảo tính nhất quán về bảng màu trên nhiều nền tảng phần cứng và phiên bản hệ điều hành khác nhau.
  /// Việc khởi tạo danh sách này ngay tại cấp độ state giúp dữ liệu được bảo toàn trong suốt vòng đời của widget và sẵn sàng cho các thao tác kéo thả phức tạp.
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.brown,
    Colors.deepPurple
  ];

  /// Danh sách shuffledColors được khởi tạo như một bản lưu trữ trung gian để quản lý trạng thái sắp xếp của các khối màu trong quá trình tương tác.
  ///
  /// Việc tạo bản sao này giúp chúng ta bảo vệ mảng màu gốc ban đầu và cho phép thực hiện các phép hoán đổi vị trí một cách an toàn.
  /// Trong kiến trúc Flutter, việc duy trì một trạng thái tạm thời như thế này là cực kỳ quan trọng để đảm bảo tính nhất quán của giao diện khi người dùng thực hiện thao tác kéo thả.
  /// Nó đóng vai trò là tầng đệm dữ liệu, giúp các hoạt ảnh và trạng thái hiển thị không bị xung đột với dữ liệu nguồn trong khi logic xử lý đang diễn ra.
  List<Color> shuffledColors = [];

  /// Biến lưu trữ vị trí index của phần tử bắt đầu được người dùng tương tác kéo đi trên màn hình.
  ///
  /// Giá trị này cực kỳ quan trọng vì nó xác định đối tượng nguồn trong phép hoán đổi dữ liệu giữa vị trí cũ và vị trí mới khi sự kiện thả xảy ra.
  /// Bằng cách ghi nhớ index này, hệ thống có thể truy cập nhanh chóng vào mảng dữ liệu để trích xuất màu sắc và các thuộc tính liên quan khác của vật thể.
  /// Chỉ số này được cập nhật ngay khi sự kiện onDragStarted kích hoạt, tạo ra một tham chiếu chính xác cho toàn bộ quy trình xử lý sự kiện tiếp theo.
  int indexStarted = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Widget BaseLoading cung cấp khả năng hiển thị vòng xoay chờ đợi khi ứng dụng đang thực hiện các tác vụ nền tảng phức tạp hoặc load dữ liệu.
    ///
    /// Nó bao bọc các widget con để giúp quản lý trạng thái phản hồi của giao diện một cách trực quan, đảm bảo người dùng không bị nhầm lẫn khi hệ thống đang xử lý.
    /// Trong ví dụ này, giá trị isLoading được đặt là false nhưng nó tạo ra một cấu trúc chuẩn để chúng ta có thể mở rộng tính năng đồng bộ hóa dữ liệu Isolate sau này.
    /// Việc sử dụng một widget cơ sở chung như thế này giúp duy trì trải nghiệm người dùng đồng nhất xuyên suốt toàn bộ các module trong dự án học tập.
    return BaseLoading(
      isLoading: false,
      child: SingleChildScrollView(
        /// Thuộc tính scrollDirection được cấu hình là Axis.horizontal nhằm đảm bảo hàng chứa các khối màu có thể cuộn ngang mượt mà trên các thiết bị có màn hình hẹp.
        ///
        /// Mặc định SingleChildScrollView sẽ cuộn dọc, điều này gây xung đột với cách bố trí của Row bên trong vốn phát triển theo chiều ngang của ứng dụng.
        /// Việc thiết lập tham số này giúp ngăn chặn tình trạng tràn viền (overflow) khi số lượng vật thể tăng lên hoặc khi chạy trên các thiết bị di động có kích thước nhỏ.
        /// Đây là một bước tối ưu hóa quan trọng giúp trải nghiệm người dùng trở nên nhất quán và chuyên nghiệp hơn trong mọi ngữ cảnh sử dụng thực tế.
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            5,
            (index) {
              /// Xác định màu sắc hiển thị cho mỗi ô dựa trên việc danh sách tạm shuffledColors đã có dữ liệu hay chưa.
              ///
              /// Logic này cho phép ứng dụng linh hoạt chuyển đổi giữa trạng thái mặc định ban đầu và trạng thái sau khi người dùng bắt đầu các hành động tương tác.
              /// Đây là một kỹ thuật quản lý trạng thái đơn giản nhưng hiệu quả trong Flutter, giúp UI luôn phản ánh đúng nhất tình trạng hiện tại của dữ liệu nền.
              /// Việc sử dụng toán tử ba ngôi giúp mã nguồn ngắn gọn, dễ đọc và đảm bảo rằng không bao giờ xảy ra lỗi truy cập mảng rỗng khi widget mới khởi tạo.
              Color color = shuffledColors.isNotEmpty
                  ? shuffledColors[index]
                  : colors[index];

              /// Widget Draggable cho phép bất kỳ thành phần giao diện nào trở nên linh động và có thể di chuyển theo ngón tay người dùng.
              ///
              /// Nó mang theo một payload dữ liệu được định nghĩa qua thuộc tính data để truyền tải thông tin từ vị trí bắt đầu sang vị trí đích của hành động thả.
              /// Flutter cung cấp cơ chế này để thực hiện mô hình kéo-thả (drag-and-drop) một cách mượt mà nhờ vào việc tách biệt giữa vật thể hiển thị và dữ liệu thực tế.
              /// Các callback như onDragStarted đóng vai trò khởi động các quy trình chuẩn bị dữ liệu tạm thời để giao diện có thể phản hồi tức thì với thao tác của user.
              return Draggable(
                data: colors,
                feedback: Container(
                  width: 50,
                  height: 50,
                  color: color,
                ),
                onDragStarted: () {
                  setState(() {
                    indexStarted = index;
                    shuffledColors = List.from(colors);
                  });
                },

                /// Callback onDraggableCanceled được kích hoạt khi người dùng kết thúc thao tác kéo nhưng không thả vật thể vào bất kỳ vùng mục tiêu hợp lệ nào.
                ///
                /// Trong trường hợp này, chúng ta thực hiện việc xóa sạch danh sách tạm shuffledColors để đưa hệ thống về trạng thái ban đầu ổn định nhất.
                /// Việc gọi setState() ở đây đảm bảo giao diện được cập nhật lại ngay lập tức, tránh việc dữ liệu rác vẫn còn tồn tại âm thầm trong bộ nhớ đệm.
                /// Điều này giúp tối ưu hóa tài nguyên và ngăn chặn các hành vi bất thường của UI khi người dùng bắt đầu một lượt tương tác mới tiếp theo.
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    shuffledColors.clear();
                  });
                },
                childWhenDragging: Container(),
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: color,
                    );
                  },
                  onWillAcceptWithDetails: (DragTargetDetails details) {
                    return true;
                  },
                  onAcceptWithDetails: (DragTargetDetails details) {
                    setState(() {
                      /// Biến tạm thời này đóng vai trò quan trọng trong việc ghi nhớ giá trị màu sắc tại vị trí đích trước khi nó bị ghi đè bởi thao tác kéo thả.
                      ///
                      /// Kỹ thuật này giúp lập trình viên bảo toàn dữ liệu để có thể thực hiện phép hoán đổi vị trí giữa hai phần tử một cách chính xác.
                      /// Trong quá trình phát triển ứng dụng Flutter, việc sử dụng các biến lưu trữ tạm là phương pháp tiêu chuẩn để xử lý logic hoán đổi mà không làm mất mát thông tin của người dùng.
                      /// Nó đảm bảo rằng dữ liệu không bị thất lạc trong kẽ hở thời gian khi một ô màu được nhấc lên và ô kia được đặt xuống tại cùng một vùng hiển thị.
                      Color temp = shuffledColors[index];

                      /// Dòng mã này thực hiện việc cập nhật giá trị tại vị trí đích bằng màu sắc của khối được kéo.
                      ///
                      /// Đây là bước then chốt trong logic hoán đổi vị trí giúp thay đổi cấu trúc của danh sách các khối màu ngay trên giao diện.
                      /// Bằng cách thay đổi trực tiếp trên bản sao dữ liệu, chúng ta tạo ra tiền đề để hệ thống có thể nhận diện sự thay đổi và chuẩn bị cho việc cập nhật lại trạng thái hiển thị.
                      /// Thao tác này mô phỏng lại cách các phần tử vật lý di chuyển trong không gian thực, mang lại cảm giác chân thực cho trải nghiệm người dùng cuối.
                      shuffledColors[index] = shuffledColors[indexStarted];

                      /// Phép gán cuối cùng này đưa giá trị màu tại vị trí đích ban đầu vào vị trí của khối vừa được kéo đi để hoàn thành phép hoán đổi.
                      ///
                      /// Hành động này xác nhận rằng mọi thay đổi về mặt logic đã được thực thi đầy đủ và danh sách màu sắc đã đạt được trạng thái mong muốn sau thao tác của người dùng.
                      /// Việc thực hiện bước này một cách tường minh giúp đảm bảo tính toàn vẹn của dữ liệu và giúp Flutter render lại giao diện một cách chuẩn xác nhất.
                      /// Sau khi hoàn tất, mảng dữ liệu đã sẵn sàng để được đồng bộ về mảng colors chính thức dùng cho các lần tương tác tiếp theo.
                      shuffledColors[indexStarted] = temp;

                      print(shuffledColors);
                      print(colors);
                      print(index);
                      print(
                          '${DragTargetStrings.onAcceptWithDetails} ${details.offset.dx}');
                      print(
                          '${DragTargetStrings.onAcceptWithDetails} ${details.offset.dy}');
                      colors = List.from(shuffledColors);
                      shuffledColors.clear();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
