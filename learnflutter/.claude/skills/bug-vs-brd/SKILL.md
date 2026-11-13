---
name: bug-vs-brd
description: Use when the user gives a Jira bug ID (FE-xxx) and wants ALL comments and attached QC screenshots/video scanned via the Atlassian MCP (not just the last comment) and the behavior compared first against the PRD the user specifies (ask the user if no PRD is given or found), and any supporting doc the user names, to conclude whether it is a real defect, a specification mismatch, or already resolved by a decided comment
---

# Bug vs BRD

Đọc 1 bug Jira theo ID qua **MCP Atlassian** (không phải CSV export), hiểu bug qua Description +
Comment (Comment thường chứa quyết định mới nhất của PM/BA, override cả Description), đối chiếu
hành vi Expected/Actual với BRD/PRD thật, rồi kết luận: đúng là bug theo BRD / không phải bug (BRD
chưa có rule hoặc app đúng theo BRD) / đã có quyết định khác trong comment (BRD cũ, comment mới hơn)
— kèm trích dẫn cụ thể.

## Bước 0 — Verify Jira đã connect

```
mcp__atlassian__atlassianUserInfo (không tham số)
```

Chưa auth → gọi `mcp__atlassian__authenticate`, đưa user URL, đợi xác nhận xong mới query tiếp.
`cloudId` dùng `foxproject.atlassian.net` (site hostname, không cần tra UUID qua
`getAccessibleAtlassianResources` trừ khi hostname lỗi).

## Bước 0.5 — Chốt folder lưu notes/evidence

`<folder>` là folder do **user nêu** (vd `qc-r1`). Không có folder mặc định hardcode.

- User chưa nêu folder → hỏi (dùng `AskUserQuestion`; có thể gợi ý các folder `*-qc-*` đã có ở root repo
  làm lựa chọn, cho user nhập tên khác). Dùng đúng tên user trả lời, tạo folder nếu chưa có.
- User không trả lời → dùng key ticket Jira (vd `OMB-276`) làm tên folder, báo lại user.
- Cùng phiên, các bug tiếp theo dùng lại folder này, trừ khi user đổi.

## Bước 1 — Lấy issue qua MCP (BẮT BUỘC lấy đủ comment + attachment)

```
mcp__atlassian__getJiraIssue
  cloudId: foxproject.atlassian.net
  issueIdOrKey: FE-XXX
  fields: ["summary", "description", "status", "priority", "comment", "attachment"]
  responseContentFormat: markdown
```

Response trả `fields.comment.comments[]` (đủ toàn bộ comment, sort theo `created` tăng dần — không
bị giới hạn/mất comment như lỗi CSV cũ) và `fields.attachment[]` (đủ toàn bộ file đính kèm, mỗi
phần tử có `filename`, `content` = URL tải, `mimeType`, `created`). Không cần script parse riêng —
đọc thẳng JSON trả về.

**Ngay sau khi lấy được issue**, tạo `<folder>/assets/<ISSUE-KEY>/notes.txt` (`<folder>` xem Bước 0.5; giữ nguyên
format cũ từ thời CSV — future session/agent nào mở lại ticket đọc file này trước, khỏi gọi lại MCP):

```
# <ISSUE-KEY>: <summary>
Status: <status> | Priority: <priority>

## Description
<description, giữ nguyên markdown/text gốc>

## Comments (<n>)
<mỗi comment: [created] author: body, cách nhau 1 dòng trống — rỗng thì ghi "(0)">

## Attachments (<n>)
- [<created, format DD/Mon/YY HH:MM AM/PM>] <filename> — <content URL>
```

Tạo thư mục `<folder>/assets/<ISSUE-KEY>/` nếu chưa có trước khi ghi file.

Không tìm thấy issue (404/lỗi) → báo user, không suy đoán/đổi ID.

## Bước 2 — Đọc Comment kỹ, ưu tiên hơn Description

