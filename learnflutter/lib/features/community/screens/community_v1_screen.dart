import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/theme/habit_builder_theme.dart';

class CommunityV1Screen extends StatefulWidget {
  const CommunityV1Screen({super.key});

  @override
  State<CommunityV1Screen> createState() => _CommunityV1ScreenState();
}

class _CommunityV1ScreenState extends State<CommunityV1Screen> {
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
          AppLocaleTranslate.communityTitle.getString(context),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: themeTokens.colors.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTopicTabs(context),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPostCard(
                  context,
                  "Mina Pasquariello",
                  "12 mins ago",
                  "I just completed my 30-day journaling challenge! Feeling so much more mindful and focused.",
                  "https://i.pravatar.cc/150?u=mina",
                  null,
                  124,
                  42,
                ),
                const SizedBox(height: 20),
                _buildPostCard(
                  context,
                  "Jonathan Smith",
                  "45 mins ago",
                  "Establish a habit of daily journaling. It changed my life!",
                  "https://i.pravatar.cc/150?u=jon",
                  "https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&q=80&w=1000",
                  85,
                  12,
                ),
                const SizedBox(height: 20),
                _buildPostCard(
                  context,
                  "Sarah Connor",
                  "2 hours ago",
                  "Morning routine is key. Drink water, meditate, and read.",
                  "https://i.pravatar.cc/150?u=sarah",
                  null,
                  210,
                  65,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: themeTokens.colors.secondary,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildTopicTabs(BuildContext context) {
    final themeTokens = HabitBuilderTheme.light;
    final tabs = [
      AppLocaleTranslate.allTab.getString(context),
      AppLocaleTranslate.mindfulnessTab.getString(context),
      AppLocaleTranslate.fitnessTab.getString(context),
      AppLocaleTranslate.journalingTab.getString(context),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
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

  Widget _buildPostCard(
    BuildContext context,
    String name,
    String time,
    String content,
    String avatarUrl,
    String? imageUrl,
    int cheers,
    int comments,
  ) {
    final themeTokens = HabitBuilderTheme.light;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: themeTokens.colors.onSurface,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeTokens.colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: themeTokens.colors.onSurface,
              height: 1.5,
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionButton(
                context,
                Icons.favorite_border,
                AppLocaleTranslate.cheerCount.getString(context).replaceAll("%a", cheers.toString()),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context,
                Icons.mode_comment_outlined,
                AppLocaleTranslate.commentCount.getString(context).replaceAll("%a", comments.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final themeTokens = HabitBuilderTheme.light;
    return Row(
      children: [
        Icon(icon, size: 20, color: themeTokens.colors.onSurface.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: themeTokens.colors.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
