---
name: task-writer
description: Soạn task (Mô tả + Công việc, kèm ước lượng ngày nếu có) từ yêu cầu của user hoặc từ code/PRD đã có, xuất ra file .md lưu trong task/task_vX.Y.Z/. Trigger — "tạo task", "viết task", "log task", "breakdown task", "/task-writer <mô tả yêu cầu hoặc version>".
---

# Task Writer

Soạn task theo đúng format đang dùng trong dự án (xem ví dụ ở mục "Format chuẩn"), lưu vào `task/task_v{version}/`.

## Input

- Mô tả bằng lời của user về việc cần làm (VD "tạo giúp tôi 2 task, 1 task 3d và 1 task 2d cho X"), hoặc
- 1 phạm vi code/feature cần backfill task (VD "init core đến build màn hình"), hoặc
- 1 FR/gap-report đã có (tham chiếu skill `prd-gap-review`) muốn chuyển thành task.

## Quy trình

1. **Xác định phạm vi + số lượng task.** Nếu user cho effort/thời lượng cụ thể (VD "1 task 3d") → giữ nguyên số đó trong tiêu đề task, không tự đoán lại. Nếu user chỉ đưa phạm vi chung (VD "init core đến build màn hình") → tự chia nhỏ theo ranh giới hợp lý (1 module hạ tầng = 1 task, 1 FR/feature = 1 task), **không ước lượng effort nếu user không yêu cầu** — chỉ thêm số ngày khi được hỏi hoặc user tự cho input.

2. **Với mỗi task, đọc thật code/tài liệu liên quan** trước khi viết — liệt kê đúng tên file/class thật (`grep`/`ls` xác nhận tồn tại), KHÔNG bịa tên file hoặc mô tả chung chung kiểu "làm màn hình X" mà không nêu được file nào.

3. **Viết từng task theo format chuẩn** (xem dưới) — Tiếng Việt, ngắn gọn, mỗi task có Mô tả (1 câu) + Công việc (bullet list cụ thể, tham chiếu file/class thật).

4. **Xuất file** `task/task_v{version}/{NN}-{slug-mo-ta}.md`:
   - `{version}` lấy theo version app hiện tại (`pubspec.yaml` → `version: x.y.z`) trừ khi user chỉ định version khác.
   - `{NN}` là số thứ tự file trong folder (đếm file `.md` đã có + 1), `{slug-mo-ta}` là slug ngắn không dấu mô tả nhóm task trong file đó.
   - Nếu folder `task/task_v{version}/` chưa tồn tại → tạo mới.
   - Nhiều nhóm task khác chủ đề trong cùng 1 lần yêu cầu → có thể tách thành nhiều file `.md` riêng (như đã làm với "init core & màn hình" tách khỏi "apphub upload & fix release"), miễn mỗi file gom đúng 1 chủ đề.

5. Sau khi lưu, báo cho user đường dẫn file đã tạo + số lượng task trong mỗi file.

## Format chuẩn

Mỗi file `.md` bắt đầu bằng heading H1 tên nhóm task (+ 1 dòng ghi chú ngữ cảnh nếu cần, in nghiêng dạng `> ...`), theo sau là các task, mỗi task 1 heading H2:

```markdown
# Task v{version} — {Tên nhóm task}

> {Ghi chú ngữ cảnh nếu cần, VD: "Backfill log task cho phần code đã implement"}

## Task {n}{ (Xd) nếu có effort} — {Tên task ngắn gọn}

Mô tả: {1 câu mô tả task làm gì, cho ai/để làm gì}.

Công việc:
- {việc cụ thể 1, nêu file/class/API thật nếu có}
- {việc cụ thể 2}
- ...
```

Quy tắc:
- Tên task ngắn gọn, đúng nghiệp vụ (không mô tả kỹ thuật thuần khi task có góc nhìn nghiệp vụ, VD "Màn hình Quản lý thiết bị (FR03)" tốt hơn "device_list_page.dart").
- Bullet "Công việc" là hành động cụ thể có thể check off được, không viết chung chung ("cải thiện code", "fix bug" mà không nói fix gì).
- Nếu 1 task cần effort estimate mà user không cho — để trống, không tự bịa số ngày.
- Không tự thêm mục Acceptance Criteria/Definition of Done trừ khi user yêu cầu — giữ đúng 2 phần Mô tả + Công việc như format đang dùng.

## Nguyên tắc

- KHÔNG bịa task không có cơ sở (không có code, không có yêu cầu từ user) — mọi task phải truy vết được về 1 đoạn hội thoại, 1 đoạn code, hoặc 1 FR cụ thể.
- Không tự ý log task lên hệ thống ngoài (GitLab Issues, Jira...) trừ khi user xác nhận muốn vậy — mặc định chỉ xuất file `.md` local.
- Nếu phạm vi quá lớn (nhiều feature không liên quan), hỏi lại user có muốn tách theo feature/module trước khi viết, thay vì gộp hết vào 1 file dài.
