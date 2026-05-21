import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/engine_google_map/engine_google_map.dart';
import 'package:learnflutter/core/services/isolate/app_isolate_handler.dart';
import 'package:learnflutter/core/engine_dialog/engine_dialog.dart';
import 'package:learnflutter/core/engine_bottom_sheet/engine_bottom_sheet.dart';
import 'package:learnflutter/core/engine_queue/engine_queue.dart';

/// [GoogleMapEngineDemoScreen] – Màn hình demo toàn bộ bộ Engine Google Map.
///
/// Minh họa đầy đủ các tính năng:
/// - Thêm / Cập nhật / Xóa Marker, Polyline, Polygon
/// - Tự động tải và parse dữ liệu địa giới quận/huyện TP.HCM từ file [boudery_hcm.json]
///   thông qua bộ xử lý đa luồng [AppIsolateHandler] (Isolate) để bảo đảm UI 60fps mượt mà.
/// - Auto Cluster khi có nhiều Markers (bật/tắt được)
/// - Zoom tới tất cả dữ liệu, di chuyển tới vị trí GPS
/// - Chuyển đổi MapType (Normal, Satellite, Hybrid, Terrain)
/// - Bật/tắt chế độ 3D (Tilt)
class GoogleMapEngineDemoScreen extends StatelessWidget {
  const GoogleMapEngineDemoScreen({super.key});

  static const _initialPosition = CameraPosition(
    target: LatLng(10.7769, 106.7009), // TP.HCM
    zoom: 11,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoogleMapCubit(),
      child: const _GoogleMapEngineDemoBody(),
    );
  }
}

class _GoogleMapEngineDemoBody extends StatefulWidget {
  const _GoogleMapEngineDemoBody();

  @override
  State<_GoogleMapEngineDemoBody> createState() => _GoogleMapEngineDemoBodyState();
}

class _GoogleMapEngineDemoBodyState extends State<_GoogleMapEngineDemoBody> {
  bool _isLoadingPolygons = false;
  int _loadedPolygonsCount = 0;
  bool _isLoadingHeatmap = false;
  int _loadedHeatmapPointsCount = 0;

  late final InMemoryQueueEngine _mapQueueEngine;

  @override
  void initState() {
    super.initState();
    _mapQueueEngine = InMemoryQueueEngine(
      config: const QueueConfig(
        concurrency: 1, // Tuần tự xử lý các thao tác bản đồ nặng để giữ vững 60fps
      ),
    );
  }

  @override
  void dispose() {
    _mapQueueEngine.dispose();
    super.dispose();
  }

  // ─── Mock Data ────────────────────────────────

  static final _sampleMarkers = List.generate(20, (i) {
    return MarkerConfig(
      id: 'marker_$i',
      position: LatLng(
        10.7769 + (i % 5) * 0.03 - 0.06,
        106.7009 + (i ~/ 5) * 0.04 - 0.06,
      ),
      title: 'Điểm $i',
      snippet: 'Mô tả điểm số $i',
    );
  });

  static final _samplePolyline = PolylineConfig(
    id: 'route_demo',
    color: const Color(0xFF2563EB),
    width: 5,
    points: const [
      LatLng(10.800, 106.680),
      LatLng(10.790, 106.700),
      LatLng(10.775, 106.710),
      LatLng(10.760, 106.720),
      LatLng(10.750, 106.700),
    ],
  );

  static final _samplePolygon = PolygonConfig(
    id: 'zone_demo',
    strokeColor: const Color(0xFF16A34A),
    fillColor: const Color(0x2016A34A),
    strokeWidth: 3,
    points: const [
      LatLng(10.800, 106.680),
      LatLng(10.800, 106.730),
      LatLng(10.755, 106.730),
      LatLng(10.755, 106.680),
    ],
  );

