import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/app/localization/app_local_translate.dart';
import 'package:learnflutter/features/auth/cubit/login_cubit.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/shared/widgets/keyboard_textfield/keyboard_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0F172A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BaseLoading(
        appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 0, elevation: 0),
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            }
          },
          child: _LoginBody(
            emailController: _emailController,
            passwordController: _passwordController,
            emailFocus: _emailFocus,
            passwordFocus: _passwordFocus,
            obscurePassword: _obscurePassword,
            onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _LoginBody extends StatelessWidget {
  const _LoginBody({
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 56),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  _buildCard(context),
                  const SizedBox(height: 32),
                  _buildFooter(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 20),
        const Text(
          'Chào mừng\ntrở lại 👋',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục sử dụng ứng dụng',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(
            controller: emailController,
            focusNode: emailFocus,
            nextFocusNode: passwordFocus,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: passwordController,
            focusNode: passwordFocus,
            previousFocusNode: emailFocus,
            obscure: obscurePassword,
            onToggle: onToggleObscure,
          ),
          const SizedBox(height: 8),
          _buildForgotPassword(context),
          const SizedBox(height: 24),
          _LoginButton(),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          AppLocaleTranslate.forgotPassword.getString(context),
          style: const TextStyle(fontSize: 13, color: Color(0xFF6366F1), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocaleTranslate.noAccount.getString(context),
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
          child: Text(
            AppLocaleTranslate.register.getString(context),
            style: const TextStyle(fontSize: 14, color: Color(0xFF818CF8), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.emailError != c.emailError,
      builder: (context, state) {
        return _InputField(
          controller: controller,
          focusNode: focusNode,
          nextFocusNode: nextFocusNode,
          label: AppLocaleTranslate.emailLabel.getString(context),
          hint: AppLocaleTranslate.emailHint.getString(context),
          icon: Icons.email_outlined,
          errorText: state.emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: context.read<LoginCubit>().updateEmail,
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.previousFocusNode,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode previousFocusNode;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.passwordError != c.passwordError,
      builder: (context, state) {
        return _InputField(
          controller: controller,
          focusNode: focusNode,
          previousFocusNode: previousFocusNode,
          label: AppLocaleTranslate.passwordLabel.getString(context),
          hint: AppLocaleTranslate.passwordHint.getString(context),
          icon: Icons.lock_outline,
          errorText: state.passwordError,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onChanged: context.read<LoginCubit>().updatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFF9CA3AF),
            ),
            onPressed: onToggle,
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _InputField — dùng KeyboardTextField thay TextFormField
// ────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.nextFocusNode,
    this.previousFocusNode,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;
  final String label;
  final String hint;
  final IconData icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    const baseColor = Color(0xFFE5E7EB);
    const focusColor = Color(0xFF6366F1);
    const errorColor = Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        KeyboardTextField(
          controller: controller,
          focusNode: focusNode,
          nextFocusNode: nextFocusNode,
          previousFocusNode: previousFocusNode,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
          showToolbar: true,
          showNavigation: false,
          showDone: true,
          toolbarBackgroundColor: const Color(0xFFD1D5DB),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            suffixIcon: suffixIcon,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: baseColor)),
            enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: baseColor)),
            focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: focusColor, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: errorColor)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: errorColor, width: 1.5)),
            errorStyle: const TextStyle(fontSize: 12, color: errorColor),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.isFormValid != c.isFormValid || p.isLoading != c.isLoading,
      builder: (context, state) {
        final enabled = state.isFormValid && !state.isLoading;
        return GestureDetector(
          onTap: enabled ? () => context.read<LoginCubit>().login() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: enabled ? null : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
              boxShadow: enabled
                  ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Center(
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Text(
                      AppLocaleTranslate.loginButton.getString(context),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: enabled ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
