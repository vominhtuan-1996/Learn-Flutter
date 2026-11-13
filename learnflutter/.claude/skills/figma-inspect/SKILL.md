---
name: figma-inspect
description: "Inspect Figma node: export pixel-perfect PNG qua Figma Images API + chụp app thực tế qua Maestro, so sánh side-by-side, extract design tokens, tổng hợp SUMMARY.md với diff table. Trigger: \"figma inspect\", \"/figma-inspect <url>\"."
license: MIT
version: 3.2.0
argument-hint: "<figma_url> [--fig <file.fig>] [--flow <maestro_yaml>] [--screen <screen_name>] [--device <udid>]"
---

# Figma Inspect Skill v3.2

**Nguồn dữ liệu:**
- **`/v1/files/{key}?depth=20`** → full document tree, design tokens (PRIMARY — không bị rate limit)
- **Figma Images API** → PNG pixel-perfect của từng node (secondary, có thể 429)
- **Maestro** → screenshot app thực tế trên simulator/device
- **File `.fig` local** → fallback khi API bị 429 (rate limit): dựng `design_tokens.json` bằng `fig_tokens.py`, không cần API, không có PNG
- **Playwright** → chỉ dùng khi không có token

> 📖 Hướng dẫn: xem [USAGE.md](USAGE.md).

---

## Arguments

`$ARGUMENTS`:
- `<figma_url>` — Figma URL có `node-id=` param
- `--screen <name>` — tên màn hình (tuỳ chọn, default: tên node)
- `--fig <path>` — file `.fig` local (Figma → File → Save local copy). Dùng khi API 429, hoặc muốn bỏ qua API hoàn toàn. Nếu không truyền, tự tìm `*.fig` ở `$PROJECT_ROOT` khi gặp 429

---

## Instructions

### 0. Parse arguments + setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Từ `$ARGUMENTS`:
- `FIGMA_URL` = URL đầy đủ
- `FILE_KEY` = đoạn `/design/<FILE_KEY>/` trong URL
- `NODE_ID` = từ `node-id=` param, chuẩn hoá thành `101-2737` (dấu `-`)
- `NODE_ID_COLON` = thay `-` đầu tiên thành `:` → `101:2737`
- `SCREEN_NAME` = giá trị `--screen` hoặc lấy từ tên node ở bước 1
- `OUTPUT_DIR` = `$PROJECT_ROOT/.figma-snapshots/$NODE_ID/`

```bash
FIGMA_TOKEN=$(grep -E '^FIGMA_TOKEN=' "$PROJECT_ROOT/.env" 2>/dev/null | cut -d= -f2 | tr -d '"' | tr -d "'")
mkdir -p "$OUTPUT_DIR"
```

**Chế độ `.fig` (bỏ qua API):** nếu có `--fig <path>` → chạy luôn phần "Fallback .fig" ở bước 1 rồi nhảy sang bước 3 (bỏ bước 1 curl và bước 2).

Nếu `FIGMA_TOKEN` rỗng → log warning "No FIGMA_TOKEN — skipping API steps, Playwright screenshot only" → jump sang bước 4 (Playwright fallback).

---

### 1. Fetch full document tree — `/v1/files/{key}?depth=20` (PRIMARY)

**Đây là bước chính để lấy design tokens. Endpoint này KHÔNG bị rate limit như `/v1/nodes`.**

```bash
HTTP_CODE=$(curl -s -w "%{http_code}" \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/$FILE_KEY?depth=20" \
  -o "$OUTPUT_DIR/file_depth20.json")
echo "HTTP: $HTTP_CODE"
```

Kiểm tra lỗi:
- HTTP 200 → tiếp tục
- HTTP 403 → token invalid → jump sang Playwright fallback (bước 4)
- HTTP 404 → FILE_KEY sai → dừng, báo user
- HTTP 429 → kiểm tra header `retry-after`: nếu ≤ 60s thì sleep + retry 1 lần; nếu lớn hơn (gói Starter thường khoá ~25 giờ) → **KHÔNG chờ**, chuyển sang "Fallback .fig" bên dưới

#### Fallback .fig (khi 429, hoặc khi có `--fig`)

