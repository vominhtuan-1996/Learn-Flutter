# figma-mcp-api install script (Windows PowerShell)
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "=== figma-mcp-api install ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Node.js
Write-Host "1/5  Kiểm tra Node.js..."
try {
    $nodeVer = node --version
    Write-Host "     Node.js $nodeVer" -ForegroundColor Green
} catch {
    Write-Host "     Node.js chua cai. Tai tai https://nodejs.org (can >= 18)" -ForegroundColor Red
    exit 1
}

# Step 2: Install dependencies
Write-Host "2/5  Cai dependencies (npm install)..."
Set-Location $ScriptDir
npm install --silent
Write-Host "     Dependencies da cai" -ForegroundColor Green

# Step 3: Setup .env
Write-Host "3/5  Cau hinh Figma credentials..."
$EnvFile = Join-Path (Split-Path -Parent $ScriptDir) ".env"
$FigmaToken = Read-Host "     Nhap FIGMA_ACCESS_TOKEN (Enter de bo qua)"

if ($FigmaToken) {
    if (Test-Path $EnvFile) {
        $content = Get-Content $EnvFile -Raw
        if ($content -match "FIGMA_ACCESS_TOKEN=") {
            $content = $content -replace "FIGMA_ACCESS_TOKEN=.*", "FIGMA_ACCESS_TOKEN=$FigmaToken"
        } else {
            $content += "`nFIGMA_ACCESS_TOKEN=$FigmaToken"
        }
        Set-Content $EnvFile $content
    } else {
        "FIGMA_ACCESS_TOKEN=$FigmaToken" | Set-Content $EnvFile
    }
    Write-Host "     Token da luu vao $EnvFile" -ForegroundColor Green
} else {
    Write-Host "     Bo qua (them vao .env thu cong sau)"
}

# Step 4: Print config snippet
$ServerPath = Join-Path $ScriptDir "server.js"
Write-Host ""
Write-Host "4/5  Config snippet cho .mcp.json:" -ForegroundColor Yellow
Write-Host @"
{
  "mcpServers": {
    "figma-api": {
      "command": "node",
      "args": ["$($ServerPath -replace '\\','\\\\')"]
    }
  }
}
"@ -ForegroundColor Yellow
Write-Host ""

# Step 5: Auto-patch Claude Desktop
$ClaudeConfig = "$env:APPDATA\Claude\claude_desktop_config.json"
$DoPatch = Read-Host "5/5  Tu dong them vao Claude Desktop config? (y/N)"
if ($DoPatch -match "^[Yy]") {
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        $py = @"
import json,sys,os
p=sys.argv[1]; s=sys.argv[2]+'/server.js'
os.makedirs(os.path.dirname(p),exist_ok=True)
c={}
if os.path.exists(p):
    with open(p) as f: c=json.load(f)
c.setdefault('mcpServers',{})
c['mcpServers']['figma-api']={'command':'node','args':[s]}
with open(p,'w') as f: json.dump(c,f,indent=2)
print('Patched')
"@
        python3 -c $py $ClaudeConfig ($ScriptDir -replace '\\','/')
        Write-Host "     Da patch Claude Desktop config" -ForegroundColor Green
    } else {
        Write-Host "     python3 khong co san, hay them thu cong" -ForegroundColor Yellow
    }
}

# Step 6: Copy slash commands
Write-Host ""
$ProjectPath = Read-Host "Copy slash commands vao project? Nhap duong dan project (Enter de bo qua)"
if ($ProjectPath -and (Test-Path $ProjectPath)) {
    $Dest = Join-Path $ProjectPath ".claude\commands"
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Copy-Item "$ScriptDir\commands\*.md" $Dest -Force
    Write-Host "     Da copy commands vao $Dest" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Cai dat hoan tat! ===" -ForegroundColor Green
Write-Host "Restart Claude Desktop hoac reload Claude Code de dung:"
Write-Host "  11 tools: get_file, get_nodes, get_images, get_file_components, get_file_styles,"
Write-Host "            get_me, get_file_versions, get_comments, post_comment,"
Write-Host "            get_project_files, get_team_projects"
Write-Host "  Commands: /figma-file, /figma-nodes, /figma-export, /figma-components,"
Write-Host "            /figma-styles, /figma-comments, /figma-projects"
Write-Host ""
