import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class NotificationsV1Screen extends StatelessWidget {
  const NotificationsV1Screen({super.key});

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
          AppLocaleTranslate.notificationsTitle.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader(context, AppLocaleTranslate.todayHeader.getString(context)),
          _buildNotificationItem(
            context,
            Icons.notifications_active,
            AppLocaleTranslate.habitReminderTitle.getString(context),
            AppLocaleTranslate.habitReminderMessage.getString(context).replaceAll("%a", AppLocaleTranslate.readABook.getString(context)),
            "07:00 AM",
            themeTokens.colors.primary,
          ),
          _buildNotificationItem(
            context,
            Icons.favorite,
            AppLocaleTranslate.communityCheerTitle.getString(context),
            AppLocaleTranslate.communityCheerMessage.getString(context).replaceAll("%a", "Mira"),
            "11:30 AM",
            themeTokens.colors.secondary,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, AppLocaleTranslate.yesterdayHeader.getString(context)),
          _buildNotificationItem(
            context,
            Icons.star,
            AppLocaleTranslate.achievementUnlocked.getString(context),
            AppLocaleTranslate.daysStreakMessage
                .getString(context)
                .replaceAll("%a", "7")
                .replaceAll("%b", AppLocaleTranslate.exercise.getString(context)),
            "08:00 PM",
            Colors.amber,
          ),
          _buildNotificationItem(
            context,
            Icons.notifications_active,
            AppLocaleTranslate.habitReminderTitle.getString(context),
            AppLocaleTranslate.habitReminderMessage.getString(context).replaceAll("%a", AppLocaleTranslate.exercise.getString(context)),
            "06:00 AM",
            themeTokens.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final themeTokens = HabitBuilderTheme.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: themeTokens.colors.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    IconData icon,
    String title,
    String message,
    String time,
    Color iconColor,
  ) {
    final themeTokens = HabitBuilderTheme.light;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: themeTokens.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: themeTokens.colors.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: themeTokens.colors.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
