import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as renderer;
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/features/map/offline/mbtiles_vector_tile_provider.dart';

/// [OfflineMbtilesMapScreen] displays an offline map using a .mbtiles file.
/// It loads 'vietnam_vector.mbtiles' from the application's documents directory.
class OfflineMbtilesMapScreen extends StatefulWidget {
  const OfflineMbtilesMapScreen({super.key});

  @override
  State<OfflineMbtilesMapScreen> createState() => _OfflineMbtilesMapScreenState();
}

class _OfflineMbtilesMapScreenState extends State<OfflineMbtilesMapScreen> {
  MbtilesVectorTileProvider? provider;
  renderer.Theme? _theme;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMbtiles();
  }

  Future<void> _loadMbtiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/vietnam_vector.mbtiles';
      final file = File(path);

      if (await file.exists()) {
        final mbtiles = MbTiles(mbtilesPath: path);
        final vectorProvider = MbtilesVectorTileProvider(mbtiles: mbtiles);

        // Load a basic theme
        final theme = renderer.ThemeReader().read(_createBasicTheme());

        setState(() {
          provider = vectorProvider;
          _theme = theme;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'File không tồn tại tại: $path';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải mbtiles: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    provider?.mbtiles.dispose();
    super.dispose();
  }

  Map<String, dynamic> _createBasicTheme() {
    return {
      "version": 8,
      "sources": {
        "openmaptiles": {
          "type": "vector",
        }
      },
      "layers": [
        {
          "id": "background",
          "type": "background",
          "paint": {"background-color": "#f8f4f0"}
        },
        {
          "id": "water",
          "type": "fill",
          "source": "openmaptiles",
          "source-layer": "water",
          "paint": {"fill-color": "#a0cfdf"}
        },
        {
          "id": "landuse",
          "type": "fill",
          "source": "openmaptiles",
          "source-layer": "landuse",
          "paint": {"fill-color": "#e0dfdf"}
        },
        {
          "id": "roads",
          "type": "line",
          "source": "openmaptiles",
          "source-layer": "transportation",
          "paint": {"line-color": "#ffffff", "line-width": 1}
        },
        {
          "id": "buildings",
          "type": "fill",
          "source": "openmaptiles",
          "source-layer": "building",
          "paint": {"fill-color": "#cccccc"}
        }
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: _isLoading,
      appBar: AppBar(
        title: const Text('Offline MBTiles Map'),
      ),
      child: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : provider != null
              ? FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(16.0, 107.0),
                    initialZoom: 6.0,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    VectorTileLayer(
                      tileProviders: TileProviders({
                        'openmaptiles': provider!,
                      }),
                      theme: _theme!,
                    ),
                  ],
                )
              : Container(),
    );
  }
}
