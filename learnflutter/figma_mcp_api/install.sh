#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}=== figma-mcp-api install ===${NC}"
echo ""

# Step 1: Check Node.js
echo "1/5  Kiểm tra Node.js..."
if ! command -v node &>/dev/null; then
  echo "     ❌ Node.js chưa cài. Tải tại https://nodejs.org (cần >= 18)"
  exit 1
fi
NODE_VER=$(node -e "process.stdout.write(process.version)")
echo -e "     ✅ Node.js ${NODE_VER}"

# Step 2: Install dependencies
echo "2/5  Cài dependencies (npm install)..."
cd "$SCRIPT_DIR"
npm install --silent
echo "     ✅ Dependencies đã cài"

# Step 3: Setup .env
echo "3/5  Cấu hình Figma credentials..."
ENV_FILE="$(dirname "$SCRIPT_DIR")/.env"

read -p "     Nhập FIGMA_ACCESS_TOKEN (Enter để bỏ qua): " FIGMA_TOKEN

if [ -n "$FIGMA_TOKEN" ]; then
  if [ -f "$ENV_FILE" ]; then
    if grep -q "^FIGMA_ACCESS_TOKEN=" "$ENV_FILE"; then
      sed -i.bak "s|^FIGMA_ACCESS_TOKEN=.*|FIGMA_ACCESS_TOKEN=${FIGMA_TOKEN}|" "$ENV_FILE"
      rm -f "${ENV_FILE}.bak"
    else
      echo "FIGMA_ACCESS_TOKEN=${FIGMA_TOKEN}" >> "$ENV_FILE"
    fi
  else
    echo "FIGMA_ACCESS_TOKEN=${FIGMA_TOKEN}" > "$ENV_FILE"
  fi
  echo "     ✅ Token đã lưu vào ${ENV_FILE}"
else
  echo "     ⏭  Bỏ qua (thêm vào .env thủ công sau)"
fi

# Step 4: Print config snippet
CONFIG_SNIPPET='{
  "mcpServers": {
    "figma-api": {
      "command": "node",
      "args": ["'"$SCRIPT_DIR/server.js"'"]
    }
  }
}'
echo ""
echo "4/5  Config snippet cho .mcp.json:"
echo -e "${YELLOW}${CONFIG_SNIPPET}${NC}"
echo ""

# Step 5: Auto-patch Claude Desktop
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
read -p "5/5  Tự động thêm vào Claude Desktop config? (y/N): " DO_PATCH
if [[ "$DO_PATCH" =~ ^[Yy]$ ]]; then
  if command -v python3 &>/dev/null; then
    python3 - "$CLAUDE_CONFIG" "$SCRIPT_DIR" <<'PYEOF'
import json, sys, os
config_path = sys.argv[1]
server_path = sys.argv[2] + "/server.js"
os.makedirs(os.path.dirname(config_path), exist_ok=True)
cfg = {}
if os.path.exists(config_path):
    with open(config_path) as f:
        cfg = json.load(f)
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["figma-api"] = {"command": "node", "args": [server_path]}
with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)
print("     ✅ Đã patch Claude Desktop config")
PYEOF
  else
    echo "     ⚠️  python3 không có sẵn, hãy thêm thủ công"
  fi
fi

# Step 6: Copy slash commands
echo ""
read -p "Copy slash commands vào project? Nhập đường dẫn project (Enter để bỏ qua): " PROJECT_PATH
if [ -n "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH" ]; then
  COMMANDS_DEST="$PROJECT_PATH/.claude/commands"
  mkdir -p "$COMMANDS_DEST"
  cp "$SCRIPT_DIR/commands/"*.md "$COMMANDS_DEST/"
  echo "     ✅ Đã copy commands vào ${COMMANDS_DEST}"
fi

echo ""
echo -e "${GREEN}=== Cài đặt hoàn tất! ===${NC}"
echo "Restart Claude Desktop hoặc reload Claude Code để dùng:"
echo "  11 tools: get_file, get_nodes, get_images, get_file_components, get_file_styles,"
echo "            get_me, get_file_versions, get_comments, post_comment,"
echo "            get_project_files, get_team_projects"
echo "  Commands: /figma-file, /figma-nodes, /figma-export, /figma-components,"
echo "            /figma-styles, /figma-comments, /figma-projects"
echo ""
