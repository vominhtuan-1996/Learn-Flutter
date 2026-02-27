import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/shared/widgets/google_map/app_google_map.dart';

/// [GoogleMapBaseScreen] là màn hình mẫu sử dụng module [AppGoogleMap].
/// Nó minh họa cách triển khai một màn hình bản đồ đầy đủ tính năng chỉ với việc gọi widget dùng chung.
class GoogleMapBaseScreen extends StatelessWidget {
  const GoogleMapBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGoogleMap(
      title: 'Google Map Base',
      initialPosition: const CameraPosition(
        target: LatLng(48.8566, 2.3522), // Paris
        zoom: 10.0,
      ),
      kmlAssetPath: 'assets/kml/Tour_de_France.kmz',
      onBack: () => Navigator.pop(context),
    );
  }
}
