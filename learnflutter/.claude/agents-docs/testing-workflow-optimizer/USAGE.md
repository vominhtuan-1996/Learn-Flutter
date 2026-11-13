# Cách dùng: testing-workflow-optimizer

Rà và tối ưu quy trình dev/QC của repo: hooks, skill, build/release, quy trình testcase → Maestro → báo cáo.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: testing-workflow-optimizer`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Rà chuỗi skill testcase (parse → compare → maestro-flow → run-report) và chỉ ra bước thừa hoặc thiếu.

## Lưu ý riêng cho repo này

`testing-workflow-optimizer.md` đã viết lại hoàn toàn cho Flutter LearnFlutter (cả `description` lẫn phần thân). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Đối tượng:** `.claude/hooks/quality_gate.py`, `isc_commit_gate.py`, `.claude/skills/`, `fastlane/`, `build_ci_cd/`. Đề xuất thay đổi, không tự sửa hook/CI.

## Nguồn chuẩn

Định nghĩa agent: [testing-workflow-optimizer.md](../../agents/testing-workflow-optimizer.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
