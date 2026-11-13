# Cách dùng: testing-api-tester

Kiểm API backend LearnFlutter (`/onmember/v2/*` và các service port từ web) bằng curl + token, đối chiếu tài liệu API.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-api-tester`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Test các endpoint trong `lib/services/<service_group>/` ở môi trường staging với token của tôi, so với tài liệu API của dự án.

## Lưu ý riêng cho repo này

`testing-api-tester.md` đã viết lại cho LearnFlutter (gateway `/api/v1`, nhóm `/onmember/v2/*`, quy tắc cho API ghi dữ liệu). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Base URL:** theo flavor trong `AppConfig` (`core/config/app_flavor.dart`); chỉ HTTPS. Token do user cung cấp, không ghi vào file/báo cáo.
- Ghi lệch spec ↔ thực tế vào báo cáo; không sửa spec BE. Lỗi map qua `ApiException`.

## Nguồn chuẩn

Định nghĩa agent: [testing-api-tester.md](../../agents/testing-api-tester.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
