import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_onboarding_view.dart';

class SliverOnboardingWithContentExample extends StatelessWidget {
  const SliverOnboardingWithContentExample({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingPageData(
        title: 'Chào bạn',
        description: 'Chào mừng đến với ứng dụng Sliver.',
        icon: Icons.star,
        backgroundColor: Colors.deepPurple,
      ),
      OnboardingPageData(
        title: 'Khám phá',
        description: 'Nhiều tính năng thú vị đang chờ bạn.',
        icon: Icons.explore,
        backgroundColor: Colors.teal,
      ),
      OnboardingPageData(
        title: 'Bắt đầu!',
        description: 'Cùng bắt đầu trải nghiệm ngay hôm nay.',
        icon: Icons.rocket,
        backgroundColor: Colors.green,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverOnboardingView(pages: pages),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Nội dung chính #${index + 1}'),
              ),
              childCount: 20,
            ),
          )
        ],
      ),
    );
  }
}
