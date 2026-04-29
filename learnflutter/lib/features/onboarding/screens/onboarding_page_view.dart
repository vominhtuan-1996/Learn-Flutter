import 'package:flutter/material.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step1_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step2_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step3_screen.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(Routes.loginV1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          OnboardingStep1Screen(
            onNext: _nextPage,
            onSkip: _goToLogin,
          ),
          OnboardingStep2Screen(
            onNext: _nextPage,
            onSkip: _goToLogin,
          ),
          OnboardingStep3Screen(
            onGetStarted: _goToLogin,
          ),
        ],
      ),
    );
  }
}
