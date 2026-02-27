import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/features/auth/cubit/login_cubit.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';

/// Lớp LoginScreen đại diện cho thành phần giao diện người dùng chính trong quá trình xác thực tài khoản của ứng dụng.
/// Widget này đóng vai trò là tầng Hiển thị nơi người dùng trực tiếp tương tác để nhập thông tin đăng nhập bao gồm email và mật khẩu.
/// Nó được thiết kế dưới dạng một StatefulWidget để có thể quản lý các trạng thái thay đổi tức thời của các controller và hiệu ứng giao diện.
/// Toàn bộ các xử lý nghiệp vụ phức tạp liên quan đến logic xác thực sẽ được giao phó cho LoginCubit xử lý nhằm đảm bảo tính tách biệt trong kiến trúc.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BaseLoading(
        child: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }

              if (state.isLoginSuccess && state.loggedInUser != null) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    // TODO: Navigate to home screen
                    // Navigator.of(context).pushReplacementNamed('/home');
                  }
                });
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 50),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildSignUpLink(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Phương thức _buildHeader chịu trách nhiệm xây dựng phần tiêu đề đầu trang cho màn hình đăng nhập nhằm định hướng người dùng.
  /// Nó sử dụng một widget Column để sắp xếp theo chiều dọc hai thành phần văn bản bao gồm tiêu đề chính và lời chào dẫn dắt.
  /// Các chuỗi văn bản ở đây đã được quốc tế hóa thông qua AppLocaleTranslate để hỗ trợ đa ngôn ngữ linh hoạt trong ứng dụng.
  /// Kiểu dáng của văn bản được kế thừa từ ThemeData của hệ thống giúp đảm bảo tính nhất quán về mặt thẩm mỹ trên toàn bộ các màn hình.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleTranslate.loginTitle.getString(context),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocaleTranslate.loginSubtitle.getString(context),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  /// Widget _buildEmailField được thiết kế để quản lý việc nhập địa chỉ email của người dùng một cách an toàn và chính xác.
  /// Nó được bao bọc trong một BlocBuilder để lắng nghe các thay đổi về giá trị email cũng như các thông báo lỗi từ LoginCubit.
  /// Khi người dùng nhập liệu thành phần này sẽ tự động cập nhật trạng thái thông qua hàm updateEmail để thực hiện validate ngay lập tức.
  /// Cấu trúc giao diện sử dụng TextFormField với các thuộc tính trang trí như icon email và các đường viền bo góc tinh tế.
  Widget _buildEmailField() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email || previous.emailError != current.emailError,
      builder: (context, state) {
        return TextFormField(
          controller: _emailController,
          onChanged: context.read<LoginCubit>().updateEmail,
          decoration: InputDecoration(
            hintText: AppLocaleTranslate.emailHint.getString(context),
            labelText: AppLocaleTranslate.emailLabel.getString(context),
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: state.emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        );
      },
    );
  }

  /// Thành phần _buildPasswordField cung cấp cơ chế nhập mật khẩu bảo mật với tính năng ẩn hiện linh hoạt cho người dùng.
  /// Nó tích hợp chặt chẽ với logic của LoginCubit để đảm bảo mật khẩu tuân thủ các quy tắc bảo mật thông qua state validation.
  /// Người dùng có thể chuyển đổi trạng thái hiển thị mật khẩu bằng cách nhấn vào biểu tượng con mắt ở cuối khung nhập liệu.
  /// Thiết kế của widget này sử dụng các thuộc tính borderRadius đồng bộ để duy trì vẻ ngoài hiện đại và chuyên nghiệp cho ứng dụng.
  Widget _buildPasswordField() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password || previous.passwordError != current.passwordError,
      builder: (context, state) {
        return TextFormField(
          controller: _passwordController,
          onChanged: context.read<LoginCubit>().updatePassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: AppLocaleTranslate.passwordHint.getString(context),
            labelText: AppLocaleTranslate.passwordLabel.getString(context),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            errorText: state.passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  /// Phương thức _buildForgotPasswordLink tạo ra một liên kết hỗ trợ người dùng trong trường hợp họ không nhớ thông tin mật khẩu truy cập.
  /// Nó sử dụng widget Align để căn lề phải liên kết tạo sự cân đối về mặt bố cục so với các thành phần khác trên form.
  /// Văn bản liên kết được sử dụng màu xanh đặc trưng để biểu thị khả năng có thể nhấn vào và chuyển hướng người dùng.
  /// Trong tương lai logic điều hướng sẽ được thêm vào hàm onPressed để dẫn người dùng tới trang khôi phục tài khoản tương ứng.
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Navigate to forgot password screen
        },
        child: Text(
          AppLocaleTranslate.forgotPassword.getString(context),
          style: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  /// Widget _buildLoginButton đại diện cho hành động then chốt khi người dùng thực hiện gửi yêu cầu đăng nhập hệ thống.
  /// Trạng thái của nút (cho phép nhấn hoặc bị vô hiệu hóa) được quản lý tự động dựa trên tính hợp lệ của dữ liệu đầu vào trong Cubit.
  /// Khi quá trình xử lý đang diễn ra thành phần này sẽ hiển thị một vòng xoay tải để thông báo cho người dùng chờ đợi phản hồi.
  /// Sau khi xử lý xong văn bản nút sẽ tự động quay lại trạng thái ban đầu dựa trên các token ngôn ngữ đã được cấu hình sẵn.
  Widget _buildLoginButton() {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.isFormValid != current.isFormValid || previous.isLoading != current.isLoading,
      builder: (context, state) {
        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    context.read<LoginCubit>().login();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppLocaleTranslate.loginButton.getString(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Phương thức _buildSignUpLink tạo ra phần giao diện mời gọi những người dùng mới tham gia vào hệ thống bằng cách đăng ký tài khoản.
  /// Nó sử dụng một widget Row để kết hợp phần văn bản thông thường và một nút nhấn có chứa nhãn đăng ký nổi bật.
  /// Nhãn văn bản này được quản lý thông qua hệ thống bản dịch giúp đảm bảo thông điệp luôn được hiển thị đúng định dạng cục bộ.
  /// Sự kết hợp giữa các kiểu chữ thường và in đậm giúp người dùng dễ dàng nhận ra hành động tiếp theo mà họ có thể thực hiện.
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocaleTranslate.noAccount.getString(context)),
        TextButton(
          onPressed: () {
            // TODO: Navigate to sign up screen
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            AppLocaleTranslate.register.getString(context),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
