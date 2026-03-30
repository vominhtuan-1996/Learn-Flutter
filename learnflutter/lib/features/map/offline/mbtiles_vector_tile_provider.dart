import 'dart:typed_data';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MbtilesVectorTileProvider extends VectorTileProvider {
  final MbTiles mbtiles;

  MbtilesVectorTileProvider({
    required this.mbtiles,
    this.minimumZoom = 0,
    this.maximumZoom = 18,
  });

  @override
  final int minimumZoom;

  @override
  final int maximumZoom;

  @override
  TileProviderType get type => TileProviderType.vector;

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    // MBTiles uses TMS (y is flipped) coordinate system.
    // Conversion: y_tms = (2^z - 1) - y_xyz
    final int invertedY = (1 << tile.z) - 1 - tile.y;
    final data = mbtiles.getTile(z: tile.z, x: tile.x, y: invertedY);
    if (data == null) {
      throw Exception('Tile not found at ${tile.z}/${tile.x}/${tile.y}');
    }
    return data;
  }

  @override
  TileOffset get tileOffset => TileOffset.DEFAULT;
}
