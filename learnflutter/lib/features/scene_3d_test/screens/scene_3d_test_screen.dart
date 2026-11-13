import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/scene_3d_test_cubit.dart';
import '../cubit/scene_3d_test_state.dart';

class Scene3dTestScreen extends StatelessWidget {
  const Scene3dTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => Scene3dTestCubit(), child: const _Scene3dTestView());
  }
}

class _Scene3dTestView extends StatelessWidget {
  const _Scene3dTestView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Scene3dTestCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('3D Scene Test')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  BlocSelector<Scene3dTestCubit, Scene3dTestState,
                      (String, int)>(
                    selector: (s) => (s.model.src, s.reloadToken),
                    builder: (context, key) => Flutter3DViewer(
                      key: ValueKey(key),
                      src: key.$1,
                      controller: cubit.viewer,
                      progressBarColor: Colors.transparent,
                      onProgress: cubit.onProgress,
                      onLoad: (_) => cubit.onLoaded(),
                      onError: cubit.onLoadFailed,
                    ),
                  ),
                  const _StatusOverlay(),
                ],
              ),
            ),
            const _Controls(),
          ],
        ),
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Scene3dTestCubit, Scene3dTestState>(
      buildWhen: (p, c) =>
          p.status != c.status ||
          p.progress != c.progress ||
          p.errorMessage != c.errorMessage,
      builder: (context, state) {
        switch (state.status) {
          case Scene3dStatus.ready:
            return const SizedBox.shrink();
          case Scene3dStatus.loading:
            return Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 160,
                        child: LinearProgressIndicator(
                            value: state.progress > 0 ? state.progress : null),
                      ),
                      const SizedBox(height: 8),
                      Text('Loading ${(state.progress * 100).round()}%'),
                    ],
                  ),
                ),
              ),
            );
          case Scene3dStatus.error:
            return Positioned.fill(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 40),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage ?? 'Failed to load model',
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                            onPressed: context.read<Scene3dTestCubit>().reload,
                            child: const Text('Retry')),
                      ],
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Scene3dTestCubit>();
    return BlocBuilder<Scene3dTestCubit, Scene3dTestState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Model',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in Scene3dTestCubit.models)
                    ChoiceChip(
                      label: Text(m.label),
                      selected: m == state.model,
                      onSelected: (_) => cubit.selectModel(m),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Camera preset',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                children: [
                  for (final p in Scene3dTestCubit.presetsFor(state.model))
                    ChoiceChip(
                      label: Text(p.label),
                      selected: p == state.cameraPreset,
                      onSelected: (_) => cubit.selectCameraPreset(p),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-rotate'),
                subtitle: const Text('Drag to rotate, pinch to zoom'),
                value: state.autoRotate,
                onChanged: cubit.toggleAutoRotate,
              ),
            ],
          ),
        );
      },
    );
  }
}
