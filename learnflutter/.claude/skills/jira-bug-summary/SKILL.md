---
name: jira-bug-summary
description: Tổng hợp bug (issuetype Bug) của cả project Jira, chỉ lọc assignee khi user yêu cầu, thành file summary trong folder do user đặt tên (không trả lời thì lấy ticketId Jira) — dùng khi user nói "tổng hợp bug jira", "lấy list bug", "summary bug chưa done", "recheck jira"
triggers:
  - tổng hợp bug jira
  - summary bug
  - lấy list bug OMB
  - recheck jira
---

# Jira Bug Summary

Query bug Jira của cả project, không lọc assignee trừ khi user yêu cầu (site foxproject.atlassian.net; project mặc định OMB (FTI-OnMember), nếu user có
nhiều project thì hỏi chọn project nào), tổng hợp thành 1
file Markdown trong folder do user đặt tên (xem bước 0).

## Usage

Mở Claude Code ở repo `learn_flutter`, nói một trong các câu:

| Câu lệnh | Kết quả |
|---|---|
| "tổng hợp bug jira" / "lấy list bug OMB" | Bug cả project, loại Pending và Done |
| "summary bug chưa done" | Như trên |
| "recheck jira" | Query lại và ghi đè file summary của hôm nay |
| "lấy cả pending" / "lấy all" | Thêm Pending (và Done nếu nói "all") |
| "bug của tôi" / "bug của AnhHH4" | Lọc assignee: `currentUser()` hoặc tên user nêu |

Output: `<folder>/SUMMARY-bug-chua-done-<YYYY-MM-DD>.md`. `<folder>` do user đặt tên; không trả lời thì
dùng ticketId Jira. Skill không tự commit.

Lần đầu dùng cần cài Atlassian MCP và đăng nhập, xem [GUIDE.md](GUIDE.md).

## Quy trình

### 0. Hỏi tên folder output

Trước khi làm gì, hỏi user: "Lưu summary vào folder nào? (vd `fix-bug-qc-r1`)". Dùng đúng tên user
trả lời, tạo folder nếu chưa có.

**Nếu user không trả lời** (bỏ qua câu hỏi, hoặc nói "tuỳ"/"mặc định"): lấy ticketId trên Jira làm tên
folder, chọn sau khi có kết quả bước 2:

1. User đã nêu 1 ticket key cụ thể (vd "OMB-123") → dùng key đó.
2. Không thì, nếu mọi bug cùng 1 parent/epic → dùng key của parent/epic.
3. Còn lại → dùng key của bug cập nhật gần nhất (issue đầu tiên của kết quả).

Báo user tên folder đã chọn và lý do khi tạo file xong.

### 1. Verify Jira đã connect

```
mcp__atlassian__atlassianUserInfo (không tham số)
```

Nếu tool báo chưa auth → gọi `mcp__atlassian__authenticate`, đưa user URL để authorize, đợi user
xác nhận xong rồi mới query tiếp.

### 1b. Chọn project để fetch

Liệt kê project user truy cập được:

```
mcp__atlassian__getVisibleJiraProjects
  cloudId: foxproject.atlassian.net
```

- **Chỉ có 1 project** → dùng luôn, không hỏi.
- **Có nhiều project** → hỏi user fetch project nào (liệt kê `key — tên`, cho chọn 1 hoặc nhiều).
  Nếu user đã nêu rõ project/key trong câu lệnh thì dùng luôn, không hỏi lại.
- **User không trả lời** → dùng project `OMB` nếu có trong danh sách; không có thì dừng và hỏi lại.

Gọi project đã chọn là `<PROJECT>`. Chọn nhiều project thì dùng `project IN (A, B)` và thêm cột/nhóm
project trong file summary.

### 2. Query JQL — mặc định loại Pending và Done

```
mcp__atlassian__searchJiraIssuesUsingJql
  cloudId: foxproject.atlassian.net
  jql: project = <PROJECT> AND issuetype = Bug AND status NOT IN (Pending, Done) ORDER BY updated DESC
  fields: ["summary", "status", "issuetype", "assignee"]
  maxResults: 100
```

