import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class SettingsV1Screen extends StatefulWidget {
  const SettingsV1Screen({super.key});

  @override
  State<SettingsV1Screen> createState() => _SettingsV1ScreenState();
}

class _SettingsV1ScreenState extends State<SettingsV1Screen> {
  bool _nightMode = false;

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
          AppLocaleTranslate.profileTitle.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: themeTokens.colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mebas'),
            ),
            const SizedBox(height: 16),
            Text(
              "Mebas Gul",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: themeTokens.colors.onSurface,
              ),
            ),
            Text(
              "mebasgul@gmail.com",
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: themeTokens.colors.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, "7", AppLocaleTranslate.habitsStat.getString(context)),
                  _buildDivider(),
                  _buildStatItem(context, "12", AppLocaleTranslate.tasksStat.getString(context)),
                  _buildDivider(),
                  _buildStatItem(context, "20", AppLocaleTranslate.streakStat.getString(context)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Menu Groups
            _buildMenuSection(context, "General", [
              _buildMenuItem(context, Icons.payment, AppLocaleTranslate.billing.getString(context)),
              _buildMenuItem(
                context, 
                Icons.notifications_none, 
                AppLocaleTranslate.notifications.getString(context),
                onTap: () => Navigator.of(context).pushNamed(Routes.notificationsV1),
              ),
              _buildMenuToggle(
                context, 
                Icons.nightlight_outlined, 
                AppLocaleTranslate.nightMode.getString(context), 
                _nightMode, 
                (val) => setState(() => _nightMode = val)
              ),
            ]),
            const SizedBox(height: 20),
            _buildMenuSection(context, "Others", [
              _buildMenuItem(context, Icons.mail_outline, AppLocaleTranslate.contactUs.getString(context)),
              _buildMenuItem(context, Icons.info_outline, AppLocaleTranslate.aboutUs.getString(context)),
            ]),
            const SizedBox(height: 40),
            // Logout Button
            TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.loginV1, (route) => false),
              child: Text(
                AppLocaleTranslate.logout.getString(context),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final themeTokens = HabitBuilderTheme.light;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: themeTokens.colors.onBackground.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    final themeTokens = HabitBuilderTheme.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: themeTokens.colors.onSurface.withOpacity(0.4),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final themeTokens = HabitBuilderTheme.light;
    return ListTile(
      leading: Icon(icon, color: themeTokens.colors.primary),
      title: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: themeTokens.colors.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: themeTokens.colors.onSurface.withOpacity(0.3)),
      onTap: onTap,
    );
  }

  Widget _buildMenuToggle(BuildContext context, IconData icon, String label, bool value, Function(bool) onChanged) {
    final themeTokens = HabitBuilderTheme.light;
    return ListTile(
      leading: Icon(icon, color: themeTokens.colors.primary),
      title: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: themeTokens.colors.onSurface,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: themeTokens.colors.secondary,
      ),
    );
  }
}
