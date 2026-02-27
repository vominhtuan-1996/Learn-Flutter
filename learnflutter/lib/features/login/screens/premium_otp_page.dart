import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import 'package:learnflutter/core/theme/extension_theme.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';

/// Trang xác thực mã OTP (One-Time Password) được thiết kế theo phong cách Premium.
/// Giao diện này thừa hưởng các đặc tính thẩm mỹ từ màn hình đăng nhập chính như hiệu ứng Glassmorphism và nền gradient.
/// Mục tiêu của màn hình là cung cấp một bước xác thực an toàn, mượt mà và trực quan cho người dùng sau khi khởi tạo đăng nhập.
/// Tận dụng thư viện 'pinput' để tối ưu hóa việc nhập liệu và phản hồi trạng thái mã xác thực.
class PremiumOtpPage extends StatefulWidget {
  const PremiumOtpPage({super.key});

  @override
  State<PremiumOtpPage> createState() => _PremiumOtpPageState();
}

class _PremiumOtpPageState extends State<PremiumOtpPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Cấu hình giao diện cho các ô nhập mã PIN (Pin Themes).
    /// Việc tùy chỉnh từng trạng thái (mặc định, đang tập trung, có dữ liệu) giúp tăng cường trải nghiệm người dùng.
    /// Màu sắc và độ bo góc được tính toán kỹ lưỡng để hòa hợp với ngôn ngữ thiết kế chung của hệ thống.
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: context.textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: context.colorScheme.primary, width: 2),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white.withOpacity(0.7)),
      ),
      body: Stack(
        children: [
          /// Nền Gradient động mang lại cảm giác chiều sâu và sự hiện đại cho ứng dụng.
          /// Các dải màu được chuyển tiếp mượt mà, tạo nên một phông nền tinh tế không gây xao nhãng cho nội dung chính.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary.withOpacity(0.9),
                  context.colorScheme.secondary.withOpacity(0.8),
                  context.colorScheme.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    /// Biểu tượng xác thực được đặt trong một khối Glassmorphism để tạo sự đồng nhất.
                    /// Hiệu ứng trễ (staggered delay) khi xuất hiện giúp dẫn dắt mắt người dùng tập trung vào khu vực quan trọng.
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        Icons.mark_email_read_rounded,
                        size: 64,
                        color: context.colorScheme.onPrimary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(curve: Curves.elasticOut),

                    const SizedBox(height: 32),

                    Text(
                      'Xác minh tài khoản',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Vui lòng nhập mã bảo mật chúng tôi vừa gửi đến phương thức xác thực của bạn.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 64),

                    /// Khu vực nhập mã PIN với thư viện Pinput được tinh chỉnh để tối ưu hóa sự tiện dụng.
                    /// Các hiệu ứng chuyển cảnh khi nhập từng ký tự mang lại cảm giác phản hồi nhanh chóng và chắc chắn.
                    /// Đây là thành phần tương tác chính, nơi người dùng hoàn tất quy trình xác thực danh tính của mình.
                    Pinput(
                      controller: _pinController,
                      focusNode: _focusNode,
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      onCompleted: (pin) {
                        // Xây dựng logic xử lý khi mã đã được nhập đầy đủ
                      },
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 48),

                    /// Nút gửi lại mã được thiết kế tinh tế bên dưới để hỗ trợ người dùng khi gặp sự cố.
                    /// Việc sử dụng độ mờ và hiệu ứng gạch chân giúp phân biệt rõ ràng giữa hành động chính và phụ.
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Không nhận được mã? Gửi lại ngay',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 32),

                    /// Nút xác nhận cuối cùng được làm nổi bật với màu sắc đồng bộ của thương hiệu.
                    /// Thiết kế bo góc và độ dài tối đa giúp nút bấm trở nên hấp dẫn và dễ tiếp cận hơn trên màn hình cảm ứng.
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Xác nhận mã và hoàn tất đăng nhập
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'XÁC NHẬN MÃ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1.seconds)
                        .slideY(begin: 0.1, end: 0),
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
