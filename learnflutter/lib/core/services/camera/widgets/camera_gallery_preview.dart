import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Overlay Gallery xem lại ảnh đã chụp dạng PageView trượt mượt mà,
/// tích hợp nút Đóng và nút Chụp lại thế chỗ tại đúng index ảnh đang xem.
class CameraGalleryPreview extends StatelessWidget {
  final bool show;
  final List<XFile> photos;
  final int currentIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onCloseTap;
  final ValueChanged<int> onRetakeTap;

  const CameraGalleryPreview({
    super.key,
    required this.show,
    required this.photos,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
    required this.onCloseTap,
    required this.onRetakeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!show || photos.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: photos.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final file = photos[index];
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Hero(
                        tag: file.path,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(file.path, fit: BoxFit.contain)
                              : Image.file(File(file.path), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${photos.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 20,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: onCloseTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 20,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => onRetakeTap(currentIndex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber[800]?.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.replay, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Chụp lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
