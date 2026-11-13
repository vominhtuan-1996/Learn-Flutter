# Cách dùng: testing-accessibility-auditor

Kiểm khả năng truy cập của UI Flutter: `Semantics`, touch target, contrast, cỡ chữ lớn, dark/light.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-accessibility-auditor`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Audit màn Đăng nhập: nhãn Semantics, thứ tự focus, touch target ≥ 48dp, contrast ở cả light và dark.

## Lưu ý riêng cho repo này

`testing-accessibility-auditor.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Phạm vi:** Flutter (`Semantics`, `tooltip`, `textScaler`), không phải WCAG web. Contrast so với bảng `ColorScheme` trong `rule_convention.md` (mục Dark / Light Mode).
- Nhãn Semantics đồng thời là anchor Maestro: `label` và `identifier` cùng giá trị.

## Nguồn chuẩn

Định nghĩa agent: [testing-accessibility-auditor.md](../../agents/testing-accessibility-auditor.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
