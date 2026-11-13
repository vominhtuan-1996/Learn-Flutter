# Cách dùng: gis-3d-scene-developer

Dựng cảnh 3D trên web: terrain, point cloud, Cesium/ArcGIS Scene Viewer.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: gis-3d-scene-developer`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Dựng viewer 3D (Cesium/WebGL) nhúng vào `lib/features/web_view` để xem mô hình terrain từ file GeoJSON/3D Tiles.

## Lưu ý riêng cho repo này

Agent port nguyên bản (tiếng Anh) từ [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents/tree/main/gis), chưa chỉnh theo repo. Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/`, chạy bằng `fvm flutter`. Bản đồ: `google_maps_flutter`, `flutter_map` (+ `flutter_map_mbtiles`), `geolocator`.
- **Code bản đồ:** `lib/core/engines/engine_google_map/` (engine dùng chung), `lib/features/map/` (các demo: `google_map_base`, `google_map_custom_markers`, `google_map_offline`, `flutter_map_osm`).
- **Repo này:** App chỉ có `flutter_3d`, `photo_3d`, `web_view` — không có Cesium native. Chỉ dùng agent khi nhúng viewer web vào `webview_flutter`.
- **Không đưa vào báo cáo:** API key (Google Maps…), token, toạ độ/địa chỉ cá nhân thật.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- Agent nhiều công cụ gốc là Esri/ArcGIS; nếu máy không có, nêu rõ và đề xuất phương án mã nguồn mở thay vì giả định.

## Nguồn chuẩn

Định nghĩa agent: [gis-3d-scene-developer.md](../../agents/gis-3d-scene-developer.md). Đọc `CLAUDE.md` của repo trước khi làm; trả lời bằng tiếng Việt.
