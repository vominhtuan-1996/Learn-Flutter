---
name: summary-artifact
description: Tạo Artifact (trang dashboard có biểu đồ) từ một file summary bug do user chỉ định (vd qc-r1/SUMMARY-*.md) — dùng khi user nói "tạo artifact/antifac cho summary", "dựng dashboard từ file summary", "làm trang biểu đồ bug R1", "cập nhật artifact theo summary mới"
triggers:
  - tạo artifact summary
  - tạo antifac cho summary
  - dashboard từ file summary
  - biểu đồ bug R1
  - cập nhật artifact summary
---

# Summary → Artifact

Đọc **một file summary Markdown do user chỉ định**, rồi dựng Artifact dạng dashboard: 5 ô số liệu theo trạng thái, 4 biểu đồ thanh (trạng thái, người xử lý, module, ưu tiên) và bảng bug có ô tìm kiếm + nút "Chỉ To Do". Mọi con số trên trang đều lấy từ dữ liệu của file, không gõ tay.

File mẫu: `qc-r1/SUMMARY-bug-chua-done-*.md`, `qc-r1/SUMMARY-R1-tong-hop-*.md`.

## Đầu vào

- **File summary** (bắt buộc, do user nêu). Không nêu → liệt kê `qc-*/SUMMARY*.md` bằng `ls` rồi hỏi chọn (dùng `AskUserQuestion`). **Không tự chọn.**
- Tên dashboard (tuỳ chọn): 2-4 từ. Không nêu → dùng tiêu đề `# ...` của file, rút còn 2-4 từ.
- URL artifact có sẵn (tuỳ chọn): user nói "cập nhật artifact <url>" → chế độ cập nhật (bước 7); không thì tạo mới.

## File cần có trong skill

- `scripts/parse_summary.py` — đọc bảng Markdown, ra `rows.json` (mỗi bug một dòng).
- `scripts/build_docs.py` — dựng 3 tài liệu JSON cho store của artifact.
- `assets/dashboard_page.html` — trang dashboard (template, có biểu đồ).

## Quy trình

### 1. Đọc file summary

```bash
SK="$(git rev-parse --show-toplevel)/.claude/skills/summary-artifact"
W="$(mktemp -d)"     # thư mục tạm, hoặc scratchpad của phiên
python3 -I "$SK/scripts/parse_summary.py" "<summary.md>" -o "$W/rows.json"
```

Script in ra stderr: số bug đọc được, trường nào thiếu, số bug theo trạng thái. Xử lý:

- **Không có dòng nào** (script thoát lỗi): file chỉ có bảng tổng hợp, không liệt kê từng bug. Dừng, báo user thêm bảng `| Key | Status | Assignee | Module | Priority | Summary |` hoặc chạy skill `jira-bug-summary` để có file đủ dòng. **Không tự bịa dòng.**
- **Cảnh báo "file khai báo tổng N bug nhưng chỉ đọc được M"**: báo user con số lệch trước khi tiếp tục; hỏi có dựng với M dòng không.
- **Thiếu cột** (vd `priority`): vẫn dựng được, thẻ biểu đồ tương ứng tự ẩn; nói rõ cho user trang sẽ thiếu phần nào.
- Đọc nhanh `rows.json` (vài dòng đầu) để chắc trạng thái và người xử lý đúng.

### 2. Tạo Artifact mới theo quy trình của công cụ

1. `Artifact` với `action: "quickstart"`, `intent: "other"`, `design_systems: false`. Kết quả chỉ ra `type_url` của loại **Dashboard**; **dùng đúng URL trong kết quả**, không dán cứng từ skill này.
2. `Artifact` với `type_url`, `title`, **không** `file_path`/`files`, `auto_open: "after_first_write"`. Ghi lại URL artifact trả về.
3. Nạp `ArtifactData` bằng `ToolSearch` (`select:ArtifactData`) nếu chưa có.

### 3. Đọc hướng dẫn của loại Dashboard (một lần)

Kết quả bước 2 kèm hướng dẫn của loại. Nếu nó có yêu cầu mới (đổi tên tài liệu, đổi cách đánh dấu số liệu) mà template không đáp ứng, **làm theo hướng dẫn của loại** và sửa template cho khớp. Chỉ đọc thêm `artifact-type/reference/*.md` khi cần (Artifact `read` với `path`).

### 4. Tải `rows.json` lên artifact

`Artifact` với `url` = URL artifact, `file_path` = `$W/rows.json`, `asset: true`. Kết quả có `url` dạng `/_blob/<32 hex>`. **Dùng nguyên văn.**

### 5. Dựng tài liệu và ghi vào artifact

