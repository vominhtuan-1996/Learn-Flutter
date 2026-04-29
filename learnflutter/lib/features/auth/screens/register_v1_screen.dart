import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class RegisterV1Screen extends StatefulWidget {
  const RegisterV1Screen({super.key});

  @override
  State<RegisterV1Screen> createState() => _RegisterV1ScreenState();
}

class _RegisterV1ScreenState extends State<RegisterV1Screen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepMeSignedIn = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Text(
                AppLocaleTranslate.registerTitle.getString(context),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: themeTokens.colors.onSurface,
                ),
              ),
              const SizedBox(height: 30),
              // Placeholder for Illustration
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themeTokens.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.person_add_alt_1, size: 100, color: themeTokens.colors.primary),
              ),
              const SizedBox(height: 30),
              // Form
              _buildTextField(
                controller: _nameController,
                label: AppLocaleTranslate.nameLabel.getString(context),
                hint: AppLocaleTranslate.nameHint.getString(context),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
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
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _keepMeSignedIn,
                    onChanged: (val) => setState(() => _keepMeSignedIn = val ?? false),
                    activeColor: themeTokens.colors.secondary,
                  ),
                  Text(
                    AppLocaleTranslate.keepMeSignedIn.getString(context),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeTokens.colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeTokens.colors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocaleTranslate.createButton.getString(context),
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Social Login
              Row(
                children: [
                  Expanded(child: Divider(color: themeTokens.colors.onBackground.withOpacity(0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocaleTranslate.signUpWith.getString(context),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: themeTokens.colors.onBackground.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: themeTokens.colors.onBackground.withOpacity(0.1))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(icon: Icons.g_mobiledata),
                  const SizedBox(width: 20),
                  _SocialIcon(icon: Icons.facebook),
                  const SizedBox(width: 20),
                  _SocialIcon(icon: Icons.apple),
                ],
              ),
              const SizedBox(height: 30),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocaleTranslate.alreadyHaveAccount.getString(context),
                    style: GoogleFonts.manrope(
                      color: themeTokens.colors.onBackground.withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocaleTranslate.loginTitle.getString(context),
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
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: themeTokens.colors.primary),
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

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: themeTokens.colors.onSurface),
    );
  }
}
