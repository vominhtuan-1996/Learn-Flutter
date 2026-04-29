import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class CoursesV1Screen extends StatefulWidget {
  const CoursesV1Screen({super.key});

  @override
  State<CoursesV1Screen> createState() => _CoursesV1ScreenState();
}

class _CoursesV1ScreenState extends State<CoursesV1Screen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeTokens.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocaleTranslate.coursesTitle.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: themeTokens.colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildCategoryTabs(context),
            const SizedBox(height: 24),
            _buildFeaturedCard(context),
            const SizedBox(height: 30),
            _buildCourseList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    final tabs = [
      AppLocaleTranslate.allTab.getString(context),
      AppLocaleTranslate.popularTab.getString(context),
      AppLocaleTranslate.newTab.getString(context),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          bool isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? themeTokens.colors.secondary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(color: themeTokens.colors.secondary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : themeTokens.colors.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Routes.courseDetailsV1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2E6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFFDA758).withOpacity(0.2),
                child: Center(
                  child: Icon(Icons.menu_book, size: 80, color: themeTokens.colors.secondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleTranslate.featuredCourseTitle.getString(context),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocaleTranslate.featuredCourseDesc.getString(context),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: themeTokens.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.play_circle_fill, size: 20, color: themeTokens.colors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        AppLocaleTranslate.lessonsCount.getString(context).replaceAll("%a", "12").replaceAll("%b", "2h 41m"),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: themeTokens.colors.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    return Column(
      children: [
        _buildCourseItem(context, AppLocaleTranslate.morningRoutine.getString(context), "8 Lessons (1h 15m)", Icons.wb_sunny_outlined),
        const SizedBox(height: 16),
        _buildCourseItem(context, AppLocaleTranslate.selfCare.getString(context), "10 Lessons (1h 50m)", Icons.spa_outlined),
        const SizedBox(height: 16),
        _buildCourseItem(context, AppLocaleTranslate.productivity.getString(context), "6 Lessons (45m)", Icons.bolt_outlined),
      ],
    );
  }

  Widget _buildCourseItem(BuildContext context, String title, String stats, IconData icon) {
    final themeTokens = HabitBuilderTheme.light;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Routes.courseDetailsV1),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: themeTokens.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: themeTokens.colors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeTokens.colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16, color: themeTokens.colors.onSurface.withOpacity(0.3)),
              onPressed: () => Navigator.of(context).pushNamed(Routes.courseDetailsV1),
            ),
          ],
        ),
      ),
    );
  }
}
