# Cách dùng: testing-tool-evaluator

Đánh giá package/công cụ mới trước khi thêm vào dự án Flutter.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-tool-evaluator`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Đánh giá thay `flutter_localization` bằng `easy_localization`: tương thích Dart ^3.8.1, mức bảo trì, chi phí migrate.

## Lưu ý riêng cho repo này

`testing-tool-evaluator.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Tiêu chí:** tương thích Dart ^3.8.1 và Flutter stable, hỗ trợ Android + iOS, bảo trì/pub points, license, kích thước, không trùng chức năng package có sẵn (`pubspec.yaml`), ảnh hưởng 3 flavor.
- Chỉ đề xuất; không tự sửa `pubspec.yaml`/`pubspec.lock`.

## Nguồn chuẩn

Định nghĩa agent: [testing-tool-evaluator.md](../../agents/testing-tool-evaluator.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