`.fig` là bản sao local của file Figma nên không dính rate limit. Cần `pip3 install --user zstandard` nếu file nén zstd.

```bash
FIG=${FIG_PATH:-$(ls "$PROJECT_ROOT"/*.fig 2>/dev/null | head -1)}
[ -z "$FIG" ] && echo "RATE_LIMIT: chưa có file .fig — nhờ user: Figma → File → Save local copy, rồi chạy lại với --fig <path>" && exit 1

python3 "$PROJECT_ROOT/.claude/skills/figma-inspect/fig_tokens.py" "$FIG" "$NODE_ID_COLON" "$OUTPUT_DIR"
```

Script in cây node (cùng format `print_tree` bên dưới) và ghi `design_tokens.json` + `children.tsv` **cùng schema** với đường API, nên bước 3 trở đi dùng y nguyên. Khác biệt so với API: có thêm `position` (x,y tuyệt đối), `effects` (shadow) và `strokeWeight`; **không có PNG** → bỏ bước 2, ghi rõ trong SUMMARY.md "Token: .fig local (no PNG)". Nếu node không có trong `.fig` (file cũ hơn thiết kế) → báo user Save local copy lại.

Dùng Python để tìm node target và extract toàn bộ subtree:

```python
python3 << 'PYEOF'
import json, os

FILE = '/path/to/file_depth20.json'   # thay bằng $OUTPUT_DIR/file_depth20.json
NODE_ID_COLON = '522:806'             # thay bằng $NODE_ID_COLON
OUTPUT_DIR = '/path/to/output'        # thay bằng $OUTPUT_DIR

def find_node(node, target_id):
    if node.get('id') == target_id:
        return node
    for child in node.get('children', []):
        result = find_node(child, target_id)
        if result:
            return result
    return None

def rgba_to_hex(color):
    r = round(color.get('r', 0) * 255)
    g = round(color.get('g', 0) * 255)
    b = round(color.get('b', 0) * 255)
    a = color.get('a', 1)
    return f'#{r:02x}{g:02x}{b:02x}' + (f' a={a:.2f}' if a < 1 else '')

def extract_fills(node):
    return [rgba_to_hex(f['color']) for f in node.get('fills', [])
            if f.get('type') == 'SOLID' and 'color' in f]

def extract_strokes(node):
    return [rgba_to_hex(s['color']) for s in node.get('strokes', [])
            if s.get('type') == 'SOLID' and 'color' in s]

def extract_node(node):
    bbox = node.get('absoluteBoundingBox', {})
    style = node.get('style', {})
    return {
        'id': node.get('id'),
        'name': node.get('name'),
        'type': node.get('type'),
        'size': {'w': bbox.get('width'), 'h': bbox.get('height')},
        'padding': {
            'top': node.get('paddingTop', 0),
            'right': node.get('paddingRight', 0),
            'bottom': node.get('paddingBottom', 0),
            'left': node.get('paddingLeft', 0),
        },
        'gap': node.get('itemSpacing', 0),
        'layout': node.get('layoutMode', 'NONE'),
        'fills': extract_fills(node),
        'strokes': extract_strokes(node),
        'corner': node.get('cornerRadius', node.get('rectangleCornerRadii', 0)),
        'text': node.get('characters'),
        'font': {
            'size': style.get('fontSize'),
            'weight': style.get('fontWeight'),
            'family': style.get('fontFamily'),
        } if node.get('type') == 'TEXT' else None,
        'children': [extract_node(c) for c in node.get('children', [])],
    }

def print_tree(node, depth=0):
    indent = '  ' * depth
    bbox = node.get('absoluteBoundingBox', {})
    fills = extract_fills(node)
    style = node.get('style', {})
    text = node.get('characters', '')
    corner = node.get('cornerRadius', node.get('rectangleCornerRadii'))
    pad = (node.get('paddingTop',0), node.get('paddingRight',0),
           node.get('paddingBottom',0), node.get('paddingLeft',0))
    gap = node.get('itemSpacing', 0)
    layout = node.get('layoutMode', '')

    info = f"{indent}[{node['type']}] {node['name']} | {bbox.get('width')}×{bbox.get('height')}"
    if fills: info += f" | fill={fills}"
    if corner: info += f" | r={corner}"
    if any(pad): info += f" | pad={pad[0]},{pad[1]},{pad[2]},{pad[3]}"
    if gap: info += f" | gap={gap}"
    if layout: info += f" | {layout}"
    if text: info += f" | '{text}'"
    if node.get('type') == 'TEXT' and style:
        info += f" | {style.get('fontSize')}px w{style.get('fontWeight')}"
    print(info)
    for child in node.get('children', []):
        print_tree(child, depth + 1)

with open(FILE) as f:
    data = json.load(f)

node = find_node(data['document'], NODE_ID_COLON)
if not node:
    print(f"ERROR: node {NODE_ID_COLON} not found in file")
    exit(1)

print(f"=== Node: {node['name']} | type: {node['type']} ===")
bbox = node.get('absoluteBoundingBox', {})
print(f"Size: {bbox.get('width')}×{bbox.get('height')}")
print(f"Children: {len(node.get('children', []))}")
print()
print_tree(node)

# Save structured tokens
result = extract_node(node)
with open(f'{OUTPUT_DIR}/design_tokens.json', 'w') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

# Save children list
children = node.get('children', [])
with open(f'{OUTPUT_DIR}/children.tsv', 'w') as f:
    for c in children:
        f.write(f"{c['id']}\t{c['name']}\t{c['type']}\n")

print(f"\nSaved: design_tokens.json, children.tsv ({len(children)} children)")
PYEOF
```

