import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SharedItemType { url, text, image, file, location }

class SharedItem {
  final SharedItemType type;
  final String value;
  final LatLng? latLng; // only for location type

  const SharedItem({required this.type, required this.value, this.latLng});

  factory SharedItem.fromMap(Map<String, dynamic> map) => SharedItem(
        type: SharedItemType.values.byName((map['type'] as String?) ?? 'text'),
        value: (map['value'] as String?) ?? '',
      );

  bool get isUrl => type == SharedItemType.url;
  bool get isImage => type == SharedItemType.image;
  bool get isLocation => type == SharedItemType.location;
}

/// Parse Google Maps / Apple Maps URL → LatLng
/// Supports:
///   https://maps.google.com/?q=lat,lng
///   https://www.google.com/maps?q=lat,lng
///   https://www.google.com/maps/place/.../@lat,lng,zoom
///   https://maps.apple.com/?ll=lat,lng
LatLng? parseLocationUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final host = uri.host;

    if (host.contains('google')) {
      // ?q=lat,lng or &q=lat,lng
      final q = uri.queryParameters['q'];
      if (q != null) {
        final parts = q.split(',');
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) return LatLng(lat, lng);
        }
      }
      // /place/.../@lat,lng,zoom
      final atMatch = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)').firstMatch(uri.path);
      if (atMatch != null) {
        final lat = double.tryParse(atMatch.group(1)!);
        final lng = double.tryParse(atMatch.group(2)!);
        if (lat != null && lng != null) return LatLng(lat, lng);
      }
    }

    if (host.contains('apple')) {
      // ?ll=lat,lng
      final ll = uri.queryParameters['ll'];
      if (ll != null) {
        final parts = ll.split(',');
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) return LatLng(lat, lng);
        }
      }
    }
  } catch (_) {}
  return null;
}
