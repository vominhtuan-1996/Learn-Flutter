# Cách dùng: gis-drone-reality-mapping

Xử lý ảnh drone thành orthomosaic, DTM, point cloud, mesh.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: gis-drone-reality-mapping`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Chuẩn bị quy trình xuất orthomosaic thành `.mbtiles` để `flutter_map_mbtiles` dùng offline.

## Lưu ý riêng cho repo này

Agent port nguyên bản (tiếng Anh) từ [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents/tree/main/gis), chưa chỉnh theo repo. Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/`, chạy bằng `fvm flutter`. Bản đồ: `google_maps_flutter`, `flutter_map` (+ `flutter_map_mbtiles`), `geolocator`.
- **Code bản đồ:** `lib/core/engines/engine_google_map/` (engine dùng chung), `lib/features/map/` (các demo: `google_map_base`, `google_map_custom_markers`, `google_map_offline`, `flutter_map_osm`).
- **Repo này:** Dự án không có pipeline drone/photogrammetry; chỉ liên quan khi cần tile offline (`lib/features/map/offline`, `google_map_offline`).
- **Không đưa vào báo cáo:** API key (Google Maps…), token, toạ độ/địa chỉ cá nhân thật.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- Agent nhiều công cụ gốc là Esri/ArcGIS; nếu máy không có, nêu rõ và đề xuất phương án mã nguồn mở thay vì giả định.

## Nguồn chuẩn

Định nghĩa agent: [gis-drone-reality-mapping.md](../../agents/gis-drone-reality-mapping.md). Đọc `CLAUDE.md` của repo trước khi làm; trả lời bằng tiếng Việt.