Chạy với đường dẫn thực tế:
```bash
python3 - << 'PYEOF'
# (script trên với FILE, NODE_ID_COLON, OUTPUT_DIR đã thay đúng giá trị)
PYEOF
```

Ghi lại `NODE_NAME`, `children` list, `design_tokens`.

---

### 2. Export Figma node images qua Images API (best-effort — có thể 429)

**Thử trước. Nếu 429 → bỏ qua ảnh, vẫn có đủ tokens từ bước 1 để phân tích.**

#### 2a. Export node gốc (overview)

```bash
HTTP_IMG=$(curl -s -w "%{http_code}" \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/$FILE_KEY?ids=$NODE_ID_COLON&format=png&scale=2" \
  -o "$OUTPUT_DIR/images_root.json")

if [ "$HTTP_IMG" = "200" ]; then
  ROOT_IMG_URL=$(python3 -c "import json; d=json.load(open('$OUTPUT_DIR/images_root.json')); print(d['images'].get('$NODE_ID_COLON','null'))")
  if [ "$ROOT_IMG_URL" != "null" ]; then
    curl -sf "$ROOT_IMG_URL" -o "$OUTPUT_DIR/00_overview.png"
    echo "✅ Root image saved"
  fi
else
  echo "⚠️  Images API $HTTP_IMG — skip PNG export, using tokens from file_depth20.json"
fi
```

#### 2b. Export từng child node (batch, best-effort)

```bash
# Gom tất cả child IDs thành 1 batch (tối đa 20)
IDS_PARAM=$(awk -F'\t' '{printf "%s,", $1}' "$OUTPUT_DIR/children.tsv" | tr '-' ':' | sed 's/,$//')

HTTP_BATCH=$(curl -s -w "%{http_code}" \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/$FILE_KEY?ids=$IDS_PARAM&format=png&scale=2&use_absolute_bounds=true" \
  -o "$OUTPUT_DIR/images_batch.json")

if [ "$HTTP_BATCH" = "200" ]; then
  # Download mỗi ảnh
  python3 << 'PYEOF'
import json, subprocess, os

output_dir = '$OUTPUT_DIR'  # thay thực tế
with open(f'{output_dir}/images_batch.json') as f:
    batch = json.load(f)
with open(f'{output_dir}/children.tsv') as f:
    children = [line.strip().split('\t') for line in f]

for idx, (child_id, name, ctype) in enumerate(children):
    child_colon = child_id.replace('-', ':', 1)
    url = batch.get('images', {}).get(child_colon)
    if url and url != 'null':
        safe = name.lower().replace(' ', '_')[:30]
        out = f'{output_dir}/{idx+1:02d}_{safe}.png'
        subprocess.run(['curl', '-sf', url, '-o', out], check=False)
        print(f'✅ {name} → {out}')
    else:
        print(f'⚠️  {name} → null, skip')
PYEOF
else
  echo "⚠️  Images batch $HTTP_BATCH — no PNGs, analysis from tokens only"
fi
```

