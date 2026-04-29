import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class ForgotPasswordV1Screen extends StatefulWidget {
  const ForgotPasswordV1Screen({super.key});

  @override
  State<ForgotPasswordV1Screen> createState() => _ForgotPasswordV1ScreenState();
}

class _ForgotPasswordV1ScreenState extends State<ForgotPasswordV1Screen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeTokens.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Illustration
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themeTokens.colors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_reset_outlined,
                    size: 120,
                    color: themeTokens.colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Header
              Text(
                AppLocaleTranslate.forgotPasswordTitle.getString(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: themeTokens.colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppLocaleTranslate.forgotPasswordDescription.getString(context),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: themeTokens.colors.onBackground.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Form
              _buildTextField(
                controller: _emailController,
                label: AppLocaleTranslate.emailLabel.getString(context),
                hint: AppLocaleTranslate.forgotPasswordEmailHint.getString(context),
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 30),
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Action for sending reset link
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeTokens.colors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocaleTranslate.sendResetLink.getString(context),
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocaleTranslate.rememberPassword.getString(context),
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
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: themeTokens.colors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
