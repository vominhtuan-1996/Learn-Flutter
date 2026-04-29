import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/features/auth/cubit/login_cubit.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class LoginV1Screen extends StatefulWidget {
  const LoginV1Screen({super.key});

  @override
  State<LoginV1Screen> createState() => _LoginV1ScreenState();
}

class _LoginV1ScreenState extends State<LoginV1Screen> {
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
    final themeTokens = HabitBuilderTheme.light;

    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BaseLoading(
        child: Scaffold(
          backgroundColor: themeTokens.colors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    AppLocaleTranslate.loginTitle
                        .getString(context)
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocaleTranslate.loginWelcomeBack.getString(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: themeTokens.colors.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Social Buttons
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: AppLocaleTranslate.continueWithGoogle
                        .getString(context),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    icon: Icons.facebook,
                    label: AppLocaleTranslate.continueWithFacebook
                        .getString(context),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 30),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: themeTokens.colors.onBackground
                                  .withOpacity(0.1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color: themeTokens.colors.onBackground
                                .withOpacity(0.3),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: themeTokens.colors.onBackground
                                  .withOpacity(0.1))),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Form
                  _buildTextField(
                    controller: _emailController,
                    label: AppLocaleTranslate.emailLabel.getString(context),
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: AppLocaleTranslate.passwordLabel.getString(context),
                    hint: "********",
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    obscure: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.forgotPasswordV1),
                      child: Text(
                        AppLocaleTranslate.forgotPassword.getString(context),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: themeTokens.colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.homeV1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeTokens.colors.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocaleTranslate.loginButton.getString(context),
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocaleTranslate.noAccount.getString(context),
                        style: GoogleFonts.manrope(
                          color:
                              themeTokens.colors.onBackground.withOpacity(0.6),
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.registerV1),
                        child: Text(
                          AppLocaleTranslate.register.getString(context),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            color: themeTokens.colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    final themeTokens = HabitBuilderTheme.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeTokens.colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: themeTokens.colors.primary),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: themeTokens.colors.primary),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: themeTokens.colors.onSurface),
        label: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: themeTokens.colors.onSurface,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: themeTokens.colors.onBackground.withOpacity(0.1)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