Ghi lại: `figma_images = [{child_id, name, path}]` (có thể rỗng nếu 429).

---

### 3. Phân tích design tokens (từ `design_tokens.json`)

Đọc `$OUTPUT_DIR/design_tokens.json` đã lưu ở bước 1. Nếu có ảnh `00_overview.png` thì dùng Read tool đọc thêm.

Phân tích:
- Layout tổng thể (column/row, alignment, spacing, gap)
- Màu fills / strokes của từng layer
- Typography: fontSize, fontWeight, fontFamily
- Padding, corner radius, sizes
- Text content (locale VI/EN)

---

---

### 4. Đọc Figma image để phân tích visual

Dùng Read tool (image) để đọc `$OUTPUT_DIR/00_overview.png` (Figma export).

Phân tích từng component trong ảnh:
- Layout tổng thể (column/row, alignment, spacing)
- Màu header, body background, buttons
- Typography: font size tương đối, weight
- Component shapes: icon circles, toggle, card corners
- Text content (locale VI/EN)
- Missing/extra elements so với code

> Không chụp app thực tế — bước này chỉ dùng Figma export.

---

### 5. Grep Flutter code — so sánh design tokens vs implementation

Với mỗi token quan trọng tìm được từ Figma, grep code để tìm current value:

```bash
# Tìm icon container trong biometric page
grep -n "BoxShape\|width: 4[0-9]\|height: 4[0-9]\|BoxDecoration" \
  "$PROJECT_ROOT/learnflutter/lib/features/auth/screens/biometric_onboarding_page.dart" | head -20

# Tìm button styles
grep -n "OutlinedButton\|FilledButton\|side:\|BorderSide" \
  "$PROJECT_ROOT/learnflutter/lib/features/auth/screens/biometric_onboarding_page.dart" | head -20

# Tìm padding values
grep -n "padding:\|EdgeInsets\|spacingMD\|spacingLG" \
  "$PROJECT_ROOT/learnflutter/lib/features/auth/screens/biometric_onboarding_page.dart" | head -20
```

Ghi lại diff list: `{ component, figma_value, code_value, file, line, priority }`

Priority:
- 🔴 Critical: layout broken, missing component
- 🟡 Minor: color/size/spacing off
- 🟢 Cosmetic: pixel-perfect difference

---

### 6. Tạo SUMMARY.md

````markdown
# Figma Inspect — Node <NODE_ID>

**File Key:** <FILE_KEY>
**Node:** <NODE_ID> (<NODE_NAME>)
**Children found:** <N>
**Inspected:** <ISO date>
**Token:** available (API + Images export)

---

## Overview

![figma](00_overview.png)

*(Figma: exported via Images API scale=2)*

---

## Screen Structure (API verified)

```
<NODE_ID>  <NODE_NAME>  <W>×<H>  full screen
├── <CHILD_1_ID>  <name>  <W>×<H>  <brief desc>
│   ├── ...
│   └── ...
├── <CHILD_2_ID>  <name>  <W>×<H>
└── <CHILD_3_ID>  <name>  <W>×<H>
```

---

## Screenshots

### 01 — <child_name> (`<child_id>`)

![section](01_<name>.png)

#### Size: <W>×<H>
#### Layout: <VERTICAL|HORIZONTAL|NONE> | gap=<N> | pad t=<T> r=<R> b=<B> l=<L>

#### Children

| # | Name | Type | W×H | Fill | Corner | Text/Font |
|---|------|------|-----|------|--------|-----------|
| 1 | ... | FRAME | ... | #hex | 12 | — |
| 2 | ... | TEXT | ... | — | — | Inter 14px 600 |

---

(repeat for each child)

---

## Design Tokens Summary

### Colors
| Hex | Usage |
|-----|-------|
| `#f14e12` | primary — header bg, icon tint |
| `#ffffff` | surface — card, avatar bg |
| ... | ... |

