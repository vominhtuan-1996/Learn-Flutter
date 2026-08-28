import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';

class AppImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const AppImageViewer._({
    required this.images,
    this.initialIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => AppImageViewer._(images: [imageUrl]),
      ),
    );
  }

  static Future<void> showGallery(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => AppImageViewer._(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: widget.images[i],
                    child: Image.network(
                      widget.images[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.close, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            // Page indicator
            if (widget.images.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentIndex ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentIndex
                            ? AppColors.white
                            : AppColors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
