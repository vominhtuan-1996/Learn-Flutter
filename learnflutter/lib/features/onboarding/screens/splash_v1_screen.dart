import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class SplashV1Screen extends StatefulWidget {
  const SplashV1Screen({super.key});

  @override
  State<SplashV1Screen> createState() => _SplashV1ScreenState();
}

class _SplashV1ScreenState extends State<SplashV1Screen> {
  @override
  void initState() {
    super.initState();
    // Chuyển màn hình sau 3 giây
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.onboardingPageView);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu sắc và kiểu chữ từ theme tokens của dự án
    final themeTokens = HabitBuilderTheme.light;
    
    return Scaffold(
      backgroundColor: themeTokens.colors.surface, // Sử dụng màu nền từ theme
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // Sử dụng localization thay vì hardcode string
                AppLocaleTranslate.onboardingWelcome.getString(context).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -1.2,
                  // Sử dụng màu chính từ thiết kế Habit Builder
                  color: themeTokens.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