  static final _sampleHeatmap = HeatmapConfig(
    id: 'heatmap_demo',
    data: () {
      final random = Random(42);
      final points = <WeightedLatLng>[];

      // Cluster 1: Q1 center (high density)
      final center1 = const LatLng(10.7769, 106.7009);
      for (int i = 0; i < 2000; i++) {
        points.add(WeightedLatLng(
          LatLng(
            center1.latitude + (random.nextDouble() - 0.5) * 0.05,
            center1.longitude + (random.nextDouble() - 0.5) * 0.05,
          ),
          weight: random.nextInt(5) + 1.0,
        ));
      }

      // Cluster 2: Q7 center (medium density)
      final center2 = const LatLng(10.7333, 106.7275);
      for (int i = 0; i < 1500; i++) {
        points.add(WeightedLatLng(
          LatLng(
            center2.latitude + (random.nextDouble() - 0.5) * 0.08,
            center2.longitude + (random.nextDouble() - 0.5) * 0.08,
          ),
          weight: random.nextInt(3) + 1.0,
        ));
      }

      // Cluster 3: Tan Binh center (wide density)
      final center3 = const LatLng(10.8015, 106.6521);
      for (int i = 0; i < 1500; i++) {
        points.add(WeightedLatLng(
          LatLng(
            center3.latitude + (random.nextDouble() - 0.5) * 0.06,
            center3.longitude + (random.nextDouble() - 0.5) * 0.06,
          ),
          weight: random.nextInt(4) + 1.0,
        ));
      }

      // ─── Boundary of Tân Thuận ───
      points.addAll(const [
        WeightedLatLng(LatLng(10.7735101, 106.7476816), weight: 10),
        WeightedLatLng(LatLng(10.7740551, 106.7470609), weight: 2),
        WeightedLatLng(LatLng(10.7743204, 106.7467441), weight: 5),
        WeightedLatLng(LatLng(10.7745988, 106.7464009), weight: 2),
        WeightedLatLng(LatLng(10.7748716, 106.746053), weight: 4),
        WeightedLatLng(LatLng(10.775661, 106.7450015), weight: 1),
        WeightedLatLng(LatLng(10.7759144, 106.7446461), weight: 3),
        WeightedLatLng(LatLng(10.7763208, 106.7440514), weight: 1),
        WeightedLatLng(LatLng(10.7765186, 106.7437503), weight: 4),
        WeightedLatLng(LatLng(10.7768017, 106.743244), weight: 4),
        WeightedLatLng(LatLng(10.7770556, 106.7427218), weight: 1),
        WeightedLatLng(LatLng(10.7772827, 106.742177), weight: 2),
        WeightedLatLng(LatLng(10.777396, 106.741812), weight: 1),
        WeightedLatLng(LatLng(10.7775037, 106.7413911), weight: 2),
        WeightedLatLng(LatLng(10.7775541, 106.7411532), weight: 4),
        WeightedLatLng(LatLng(10.7776336, 106.740673), weight: 4),
        WeightedLatLng(LatLng(10.7776805, 106.7402244), weight: 4),
        WeightedLatLng(LatLng(10.7776896, 106.739809), weight: 3),
        WeightedLatLng(LatLng(10.7776632, 106.7393945), weight: 3),
        WeightedLatLng(LatLng(10.7776019, 106.7389863), weight: 5),
        WeightedLatLng(LatLng(10.7775067, 106.7385875), weight: 3),
        WeightedLatLng(LatLng(10.7773783, 106.7381985), weight: 4),
        WeightedLatLng(LatLng(10.7773018, 106.7380085), weight: 5),
        WeightedLatLng(LatLng(10.7772026, 106.7378086), weight: 2),
        WeightedLatLng(LatLng(10.7769822, 106.7374208), weight: 3),
        WeightedLatLng(LatLng(10.7767447, 106.7370666), weight: 1),
        WeightedLatLng(LatLng(10.7764949, 106.7367454), weight: 1),
        WeightedLatLng(LatLng(10.776362, 106.7365916), weight: 3),
        WeightedLatLng(LatLng(10.776055, 106.7362823), weight: 2),
        WeightedLatLng(LatLng(10.7757254, 106.735998), weight: 5),
        WeightedLatLng(LatLng(10.7753754, 106.7357404), weight: 3),
        WeightedLatLng(LatLng(10.7750129, 106.7355144), weight: 5),
        WeightedLatLng(LatLng(10.7746345, 106.735317), weight: 3),
        WeightedLatLng(LatLng(10.7742426, 106.7351494), weight: 3),
        WeightedLatLng(LatLng(10.7739956, 106.7350518), weight: 2),
        WeightedLatLng(LatLng(10.7737455, 106.734963), weight: 1),
        WeightedLatLng(LatLng(10.7735276, 106.7348939), weight: 5),
        WeightedLatLng(LatLng(10.7730271, 106.73476), weight: 4),
        WeightedLatLng(LatLng(10.7727738, 106.7347059), weight: 1),
        WeightedLatLng(LatLng(10.7722869, 106.7346271), weight: 4),
        WeightedLatLng(LatLng(10.7718205, 106.7345814), weight: 5),
        WeightedLatLng(LatLng(10.7682659, 106.7344427), weight: 3),
        WeightedLatLng(LatLng(10.767884, 106.7344219), weight: 3),
        WeightedLatLng(LatLng(10.7671217, 106.7343574), weight: 4),
        WeightedLatLng(LatLng(10.7663626, 106.7342626), weight: 2),
        WeightedLatLng(LatLng(10.7659845, 106.7342038), weight: 3),
        WeightedLatLng(LatLng(10.7652019, 106.7340575), weight: 1),
        WeightedLatLng(LatLng(10.764798, 106.7339688), weight: 1),
        WeightedLatLng(LatLng(10.764396, 106.7338714), weight: 1),
        WeightedLatLng(LatLng(10.7635985, 106.7336507), weight: 5),
        WeightedLatLng(LatLng(10.7631528, 106.733475), weight: 2),
        WeightedLatLng(LatLng(10.7627184, 106.733272), weight: 2),
        WeightedLatLng(LatLng(10.7622969, 106.7330423), weight: 2),
        WeightedLatLng(LatLng(10.7618692, 106.7327729), weight: 1),
        WeightedLatLng(LatLng(10.7614395, 106.7324605), weight: 3),
        WeightedLatLng(LatLng(10.7610314, 106.7321193), weight: 1),
        WeightedLatLng(LatLng(10.7608745, 106.7319223), weight: 4),
        WeightedLatLng(LatLng(10.7607251, 106.7317192), weight: 1),
        WeightedLatLng(LatLng(10.7605835, 106.7315105), weight: 2),
        WeightedLatLng(LatLng(10.7604498, 106.7312965), weight: 4),
        WeightedLatLng(LatLng(10.7603242, 106.7310774), weight: 4),
        WeightedLatLng(LatLng(10.760207, 106.7308536), weight: 5),
        WeightedLatLng(LatLng(10.7601008, 106.730631), weight: 1),
        WeightedLatLng(LatLng(10.7600029, 106.7304046), weight: 4),
        WeightedLatLng(LatLng(10.7599133, 106.7301746), weight: 2),
        WeightedLatLng(LatLng(10.7598322, 106.7299414), weight: 5),
        WeightedLatLng(LatLng(10.7597597, 106.7297053), weight: 5),
        WeightedLatLng(LatLng(10.7596959, 106.7294666), weight: 3),
        WeightedLatLng(LatLng(10.7596409, 106.7292256), weight: 2),
        WeightedLatLng(LatLng(10.7594765, 106.7281855), weight: 2),
        WeightedLatLng(LatLng(10.759329, 106.7270676), weight: 5),
        WeightedLatLng(LatLng(10.7592041, 106.7258719), weight: 1),
        WeightedLatLng(LatLng(10.75915, 106.7250908), weight: 2),
        WeightedLatLng(LatLng(10.7591349, 106.7246996), weight: 2),
        WeightedLatLng(LatLng(10.7591242, 106.7240317), weight: 2),
        WeightedLatLng(LatLng(10.7591337, 106.7234636), weight: 4),
        WeightedLatLng(LatLng(10.7591658, 106.7229966), weight: 3),
        WeightedLatLng(LatLng(10.7592176, 106.7225764), weight: 3),
        WeightedLatLng(LatLng(10.7592738, 106.7222803), weight: 3),
        WeightedLatLng(LatLng(10.7580069, 106.7217145), weight: 4),
        WeightedLatLng(LatLng(10.7567526, 106.72112), weight: 1),
        WeightedLatLng(LatLng(10.7560248, 106.7207548), weight: 3),
        WeightedLatLng(LatLng(10.7555117, 106.7204973), weight: 3),
        WeightedLatLng(LatLng(10.7552539, 106.7203632), weight: 1),
        WeightedLatLng(LatLng(10.7551379, 106.7203028), weight: 4),
        WeightedLatLng(LatLng(10.7547764, 106.7200864), weight: 2),
        WeightedLatLng(LatLng(10.7543887, 106.7198197), weight: 5),
        WeightedLatLng(LatLng(10.7540192, 106.7195276), weight: 2),
        WeightedLatLng(LatLng(10.7537245, 106.7192636), weight: 2),
        WeightedLatLng(LatLng(10.7536289, 106.7191602), weight: 2),
        WeightedLatLng(LatLng(10.7535121, 106.7190339), weight: 2),
        WeightedLatLng(LatLng(10.7533277, 106.7187891), weight: 4),
        WeightedLatLng(LatLng(10.7532452, 106.7186608), weight: 3),
        WeightedLatLng(LatLng(10.7531384, 106.7184667), weight: 3),
        WeightedLatLng(LatLng(10.7530393, 106.7182678), weight: 3),
        WeightedLatLng(LatLng(10.7529483, 106.7180647), weight: 1),
        WeightedLatLng(LatLng(10.7528657, 106.7178581), weight: 3),
        WeightedLatLng(LatLng(10.7527915, 106.7176482), weight: 5),
        WeightedLatLng(LatLng(10.7527259, 106.7174356), weight: 2),
        WeightedLatLng(LatLng(10.7526249, 106.7170231), weight: 2),
        WeightedLatLng(LatLng(10.7525464, 106.7165526), weight: 3),
        WeightedLatLng(LatLng(10.7524938, 106.7160772), weight: 1),
        WeightedLatLng(LatLng(10.7524833, 106.7158543), weight: 2),
        WeightedLatLng(LatLng(10.7507508, 106.7158726), weight: 1),
        WeightedLatLng(LatLng(10.7504441, 106.7158734), weight: 2),
        WeightedLatLng(LatLng(10.7498693, 106.7158749), weight: 5),
        WeightedLatLng(LatLng(10.7493409, 106.7158735), weight: 5),
        WeightedLatLng(LatLng(10.7489878, 106.7158726), weight: 4),
        WeightedLatLng(LatLng(10.7487162, 106.7158734), weight: 5),
        WeightedLatLng(LatLng(10.7475174, 106.715877), weight: 3),
        WeightedLatLng(LatLng(10.7457888, 106.7158823), weight: 5),
        WeightedLatLng(LatLng(10.7444092, 106.7158902), weight: 4),
        WeightedLatLng(LatLng(10.743674, 106.7158944), weight: 5),
        WeightedLatLng(LatLng(10.7424667, 106.7159051), weight: 5),
        WeightedLatLng(LatLng(10.7420191, 106.7159101), weight: 1),
        WeightedLatLng(LatLng(10.7406713, 106.7159252), weight: 2),
        WeightedLatLng(LatLng(10.7399702, 106.715933), weight: 1),
        WeightedLatLng(LatLng(10.7383498, 106.7159561), weight: 5),
        WeightedLatLng(LatLng(10.7382547, 106.7175651), weight: 2),
        WeightedLatLng(LatLng(10.738225, 106.7180851), weight: 2),
        WeightedLatLng(LatLng(10.7381572, 106.7192709), weight: 3),
        WeightedLatLng(LatLng(10.7381375, 106.7195927), weight: 3),
        WeightedLatLng(LatLng(10.7380544, 106.72095), weight: 2),
        WeightedLatLng(LatLng(10.7380116, 106.7217012), weight: 5),
        WeightedLatLng(LatLng(10.7379622, 106.7226344), weight: 3),
        WeightedLatLng(LatLng(10.7378884, 106.7234793), weight: 4),
        WeightedLatLng(LatLng(10.7378618, 106.7238775), weight: 4),
        WeightedLatLng(LatLng(10.7377273, 106.7263732), weight: 5),
        WeightedLatLng(LatLng(10.737716, 106.7265636), weight: 3),
        WeightedLatLng(LatLng(10.7376985, 106.7268568), weight: 4),
        WeightedLatLng(LatLng(10.7376053, 106.7285774), weight: 5),
        WeightedLatLng(LatLng(10.737528, 106.7301796), weight: 3),
        WeightedLatLng(LatLng(10.7375308, 106.7304317), weight: 5),
        WeightedLatLng(LatLng(10.7376921, 106.7306301), weight: 4),
        WeightedLatLng(LatLng(10.7379003, 106.7309399), weight: 3),
        WeightedLatLng(LatLng(10.7379837, 106.731087), weight: 3),
        WeightedLatLng(LatLng(10.7380831, 106.7312669), weight: 3),
        WeightedLatLng(LatLng(10.7409296, 106.7366203), weight: 4),
        WeightedLatLng(LatLng(10.7420046, 106.7385882), weight: 3),
        WeightedLatLng(LatLng(10.7424487, 106.7394319), weight: 3),
        WeightedLatLng(LatLng(10.743102, 106.7407361), weight: 3),
        WeightedLatLng(LatLng(10.7433565, 106.7407809), weight: 2),
        WeightedLatLng(LatLng(10.7436714, 106.7407836), weight: 3),
        WeightedLatLng(LatLng(10.7437615, 106.7408255), weight: 5),
        WeightedLatLng(LatLng(10.7439231, 106.7415574), weight: 4),
        WeightedLatLng(LatLng(10.7441006, 106.7422834), weight: 2),
        WeightedLatLng(LatLng(10.7441286, 106.7424935), weight: 1),
        WeightedLatLng(LatLng(10.744135, 106.7426164), weight: 5),
        WeightedLatLng(LatLng(10.744126, 106.7428623), weight: 3),
        WeightedLatLng(LatLng(10.7440482, 106.7436723), weight: 2),
        WeightedLatLng(LatLng(10.7440482, 106.7438668), weight: 1),
        WeightedLatLng(LatLng(10.7440719, 106.7443442), weight: 2),
        WeightedLatLng(LatLng(10.744068, 106.7447546), weight: 5),
        WeightedLatLng(LatLng(10.7439468, 106.7453313), weight: 5),
        WeightedLatLng(LatLng(10.7441616, 106.7451937), weight: 1),
        WeightedLatLng(LatLng(10.7444068, 106.7450469), weight: 5),
        WeightedLatLng(LatLng(10.7446564, 106.7449082), weight: 2),
        WeightedLatLng(LatLng(10.7449103, 106.7447776), weight: 4),
        WeightedLatLng(LatLng(10.7451681, 106.7446553), weight: 4),
        WeightedLatLng(LatLng(10.7452881, 106.7446006), weight: 2),
        WeightedLatLng(LatLng(10.7457601, 106.7444091), weight: 3),
        WeightedLatLng(LatLng(10.7459999, 106.7443236), weight: 4),
        WeightedLatLng(LatLng(10.746242, 106.744245), weight: 4),
        WeightedLatLng(LatLng(10.7464701, 106.7441954), weight: 3),
        WeightedLatLng(LatLng(10.7466999, 106.7441547), weight: 4),
        WeightedLatLng(LatLng(10.7471633, 106.7441003), weight: 3),
        WeightedLatLng(LatLng(10.7476196, 106.7440823), weight: 5),
        WeightedLatLng(LatLng(10.7480661, 106.7440984), weight: 4),
        WeightedLatLng(LatLng(10.7485103, 106.7441478), weight: 3),
        WeightedLatLng(LatLng(10.7489496, 106.7442302), weight: 3),
        WeightedLatLng(LatLng(10.7493188, 106.7443435), weight: 1),
        WeightedLatLng(LatLng(10.7500495, 106.7445938), weight: 3),
        WeightedLatLng(LatLng(10.7504108, 106.7447307), weight: 2),
        WeightedLatLng(LatLng(10.7511183, 106.7450249), weight: 5),
        WeightedLatLng(LatLng(10.751807, 106.745346), weight: 2),
        WeightedLatLng(LatLng(10.752482, 106.7456961), weight: 3),
        WeightedLatLng(LatLng(10.7532734, 106.7461688), weight: 3),
        WeightedLatLng(LatLng(10.7536636, 106.7464144), weight: 1),
        WeightedLatLng(LatLng(10.7544328, 106.7469237), weight: 5),
        WeightedLatLng(LatLng(10.7552165, 106.7474791), weight: 5),
        WeightedLatLng(LatLng(10.756012, 106.7480829), weight: 5),
        WeightedLatLng(LatLng(10.7567874, 106.7487132), weight: 1),
        WeightedLatLng(LatLng(10.7578669, 106.749644), weight: 1),
        WeightedLatLng(LatLng(10.7585893, 106.7502217), weight: 4),
        WeightedLatLng(LatLng(10.7589585, 106.7504998), weight: 1),
        WeightedLatLng(LatLng(10.7597127, 106.7510337), weight: 3),
        WeightedLatLng(LatLng(10.7604237, 106.7514979), weight: 4),
        WeightedLatLng(LatLng(10.7607852, 106.7517203), weight: 4),
        WeightedLatLng(LatLng(10.7609817, 106.7518314), weight: 5),
        WeightedLatLng(LatLng(10.7613851, 106.7520333), weight: 3),
        WeightedLatLng(LatLng(10.7617929, 106.7522047), weight: 2),
        WeightedLatLng(LatLng(10.7622029, 106.7523462), weight: 2),
        WeightedLatLng(LatLng(10.7626517, 106.7524697), weight: 3),
        WeightedLatLng(LatLng(10.7631376, 106.7525752), weight: 3),
        WeightedLatLng(LatLng(10.7636284, 106.7526537), weight: 1),
        WeightedLatLng(LatLng(10.7639233, 106.7526877), weight: 1),
        WeightedLatLng(LatLng(10.7642192, 106.7527119), weight: 5),
        WeightedLatLng(LatLng(10.7645157, 106.7527264), weight: 1),
        WeightedLatLng(LatLng(10.7648125, 106.7527312), weight: 3),
        WeightedLatLng(LatLng(10.7651092, 106.7527261), weight: 3),
        WeightedLatLng(LatLng(10.7656908, 106.7526561), weight: 5),
        WeightedLatLng(LatLng(10.7662674, 106.7525521), weight: 2),
        WeightedLatLng(LatLng(10.7668315, 106.7524159), weight: 1),
        WeightedLatLng(LatLng(10.7671076, 106.7523365), weight: 1),
        WeightedLatLng(LatLng(10.7673016, 106.7522715), weight: 4),
        WeightedLatLng(LatLng(10.7676528, 106.7521539), weight: 1),
        WeightedLatLng(LatLng(10.7679213, 106.7520509), weight: 1),
        WeightedLatLng(LatLng(10.7684425, 106.7518294), weight: 5),
        WeightedLatLng(LatLng(10.7689439, 106.7515854), weight: 3),
        WeightedLatLng(LatLng(10.7694306, 106.7513126), weight: 2),
        WeightedLatLng(LatLng(10.769885, 106.7510228), weight: 2),
        WeightedLatLng(LatLng(10.770106, 106.7508683), weight: 4),
        WeightedLatLng(LatLng(10.7705351, 106.7505411), weight: 5),
        WeightedLatLng(LatLng(10.7710634, 106.7500998), weight: 4),
        WeightedLatLng(LatLng(10.7716903, 106.7495452), weight: 5),
        WeightedLatLng(LatLng(10.7722975, 106.7489684), weight: 4),
        WeightedLatLng(LatLng(10.7729156, 106.7483365), weight: 2),
        WeightedLatLng(LatLng(10.7735101, 106.7476816), weight: 1),
      ]);

      return points;
    }(),
    radius: const HeatmapRadius.fromPixels(30),
    gradient: const HeatmapGradient(
      [
        HeatmapGradientColor(Colors.blue, 0.2),
        HeatmapGradientColor(Colors.green, 0.5),
        HeatmapGradientColor(Colors.yellow, 0.8),
        HeatmapGradientColor(Colors.red, 1.0),
      ],
    ),
  );

