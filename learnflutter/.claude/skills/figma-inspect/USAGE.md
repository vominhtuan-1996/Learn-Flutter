# figma-inspect v3 — Hướng dẫn sử dụng

Skill export Figma node PNG qua Images API (pixel-perfect) + chụp app thực tế qua Maestro, so sánh side-by-side, extract design tokens, tổng hợp SUMMARY.md với diff table.

## Cú pháp

```
/figma-inspect <figma_url> [--flow <maestro_yaml>] [--screen <name>] [--device <udid>]
```

| Tham số | Bắt buộc | Mô tả |
|---------|----------|-------|
| `figma_url` | ✅ | URL Figma đầy đủ có `node-id=` |
| `--flow <path>` | ❌ | Maestro YAML navigate đến màn hình cần inspect |
| `--screen <name>` | ❌ | Tên màn hình (dùng trong output file names) |
| `--device <udid>` | ❌ | UDID simulator/device (mặc định: booted simulator) |

## Ví dụ

```bash
# Cơ bản — launchApp + screenshot hiện tại
/figma-inspect https://www.figma.com/design/KEY/Name?node-id=101-2737

# Có Maestro flow navigate đến màn hình cụ thể
/figma-inspect https://www.figma.com/design/KEY/Name?node-id=101-2737 \
  --flow lib/features/auth/.maestro/biometric.yaml \
  --screen biometric

# Chỉ định device
/figma-inspect https://www.figma.com/design/KEY/Name?node-id=101-2737 \
  --device EDB06BB0-4C88-4F72-B404-9DF9B2D88E2D
```

## Nguồn dữ liệu (quan trọng)

| Nguồn | Dùng cho | Tại sao |
|-------|----------|---------|
| **Figma Images API** | Figma reference PNG | Server-side render, pixel-perfect, scale=2 |
| **Figma Nodes API** | Design tokens (size, color, padding) | Dữ liệu chính xác từ document tree |
| **Maestro** | App thực tế screenshot | Tự navigate đến màn hình, chụp state thực |
| **Playwright** | Fallback khi không có FIGMA_TOKEN | Kém chính xác — canvas screenshot |

## Yêu cầu

- `FIGMA_TOKEN` trong `.env` — Personal Access Token từ Figma (Settings → Security → Personal access tokens)
- Simulator đang booted (hoặc device kết nối) — để Maestro chụp app
- App đã install trên simulator với flavor dev/staging

## Output

```
.figma-snapshots/<node_id>/
├── 00_overview.png           ← Figma export (Images API scale=2)
├── 01_<section>.png          ← từng child node (Figma export)
├── 02_<section>.png
├── app_actual.png            ← app thực tế (Maestro/simctl)
├── _inspect_launch.yaml      ← Maestro flow tạm (nếu không có --flow)
├── nodes_raw.json            ← raw Figma API response
├── node_<id>.json            ← per-child raw data
├── design_<id>.json          ← parsed design tokens (Python hex)
└── SUMMARY.md                ← full report: tokens + Figma vs App diff table
```

## SUMMARY.md bao gồm

- Side-by-side: Figma export vs App screenshot
- Screen structure tree (từ API)
- Per-section: size, layout mode, gap, padding, fills, children table
- Design tokens: colors (hex), spacing, corner radii, sizes
- **Diff table**: Figma value vs current Flutter code, file:line, priority
- **Proposed fixes**: code snippet BEFORE/AFTER cho từng diff
- Prompt "Apply fixes? (y/N)"

## Workflow điển hình

```
1. /figma-inspect <url> --flow lib/features/auth/.maestro/biometric.yaml
   → Tạo SUMMARY.md với diff table

2. Review diff table, reply "y"
   → Skill apply fixes vào Flutter code

3. /wireframe-audit <screen> .figma-snapshots/<node_id>
   → Verify sau khi fix
```

## Lưu ý

- Mỗi lần chạy ghi đè `OUTPUT_DIR` — OK vì design không đổi thường xuyên
- Rate limit Figma API: sleep 2s giữa các request. Nếu 429 → sleep 60s retry
- `use_absolute_bounds=true` trong Images API → export đúng bounds kể cả effects (shadow, stroke)
- jq **không** convert RGBA → hex đúng — skill dùng Python, không thay đổi
