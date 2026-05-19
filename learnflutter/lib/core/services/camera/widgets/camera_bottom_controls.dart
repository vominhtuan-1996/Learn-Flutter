import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/camera/model/camera_mode.dart';
import 'package:video_player/video_player.dart';
import 'circle_icon_button.dart';

/// Bộ điều khiển nút bấm phía dưới bao gồm: Thumbnail hiển thị số ảnh đã chụp,
/// nút chụp/quay chính giữa (tròn/vuông bo góc), và nút pause/check hoàn thành.
class CameraBottomControls extends StatelessWidget {
  final CameraMode mode;
  final bool isRecording;
  final bool isPaused;
  final XFile? imgFile;
  final VideoPlayerController? videoPlayerController;
  final List<XFile> capturedPhotos;
  final XFile? videoFile;
  final VoidCallback onThumbnailTap;
  final VoidCallback onCaptureTap;
  final VoidCallback onPauseResumeTap;
  final VoidCallback onConfirmTap;

  const CameraBottomControls({
    super.key,
    required this.mode,
    required this.isRecording,
    required this.isPaused,
    required this.imgFile,
    required this.videoPlayerController,
    required this.capturedPhotos,
    required this.videoFile,
    required this.onThumbnailTap,
    required this.onCaptureTap,
    required this.onPauseResumeTap,
    required this.onConfirmTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildThumbnailWidget(),
          _buildCaptureButtonWidget(),
          if (mode == CameraMode.video && isRecording)
            CircleIconButton(
              icon: isPaused ? Icons.play_arrow : Icons.pause,
              size: 28,
              onTap: onPauseResumeTap,
            )
          else if ((mode == CameraMode.photo && capturedPhotos.isNotEmpty) ||
              (mode == CameraMode.video && videoFile != null))
            CircleIconButton(
              icon: Icons.check,
              color: Colors.greenAccent,
              size: 28,
              onTap: onConfirmTap,
            )
          else
            const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _buildThumbnailWidget() {
    Widget? child;
    if (imgFile != null && mode == CameraMode.photo) {
      child = kIsWeb
          ? Image.network(imgFile!.path, fit: BoxFit.cover)
          : Image.file(File(imgFile!.path), fit: BoxFit.cover);
    } else if (videoPlayerController != null && mode == CameraMode.video) {
      child = VideoPlayer(videoPlayerController!);
    }

    return GestureDetector(
      onTap: onThumbnailTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white70, width: 1.5),
              color: Colors.black45,
            ),
            clipBehavior: Clip.hardEdge,
            child: child ?? const Icon(Icons.photo, color: Colors.white30),
          ),
          if (mode == CameraMode.photo && capturedPhotos.isNotEmpty)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '${capturedPhotos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButtonWidget() {
    return GestureDetector(
      onTap: onCaptureTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: isRecording ? Colors.red : Colors.transparent,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 28 : 56,
            height: isRecording ? 28 : 56,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red[800] : Colors.white,
              borderRadius: BorderRadius.circular(isRecording ? 6 : 28),
            ),
          ),
        ),
      ),
    );
  }
}
