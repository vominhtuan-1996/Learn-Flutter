# Cách dùng: testing-test-automation-engineer

Viết và sửa test tự động: Maestro flow cho E2E, `flutter_test` + `bloc_test` + `mocktail` cho Cubit/Repository/widget.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-test-automation-engineer`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Viết test Cubit cho `AlertCubit` các nhánh trang đầu, trang kế, hết dữ liệu, lỗi (mẫu `test/features/device/cubit/alert_cubit_test.dart`).

## Lưu ý riêng cho repo này

Phần mô tả và phần thân của `testing-test-automation-engineer.md` đã viết lại cho Flutter LearnFlutter (Maestro + `flutter_test`/`bloc_test`/`mocktail`). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Không dùng Playwright/Cypress** cho app. Theo `.claude/rules/rule_testing.md`; Cubit nhận repo qua `Cubit.withRepo(...)`; `ApiClient.setInstanceForTesting` **chưa có** — tách logic thành `@visibleForTesting static` khi cần. Harness: `test/support/test_harness.dart`.
- Maestro: dùng skill `maestro` / `testcase-maestro-flow`; selector bằng `id:` (Semantics identifier) hoặc text.

## Nguồn chuẩn

Định nghĩa agent: [testing-test-automation-engineer.md](../../agents/testing-test-automation-engineer.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
