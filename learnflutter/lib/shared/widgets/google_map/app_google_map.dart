import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:learnflutter/shared/utils/google_map_kml_parser.dart';
import 'package:learnflutter/shared/utils/google_map_kml_exporter.dart';

/// [AppGoogleMap] hỗ trợ hiển thị bản đồ Google Maps với các tính năng Overlay cao cấp
/// Hỗ trợ Import/Export KML và KMZ, 3D Mode, Toàn màn hình.
class AppGoogleMap extends StatefulWidget {
  final CameraPosition initialPosition;
  final bool showAppBar;
  final String? title;
  final VoidCallback? onBack;
  final String? kmlAssetPath;

  const AppGoogleMap({
    super.key,
    required this.initialPosition,
    this.showAppBar = true,
    this.title,
    this.onBack,
    this.kmlAssetPath,
  });

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  late GoogleMapController _mapController;
  MapType _currentMapType = MapType.normal;
  bool _isFullScreen = false;
  bool _is3DMode = false;

  // Dữ liệu bản đồ tích lũy
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Polygon> _polygons = {};
  bool _isLoadingKml = false;

  CameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();
    debugPrint('AppGoogleMap: Init');
  }

  /// [_onMapCreated] nhận controller khi bản đồ sẵn sàng.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.kmlAssetPath != null) {
      _loadDataFromAsset();
    }
  }

  /// [_loadDataFromAsset] Tải dữ liệu từ assets (kml hoặc kmz).
  Future<void> _loadDataFromAsset() async {
    if (widget.kmlAssetPath == null) return;
    setState(() => _isLoadingKml = true);
    try {
      if (widget.kmlAssetPath!.toLowerCase().endsWith('.kmz')) {
        await _loadKmzFromAsset(widget.kmlAssetPath!);
      } else {
        final kmlContent = await rootBundle.loadString(widget.kmlAssetPath!);
        await _processKmlContent(kmlContent);
      }
    } catch (e) {
      debugPrint('Error loading asset data: $e');
      setState(() => _isLoadingKml = false);
    }
  }

  /// [_loadKmzFromAsset] Giải nén KMZ và parse KML.
  Future<void> _loadKmzFromAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final buffer = bytes.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(buffer);
    for (final file in archive) {
      if (file.isFile && file.name.toLowerCase().endsWith('.kml')) {
        final kmlContent = utf8.decode(file.content as List<int>);
        await _processKmlContent(kmlContent);
        break;
      }
    }
  }

  /// [_loadKmlFromUrl] Tải dữ liệu từ URL.
  Future<void> _loadKmlFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (url.toLowerCase().contains('.kmz')) {
          final archive = ZipDecoder().decodeBytes(response.bodyBytes);
          for (final file in archive) {
            if (file.isFile && file.name.toLowerCase().endsWith('.kml')) {
              await _processKmlContent(utf8.decode(file.content as List<int>));
              break;
            }
          }
        } else {
          await _processKmlContent(response.body);
        }
      }
    } catch (e) {
      debugPrint('Error loading remote data ($url): $e');
    }
  }

  /// [_processKmlContent] Parse và cập nhật dữ liệu lên Map.
  Future<void> _processKmlContent(String content) async {
    final data = GoogleMapKmlParser.parse(content);
    setState(() {
      _markers.addAll(data.markers);
      _polylines.addAll(data.polylines);
      _polygons.addAll(data.polygons);
      _isLoadingKml = false;
    });

    for (var link in data.networkLinks) {
      _loadKmlFromUrl(link);
    }
    _zoomToFitAll();
  }

  /// [exportKml] Thực hiện xuất dữ liệu hiện tại sang file KML và chia sẻ.
  Future<void> exportKml() async {
    if (_markers.isEmpty && _polylines.isEmpty && _polygons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có dữ liệu trên bản đồ để xuất!')),
      );
      return;
    }

    try {
      setState(() => _isLoadingKml = true);

      final kmlString = GoogleMapKmlExporter.export(
        documentName: widget.title ?? 'My Map Export',
        markers: _markers,
        polylines: _polylines,
        polygons: _polygons,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/map_export_${DateTime.now().millisecondsSinceEpoch}.kml');
      await file.writeAsString(kmlString);

      setState(() => _isLoadingKml = false);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Xuất dữ liệu bản đồ KML',
        text: 'Dữ liệu bản đồ được xuất từ AppGoogleMap',
      );
    } catch (e) {
      debugPrint('Lỗi khi xuất KML: $e');
      setState(() => _isLoadingKml = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xuất file: $e')),
      );
    }
  }

  /// [_zoomToFitAll] Camera bao quát toàn bộ dữ liệu.
  void _zoomToFitAll() {
    if (_markers.isEmpty && _polylines.isEmpty && _polygons.isEmpty) return;
    List<LatLng> allPoints = [];
    allPoints.addAll(_markers.map((m) => m.position));
    for (var p in _polylines) {
      allPoints.addAll(p.points);
    }
    for (var p in _polygons) {
      allPoints.addAll(p.points);
    }
    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (var p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60.0,
      ),
    );
  }

  /// [_goToCurrentLocation] Di chuyển tới vị trí GPS.
  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 16.0),
    );
  }

  /// [_toggle3DMode] Bật/tắt Tilt 3D.
  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      final targetTilt = _is3DMode ? 75.0 : 0.0;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                _lastCameraPosition?.target ?? widget.initialPosition.target,
            zoom: _lastCameraPosition?.zoom ?? widget.initialPosition.zoom,
            bearing: _lastCameraPosition?.bearing ?? 0,
            tilt: targetTilt,
          ),
        ),
      );
    });
  }

  /// [_showMapTypeSelector] Chọn Map Style.
  void _showMapTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 16),
                child: Text('Chọn kiểu bản đồ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTypeOption(MapType.normal, 'Mặc định', Icons.map),
                  _buildTypeOption(
                      MapType.satellite, 'Vệ tinh', Icons.satellite_alt),
                  _buildTypeOption(MapType.terrain, 'Địa hình', Icons.terrain),
                  _buildTypeOption(MapType.hybrid, 'Hỗn hợp', Icons.layers),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeOption(MapType type, String label, IconData icon) {
    final isSelected = _currentMapType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _currentMapType = type);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  width: 2),
            ),
            child: Icon(icon,
                color: isSelected ? Colors.blueAccent : Colors.grey, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blueAccent : Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShowAppBar = widget.showAppBar && !_isFullScreen;

    return Scaffold(
      appBar: effectiveShowAppBar
          ? AppBar(
              title: Text(widget.title ?? 'Bản đồ'),
              leading: widget.onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onBack)
                  : null,
              actions: [
                if (_isLoadingKml)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                  ),
              ],
            )
          : null,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: widget.initialPosition,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onCameraMove: (position) => _lastCameraPosition = position,
            markers: _markers,
            polylines: _polylines,
            polygons: _polygons,
          ),

          // Right Controls Overlay
          Positioned(
            top: _isFullScreen ? MediaQuery.of(context).padding.top + 16 : 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControl(
                    icon: Icons.my_location,
                    onPressed: _goToCurrentLocation,
                    tooltip: 'Vị trí hiện tại'),
                const SizedBox(height: 12),
                _buildMapControl(
                    icon: Icons.layers,
                    onPressed: _showMapTypeSelector,
                    tooltip: 'Kiểu bản đồ'),
                const SizedBox(height: 12),
                _buildMapControl(
                    icon: Icons.threed_rotation,
                    onPressed: _toggle3DMode,
                    isActive: _is3DMode,
                    tooltip: 'Chế độ 3D'),
                const SizedBox(height: 12),
                _buildMapControl(
                    icon: Icons.download,
                    onPressed: exportKml,
                    tooltip: 'Xuất KML'),
                const SizedBox(height: 12),
                _buildMapControl(
                    icon: _isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    onPressed: () =>
                        setState(() => _isFullScreen = !_isFullScreen),
                    tooltip: 'Toàn màn hình'),
              ],
            ),
          ),

          // Back Button for Full Screen or No AppBar
          if (_isFullScreen || (!effectiveShowAppBar && widget.onBack != null))
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildMapControl(
                icon: Icons.arrow_back,
                onPressed: () {
                  if (_isFullScreen)
                    setState(() => _isFullScreen = false);
                  else
                    widget.onBack?.call();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControl(
      {required IconData icon,
      required VoidCallback onPressed,
      bool isActive = false,
      String? tooltip}) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: IconButton(
          icon: Icon(icon, color: isActive ? Colors.white : Colors.blueAccent),
          onPressed: onPressed,
          tooltip: tooltip),
    );
  }
}
