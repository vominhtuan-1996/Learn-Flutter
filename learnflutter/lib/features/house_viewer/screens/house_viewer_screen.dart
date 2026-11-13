import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/house_viewer_cubit.dart';
import '../cubit/house_viewer_state.dart';

/// Dedicated viewer for the procedural house: pick a group (exterior faces,
/// rooms, close-up details) and a part to fly the camera to it.
class HouseViewerScreen extends StatelessWidget {
  const HouseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => HouseViewerCubit(), child: const _HouseViewerView());
  }
}

class _HouseViewerView extends StatelessWidget {
  const _HouseViewerView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HouseViewerCubit>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('House Viewer'),
        actions: [
          IconButton(
            tooltip: 'Reset camera to this part',
            icon: const Icon(Icons.center_focus_strong),
            onPressed: cubit.resetCamera,
          ),
        ],
      ),
      // Viewer fills the whole screen; options live in a draggable sheet.
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocSelector<HouseViewerCubit, HouseViewerState,
                (HouseModel, int)>(
              selector: (s) => (s.part.model, s.reloadToken),
              builder: (context, key) => Flutter3DViewer(
                key: ValueKey(key),
                src: key.$1.asset,
                controller: cubit.viewer,
                progressBarColor: Colors.transparent,
                onProgress: cubit.onProgress,
                onLoad: (_) => cubit.onLoaded(),
                onError: cubit.onLoadFailed,
              ),
            ),
          ),
          const _StatusOverlay(),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.08,
            maxChildSize: 0.6,
            snap: true,
            snapSizes: const [0.08, 0.2, 0.6],
            builder: (context, scrollController) =>
                _Panel(scrollController: scrollController),
          ),
        ],
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseViewerCubit, HouseViewerState>(
      buildWhen: (p, c) =>
          p.status != c.status ||
          p.progress != c.progress ||
          p.errorMessage != c.errorMessage,
      builder: (context, state) {
        switch (state.status) {
          case HouseViewerStatus.ready:
            return const SizedBox.shrink();
          case HouseViewerStatus.loading:
            return Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                        value: state.progress > 0 ? state.progress : null),
                  ),
                ),
              ),
            );
          case HouseViewerStatus.error:
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
                            onPressed: context.read<HouseViewerCubit>().reload,
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

class _Panel extends StatelessWidget {
  const _Panel({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HouseViewerCubit>();
    return BlocBuilder<HouseViewerCubit, HouseViewerState>(
      buildWhen: (p, c) =>
          p.group != c.group ||
          p.part != c.part ||
          p.autoRotate != c.autoRotate,
      builder: (context, state) {
        final theme = Theme.of(context);
        return Material(
          elevation: 8,
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<HouseType>(
                  showSelectedIcon: false,
                  segments: [
                    for (final h in HouseType.values)
                      ButtonSegment(value: h, label: Text(h.label)),
                  ],
                  selected: {state.house},
                  onSelectionChanged: (s) => cubit.selectHouse(s.first),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<HousePartGroup>(
                  showSelectedIcon: false,
                  segments: [
                    for (final g in HousePartGroup.values)
                      if (HouseViewerCubit.partsOf(state.house, g).isNotEmpty)
                        ButtonSegment(value: g, label: Text(g.label)),
                  ],
                  selected: {state.group},
                  onSelectionChanged: (s) => cubit.selectGroup(s.first),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final p
                      in HouseViewerCubit.partsOf(state.house, state.group))
                    ChoiceChip(
                      label: Text(p.label),
                      selected: p == state.part,
                      onSelected: (_) => cubit.selectPart(p),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(state.part.description, style: theme.textTheme.bodyMedium),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
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
