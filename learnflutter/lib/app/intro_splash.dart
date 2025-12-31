import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnflutter/modules/home/home_aniamtion.dart';

/// IntroSplash - Giới thiệu ứng dụng social về động vật (PetSocial)
///
/// Widget này hiển thị một splash intro có logo, tên app, tagline và nút "Bắt đầu".
/// Nó có animation scale + fade cho logo và text, và tự chuyển sang HomeAnimationPage
/// sau một thời gian hoặc khi người dùng nhấn nút.
class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Nếu người dùng không nhấn gì, tự chuyển tiếp sau 3.5 giây
    // Auto transition after 4 seconds (4000ms)
    _timer = Timer(const Duration(milliseconds: 4000), _goToHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToHome() {
    // Nếu context không mounted thì bỏ qua
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeAnimationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient nhẹ gợi về thiên nhiên
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB3E5CC), Color(0xFF81C784)],
              ),
            ),
          ),
          // Center content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/pet_logo.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if asset not found
                                return Icon(
                                  Icons.pets,
                                  size: 72,
                                  color: theme.primaryColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text(
                          'PetSocial',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nơi chủ thú cưng giao lưu và chia sẻ kiến thức',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        _goToHome();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                      ),
                      child: const Text('Bắt đầu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottom small credits
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Text(
                'Kết nối những người yêu động vật',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
