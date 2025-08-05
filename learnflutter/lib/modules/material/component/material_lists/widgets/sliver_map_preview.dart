import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SliverMapPreview extends StatefulWidget {
  final double height;
  final LatLng center;
  final double fadeInFraction;
  final double zoom;

  const SliverMapPreview({
    super.key,
    required this.center,
    this.height = 300,
    this.zoom = 14.0,
    this.fadeInFraction = 0.3,
  });

  @override
  State<SliverMapPreview> createState() => _SliverMapPreviewState();
}

class _SliverMapPreviewState extends State<SliverMapPreview> {
  bool _isVisible = false;
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: VisibilityDetector(
        key: const Key('sliver-map-preview'),
        onVisibilityChanged: (info) {
          final visible = info.visibleFraction > widget.fadeInFraction;
          if (visible != _isVisible) {
            setState(() => _isVisible = visible);
          }
        },
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: SizedBox(
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.center,
                  zoom: widget.zoom,
                ),
                onMapCreated: (controller) => _controller = controller,
                markers: {
                  Marker(
                    markerId: const MarkerId('center'),
                    position: widget.center,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  )
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
