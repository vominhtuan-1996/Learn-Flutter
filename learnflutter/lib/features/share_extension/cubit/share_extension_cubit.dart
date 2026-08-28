import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import '../models/shared_item.dart';

part 'share_extension_state.dart';

class ShareExtensionCubit extends BaseCubit<ShareExtensionState> {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  ShareExtensionCubit() : super(const ShareExtensionState()) {
    _init();
  }

  void _init() {
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(_handle);
    ReceiveSharingIntent.instance.getInitialMedia().then(_handle);
  }

  void _handle(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final items = files.map((f) {
      // Detect maps URL → parse as location
      if (f.type == SharedMediaType.url || f.type == SharedMediaType.text) {
        final latLng = parseLocationUrl(f.path);
        if (latLng != null) {
          return SharedItem(type: SharedItemType.location, value: f.path, latLng: latLng);
        }
      }
      final type = switch (f.type) {
        SharedMediaType.url => SharedItemType.url,
        SharedMediaType.image => SharedItemType.image,
        SharedMediaType.file => SharedItemType.file,
        _ => SharedItemType.text,
      };
      return SharedItem(type: type, value: f.path);
    }).toList();
    ReceiveSharingIntent.instance.reset();
    emit(state.copyWith(items: items, status: ShareExtensionStatus.loaded));
  }

  // ── Feature A: Share current location OUT ─────────────────────────────────
  Future<void> shareMyLocation() async {
    emit(state.copyWith(locationStatus: LocationStatus.loading));
    try {
      final permission = await _ensurePermission();
      if (!permission) {
        emit(state.copyWith(locationStatus: LocationStatus.denied));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      final url = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
      emit(state.copyWith(locationStatus: LocationStatus.idle, myLocation: latLng));
      await SharePlus.instance.share(ShareParams(text: url));
    } catch (e) {
      emit(state.copyWith(locationStatus: LocationStatus.error));
    }
  }

  Future<bool> _ensurePermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.whileInUse || perm == LocationPermission.always;
  }

  void clear() => emit(state.copyWith(
        items: [],
        status: ShareExtensionStatus.idle,
        myLocation: null,
        locationStatus: LocationStatus.idle,
      ));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