### Spacing
| Token | Value | Where |
|-------|-------|-------|
| Body padding | t=18 r=20 b=18 l=20 | body container |
| Card padding | 16px all | toggle card |
| ... | ... | ... |

### Corner Radii
| Value | Where |
|-------|-------|
| 12px | icon bg, avatar, consent row |
| 14px | buttons |
| 999px (pill) | toggle switch |

### Sizes
| Element | Size |
|---------|------|
| Screen | 390×844 |
| Icon circle | 44×44 |
| Toggle | 42×24 |

---

## Diffs vs Current Implementation

| # | Component | Figma | Current Code | File:line | Priority |
|---|-----------|-------|--------------|-----------|----------|
| 1 | Icon circle | rounded 44×44 #fff3eb | BoxShape.circle 40×40 | biometric_onboarding_page.dart:260 | 🟡 Minor |
| ... | ... | ... | ... | ... | ... |

---

## Proposed Fixes

### Fix N — <description>
```dart
// File: <path>:line
// BEFORE
<current code>
// AFTER
<fixed code>
```

---

## Summary
```
🔴 Critical:   N
🟡 Minor:      N
🟢 Cosmetic:   N

Apply fixes? (y/N)
```
````

---

### 7. Báo cáo

Output cuối:
- Tổng số child nodes exported
- So sánh visual: Figma vs App (đã thấy gì khác)
- Số diff: critical / minor / cosmetic
- Path `SUMMARY.md`
- "Apply fixes? (y/N)"

---

## Error Handling

| Lỗi | Xử lý |
|-----|-------|
| FIGMA_TOKEN không có | Skip API steps; dùng Playwright chụp canvas (fallback) |
| `/v1/files` 403 | Token invalid → fallback Playwright |
| `/v1/files` 429 | `retry-after` ≤ 60s → retry 1 lần; lớn hơn → dùng `fig_tokens.py` với file `.fig` (không chờ). Chưa có `.fig` → nhờ user Save local copy |
| `/v1/images` 429 | Bỏ qua ảnh — tokens từ `file_depth20.json` (hoặc `.fig`) đã đủ để phân tích |
| `.fig` báo zstd | `pip3 install --user zstandard` rồi chạy lại |
| Node không có trong `.fig` | File `.fig` cũ hơn thiết kế → Save local copy lại |
| Images API trả `null` URL | Skip node, log warning |
| Node ID không tìm thấy trong tree | Báo user kiểm tra lại `node-id` param |
| `00_overview.png` không có (429) | Phân tích từ tokens only — vẫn đủ để diff |

---

## Playwright Fallback (khi không có FIGMA_TOKEN)

Chỉ dùng khi không có token. Kém chính xác hơn Images API.

```
browser_navigate(FIGMA_URL + "&scaling=fit-width")
browser_wait_for(5s)
browser_take_screenshot(OUTPUT_DIR + "00_overview.png")
```

Với từng child:
```
browser_navigate(BASE_URL + "?node-id=" + CHILD_ID)
browser_wait_for(3s)
# Zoom to fit: press Shift+1 (Figma shortcut)
browser_press_key("Shift+1")
browser_wait_for(1s)
browser_take_screenshot(OUTPUT_DIR + INDEX + "_" + NAME + ".png")
```

Không có design tokens khi dùng Playwright fallback — chỉ visual.

---

## Notes

- `.fig` là file nặng (~3 MB), đã gitignore (`*.fig`) — không commit. Bộ giải mã kiwi dùng chung với skill `figma-export` (`figma_export.py`)
- **Figma Images API** là nguồn dữ liệu chính — không bao giờ dùng Playwright canvas làm reference design
- **Python** cho hex conversion — jq `tostring` cho decimal, KHÔNG phải hex
- **Sleep 2s** giữa mỗi Figma API call để tránh 429
- **scale=2** trong Images API → 2x resolution, đủ rõ để visual compare
- **use_absolute_bounds=true** → export đúng bounds kể cả shadow/stroke nằm ngoài frame
- Mỗi lần chạy ghi đè `OUTPUT_DIR` — dùng node_id khác nhau để tạo folder riêng
