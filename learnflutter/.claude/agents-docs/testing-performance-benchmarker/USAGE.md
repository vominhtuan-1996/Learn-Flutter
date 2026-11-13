# Cách dùng: testing-performance-benchmarker

Đo hiệu năng app Flutter: frame build/raster, jank, bộ nhớ, thời gian khởi động, độ trễ API.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-performance-benchmarker`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Đo jank khi cuộn danh sách hợp đồng bằng Flutter DevTools (profile mode) và đề xuất sửa kèm số liệu.

## Lưu ý riêng cho repo này

`testing-performance-benchmarker.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Phải đo ở `--profile`**, không phải debug. Dùng DevTools (Performance, Memory), `flutter run --profile --flavor dev -t lib/main_dev.dart`. Ghi thiết bị và build đã đo.

## Nguồn chuẩn

Định nghĩa agent: [testing-performance-benchmarker.md](../../agents/testing-performance-benchmarker.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
