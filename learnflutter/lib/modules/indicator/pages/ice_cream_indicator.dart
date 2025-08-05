import 'dart:async';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:sdk_pms/widgets/loading_animation/loading_animation.dart';

class IceCreamIndicatorScreen extends StatefulWidget {
  final Widget child;
  final IndicatorController? controller;

  const IceCreamIndicatorScreen({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<IceCreamIndicatorScreen> createState() => _IceCreamIndicatorState();
}

class _IceCreamIndicatorState extends State<IceCreamIndicatorScreen> with SingleTickerProviderStateMixin {
  static const _indicatorSize = 80.0;
  bool _showExplosion = false;
  late AnimationController _spoonController;
  // late AudioPlayer _audioPlayer;

  @override
  void initState() {
    _spoonController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    // _audioPlayer = AudioPlayer();
    // Preload audio
    // _audioPlayer.setAsset('assets/sound/sound_effect_refreshing.wav');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: CustomRefreshIndicator(
        controller: widget.controller,
        offsetToArmed: _indicatorSize,
        onRefresh: () async {
          // _audioPlayer.play();
          await Future.delayed(Duration(seconds: 4));
        },
        autoRebuild: false,
        child: widget.child,
        onStateChanged: (change) {
          if (change.didChange(to: IndicatorState.loading)) {
            // _spoonController.repeat(reverse: true);
            _spoonController.forward(from: 0);
          } else if (change.didChange(from: IndicatorState.loading)) {
            _spoonController.stop();
          } else if (change.didChange(to: IndicatorState.idle)) {
            _spoonController.value = 0.0;
          }
        },
        builder: (BuildContext context, Widget child, IndicatorController controller) {
          return Stack(
            children: <Widget>[
              AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget? _) {
                  return SizedBox(
                    height: controller.value * _indicatorSize,
                    child: Stack(
                      children: <Widget>[
                        AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            final progress = controller.value.clamp(0.0, 1.0);
                            final isRefreshing = controller.state == IndicatorState.dragging;
                            if (controller.state == IndicatorState.loading) {
                              return Center(
                                child: LoadingAnimationWidget.progressiveDots(
                                  color: Colors.grey,
                                  size: 36,
                                ),
                              );
                            }
                            return Align(
                              alignment: Alignment.topCenter,
                              child: Transform.scale(
                                scale: isRefreshing ? 1.2 : progress,
                                child: LoadingAnimationWidget.progressiveDots(
                                  color: Colors.grey,
                                  size: progress * 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0.0, controller.value * _indicatorSize),
                    child: child,
                  );
                },
                animation: controller,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _spoonController.dispose();
    super.dispose();
  }
}
