# Hướng dẫn cài đặt — jira-bug-summary

Skill gọi Jira qua Atlassian MCP (`mcp__atlassian__*`). Cần cài MCP và đăng nhập một lần trước khi dùng.

## Yêu cầu

- Claude Code đã cài (`claude --version`).
- Tài khoản có quyền truy cập site `foxproject.atlassian.net`, project **OMB** (FTI-OnMember).
- Python 3 (skill dùng để parse file JSON khi kết quả query quá lớn).

## Cài đặt

### 1. Thêm Atlassian MCP

Dùng scope `user` để dùng được ở mọi project. Scope mặc định (`local`) chỉ có hiệu lực trong đúng thư mục đang đứng.

```bash
claude mcp add --scope user --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

Kiểm tra:

```bash
claude mcp list
# atlassian: https://mcp.atlassian.com/v1/sse (SSE) - ! Needs authentication   <- bình thường, chưa đăng nhập
```

### 2. Khởi động lại Claude Code

Phiên đang chạy không tự nạp server MCP mới. Thoát (`/exit`) rồi chạy lại `claude`.

### 3. Đăng nhập Atlassian

Trong Claude Code gõ `/mcp`, chọn `atlassian`, chọn authenticate. Trình duyệt mở ra, đăng nhập và cấp quyền cho site `foxproject.atlassian.net`.

Sau khi xong, `claude mcp list` hiện `✔ Connected`.

### 4. Kiểm tra

Hỏi Claude: "dùng atlassianUserInfo cho tôi xem tài khoản Jira". Có tên và email là cài đúng.

## Tải attachment Jira bằng API token (tuỳ chọn)

Token OAuth của MCP không đưa ra ngoài Claude Code, nên `curl` tới URL attachment của `api.atlassian.com` bị 401/403. Muốn tải ảnh/video QC về máy thì dùng API token cá nhân.

### 1. Tạo file cấu hình

```bash
cd .claude/skills/jira-bug-summary
cp .env.example .env.local
chmod 600 .env.local
```

Mở `.env.local`, điền `JIRA_EMAIL` (email tài khoản Jira) và `JIRA_TOKEN`.

| Biến | Ý nghĩa |
|---|---|
| `JIRA_SITE` | Site Jira, mặc định `foxproject.atlassian.net` |
| `JIRA_EMAIL` | Email tài khoản Jira |
| `JIRA_TOKEN` | API token cá nhân, tạo tại https://id.atlassian.com/manage-profile/security/api-tokens |

`.env.local` đã nằm trong `.gitignore` của repo. `.env.example` thì được commit, chỉ chứa giá trị mẫu, không có token.

### 2. Tải attachment

```bash
set -a; source .claude/skills/jira-bug-summary/.env.local; set +a
curl -sL -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "https://$JIRA_SITE/rest/api/3/attachment/content/<attachment-id>" -o <file>.png
file <file>.png   # phải ra "PNG image data", không phải HTML/JSON
```

`<attachment-id>` lấy từ `fields.attachment[].id` của issue, hoặc từ cuối URL attachment trong `notes.txt`.

### Lưu ý bảo mật

- Không dán token vào chat, không commit `.env.local`.
- Đặt hạn ngắn khi tạo token, thu hồi tại trang API tokens khi không dùng nữa.
- Nếu `git status` hiện `.env.local`, dừng lại và kiểm tra `.gitignore` trước khi commit.

## Xử lý lỗi

| Hiện tượng | Nguyên nhân / cách xử lý |
|---|---|
| `/mcp` không thấy `atlassian` | Thêm MCP bằng scope `local` ở thư mục khác. Thêm lại với `--scope user`, rồi mở lại phiên. |
| Vẫn `Needs authentication` sau khi đăng nhập | Mở lại phiên, gõ `/mcp` và authenticate lại. |
| Không có quyền site / project | Hỏi admin Jira cấp quyền vào project OMB. |
| Tool không xuất hiện trong phiên | Thoát hẳn và chạy lại `claude`. |
| Gỡ MCP | `claude mcp remove atlassian -s user` |
| Tải attachment trả HTML/JSON hoặc 401/403 | Sai `JIRA_EMAIL`/`JIRA_TOKEN`, hoặc tổ chức chặn API token (SSO). Tải tay trên trang ticket. |
| `.env.local` hiện trong `git status` | `.gitignore` thiếu dòng `.env.local`. Thêm vào trước khi commit. |
