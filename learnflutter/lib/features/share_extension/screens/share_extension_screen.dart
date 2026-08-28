import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/features/share_extension/cubit/share_extension_cubit.dart';
import 'package:learnflutter/features/share_extension/models/shared_item.dart';

class ShareExtensionScreen extends StatelessWidget {
  const ShareExtensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShareExtensionView();
  }
}

class _ShareExtensionView extends StatelessWidget {
  const _ShareExtensionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Extension'),
        actions: [
          BlocBuilder<ShareExtensionCubit, ShareExtensionState>(
            builder: (context, state) => state.items.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: context.read<ShareExtensionCubit>().clear,
                  ),
          ),
        ],
      ),
      body: BlocBuilder<ShareExtensionCubit, ShareExtensionState>(
        builder: (context, state) {
          if (state.status == ShareExtensionStatus.idle || state.items.isEmpty) {
            return _EmptyState(
              locationStatus: state.locationStatus,
              onShareLocation: context.read<ShareExtensionCubit>().shareMyLocation,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _SharedItemCard(item: state.items[i]),
          );
        },
      ),
      // FAB: share my location (always visible)
      floatingActionButton: BlocBuilder<ShareExtensionCubit, ShareExtensionState>(
        builder: (context, state) => FloatingActionButton.extended(
          onPressed: state.locationStatus == LocationStatus.loading
              ? null
              : context.read<ShareExtensionCubit>().shareMyLocation,
          icon: state.locationStatus == LocationStatus.loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.my_location),
          label: const Text('Chia sẻ vị trí'),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final LocationStatus locationStatus;
  final VoidCallback onShareLocation;
  const _EmptyState({required this.locationStatus, required this.onShareLocation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ios_share, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Chưa có dữ liệu được share', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Share URL / ảnh / vị trí từ app khác\nhoặc nhấn nút bên dưới để chia sẻ vị trí',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (locationStatus == LocationStatus.denied) ...[
            const SizedBox(height: 12),
            const Text('⚠️ Quyền vị trí bị từ chối', style: TextStyle(color: Colors.orange)),
          ],
          if (locationStatus == LocationStatus.error) ...[
            const SizedBox(height: 12),
            const Text('❌ Lỗi lấy vị trí', style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

// ── Shared item card ──────────────────────────────────────────────────────────
class _SharedItemCard extends StatelessWidget {
  final SharedItem item;
  const _SharedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.isLocation && item.latLng != null) {
      return _LocationCard(item: item);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(_typeIcon(item.type), size: 18),
              const SizedBox(width: 8),
              Text(
                item.type.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ]),
            const SizedBox(height: 8),
            if (item.isImage && File(item.value).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(item.value),
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              )
            else
              SelectableText(item.value,
                  style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(SharedItemType type) => switch (type) {
        SharedItemType.url => Icons.link,
        SharedItemType.image => Icons.image,
        SharedItemType.file => Icons.insert_drive_file,
        SharedItemType.text => Icons.text_fields,
        SharedItemType.location => Icons.location_on,
      };
}

// ── Location card with Google Map preview ─────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final SharedItem item;
  const _LocationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final latLng = item.latLng!;
    final marker = Marker(
      markerId: const MarkerId('shared'),
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Vị trí được share',
        snippet: '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}',
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map preview
          SizedBox(
            height: 220,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
              markers: {marker},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
            ),
          ),
          // Info row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('LOCATION',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 6),
                Text(
                  '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  item.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
