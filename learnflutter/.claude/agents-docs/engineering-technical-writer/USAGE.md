# Cách dùng: engineering-technical-writer

Viết và rà tài liệu kỹ thuật: README, hướng dẫn build/release, tài liệu API nội bộ, hướng dẫn tích hợp, migration.

## Gọi agent

Trong Claude Code, nhờ Claude gọi agent "Technical Writer" (file `engineering-technical-writer.md`; frontmatter `name: Technical Writer`, khác các agent `testing-*` dùng tên dạng slug), hoặc chỉ định `subagent_type` theo tên hiển thị trong danh sách agent của session.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Cập nhật `learnflutter/docs/api-call-map.md` theo các service mới trong `lib/services/`, liệt kê endpoint đã đổi kèm đường dẫn file.

> Viết hướng dẫn build và upload bản staging/prod dựa trên `fastlane/`, `scripts/upload-app-package.mjs`, `build_ci_cd/` (không ghi secret).

> Rà `docs/splash-auth-flow.md` xem còn khớp code `features/splash` và `core/services/auth` không.

## Phù hợp / không phù hợp

- **Phù hợp:** README, hướng dẫn build/release, tài liệu API, tutorial, migration, rà tài liệu cũ.
- **Không dùng cho:** sửa code app, tạo task/breakdown theo PRD (`prd-breakdown`, `task-writer`), đối chiếu PRD với code (`prd-gap-review`).

## Lưu ý riêng cho repo này

`engineering-technical-writer.md` đã viết lại cho LearnFlutter (Markdown trong `learnflutter/docs/` và KB, tiếng Việt, kiểm chứng ví dụ). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Ngôn ngữ:** viết tiếng Việt (code, tên file, thuật ngữ kỹ thuật giữ tiếng Anh).
- **Không dựng hạ tầng docs mới** (Docusaurus, MkDocs, Vale) nếu không được yêu cầu: tài liệu là Markdown trong `learnflutter/docs/`, `docs/prd-v1.0/`.
- **Ví dụ code phải kiểm chứng được:** chạy `dart analyze lib test`; không ghi số liệu/kết quả chưa chạy thật.
- **Nguồn chuẩn:** API ở tài liệu API của dự án, `docs/api-call-map.md`; release ở `docs/android_ios_identifiers_and_signing.md`, `docs/store_release_policy_*.md`; hệ thống ở KB KB dự án (nếu có).

## Nguồn chuẩn

Định nghĩa agent: [engineering-technical-writer.md](../../agents/engineering-technical-writer.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