```bash
python3 -I "$SK/scripts/build_docs.py" --rows "$W/rows.json" --out "$W" \
  --title "<tên dashboard>" --blob-url "/_blob/<id>" \
  --source-note "Nguồn: <tên file summary>, tạo ngày <dd/mm/yyyy>. Bản chụp cố định, chưa tự cập nhật." \
  [--subtitle "<một câu, không chứa con số>"]
```

Rồi **một** lệnh `ArtifactData` `action: "batch"` (3 ghi, mỗi ghi dùng `file_path`):

| `collection` | `doc_id` | `file_path` |
|---|---|---|
| `dash` | `meta` | `$W/meta_doc.json` |
| `datasets` | `bugs` | `$W/ds_doc.json` |
| `files` | `index.html` | `$W/index_doc.json` |

Quy tắc:
- Phụ đề (`--subtitle`) chỉ là lời, **không có con số**: mọi con số trên trang phải đến từ dataset.
- Dataset phải tên đúng `bugs` (template đọc `bugs`).
- Không ghi token, mật khẩu, email vào dữ liệu hay trang.

### 6. Kiểm tra (không làm nhiều hơn)

- `ArtifactData` `get` collection `data/users/me`, doc `check`. Chưa có thì đọc lại **một lần nữa**, tối đa 2 lần. Không thấy gì thì ghi rõ "chưa xác nhận được kết quả kiểm tra".
- `failed` và có lỗi do mã của trang → sửa đúng chỗ đó, ghi lại, kiểm tra lại, **tối đa 2 lần sửa**.
- **Không** mở trang, chụp màn hình hay cài thêm công cụ để xem; chỉ khi user yêu cầu. **Không nói trang chạy đúng** chỉ vì không có lỗi.

### 7. Cập nhật artifact đã có

Khi user cho URL artifact: bỏ bước 2.1-2.2. Chạy bước 1, rồi bước 4 (upload `rows.json` mới), bước 5 nhưng:
- `ArtifactData` `get` hai tài liệu `datasets/bugs` và `files/index.html` để lấy `version`.
- `batch` với `op: "set"` và `if_version` cho từng tài liệu đã có (giữ `dash/meta` nếu không đổi tên).
- Xoá tài liệu asset cũ chỉ khi user yêu cầu (`Artifact` `action: "delete"` với `url` + `path`).

### 8. Báo cho user

Một đoạn ngắn, bằng lời của user (không nói "store", "document", "dataset"):
- Link artifact, và nó đang **riêng tư**: người khác chỉ mở được sau khi user chia sẻ từ menu Share (skill không đổi được việc chia sẻ).
- Trang có gì: 5 ô số liệu, các biểu đồ nào hiển thị / bị ẩn vì thiếu cột, bảng có tìm kiếm.
- Là **bản chụp cố định** từ file summary; muốn mới thì chạy lại skill (hoặc `jira-bug-summary` trước, rồi skill này).
- Kiểm tra tự động: đã xác nhận được hay chưa.
- Gợi ý ngắn: có thể nhờ thêm biểu đồ hoặc bộ lọc cụ thể.

## Điều không làm

- Không tự chọn file summary, không đoán tên module, không bịa dòng bug khi file thiếu.
- Không commit, không push; artifact là sản phẩm riêng, file tạm nằm ở `$W`.
- Không đưa dữ liệu ngoài file summary vào trang (kể cả số liệu từ Jira) trừ khi user yêu cầu và ghi rõ nguồn.
- Không gọi `Artifact` `delete` nếu user chưa yêu cầu rõ.

## Định dạng file summary được hỗ trợ

Parser chỉ cần bảng Markdown có cột mã bug (`OMB-123`). Tên cột được nhận (không phân biệt hoa thường):

| Trường | Tên cột |
|---|---|
| Mã bug (bắt buộc) | `Key`, `Mã`, `Ticket`, `Issue` |
| Tóm tắt | `Summary`, `Tóm tắt`, `Mô tả` |
| Trạng thái | `Status`, `Trạng thái` (không có cột thì lấy từ tiêu đề gần nhất `## To Do (n)`, `## In review (n)`...) |
| Người xử lý | `Assignee`, `Người xử lý` |
| Module | `Flow (TC)`, `Flow`, `Module` (không có thì lấy từ tiền tố `[TC_03 - ...]` của tóm tắt) |
| Ưu tiên | `Priority`, `Ưu tiên` |

Cùng một mã nằm ở nhiều bảng thì được gộp (mỗi trường lấy giá trị không rỗng đầu tiên). Bảng không có cột mã bug (bảng tổng hợp theo người, theo module) bị bỏ qua; số liệu đó sẽ được tính lại từ các dòng bug.
