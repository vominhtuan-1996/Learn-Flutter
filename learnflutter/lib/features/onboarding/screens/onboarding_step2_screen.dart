import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class OnboardingStep2Screen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const OnboardingStep2Screen({super.key, required this.onNext, required this.onSkip});

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
            // Illustration
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
                  Icons.auto_awesome,
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
                    AppLocaleTranslate.onboardingStep3Title.getString(context),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocaleTranslate.onboardingStep3Body.getString(context),
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
            // Pagination & Next
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 2 // Active: Bước 3
                              ? themeTokens.colors.primary
                              : themeTokens.colors.primary.withOpacity(0.2),
                        ),
                      );
                    }),
                  ),
                  // Next Button
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