Đọc **toàn bộ** `comments[]` theo thứ tự thời gian (không chỉ đọc comment cuối) — comment kỹ thuật
rỗng ("." hoặc do QC thử API) thường bị lẫn giữa các comment thật, bỏ qua nhưng đừng dừng đọc giữa
chừng. Comment là nơi PM/BA chốt lại — có thể đảo ngược Expected trong Description (vd BA nói "bỏ
tính năng này" thì Description cũ coi như lỗi thời). Nếu Comment mâu thuẫn Description, **Comment
thắng**, và kết luận phải nêu rõ vì sao (trích câu comment). Nếu nhiều comment cùng chủ đề nối tiếp
nhau (retest round 1, round 2...) — **comment mới nhất (`created` lớn nhất) thắng**, nhưng đọc cả
chuỗi để hiểu bug đã qua những vòng sửa nào, tránh kết luận dựa trên round cũ đã lỗi thời.

Comment ADF/markdown có thể chèn ảnh dạng `![](blob:...&id=<attachment-id>&...)` — `id` trong URL
blob khớp với `id` của 1 phần tử trong `attachment[]` (không phải `filename` như CSV cũ — đối chiếu
qua `id`, không qua tên file). Ghi lại các `id`/`filename` này, dùng ở Bước 2.5.

## Bước 2.5 — Assets: tải ảnh/video QC đính kèm, đối chiếu device

Nhiều bug (đặc biệt bug UI/layout) chỉ mô tả bằng ảnh/video QC đính kèm ("chưa đúng demo", "không
giống UI") — Description/Comment text không đủ để kết luận, PHẢI xem media thật trước khi kết luận
`ĐÚNG BUG` hay `KHÔNG PHẢI BUG` cho loại bug này.

1. Tải attachment bằng API token cá nhân (`attachment[].content` trỏ tới `api.atlassian.com` cần OAuth
   của phiên MCP, `curl` không dùng được — đừng gọi URL đó). Token nằm trong
   `.claude/skills/jira-bug-summary/.env.local` (`JIRA_SITE`, `JIRA_EMAIL`, `JIRA_TOKEN`; cách tạo xem
   `.claude/skills/jira-bug-summary/GUIDE.md`). Chạy từ root repo, mỗi attachment lấy `id` + `filename`
   từ `attachment[]`:

   ```bash
   ROOT="$(git rev-parse --show-toplevel)"
   ENV="$ROOT/.claude/skills/jira-bug-summary/.env.local"
   [ -s "$ENV" ] || { echo "THIEU .env.local"; exit 1; }
   set -a; . "$ENV"; set +a
   [ -n "$JIRA_TOKEN" ] || { echo "JIRA_TOKEN rong"; exit 1; }
   OUT="$ROOT/<folder>/assets/<ISSUE-KEY>"; mkdir -p "$OUT"
   curl -sL -u "$JIRA_EMAIL:$JIRA_TOKEN" \
     "https://$JIRA_SITE/rest/api/3/attachment/content/<attachment-id>" -o "$OUT/<filename>"
   file "$OUT/<filename>"   # phải là image/video thật, không phải HTML/JSON (= 401/403)
   ```

   Quy tắc:
   - **KHÔNG** in, `cat`, `Read` hay `echo` nội dung `.env.local` / `$JIRA_TOKEN`; không đưa token vào
     chat, `notes.txt` hay commit. Chỉ kiểm tra rỗng/không rỗng như trên.
   - `file` ra HTML/JSON/text, hoặc curl lỗi 401/403 (sai token, hoặc tổ chức chặn API token) → dừng,
     báo user đúng lỗi đó, không lặp lại với token khác.
   - Thiếu `.env.local` hoặc `JIRA_TOKEN` rỗng → hỏi user: điền token theo GUIDE, hoặc tự tải tay trên
     ticket và paste path (hoặc để trong Downloads). Báo URL + filename để họ tải.
   - Tải xong dùng `Read` đọc từng ảnh. Video: chỉ xem được khung hình nếu user cung cấp ảnh chụp từ video;
     không đọc được thì nói rõ, không đoán nội dung.
2. Evidence đã tải ở bước 1 nằm sẵn trong `<folder>/assets/<ISSUE-KEY>/` — thư mục lưu ảnh QC đã dùng
   để kết luận. Ảnh user cung cấp tay thì copy vào đúng thư mục này.
3. So ảnh QC với screenshot chụp trên device thật (`adb exec-out screencap`) ở cùng màn hình/trạng
   thái — chỉ kết luận `ĐÚNG BUG` khi thấy khác biệt cụ thể (thiếu block, sai text, sai layout...),
   không suy đoán từ mô tả text ("chưa đúng demo" không tự nó là bằng chứng).
4. Không có ảnh + không xin được từ user + Description/Comment không đủ chi tiết → kết luận "CẦN XEM
   ẢNH ĐÍNH KÈM, chưa đủ căn cứ kết luận" thay vì đoán liều theo BRD text.

## Bước 3 — Xác định PRD liên quan

### 3.0 Xác định PRD — do user chỉ định, KHÔNG tự chọn

PRD dùng để đối chiếu là file **user nêu** (path, tên file, hoặc tên FR/folder PRD). Không có PRD
mặc định hardcode.

1. User đã nêu PRD → resolve ra path thật (tìm bằng `find`/`ls` trong `docs/` và thư mục user nói).
   Thấy đúng 1 file → dùng. Thấy nhiều file khớp tên → hỏi user chọn file nào.
2. User **không nêu PRD**, hoặc nêu nhưng **không tìm thấy file** → DỪNG, hỏi user (dùng
   `AskUserQuestion`): liệt kê các PRD tìm được làm lựa chọn, ví dụ
   `find "$(git rev-parse --show-toplevel)" -ipath '*prd*' \( -name '*.md' -o -name '*.docx' \) -not -path '*/node_modules/*'`
   và `ls "$(git rev-parse --show-toplevel)/docs"`; cho phép user nhập path khác. Không tìm được gì
   → hỏi user path. Tuyệt đối không đoán PRD, không dùng PRD khác khi chưa được xác nhận, không
   kết luận khi chưa có PRD.
3. Đã chốt PRD → ghi path vào phần "Căn cứ" của kết luận. Cùng phiên, các bug tiếp theo dùng lại
   PRD này, trừ khi user đổi.

**Thứ tự ưu tiên nguồn (cao → thấp) khi 2 nguồn mâu thuẫn nhau:**

1. **PRD do user chỉ định** (3.0) — thường có AC ID/BR ID/FR ID tường minh cho từng rule, kèm literal
   string chính xác (label nút, tiêu đề, empty state...). Nguồn đáng tin nhất, ưu tiên hơn tài liệu phụ.
2. Tài liệu phụ **do user chỉ định** (BRD, wireframe/Figma...) — chỉ dùng khi user đưa, và khi PRD không
   có mục tương ứng hoặc chỉ nói chung chung. Wireframe chỉ dùng cho chi tiết UI/layout thuần mà PRD
   không đặc tả, KHÔNG override literal string PRD đã ghi rõ. PRD và tài liệu phụ lệch nhau thật → nêu
   rõ cả 2 nguồn trong kết luận, đừng tự chọn 1 bên, đề xuất hỏi lại BA bản nào đang hiệu lực.
3. Comment BA/PM trong Jira ticket (Bước 2) — vẫn override tất cả nguồn văn bản nếu comment mới hơn
   và rõ ràng, như đã mô tả ở Bước 2.

Không tự dùng bất kỳ tài liệu nào trong repo ngoài những gì user chỉ định (kể cả file BRD/PRD có sẵn
trong `docs/` — có thể lỗi thời hoặc thuộc dự án khác).

Chọn mục cần đọc theo `[TC_XX - <tên module>]` trong Summary + từ khoá tính năng.

**Đọc PRD** — PRD là `.md` (hoặc `.txt`) → `grep -n "<từ khoá>" "<path PRD>"` trực tiếp. PRD là
`.docx` — máy dev hiện tại KHÔNG có `pandoc`/`python-docx`, dùng script riêng (đọc thẳng
`word/document.xml` trong zip, không cần dependency ngoài):

```bash
python3 "$(git rev-parse --show-toplevel)/.claude/skills/bug-vs-brd/scripts/extract_prd_docx.py" \
  "<path PRD .docx user chỉ định>"
# In ra path .txt (mặc định /tmp/<tên file>.txt) — grep -n trên file đó
grep -n "<từ khoá>" "/tmp/<tên file>.txt"
```

Output là text thô đã tách dòng theo `<w:p>` (đủ để `grep -n` định vị đúng đoạn), KHÔNG phải markdown
đẹp — số dòng KHÔNG map với số trang trong docx gốc, chỉ dùng để tìm đúng câu/mục (FR/AC/BR ID) rồi
trích nguyên văn.

Không tìm thấy rule liên quan trong PRD (và tài liệu phụ nếu có) → ghi rõ "BRD/PRD không có rule này", không tự
suy diễn ra rule.

## Bước 4 — Kết luận

Kết luận PHẢI có đủ 3 phần, mỗi phần 1-2 câu:

1. **Bug thật hay không** — 1 trong 3: `ĐÚNG BUG` (Actual sai so với BRD/PRD), `KHÔNG PHẢI BUG` (Actual
   đúng theo BRD, hoặc BRD không yêu cầu hành vi như Expected trong ticket), `ĐÃ CHỐT KHÁC` (Comment
   có quyết định mới override BRD/Description cũ).
2. **Căn cứ** — trích đúng câu/section BRD/PRD (kèm đường dẫn file — với PRD ưu tiên trích kèm ID
   `FRxx`/`ACxx`/`BRxx-xx`/`EMP-xx` nếu có, dễ tra lại hơn số dòng file `.txt` tạm), hoặc trích câu
   comment nếu rơi vào case `ĐÃ CHỐT KHÁC`.
3. **Đề xuất** — fix theo BRD / giữ nguyên hành vi hiện tại / cần hỏi lại BA (khi BRD và comment đều
   không rõ).

Không kết luận `ĐÚNG BUG` nếu chưa trích được câu BRD cụ thể — nếu chỉ đoán, ghi rõ "chưa xác nhận
được qua BRD, cần hỏi BA" thay vì kết luận chắc. Với bug có ảnh QC đính kèm mô tả sai UI/layout —
không kết luận nếu chưa xem được ảnh đó (Bước 2.5), kể cả khi BRD có vẻ ủng hộ 1 phía.

## Bước 5 — Ghi `evidence.md` (khi không phải lỗi app / chờ BA, BE)

Kết luận là `KHÔNG PHẢI BUG`, `ĐÃ CHỐT KHÁC`, hoặc `ĐÚNG BUG` nhưng nguyên nhân nằm ngoài app / cần BA, BE
trả lời (vd chờ BA chốt rule, chờ BE sửa data/API) → ghi `<folder>/assets/<ISSUE-KEY>/evidence.md`, cạnh
`notes.txt` và ảnh QC đã tải. `notes.txt` là bản chép ticket; `evidence.md` là căn cứ của kết luận — ai mở
lại ticket đọc file này để khỏi lặp lại quá trình điều tra và biết đang chờ ai.

Bug `ĐÚNG BUG` mà lỗi nằm ở app, sửa được ngay → không cần file này.

Ghi đè nếu file đã có (kết luận đổi sau khi có thêm dữ kiện, vd BE trả lời) và ghi ngày ở đầu file.

**Mọi tài liệu, ảnh, video, code được nhắc tới PHẢI là link bấm mở được** — không ghi tên file/đường dẫn trần:
- Link dùng **đường dẫn tương đối tính từ vị trí `evidence.md`** (file nằm ở `<folder>/assets/<ISSUE-KEY>/`,
  nên repo root là `../../../`). Ví dụ PRD: `[PRD v2](../../../learnflutter/docs/prd-v1.0/<file>.md#L336)`.
- PRD/code: link kèm số dòng bằng fragment `#L<dòng>` (hoặc `#L<a>-L<b>`), text link ghi `file:dòng` hoặc ID
  `BR-02-02`; vẫn trích nguyên văn bên cạnh, không chỉ để link.
- Ảnh QC: nhúng `![mô tả](<tên-file>.png)` VÀ đặt link `[<tên-file>.png](<tên-file>.png)` (file nằm cùng thư mục).
- Video: link `[<tên-file>.mp4](<tên-file>.mp4)` (markdown không nhúng được video); ghi rõ đã xem hay chưa.
- Ticket Jira: link URL đầy đủ `[OMB-xxx](https://<site>/browse/OMB-xxx)`; attachment chưa tải được thì link
  URL attachment trên Jira và ghi "chưa tải về".
- Tài liệu ngoài repo (Confluence, Figma...): link URL gốc.
- **Kiểm tra link trước khi báo xong**: chạy `ls` (hoặc `test -f`) cho từng đường dẫn tương đối, phải tồn tại;
  số dòng trích phải khớp nội dung đã trích. Không có file để link (chưa tải ảnh, PRD ở /tmp) → KHÔNG ghi link
  giả, ghi "chưa có file" ở mục "Chưa làm được".
- Nguồn tạm (vd `/tmp/<prd>.txt` từ script docx) không link được → link PRD `.docx` gốc trong repo + ghi ID
  FR/AC/BR thay cho số dòng.

Cấu trúc (bỏ mục không có nội dung, KHÔNG bịa để đủ mục):

```
# <ISSUE-KEY> — Evidence: <không phải lỗi app / chờ BA / chờ BE ...>

Ngày: <YYYY-MM-DD> | Kết luận: <ĐÚNG BUG / KHÔNG PHẢI BUG / ĐÃ CHỐT KHÁC + 1 cụm lý do> | Chờ: <BA / BE / OPS / Data>

## Ticket nói gì
<Expected/Actual tóm tắt; ghi rõ có hay không có comment của BA/PM>

## Evidence ảnh / video
<mỗi ảnh QC đã xem: nhúng ảnh + link file + mô tả những gì thấy; video: link file + đã xem hay chưa; không đoán nội dung video chưa xem được>

## Evidence request/response
<curl/response do user hoặc dev cung cấp, ĐÃ che token/secret; ghi rõ ai chạy và ngày>

## Căn cứ PRD
<link PRD (tương đối, kèm #L<dòng>) + ID FR/AC/BR + trích nguyên văn; hoặc "PRD không có rule này" kèm từ khoá đã grep>

## Căn cứ code (app)
<link `file:line` (tương đối, kèm #L<dòng>) + app làm gì; ghi rõ nếu là ghi chú của dev trong code, chưa kiểm chứng>

## Vì sao không phải lỗi app
<1-3 gạch đầu dòng, chỉ dựa trên evidence ở trên>

## Cần BA / BE trả lời
<câu hỏi đánh số, mỗi câu ghi rõ ai trả lời>

## Chưa làm được
<việc chưa kiểm chứng: chưa tải ảnh, chưa chụp device, chưa gọi API, chưa đọc code...>
```

Quy tắc:
- Chỉ ghi điều đã thấy/đọc trong phiên; giả thuyết ghi rõ là giả thuyết và đưa xuống "Cần BA / BE trả lời".
- KHÔNG ghi token, `Authorization`, mã `code` bí mật trong response, email/PII; che bằng `***`.
- Kết luận trong `evidence.md` PHẢI khớp kết luận đã báo user ở Bước 4; nếu phiên sau đổi kết luận thì sửa
  cả hai.
- Không tự commit; báo user đường dẫn file đã ghi.

## Ví dụ

Input: `FE-290`. `getJiraIssue` trả Description yêu cầu hiện lỗi đỏ "Số điện thoại không hợp lệ..."
khi input sai định dạng, nhưng comment mới nhất (23/09, `anhptm17`) cho thấy hành vi đã đổi: app
**tự chuẩn hoá SĐT rồi lưu thành công** (`0912 345 678` → `0912345678`, `+84987654321` →
`0987654321`), không còn hiện lỗi như Expected — và comment thứ 2 hỏi thẳng BA/dev có PRD chỉ hỗ trợ
định dạng VN (10 số, đầu `0`) trong khi app đang cho nhập cả `+84`.
→ Kết luận: `ĐÃ CHỐT KHÁC` (một phần) — hành vi thật đã lệch cả Description gốc lẫn quyết định cũ,
cần BA chốt lại: chấp nhận tự chuẩn hoá silent hay bắt buộc hiện lỗi. Không tự chọn 1 hướng khi cả 2
comment đều đang chờ BA trả lời.
