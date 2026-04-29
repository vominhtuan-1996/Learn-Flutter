import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class HomeV1Screen extends StatefulWidget {
  const HomeV1Screen({super.key});

  @override
  State<HomeV1Screen> createState() => _HomeV1ScreenState();
}

class _HomeV1ScreenState extends State<HomeV1Screen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;

    return Scaffold(
      backgroundColor: themeTokens.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildQuoteCard(context),
                    const SizedBox(height: 30),
                    _buildCalendarStrip(context),
                    const SizedBox(height: 30),
                    Text(
                      AppLocaleTranslate.inProgress.getString(context),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: themeTokens.colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHabitList(context),
                    const SizedBox(height: 100), // Space for FAB/BottomNav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.addHabitV1),
        backgroundColor: themeTokens.colors.secondary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Navigator.of(context).pushNamed(Routes.settingsV1),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocaleTranslate.homeGreeting.getString(context),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: themeTokens.colors.onSurface,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: themeTokens.colors.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: themeTokens.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            themeTokens.colors.primary.withOpacity(0.8),
            themeTokens.colors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: themeTokens.colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocaleTranslate.dailyQuote.getString(context),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocaleTranslate.dailyQuoteAuthor.getString(context),
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    // Simple calendar strip for 7 days
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.subtract(Duration(days: now.weekday - 1 - index)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) {
        bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Column(
            children: [
              Text(
                ["M", "T", "W", "T", "F", "S", "S"][date.weekday - 1],
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: themeTokens.colors.onSurface.withOpacity(isSelected ? 1.0 : 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? themeTokens.colors.secondary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : themeTokens.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitList(BuildContext context) {
    return Column(
      children: [
        _buildHabitCard(context, AppLocaleTranslate.readABook.getString(context), Icons.book, true),
        const SizedBox(height: 12),
        _buildHabitCard(context, AppLocaleTranslate.exercise.getString(context), Icons.fitness_center, false),
        const SizedBox(height: 12),
        _buildHabitCard(context, AppLocaleTranslate.wakeUpEarly.getString(context), Icons.wb_sunny, false),
      ],
    );
  }

  Widget _buildHabitCard(BuildContext context, String title, IconData icon, bool isDone) {
    final themeTokens = HabitBuilderTheme.light;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.habitDetailsV1,
        arguments: {'habitName': title},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeTokens.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeTokens.colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: themeTokens.colors.onSurface,
                ),
              ),
            ),
            if (isDone)
              Icon(Icons.check_circle, color: themeTokens.colors.secondary)
            else
              TextButton(
                onPressed: () {},
                child: Text(
                  AppLocaleTranslate.doneButton.getString(context),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: themeTokens.colors.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, AppLocaleTranslate.homeTab.getString(context)),
            _buildNavItem(1, Icons.book_outlined, AppLocaleTranslate.coursesTab.getString(context)),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(2, Icons.people_outline, AppLocaleTranslate.communityTab.getString(context)),
            _buildNavItem(3, Icons.settings_outlined, AppLocaleTranslate.settingsTab.getString(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final themeTokens = HabitBuilderTheme.light;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.of(context).pushNamed(Routes.coursesV1);
        }
        if (index == 2) {
          Navigator.of(context).pushNamed(Routes.communityV1);
        }
        if (index == 3) {
          Navigator.of(context).pushNamed(Routes.settingsV1);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? themeTokens.colors.secondary : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected ? themeTokens.colors.secondary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
