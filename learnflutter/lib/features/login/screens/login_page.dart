import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/features/login/cubit/login_cubit.dart';
import 'package:learnflutter/features/login/screens/premium_otp_page.dart';
import 'package:learnflutter/features/login/state/login_state.dart';
import 'package:learnflutter/core/theme/extension_theme.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

/// Lớp LoginPage đại diện cho màn hình xác thực người dùng được thiết kế theo tiêu chuẩn giao diện cao cấp (Premium UI).
/// Cấu trúc của trang sử dụng một hệ thống lớp chồng (Stack) để kết hợp nền gradient động với hiệu ứng kính mờ (Glassmorphism) hiện đại.
/// Toàn bộ các thành phần giao diện đều được tích hợp các hiệu ứng chuyển động mượt mà thông qua gói thư viện flutter_animate.
/// Đây là nơi người dùng thực hiện các thao tác đăng nhập quan trọng, đồng thời trải nghiệm sự tinh tế trong thiết kế hình ảnh của ứng dụng.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Phương thức dispose được sử dụng để giải phóng tài nguyên hệ thống khi màn hình đăng nhập không còn hiển thị.
  /// Việc giải phóng các TextEditingController là cực kỳ quan trọng để ngăn ngừa tình trạng rò rỉ bộ nhớ (memory leaks) trong dự án.
  /// Điều này đảm bảo rằng các listener gắn liền với các khung nhập liệu sẽ được loại bỏ hoàn toàn khỏi chu trình sống của ứng dụng.
  /// Đây là một thực hành lập trình tốt giúp duy trì hiệu năng ổn định cho ứng dụng Flutter trong thời gian dài.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.loginResponse != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chào mừng bạn quay trở lại!')),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xác thực thất bại: ${state.errorMessage}'),
                  backgroundColor: context.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                /// Thành phần nền phía sau sử dụng dải màu gradient đa sắc để tạo chiều sâu và cảm giác sống động cho giao diện.
                /// Các màu sắc được lựa chọn dựa trên bảng màu thương hiệu, tạo ra sự hài hòa và thu hút ánh nhìn ngay từ giây đầu tiên.
                /// Hiệu ứng chuyển màu chéo giúp phá vỡ sự đơn điệu của các màn hình đăng nhập thông thường, nâng tầm thẩm mỹ chuyên nghiệp.
                /// Đây là lớp nền tảng quan trọng giúp làm nổi bật các thành phần tương tác phía trên của màn hình xác thực.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colorScheme.primary.withOpacity(0.8),
                        context.colorScheme.secondary.withOpacity(0.6),
                        context.colorScheme.surface,
                      ],
                    ),
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Logo biểu tượng đại diện mang tính bảo mật và định danh cho toàn bộ ứng dụng.
                        /// Thành phần này được thiết kế với phong cách tối giản, sử dụng các dải màu tương phản để nổi bật trên nền gradient.
                        /// Hiệu ứng chuyển động phóng đại nhẹ khi vừa xuất hiện giúp tạo điểm nhấn thị giác mạnh mẽ cho người dùng.
                        /// Đây là yếu tố then chốt trong việc xây dựng sự tin tưởng và tính chuyên nghiệp ngay từ màn hình đầu tiên.
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.surface.withOpacity(0.15),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: context.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            size: 72,
                            color: context.colorScheme.onPrimary,
                          ),
                        ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 64),

                        /// Khối chứa các tùy chọn đăng nhập SSO (Single Sign-On) áp dụng hiệu ứng kính mờ (Glassmorphism).
                        /// Thiết kế này loại bỏ các rào cản về biểu mẫu truyền thống, mang lại trải nghiệm truy cập tức thì và bảo mật.
                        /// Các nút bấm được thiết kế dưới dạng các ô (tiles) lớn, dễ dàng tương tác và tuân thủ các quy tắc thiết kế hiện đại.
                        /// Sự kết hợp giữa độ mờ của nền và đường viền sắc nét tạo nên cảm giác sang trọng và đáng tin cậy.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Xác thực an toàn',
                                    style: context.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.onSurface,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tiếp tục với phương thức đăng nhập SSO',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: context.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 48),

                                  /// Tùy chỉnh đăng nhập với Apple - phương thức bảo mật hàng đầu dành cho các thiết bị trong hệ sinh thái của Apple.
                                  /// Nút bấm được thiết kế với phong cách đặc thù, truyền tải thông điệp về sự an toàn và quyền riêng tư tuyệt đối.
                                  /// Hiệu ứng rung nhẹ khi chạm (feedback) giúp người dùng cảm nhận được sự phản hồi trực quan từ hệ thống.
                                  _SSOTile(
                                    icon: Icons.apple_rounded,
                                    label: 'Tiếp tục với Apple',
                                    onTap: () => context.read<LoginCubit>().loginWithApple(),
                                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

                                  const SizedBox(height: 20),

                                  /// Giải pháp đăng nhập thông qua Google, mang lại sự tiện lợi tối đa nhờ tính phổ biến và khả năng đồng bộ cao.
                                  /// Thành phần này giúp rút ngắn quy trình đăng ký, cho phép người dùng truy cập ứng dụng chỉ trong vài giây.
                                  /// Mỗi lượt tương tác đều được mã hóa và xử lý thông qua các giao diện SDK an toàn nhất hiện nay.
                                  _SSOTile(
                                    icon: Icons.g_mobiledata_rounded,
                                    label: 'Tiếp tục với Google',
                                    onTap: () => context.read<LoginCubit>().loginWithGoogle(),
                                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),

                                  const SizedBox(height: 20),

                                  /// Kết nối thông qua Facebook để tận dụng mạng lưới xã hội sẵn có và cá nhân hóa trải nghiệm người dùng.
                                  /// Thiết kế của nút bấm đảm bảo sự nhất quán với toàn bộ ngôn ngữ thiết kế chung của hệ thống SSO.
                                  /// Việc tích hợp đa dạng các nhà cung cấp giúp mở rộng khả năng tiếp cận và tối ưu hóa tỷ lệ chuyển đổi cho ứng dụng.
                                  _SSOTile(
                                    icon: Icons.facebook_rounded,
                                    label: 'Tiếp tục với Facebook',
                                    onTap: () async {
                                      await context.read<LoginCubit>().loginWithFacebook();
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PremiumOtpPage()),
                                        );
                                      }
                                    },
                                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 800.ms),

                        const SizedBox(height: 40),

                        /// Phần thông tin hỗ trợ kỹ thuật hoặc liên hệ khi người dùng gặp khó khăn trong quá trình xác thực danh tính.
                        /// Thành phần này được thiết kế nhỏ gọn, không gây xao nhãng nhưng vẫn đảm bảo tính sẵn sàng khi cần thiết.
                        /// Sử dụng màu sắc mờ nhạt để tạo sự phân cấp thông tin rõ ràng giữa các hành động chính và các liên kết phụ.
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Cần hỗ trợ đăng nhập?',
                            style: TextStyle(
                              color: context.colorScheme.onPrimary.withOpacity(0.7),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ).animate().fadeIn(delay: 1.2.seconds),

                        const SizedBox(height: 16),

                        /// Thành phần "Bỏ qua đăng nhập" được thiết lập nhằm mục đích hỗ trợ kiểm thử nhanh các tính năng mà không cần thông qua bước xác thực tài khoản.
                        /// Đây là một công cụ hữu ích dành cho đội ngũ phát triển để rút ngắn thời gian tiếp cận các màn hình chức năng trong giai đoạn triển khai dự án.
                        /// Thành phần này sẽ thực hiện lệnh điều hướng trực tiếp tới TestScreen, nơi chứa các kịch bản kiểm thử đa dạng của hệ thống.
                        /// Chúng tôi sử dụng kiểu dáng chữ mờ để đảm bảo tính thẩm mỹ, tránh làm xao nhãng người dùng cuối trong khi vẫn duy trì sự tiện dụng cho lập trình viên.
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.testScreen);
                          },
                          child: Text(
                            'Bỏ qua đăng nhập (Developer)',
                            style: TextStyle(
                              color: context.colorScheme.onPrimary.withOpacity(0.4),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ).animate().fadeIn(delay: 1.5.seconds),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lớp _SSOTile là một thành phần giao diện biểu diễn cho một phương thức đăng nhập SSO đơn lẻ.
/// Nó được thiết kế với kích thước lớn và nhãn văn bản rõ ràng để tối ưu hóa khả năng nhận diện và thao tác.
/// Việc sử dụng màu nền mờ kết hợp với hiệu ứng Glassmorphism giúp thành phần này hòa quyện vào tổng thể sang trọng của trang.
/// Mỗi khi nhấn vào, người dùng sẽ nhận được phản hồi trực quan mượt mà, tạo cảm giác về một ứng dụng cao cấp và nhạy bén.
class _SSOTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SSOTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