  // ─── Isolate JSON Parser (Static to run cleanly in Isolate) ───
  static List<PolygonConfig> _parsePolygonJsonBytes(Uint8List bytes) {
    final List<PolygonConfig> parsedList = [];
    final jsonString = utf8.decode(bytes);
    final decoded = json.decode(jsonString);
    if (decoded is Map<String, dynamic> && decoded['data'] != null) {
      final dataObj = decoded['data'];
      if (dataObj['data'] is List) {
        final list = dataObj['data'] as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final id = item['insideId']?.toString() ?? item['areaId']?.toString() ?? '';
            final latlngStr = item['latlng']?.toString() ?? '';
            final borderColor = item['borderColor']?.toString() ?? '';
            final bgColor = item['bgColor']?.toString() ?? '';

            // Parse coordinates string: "(lat,lng);(lat,lng);..."
            final List<LatLng> points = [];
            final parts = latlngStr.split(';');
            for (final part in parts) {
              if (part.trim().isEmpty) continue;
              final clean = part.replaceAll('(', '').replaceAll(')', '').trim();
              final coords = clean.split(',');
              if (coords.length == 2) {
                final lat = double.tryParse(coords[0].trim());
                final lng = double.tryParse(coords[1].trim());
                if (lat != null && lng != null) {
                  points.add(LatLng(lat, lng));
                }
              }
            }

            // Định dạng màu sắc đường viền
            Color strokeColor = const Color(0xFFEF4444);
            if (borderColor.isNotEmpty && borderColor.startsWith('#')) {
              final hex = borderColor.substring(1);
              final parsedColor = int.tryParse(hex, radix: 16);
              if (parsedColor != null) {
                strokeColor = Color(0xFF000000 | parsedColor);
              }
            }

            // Định dạng màu sắc nền (có độ mờ 20% - 0x33)
            Color fillColor = const Color(0x33EF4444);
            if (bgColor.isNotEmpty && bgColor.startsWith('#')) {
              final hex = bgColor.substring(1);
              final parsedColor = int.tryParse(hex, radix: 16);
              if (parsedColor != null) {
                fillColor = Color(0x33000000 | parsedColor);
              }
            }

            parsedList.add(PolygonConfig(
              id: 'hcm_polygon_$id',
              points: points,
              strokeColor: strokeColor,
              fillColor: fillColor,
              strokeWidth: 2,
            ));
          }
        }
      }
    }
    return parsedList;
  }

  // Hàm static để cô lập hoàn toàn Lexical Scope (không capture 'this' hay BuildContext)
  // giúp tránh được lỗi unsendable object khi truyền closure vào Isolate.
  static Future<List<PolygonConfig>> runParsing(Uint8List bytes) async {
    final isolateHandler = AppIsolateHandler();
    return await isolateHandler.parseJson<List<PolygonConfig>>(
      () => _parsePolygonJsonBytes(bytes),
    );
  }

  // Tải dữ liệu JSON & gọi Isolate để xử lý tính toán nặng bằng QueueEngine
  Future<void> _loadHcmPolygonsFromAsset() async {
    setState(() {
      _isLoadingPolygons = true;
    });

    final task = CallbackQueueTask(
      id: 'load_hcm_polygons',
      name: 'Nạp và phân tích địa giới HCM',
      maxRetries: 1,
      callback: () async {
        try {
          // 1. Đọc dữ liệu nhị phân thô (raw bytes) cực nhanh từ asset
          final byteData = await rootBundle.load('assets/json/boudery_hcm.json');
          final bytes = byteData.buffer.asUint8List();

          // 2. Chuyển tác vụ giải mã UTF-8, parse JSON vào Isolate hoàn toàn
          final configs = await _GoogleMapEngineDemoBodyState.runParsing(bytes);

          if (mounted) {
            final cubit = context.read<GoogleMapCubit>();

            // Xóa các polygons cũ trước khi nạp mới
            cubit.clearPolygons();

            setState(() {
              _loadedPolygonsCount = configs.length;
            });

            // 3. Tiến hành phân phối (batch rendering) polygon lên bản đồ theo từng đợt
            const int batchSize = 20; 
            for (int i = 0; i < configs.length; i += batchSize) {
              if (!mounted) break;

              final end = (i + batchSize < configs.length) ? i + batchSize : configs.length;
              final chunk = configs.sublist(i, end);

              // Thêm lô polygon hiện tại vào state để hiển thị
              cubit.addPolygons(chunk);

              // Chờ 30ms trước khi nạp tiếp để luồng giao diện có thể render mượt mà
              await Future.delayed(const Duration(milliseconds: 30));
            }

            if (mounted) {
              // Tự động zoom camera bao quát toàn bộ Polygon sau khi đã nạp xong
              cubit.zoomToFitAll();

              AppSnackbarEngine.showSuccess(
                context,
                message: 'Đã nạp mượt mà $_loadedPolygonsCount địa giới TP.HCM nhờ cơ chế Isolate + Batch Rendering!',
              );
            }
          }
        } catch (e) {
          if (mounted) {
            AppDialogEngine.showError(
              context,
              title: 'Lỗi nạp dữ liệu',
              message: e.toString(),
            );
          }
          rethrow;
        }
      },
    );

    _mapQueueEngine.enqueue(task);

    late StreamSubscription<List<QueueTask>> subscription;
    subscription = _mapQueueEngine.tasksStream.listen((tasks) {
      final t = tasks.where((element) => element.id == 'load_hcm_polygons');
      if (t.isEmpty) return;
      final currentTask = t.first;

      if (mounted) {
        setState(() {
          _isLoadingPolygons = currentTask.status == QueueTaskStatus.executing || 
                              currentTask.status == QueueTaskStatus.pending;
        });
      }

      if (currentTask.status == QueueTaskStatus.completed || 
          currentTask.status == QueueTaskStatus.failed ||
          currentTask.status == QueueTaskStatus.cancelled) {
        subscription.cancel();
      }
    });
  }

  // ─── Heatmap (Port WH Quick) – parse trong Isolate ───
  static List<WeightedLatLng> _parseHeatmapJsonBytes(Uint8List bytes) {
    final jsonString = utf8.decode(bytes);
    final decoded = json.decode(jsonString);
    final List<WeightedLatLng> out = [];
    if (decoded is Map<String, dynamic> && decoded['points'] is List) {
      final list = decoded['points'] as List;
      for (final p in list) {
        if (p is List && p.length >= 3) {
          final lat = (p[0] as num).toDouble();
          final lng = (p[1] as num).toDouble();
          final w = (p[2] as num).toDouble();
          out.add(WeightedLatLng(LatLng(lat, lng), weight: w));
        }
      }
    }
    return out;
  }

  static Future<List<WeightedLatLng>> _runParseHeatmap(Uint8List bytes) {
    final handler = AppIsolateHandler();
    return handler.parseJson<List<WeightedLatLng>>(
      () => _parseHeatmapJsonBytes(bytes),
    );
  }

  Future<void> _loadHeatmapFromAsset() async {
    setState(() => _isLoadingHeatmap = true);

    final task = CallbackQueueTask(
      id: 'load_heatmap',
      name: 'Nạp và phân tích dữ liệu Heatmap',
      maxRetries: 1,
      callback: () async {
        try {
          final byteData = await rootBundle.load('assets/json/heatmap_port_wh_quick.json');
          final bytes = byteData.buffer.asUint8List();
          final points = await _runParseHeatmap(bytes);

          if (!mounted) return;
          final cubit = context.read<GoogleMapCubit>();
          cubit.removeHeatmap('heatmap_port_wh_quick');
          cubit.addHeatmap(HeatmapConfig(
            id: 'heatmap_port_wh_quick',
            data: points,
            radius: const HeatmapRadius.fromPixels(25),
            gradient: const HeatmapGradient([
              HeatmapGradientColor(Colors.blue, 0.2),
              HeatmapGradientColor(Colors.green, 0.5),
              HeatmapGradientColor(Colors.yellow, 0.8),
              HeatmapGradientColor(Colors.red, 1.0),
            ]),
          ));

          setState(() => _loadedHeatmapPointsCount = points.length);
          cubit.zoomToFitAll();
          AppSnackbarEngine.showSuccess(
            context,
            message: 'Đã nạp $_loadedHeatmapPointsCount điểm heatmap (Isolate)!',
          );
        } catch (e) {
          if (mounted) {
            AppDialogEngine.showError(
              context,
              title: 'Lỗi nạp heatmap',
              message: e.toString(),
            );
          }
          rethrow;
        }
      },
    );

    _mapQueueEngine.enqueue(task);

    late StreamSubscription<List<QueueTask>> subscription;
    subscription = _mapQueueEngine.tasksStream.listen((tasks) {
      final t = tasks.where((element) => element.id == 'load_heatmap');
      if (t.isEmpty) return;
      final currentTask = t.first;

      if (mounted) {
        setState(() {
          _isLoadingHeatmap = currentTask.status == QueueTaskStatus.executing || 
                             currentTask.status == QueueTaskStatus.pending;
        });
      }

      if (currentTask.status == QueueTaskStatus.completed || 
          currentTask.status == QueueTaskStatus.failed ||
          currentTask.status == QueueTaskStatus.cancelled) {
        subscription.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GoogleMapCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Google Map Engine Demo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
        actions: [
          BlocBuilder<GoogleMapCubit, GoogleMapState>(
            buildWhen: (prev, cur) => prev.clusterEnabled != cur.clusterEnabled,
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.clusterEnabled ? Icons.bubble_chart : Icons.location_on,
                  color: state.clusterEnabled ? const Color(0xFF2563EB) : Colors.grey,
                ),
                tooltip: state.clusterEnabled ? 'Tắt Cluster' : 'Bật Cluster',
                onPressed: cubit.toggleCluster,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Google Map (Full Screen) ──────────────────────
          BlocBuilder<GoogleMapCubit, GoogleMapState>(
            builder: (context, state) {
              return GoogleMap(
                initialCameraPosition: GoogleMapEngineDemoScreen._initialPosition,
                markers: state.displayMarkers,
                polylines: state.polylines,
                polygons: state.polygons,
                heatmaps: state.heatmaps,
                mapType: state.mapType,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: cubit.onMapCreated,
                onCameraMove: cubit.onCameraMove,
              );
            },
          ),

          // ── Map Floating Overlay Controls ──────────────────
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. GPS Location Button
                _FloatingMapButton(
                  icon: Icons.my_location,
                  tooltip: 'Vị trí của tôi',
                  onTap: cubit.goToCurrentLocation,
                ),
                const SizedBox(height: 12),

                // 2. Toggle 3D Button
                BlocBuilder<GoogleMapCubit, GoogleMapState>(
                  buildWhen: (prev, cur) => prev.is3DMode != cur.is3DMode,
                  builder: (context, state) {
                    final is3D = state.is3DMode;
                    return _FloatingMapButton(
                      icon: is3D ? Icons.apartment : Icons.explore,
                      tooltip: is3D ? 'Chế độ 2D' : 'Chế độ 3D',
                      color: is3D ? const Color(0xFF2563EB) : Colors.white,
                      iconColor: is3D ? Colors.white : const Color(0xFF374151),
                      onTap: cubit.toggle3DMode,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 3. Map Type Selector Button
                _FloatingMapButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Loại bản đồ',
                  onTap: () {
                    AppBottomSheetEngine.showActionSheet(
                      context,
                      title: '🗺 Chọn loại bản đồ',
                      actions: [
                        AppBottomSheetActionItem(
                          label: 'Bản đồ thường (Normal)',
                          icon: Icons.map_outlined,
                          onTap: () => cubit.setMapType(MapType.normal),
                        ),
                        AppBottomSheetActionItem(
                          label: 'Bản đồ vệ tinh (Satellite)',
                          icon: Icons.satellite_outlined,
                          onTap: () => cubit.setMapType(MapType.satellite),
                        ),
                        AppBottomSheetActionItem(
                          label: 'Bản đồ lai ghép (Hybrid)',
                          icon: Icons.layers_outlined,
                          onTap: () => cubit.setMapType(MapType.hybrid),
                        ),
                        AppBottomSheetActionItem(
                          label: 'Bản đồ địa hình (Terrain)',
                          icon: Icons.terrain_outlined,
                          onTap: () => cubit.setMapType(MapType.terrain),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 4. Zoom to fit all data
                _FloatingMapButton(
                  icon: Icons.zoom_out_map,
                  tooltip: 'Bao quát toàn bộ dữ liệu',
                  onTap: cubit.zoomToFitAll,
                ),
                const SizedBox(height: 12),

                // 5. Open Bottom Sheet Control Panel
                _FloatingMapButton(
                  icon: Icons.tune,
                  tooltip: 'Bảng điều khiển công cụ',
                  color: const Color(0xFF10B981),
                  iconColor: Colors.white,
                  onTap: () {
                    AppBottomSheetEngine.showCustom(
                      context,
                      title: '🔧 Bảng điều khiển Google Map',
                      confirmText: 'Đóng lại',
                      contentWidget: _MapControlBottomSheet(
                        cubit: cubit,
                        onLoadHcm: _loadHcmPolygonsFromAsset,
                        onLoadHeatmap: _loadHeatmapFromAsset,
                        sampleMarkers: _sampleMarkers,
                        samplePolyline: _samplePolyline,
                        samplePolygon: _samplePolygon,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loading overlay when parsing polygons / heatmap using Isolate
          if (_isLoadingPolygons || _isLoadingHeatmap)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang parse JSON trong Isolate...',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Xử lý đa luồng qua Isolate (60 FPS)',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// Custom Circular Floating Button Overlay
// ════════════════════════════════════════════

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.iconColor = const Color(0xFF374151),
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tooltip ?? '',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Custom Bottom Sheet Content for Map controls
// ════════════════════════════════════════════

class _MapControlBottomSheet extends StatelessWidget {
  const _MapControlBottomSheet({
    required this.cubit,
    required this.onLoadHcm,
    required this.onLoadHeatmap,
    required this.sampleMarkers,
    required this.samplePolyline,
    required this.samplePolygon,
  });

  final GoogleMapCubit cubit;
  final VoidCallback onLoadHcm;
  final VoidCallback onLoadHeatmap;
  final List<MarkerConfig> sampleMarkers;
  final PolylineConfig samplePolyline;
  final PolygonConfig samplePolygon;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Marker CRUD
              const _SectionLabel(label: '📍 Markers (Auto Cluster bật sẵn)'),
              _ButtonRow(children: [
                _Btn(
                  label: 'Add 20 Markers',
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    cubit.addMarkers(sampleMarkers);
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Update [0]',
                  color: const Color(0xFF0D9488),
                  onTap: () {
                    cubit.updateMarker(
                      const MarkerConfig(
                        id: 'marker_0',
                        position: LatLng(10.7769, 106.7009),
                        title: '✏️ Đã cập nhật',
                        snippet: 'Position mới: HCM center',
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Remove [0]',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    cubit.removeMarker('marker_0');
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Clear All',
                  color: const Color(0xFF6B7280),
                  onTap: () {
                    cubit.clearMarkers();
                    Navigator.pop(context);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // Polyline CRUD
              const _SectionLabel(label: '🛣 Polyline'),
              _ButtonRow(children: [
                _Btn(
                  label: 'Add Route',
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    cubit.addPolyline(samplePolyline);
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Update',
                  color: const Color(0xFF0D9488),
                  onTap: () {
                    cubit.updatePolyline(
                      PolylineConfig(
                        id: 'route_demo',
                        color: const Color(0xFFF59E0B),
                        width: 8,
                        points: samplePolyline.points,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Remove',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    cubit.removePolyline('route_demo');
                    Navigator.pop(context);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // Polygon & Isolate HCM boundaries
              const _SectionLabel(label: '🔷 Polygon & HCM Boundaries (Isolate)'),
              _ButtonRow(children: [
                _Btn(
                  label: '⚡ Load HCM Polygons (Isolate)',
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.pop(context);
                    onLoadHcm();
                  },
                ),
                _Btn(
                  label: 'Add Sample Zone',
                  color: const Color(0xFF0D9488),
                  onTap: () {
                    cubit.addPolygon(samplePolygon);
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: 'Remove HCM Zones',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    cubit.clearPolygons();
                    Navigator.pop(context);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // Heatmap CRUD
              const _SectionLabel(label: '🔥 Heatmap'),
              _ButtonRow(children: [
                _Btn(
                  label: 'Add Heatmap',
                  color: const Color(0xFFEAB308),
                  onTap: () {
                    cubit.addHeatmap(_GoogleMapEngineDemoBodyState._sampleHeatmap);
                    Navigator.pop(context);
                  },
                ),
                _Btn(
                  label: '⚡ Load Port WH (API/Isolate)',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.pop(context);
                    onLoadHeatmap();
                  },
                ),
                _Btn(
                  label: 'Remove Heatmap',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    cubit.removeHeatmap('heatmap_demo');
                    Navigator.pop(context);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // State info
              BlocBuilder<GoogleMapCubit, GoogleMapState>(
                builder: (context, state) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Markers gốc: ${state.markers.length} | '
                      'Displayed: ${state.displayMarkers.length} | '
                      'Polylines: ${state.polylines.length} | '
                      'Polygons: ${state.polygons.length} | '
                      'Heatmaps: ${state.heatmaps.length} | '
                      'Cluster: ${state.clusterEnabled ? "ON" : "OFF"} | '
                      'Zoom: ${state.currentCameraPosition?.zoom.toStringAsFixed(1) ?? '-'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Helper Widgets
// ════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
