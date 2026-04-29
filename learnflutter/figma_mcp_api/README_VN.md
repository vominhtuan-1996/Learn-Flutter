# figma-mcp-api

MCP Server kết nối Figma REST API — đọc file, node, component, style, comment, export ảnh.

---

## Yêu cầu

- **Node.js >= 18** — tải tại [nodejs.org](https://nodejs.org)
- **Figma Access Token** — tạo tại Figma Settings → Account → Personal Access Tokens
- **Claude Desktop** hoặc **Claude Code (CLI)**

---

## Cài đặt (dành cho thành viên team)

### Bước 1 — Giải nén

Giải nén `figma-mcp-api-vX.X.X.zip` vào thư mục tùy chọn, ví dụ:

```
~/tools/figma_mcp_api/
```

### Bước 2 — Chạy script cài đặt

**Mac / Linux:**
```bash
bash ~/tools/figma_mcp_api/install.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\tools\figma_mcp_api\install.ps1"
```

Script sẽ tự động:
- Kiểm tra Node.js
- Cài dependencies (`npm install`)
- Hỏi Figma Access Token → ghi vào `.env`
- In ra config snippet
- Hỏi có muốn tự động thêm vào Claude Desktop không
- Hỏi đường dẫn project để copy 7 slash commands

### Bước 3 — Cấu hình .env thủ công (nếu cần)

Tạo file `.env` trong thư mục **cha** của `figma_mcp_api/`:

```env
FIGMA_ACCESS_TOKEN=figd_your_token_here
```

### Bước 4 — Thêm config (nếu chưa tự động)

**Claude Code** — thêm vào `.mcp.json`:

```json
{
  "mcpServers": {
    "figma-api": {
      "command": "node",
      "args": ["/đường/dẫn/tới/figma_mcp_api/server.js"]
    }
  }
}
```

**Claude Desktop** — thêm vào `claude_desktop_config.json`:

| Hệ điều hành | Đường dẫn file config |
|---|---|
| Mac | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

Sau đó **restart Claude Desktop**.

---

## Tools (11 tools)

| Tool | Mô tả |
|---|---|
| `get_file` | Lấy toàn bộ JSON của file Figma |
| `get_nodes` | Lấy JSON của các node cụ thể |
| `get_images` | Export URL ảnh cho các node |
| `get_file_components` | Liệt kê tất cả components trong file |
| `get_file_styles` | Liệt kê tất cả styles trong file |
| `get_me` | Thông tin user đang xác thực |
| `get_file_versions` | Lịch sử phiên bản của file |
| `get_comments` | Danh sách comments trên file |
| `post_comment` | Thêm comment mới vào file |
| `get_project_files` | Danh sách files trong project |
| `get_team_projects` | Danh sách projects trong team |

---

## Slash Commands

| Command | Mô tả |
|---|---|
| `/figma-file <file_key>` | Đọc nội dung file Figma |
| `/figma-nodes <file_key> <node_ids>` | Lấy dữ liệu node cụ thể |
| `/figma-export <file_key> <node_ids>` | Export ảnh từ node |
| `/figma-components <file_key>` | Xem components trong file |
| `/figma-styles <file_key>` | Xem styles trong file |
| `/figma-comments <file_key>` | Xem/thêm comments |
| `/figma-projects <team_id>` | Xem projects trong team |

---

## Lấy Figma Access Token

1. Đăng nhập Figma
2. Vào **Settings** (icon avatar góc trên phải)
3. Tab **Account** → **Personal access tokens**
4. Click **Generate new token**
5. Copy token (chỉ hiển thị 1 lần)

## Lưu ý

- `FIGMA_ACCESS_TOKEN` là key **secret** — không commit vào git
- File `.env` phải nằm trong thư mục **cha** của `figma_mcp_api/` (do server đọc `../.env`)
- Token bắt đầu bằng `figd_` (Personal Access Token)
