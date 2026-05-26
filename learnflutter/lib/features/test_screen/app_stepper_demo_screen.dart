import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/engines/engine_pagination/engine_pagination.dart';
import 'package:learnflutter/core/engines/engine_dialog/app_snackbar_engine.dart';

class AppStepperDemoScreen extends StatefulWidget {
  const AppStepperDemoScreen({super.key});

  @override
  State<AppStepperDemoScreen> createState() => _AppStepperDemoScreenState();
}

class _AppStepperDemoScreenState extends State<AppStepperDemoScreen> {
  int _selectedPayment = 0; // 0: Visa, 1: Momo, 2: COD
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Premium Stepper Engine"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: AppPaginationWidget(
          numbStep: 4,
          tabType: "0", // 0: normal mode, 1: view only
          hasCompleteStep: true,
          onNextStep: (current, next) async {
            // Validate form ở Step 1
            if (current == 1) {
              if (!_formKeyStep1.currentState!.validate()) {
                AppSnackbarEngine.showError(
                  context,
                  message: "Vui lòng điền đầy đủ thông tin tài khoản!",
                );
                return false; // Không cho qua step tiếp theo
              }
            }
            if (current == 2 && _addressController.text.trim().isEmpty) {
              AppSnackbarEngine.showError(
                context,
                message: "Vui lòng nhập địa chỉ giao hàng!",
              );
              return false;
            }
            return true;
          },
          onPreviousStep: (prev) async {
            return true;
          },
          onCompleteStep: (step) async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text("Thành công!"),
                  ],
                ),
                content: const Text(
                    "Giao dịch của bạn đã được khởi tạo thành công qua bộ Engine Pagination mới!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                      Navigator.of(context).pop(); // Quay lại test screen
                    },
                    child: const Text("Hoàn tất"),
                  ),
                ],
              ),
            );
            return true;
          },
          goToThisStep: (target) async {
            return true;
          },
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<AppPaginationCubit, AppPaginationState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _buildStepContent(state.currentStep, isDark),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step, bool isDark) {
    Widget stepWidget;
    switch (step) {
      case 1:
        stepWidget = _buildStep1Account(isDark);
        break;
      case 2:
        stepWidget = _buildStep2Address(isDark);
        break;
      case 3:
        stepWidget = _buildStep3Payment(isDark);
        break;
      case 4:
        stepWidget = _buildStep4Summary(isDark);
        break;
      default:
        stepWidget = const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: stepWidget,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep1Account(bool isDark) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        key: const ValueKey('step-1'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tạo tài khoản",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bước đầu tiên để thiết lập hồ sơ giao hàng của bạn.",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Tên không được bỏ trống"
                : null,
            decoration: InputDecoration(
              labelText: "Họ và Tên",
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            validator: (value) => value == null || !value.contains("@")
                ? "Email không hợp lệ"
                : null,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Địa chỉ Email",
              prefixIcon: const Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Address(bool isDark) {
    return Column(
      key: const ValueKey('step-2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Địa chỉ giao hàng",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Cung cấp địa chỉ giao hàng chính xác để nhận quà tặng.",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Số nhà, tên đường, phường xã",
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Payment(bool isDark) {
    return Column(
      key: const ValueKey('step-3'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Phương thức thanh toán",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        _buildPaymentOption(
            0, "Credit/Debit Card", Icons.credit_card_rounded, isDark),
        const SizedBox(height: 12),
        _buildPaymentOption(
            1, "Ví điện tử MoMo", Icons.account_balance_wallet_rounded, isDark),
        const SizedBox(height: 12),
        _buildPaymentOption(2, "Thanh toán khi nhận hàng (COD)",
            Icons.local_shipping_rounded, isDark),
      ],
    );
  }

  Widget _buildPaymentOption(
      int index, String title, IconData icon, bool isDark) {
    final isSelected = _selectedPayment == index;
    final activeColor =
        isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

    return InkWell(
      onTap: () => setState(() => _selectedPayment = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.15),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white60 : Colors.black54),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: activeColor)
            else
              Icon(Icons.circle_outlined,
                  color: isDark ? Colors.white30 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Summary(bool isDark) {
    final payType =
        ["Visa Card", "Ví MoMo", "Thanh toán COD"][_selectedPayment];

    return Column(
      key: const ValueKey('step-4'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.rocket_launch_rounded, size: 72, color: Colors.amber),
        const SizedBox(height: 16),
        Text(
          "Xác nhận đơn hàng",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow("Người mua", _nameController.text, isDark),
              const Divider(height: 20),
              _buildSummaryRow("Email", _emailController.text, isDark),
              const Divider(height: 20),
              _buildSummaryRow("Địa chỉ", _addressController.text, isDark),
              const Divider(height: 20),
              _buildSummaryRow("Thanh toán", payType, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
