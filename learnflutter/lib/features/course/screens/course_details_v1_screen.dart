import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class CourseDetailsV1Screen extends StatelessWidget {
  const CourseDetailsV1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseHeader(context),
                      const SizedBox(height: 24),
                      _buildDescription(context),
                      const SizedBox(height: 30),
                      _buildLessonsList(context),
                      const SizedBox(height: 100), // Space for sticky button
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildAppBar(context),
          _buildStickyButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=1000"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleTranslate.morningRoutine.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(context, Icons.access_time, AppLocaleTranslate.twentyMin.getString(context)),
            const SizedBox(width: 16),
            _buildInfoChip(context, Icons.star, AppLocaleTranslate.rating.getString(context).replaceAll("%a", AppLocaleTranslate.fourPointFive.getString(context))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final themeTokens = HabitBuilderTheme.light;
    return Row(
      children: [
        Icon(icon, size: 16, color: themeTokens.colors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: themeTokens.colors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Text(
      AppLocaleTranslate.courseDescription.getString(context),
      style: GoogleFonts.manrope(
        fontSize: 16,
        color: themeTokens.colors.onSurface.withOpacity(0.6),
        height: 1.6,
      ),
    );
  }

  Widget _buildLessonsList(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    final lessons = [
      {'title': AppLocaleTranslate.wakeUpEarly.getString(context), 'time': '01:00', 'locked': false},
      {'title': AppLocaleTranslate.drinkWater.getString(context), 'time': '02:00', 'locked': true},
      {'title': AppLocaleTranslate.exercise.getString(context), 'time': '05:00', 'locked': true},
      {'title': AppLocaleTranslate.meditation.getString(context), 'time': '05:00', 'locked': true},
      {'title': AppLocaleTranslate.healthyBreakfast.getString(context), 'time': '07:00', 'locked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleTranslate.fiveLessons.getString(context),
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final isLocked = lesson['locked'] as bool;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.withOpacity(0.1) : themeTokens.colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : Icons.play_arrow,
                      size: 20,
                      color: isLocked ? Colors.grey : themeTokens.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: themeTokens.colors.onSurface,
                          ),
                        ),
                        Text(
                          lesson['time'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeTokens.colors.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStickyButton(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: themeTokens.colors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: themeTokens.colors.secondary.withOpacity(0.5),
          ),
          child: Text(
            AppLocaleTranslate.startNow.getString(context),
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
