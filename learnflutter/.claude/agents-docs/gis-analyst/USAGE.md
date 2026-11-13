# Cách dùng: gis-analyst

Vận hành GIS hằng ngày: làm bản đồ, kiểm CRS, truy vấn không gian, QC dữ liệu.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: gis-analyst`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Kiểm `location_address_catalog.csv`: CRS/toạ độ lat-lng hợp lệ, trùng lặp, thiếu địa chỉ; đề xuất cách phân lớp hiển thị.

## Lưu ý riêng cho repo này

Agent port nguyên bản (tiếng Anh) từ [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents/tree/main/gis), chưa chỉnh theo repo. Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/`, chạy bằng `fvm flutter`. Bản đồ: `google_maps_flutter`, `flutter_map` (+ `flutter_map_mbtiles`), `geolocator`.
- **Code bản đồ:** `lib/core/engines/engine_google_map/` (engine dùng chung), `lib/features/map/` (các demo: `google_map_base`, `google_map_custom_markers`, `google_map_offline`, `flutter_map_osm`).
- **Repo này:** Dữ liệu điểm thực tế của repo: `location_address_catalog.csv`, `tan_thuan_points.txt`, các script `extract_*.py` / `fetch_lat_lng.py` / `inject_points.py` ở root `learnflutter/`.
- **Không đưa vào báo cáo:** API key (Google Maps…), token, toạ độ/địa chỉ cá nhân thật.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- Agent nhiều công cụ gốc là Esri/ArcGIS; nếu máy không có, nêu rõ và đề xuất phương án mã nguồn mở thay vì giả định.

## Nguồn chuẩn

Định nghĩa agent: [gis-analyst.md](../../agents/gis-analyst.md). Đọc `CLAUDE.md` của repo trước khi làm; trả lời bằng tiếng Việt.
