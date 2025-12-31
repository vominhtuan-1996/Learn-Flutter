import 'package:flutter/material.dart';

import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/extendsion_ui/shape/clipper/bottom_nav_clipper.dart';
import 'package:learnflutter/modules/indicator/indicator_example_screen.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/profile/pages/profile_screen.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

/// HomeAnimationPage - Root page that hosts the main app sections
///
/// Vai trò:
/// - Cung cấp container chính cho các trang (Test, Material, Indicator, Profile)
/// - Điều phối trạng thái `currentIndex` để chuyển giữa các trang
/// - Đặt `CustomBottomNav` làm thanh điều hướng dưới cùng
/// Thiết kế: widget này chỉ quản lý presentation-level state (index),
/// còn business logic/phức tạp hơn nên được tách ra vào các Cubit/Repository.
class HomeAnimationPage extends StatefulWidget {
  const HomeAnimationPage({super.key});

  @override
  State<HomeAnimationPage> createState() => _HomeAnimationPageState();
}

class _HomeAnimationPageState extends State<HomeAnimationPage> {
  int currentIndex = 0;

  // danh sách màn hình hiển thị trong root container
  List<Widget> get _pages => const [
        TestScreen(),
        MaterialScreen(),
        IndicatorExampleScreen(),
        ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onChanged: (i) => setState(() => currentIndex = i),
      ),
      body: Stack(
        children: [
          // Sử dụng IndexedStack để giữ trạng thái của từng page,
          // tránh rebuild/destroy khi chuyển tab.
          IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
        ],
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DeviceDimension.defaultSize(80),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: BottomNavClipper(),
            child: Container(
              height: DeviceDimension.defaultSize(60),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(DeviceDimension.defaultSize(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ).paddingSymmetric(
              horizontal: DeviceDimension.padding / 2,
            ),
          ),
          // Center notch button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedItem(
                icon: Icons.home_outlined,
                selected: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _AnimatedItem(
                icon: Icons.home_outlined,
                selected: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              // const SizedBox(width: 48),
              _AnimatedItem(
                icon: Icons.favorite_border,
                selected: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
              _AnimatedItem(
                icon: Icons.person_outline,
                selected: currentIndex == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ).paddingSymmetric(
            horizontal: DeviceDimension.padding * 1.2,
          ),
        ],
      ),
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AnimatedItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: selected ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: 26,
                color: selected ? const Color(0xFFD0024F) : Colors.grey,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFD0024F),
              borderRadius: BorderRadius.circular(2),
            ),
          ).paddingOnly(top: DeviceDimension.padding / 2).showIf(selected)
        ],
      ),
    );
  }
}
