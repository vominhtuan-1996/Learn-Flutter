import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class OnboardingStep1Screen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const OnboardingStep1Screen({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: GoogleFonts.manrope(
                color: themeTokens.colors.onBackground.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Minh họa (Sử dụng Icon thay cho Asset bị thiếu)
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: themeTokens.colors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.self_improvement,
                  size: 150,
                  color: themeTokens.colors.primary,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    AppLocaleTranslate.onboardingStep2Title.getString(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocaleTranslate.onboardingStep2Body.getString(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: themeTokens.colors.onBackground.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Phân trang và Nút tiếp theo
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dấu chấm phân trang (4 bước)
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 1 // Active: Bước 2
                              ? themeTokens.colors.primary
                              : themeTokens.colors.primary.withOpacity(0.2),
                        ),
                      );
                    }),
                  ),
                  // Nút chuyển trang (Next)
                  FloatingActionButton(
                    onPressed: onNext,
                    backgroundColor: themeTokens.colors.secondary,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
