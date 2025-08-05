import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}

class SliverOnboardingView extends StatefulWidget {
  final List<OnboardingPageData> pages;
  final ValueChanged<int>? onPageChanged;

  const SliverOnboardingView({
    super.key,
    required this.pages,
    this.onPageChanged,
  });

  @override
  State<SliverOnboardingView> createState() => _SliverOnboardingViewState();
}

class _SliverOnboardingViewState extends State<SliverOnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.pages.length,
              itemBuilder: (context, index) {
                final page = widget.pages[index];
                final isDark = ThemeData.estimateBrightnessForColor(page.backgroundColor) == Brightness.dark;
                final textColor = isDark ? Colors.white : Colors.black87;

                return Container(
                  color: page.backgroundColor,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(page.icon, size: 100, color: textColor),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page.description,
                        style: TextStyle(fontSize: 20, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
