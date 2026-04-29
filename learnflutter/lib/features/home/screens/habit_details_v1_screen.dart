import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class HabitDetailsV1Screen extends StatelessWidget {
  final String habitName;
  const HabitDetailsV1Screen({super.key, required this.habitName});

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
          habitName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.edit_outlined, color: themeTokens.colors.onSurface),
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.addHabitV1,
              arguments: {
                'mode': 'edit',
                'habitName': habitName,
                'icon': Icons.book,
                'color': const Color(0xFFFDA758),
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: themeTokens.colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCalendarView(context),
            const SizedBox(height: 30),
            _buildStatsGrid(context),
            const SizedBox(height: 30),
            _buildHabitInfo(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "January 2026",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: themeTokens.colors.onSurface,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left,
                      color: themeTokens.colors.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 10),
                  Icon(Icons.chevron_right,
                      color: themeTokens.colors.onSurface.withOpacity(0.4)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 35, // 5 weeks
            itemBuilder: (context, index) {
              final day = index - firstDayOfWeek + 2;
              final isToday = day == now.day;
              final isCompleted =
                  [2, 3, 5, 8, 9, 12, 14, 15, 16, 18, 20].contains(day);

              if (day < 1 || day > daysInMonth) return const SizedBox();

              return Container(
                decoration: BoxDecoration(
                  color: isCompleted
                      ? themeTokens.colors.secondary
                      : (isToday
                          ? themeTokens.colors.primary.withOpacity(0.1)
                          : Colors.transparent),
                  shape: BoxShape.circle,
                  border: isToday && !isCompleted
                      ? Border.all(color: themeTokens.colors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? Colors.white
                          : themeTokens.colors.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
            context,
            "12",
            AppLocaleTranslate.currentStreak.getString(context),
            const Color(0xFFFDA758)),
        const SizedBox(width: 12),
        _buildStatCard(
            context,
            "24",
            AppLocaleTranslate.bestStreak.getString(context),
            const Color(0xFF85E0A3)),
        const SizedBox(width: 12),
        _buildStatCard(
            context,
            "156",
            AppLocaleTranslate.totalCompleted.getString(context),
            const Color(0xFF7CB8F7)),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, Color color) {
    final themeTokens = HabitBuilderTheme.light;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: themeTokens.colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitInfo(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
              context,
              Icons.calendar_today_outlined,
              AppLocaleTranslate.habitFrequencyLabel.getString(context),
              AppLocaleTranslate.daily.getString(context)),
          const Divider(height: 32),
          _buildInfoRow(context, Icons.notifications_none,
              AppLocaleTranslate.reminderLabel.getString(context), "07:00 AM"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final themeTokens = HabitBuilderTheme.light;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeTokens.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: themeTokens.colors.primary),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: themeTokens.colors.onSurface.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
      ],
    );
  }
}