**Không lọc assignee mặc định.** Chỉ thêm khi user yêu cầu: "của tôi" → `AND assignee = currentUser()`; nêu tên → `AND assignee = "<tên>"` (lấy accountId qua `lookupJiraAccountId` nếu tên không khớp).

**Chỉ include Pending/Done khi user yêu cầu rõ** (vd "lấy cả pending", "lấy all"). Đây là quy tắc
mặc định đã chốt với user — không tự ý đổi lại.

### 3. Xử lý output lớn (tool result exceeds token limit)

Tool trả lỗi kèm path file JSON đã lưu (`[{type, text}]`, phần `text` có prefix cảnh báo deprecation
trước JSON thật). Parse bằng Python, không dùng jq trực tiếp (prefix làm jq parse lỗi):

```python
import json
data = json.load(open('<path-from-error>'))
full = ''.join(x['text'] for x in data)
idx = full.index('{\n  "issues"')
d = json.loads(full[idx:])
for i in d['issues']:
    f = i['fields']
    print(i['key'], '|', f['issuetype']['name'], '|', f['status']['name'], '|', f['summary'])
print('isLast:', d.get('isLast'), 'nextToken:', d.get('nextPageToken'))
```

Nếu `isLast: false` — gọi lại `searchJiraIssuesUsingJql` với `nextPageToken` để lấy trang tiếp, lặp
tới khi `isLast: true`. Gộp toàn bộ issue các trang lại trước khi tổng hợp.

### 4. Group theo status

JQL đã có `issuetype = Bug` nên chỉ trả đúng ticket Bug (không Story/Task/Sub-task) — không lấy rồi lọc sau. File summary luôn có cột Assignee (title ghi rõ nếu có lọc assignee).

Nhóm: In review / In Progress / To Do (không có Pending/Done trừ khi user yêu cầu ở bước 2).

### 5. Tạo file summary

Path: `<folder>/SUMMARY-bug-chua-done-<YYYY-MM-DD>.md` (ngày hôm nay), `<folder>` là tên đã chốt ở bước 0.

Cấu trúc:

```markdown
# Tổng hợp bug chưa Done — project <PROJECT>, <ngày>

Nguồn: Jira `<jql đã dùng>` (site foxproject.atlassian.net).
Assignee: cả project (hoặc <tên> nếu user yêu cầu lọc). Chỉ liệt kê issue type **Bug**, loại status Done và Pending.

## <Status 1> (n)

| Key | Assignee | Summary |
|---|---|---|
| OMB-xxx | ... | ... |

## <Status 2> (n)
...

## Tổng: N bug chưa Done (loại Pending)

- <Status>: n
...

## Bảng theo flow (TC)

| Key | Flow (TC) | Status | Assignee | Summary |
|---|---|---|---|---|
```

Bảng theo flow lấy TC prefix từ đầu summary (vd `[TC_04 - Đăng tin]` → flow `TC_04 - Đăng tin`), sort
theo flow để dễ gom nhóm fix theo màn hình/luồng liên quan.

### 6. Verify

Đọc lại file vừa tạo (`Read`), đối chiếu tổng số issue trong bảng khớp với số đếm ở mục "Tổng".
Không tự `git add`/`git commit` — để user tự commit nếu muốn.

## Sai lầm thường gặp

- Dùng `jq` trực tiếp trên file JSON lỗi lưu — luôn dùng Python (xem bước 3).
- Quên trang tiếp theo khi `isLast: false` — thiếu issue trong summary.
- Lấy ticket không phải Bug (Sub-task, Story) — JQL luôn phải có `issuetype = Bug`.
- User gọi project bằng tên (vd "FTI-OnMember") mà không thấy trong danh sách mặc định → gọi `getVisibleJiraProjects` với `searchString` (vd `FTI`, `action: browse`) để ra key thật (vd **OMB**).
- Tự đoán project key — luôn lấy key thật từ `getVisibleJiraProjects` (vd project "FTI-OnMember" có key **OMB**, không phải `FTIONMEMBER`).
- Có nhiều project mà không hỏi user — chỉ được bỏ qua câu hỏi khi chỉ có 1 project hoặc user đã nêu rõ.
- Include Pending/Done mặc định — chỉ khi user yêu cầu rõ.
