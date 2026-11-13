# Cách dùng: testing-evidence-collector

Thu bằng chứng tái hiện lỗi từ simulator/máy thật (screenshot, log), che PII, ghi rõ phần chưa kiểm.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-evidence-collector`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Thu bằng chứng cho lỗi thẻ hợp đồng hết hạn không hiện nút chi tiết trên iOS Simulator.

## Lưu ý riêng cho repo này

`testing-evidence-collector.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Công cụ:** `xcrun simctl io booted screenshot`, `adb exec-out screencap -p`, Maestro (`takeScreenshot`), `flutter logs`. Lưu ảnh đã che PII vào `qc-r1/` hoặc `docs/prd-v1.0/.../evidence/`.

## Nguồn chuẩn

Định nghĩa agent: [testing-evidence-collector.md](../../agents/testing-evidence-collector.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
