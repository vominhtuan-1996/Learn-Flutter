import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/features/home/home_aniamtion.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';

/// Lớp IntroSplash đảm nhiệm vai trò giới thiệu tổng quan về bản sắc và giá trị cốt lõi của thương hiệu PetSocial tới người dùng ngay khi họ bắt đầu hành trình trải nghiệm ứng dụng.
/// Thành phần này kết hợp nhuần nhuyễn giữa các hiệu ứng chuyển động mượt mà của logo và các thông điệp chào mừng để tạo ra một khởi đầu đầy ấn tượng và chuyên nghiệp.
/// Nó cung cấp một cái nhìn khái quát về hệ sinh thái của ứng dụng, đồng thời cho phép người dùng linh hoạt bắt đầu quá trình tương tác thông qua các nút bấm hành động.
/// Toàn bộ logic về thời gian chuyển cảnh tự động và xử lý hoạt họa đều được tích hợp chặt chẽ để đảm bảo luồng trải nghiệm của người dùng luôn liền mạch và hấp dẫn.
class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /// Khởi tạo AnimationController để quản lý toàn bộ dòng thời gian và tiến trình của các hiệu ứng hình ảnh xuất hiện trên màn hình giới thiệu của ứng dụng.
    /// Chúng tôi thiết kế các đối tượng Tween để tạo ra hiệu ứng phóng to kích thước nhẹ nhàng kết hợp với sự thay đổi độ trong suốt của các thành phần đồ họa chủ chốt.
    /// Việc áp dụng đường cong chuyển động Curves.elasticOut giúp cho việc xuất hiện của logo PetSocial trở nên sinh động, tự nhiên và thu hút thị giác người dùng hơn.
    /// Sau khi các thông số cấu hình đã sẵn sàng, tiến trình hoạt họa sẽ được kích hoạt ngay lập tức để người dùng có thể chiêm ngưỡng sự khởi đầu mượt mà này.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    /// Thiết lập một cơ chế đếm thời gian tự khởi động để chuyển hướng người dùng tới màn hình xác thực tài khoản sau một khoảng thời gian chờ đợi ngắn nhất định.
    /// Cơ chế này đóng vai trò quan trọng trong việc đảm bảo hành trình người dùng luôn được dẫn dắt liên tục ngay cả khi họ không thực hiện bất kỳ tương tác vật lý nào trên màn hình.
    /// Thời gian chờ 4 giây được đánh giá là ngưỡng lý tưởng để người dùng có đủ thời gian tiếp nhận các thông điệp chào mừng và quan sát trọn vẹn các hiệu ứng hình ảnh.
    /// Đây là một phần trong nỗ lực tối ưu hóa trải nghiệm người dùng, giúp tạo ra một luồng chuyển động tự động và tinh tế giữa các giai đoạn khởi chạy của ứng dụng.
    _timer = Timer(const Duration(milliseconds: 4000), _goToHome);
  }

  /// Phương thức dispose được ghi đè để đảm bảo việc giải phóng triệt để các tài nguyên hệ thống quan trọng như Timer và AnimationController khi widget không còn hiển thị.
  /// Việc hủy bỏ các luồng xử lý thời gian giúp ngăn chặn hiệu quả các rủi ro liên quan đến rò rỉ bộ nhớ hoặc các lỗi logic khi gọi hàm chuyển cảnh sau khi context đã bị hủy.
  /// Đây là một bước quản trị vòng đời bắt buộc và cực kỳ quan trọng nhằm duy trì hiệu năng ổn định và sự bền bỉ cho toàn bộ ứng dụng trong quá trình vận hành lâu dài.
  /// Tuân thủ quy tắc này giúp đảm bảo rằng ứng dụng luôn hoạt động chính xác theo các trạng thái mong muốn của lập trình viên và không gây ra các tác vụ chạy ngầm thừa thãi.
  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Hàm _goToHome thực hiện nhiệm vụ quan trọng là chuyển đổi trạng thái giao diện từ màn hình giới thiệu sang trang đăng nhập chính thức của ứng dụng.
  /// Chúng tôi sử dụng phương thức pushReplacementNamed với định danh đã được cấu hình trong router để loại bỏ hoàn toàn màn hình giới thiệu khỏi ngăn xếp điều hướng nhằm tối ưu hóa bộ nhớ.
  /// Trước khi thực thi lệnh chuyển màn, hàm sẽ luôn thực hiện kiểm tra tính hợp lệ của thuộc tính mounted để đảm bảo quá trình chuyển hướng diễn ra an toàn và không gây lỗi runtime.
  /// Việc chuyển trực tiếp tới trang đăng nhập giúp người dùng nhanh chóng bắt đầu quy trình xác thực và truy cập vào các tính năng cá nhân hóa của PetSocial.
  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeAnimationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Xây dựng lớp nền cho màn hình khởi động bằng cách sử dụng hiệu ứng chuyển màu gradient tinh tế, tạo ra cảm giác mượt mà và gần gũi với môi trường thiên nhiên.
          /// Sự kết hợp hài hòa giữa các tông màu xanh lá cây tượng trưng cho sự sinh trưởng và tươi mới, rất phù hợp với định hướng thương hiệu dành cho cộng đồng yêu thú cưng.
          /// Lớp Container này được cấu hình để bao trùm toàn bộ diện tích hiển thị, thiết lập một bối cảnh thị giác chuyên nghiệp và nhất quán cho các yếu tố thông tin phía trên.
          /// Cách tiếp cận này không chỉ làm tăng tính thẩm mỹ cho giao diện mà còn giúp làm nổi bật các thành phần tương tác và logo thương hiệu ở vị trí trung tâm.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB3E5CC), Color(0xFF81C784)],
              ),
            ),
          ),
          // Center content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Thành phần hiển thị logo thương hiệu được bao bọc bởi các lớp hoạt họa chuyển đổi về kích thước và độ trong suốt nhằm tập trung sự chú ý tối đa của người dùng.
                  /// Chúng tôi thiết kế một khung hình tròn màu trắng với hiệu ứng bóng mờ đổ xuống tinh tế để tạo chiều sâu và làm nổi bật hình ảnh nhận diện của PetSocial.
                  /// Cơ chế này đi kèm với một trình xử lý lỗi thông minh, trong trường hợp tài nguyên hình ảnh không thể tải được, nó sẽ tự động hiển thị một biểu tượng thay thế để bảo toàn cấu trúc.
                  /// Sự kết hợp giữa thiết kế đồ họa và mã nguồn xử lý giúp đảm bảo rằng logo luôn xuất hiện với một diện mạo hoàn hảo và ấn tượng nhất trên mọi thiết bị.
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/pet_logo.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if asset not found
                                return Icon(
                                  Icons.pets,
                                  size: 72,
                                  color: theme.primaryColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text(
                          AppLocaleTranslate.petSocialTitle.getString(context),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocaleTranslate.petSocialSubtitle
                              .getString(context),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        _goToHome();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                      ),
                      child: Text(
                          AppLocaleTranslate.startButton.getString(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Text(
                AppLocaleTranslate.petSocialCredits.getString(context),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),

          /// Thành phần chuyển đổi ngôn ngữ được tích hợp khéo léo ở góc trên bên phải màn hình để người dùng có thể dễ dàng thay đổi ngôn ngữ hiển thị.
          /// Chúng tôi sử dụng một PopupMenuButton chứa danh sách các ngôn ngữ được hỗ trợ như tiếng Anh, tiếng Việt, tiếng Khmer và tiếng Nhật.
          /// Khi người dùng lựa chọn một ngôn ngữ mới, hệ thống FlutterLocalization sẽ tự động cập nhật toàn bộ các chuỗi văn bản trên giao diện ngay lập tức.
          /// Đây là một tính năng quan trọng nhằm đảm bảo ứng dụng có thể tiếp cận và phục vụ hiệu quả cho nhóm đối tượng người dùng đa quốc gia.
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: Colors.white),
                  tooltip: 'Change Language',
                  onSelected: (String code) {
                    FlutterLocalization.instance.translate(code);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'en',
                      child: Text('English'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'vi',
                      child: Text('Tiếng Việt'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'km',
                      child: Text('ភាសាខ្មែរ'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ja',
                      child: Text('日本語'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
