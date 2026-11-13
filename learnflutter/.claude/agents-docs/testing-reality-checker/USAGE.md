# Cách dùng: testing-reality-checker

Cổng duyệt cuối: mặc định "NEEDS WORK", chỉ cho qua khi có bằng chứng đã chạy thật.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-reality-checker`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Xác nhận FR03 sẵn sàng release v1.0.0+14: có analyze, test, Maestro run và bằng chứng không?

## Lưu ý riêng cho repo này

`testing-reality-checker.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Điều kiện tối thiểu:** `dart analyze lib test` sạch, `flutter test --no-pub` pass, flow Maestro của FR đã chạy (`testcase-run-report`), gap PRD đã rà (`prd-gap-review`).
- Không duyệt dựa trên mô tả hoặc ảnh cũ.

## Nguồn chuẩn

Định nghĩa agent: [testing-reality-checker.md](../../agents/testing-reality-checker.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
