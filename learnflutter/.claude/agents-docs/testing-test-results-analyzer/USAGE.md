# Cách dùng: testing-test-results-analyzer

Phân tích kết quả test: `flutter test`, coverage, Maestro, báo cáo testcase QC; chỉ ra xu hướng và rủi ro.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-test-results-analyzer`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Phân tích `flutter test --coverage` và liệt kê Cubit/Repository chưa có test.

## Lưu ý riêng cho repo này

`testing-test-results-analyzer.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- Coverage: `flutter test --coverage` rồi `genhtml coverage/lcov.info`. Testcase QC ở `docs/prd-v1.0/testcase/`; báo cáo gap `docs/qc/`; dùng skill `testcase-prd-compare`, `testcase-codebase-compare` cho đối chiếu.

## Nguồn chuẩn

Định nghĩa agent: [testing-test-results-analyzer.md](../../agents/testing-test-results-analyzer.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
