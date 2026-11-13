---
name: figma-export
description: "Quét child nodes của 1 Figma node, export SVG/PNG từng node ra thư mục assets/ dự án Flutter. Trigger: \"figma export\", \"export asset figma\", \"/figma-export <url> [--format svg|png] [--dest assets/icons]\""
license: MIT
version: 1.1.0
argument-hint: "<figma_url> [--format svg|png] [--dest assets/icons|assets/images]"
---

# Figma Export Skill

Dùng Figma REST API + Personal Access Token để lấy child nodes và export SVG/PNG, lưu vào `assets/` dự án Flutter.

## Arguments

`$ARGUMENTS` — `<figma_url>` + options:
- `--format svg` (default) hoặc `--format png`
- `--dest assets/icons` (default) hoặc `--dest assets/images`

Ví dụ:
- `/figma-export https://www.figma.com/design/KEY/Name?node-id=101-2534`
- `/figma-export https://www.figma.com/design/KEY/Name?node-id=101-2534 --format png --dest assets/images`

---

## Instructions

### ⚡ Cách chạy mặc định — dùng script Python (thay cho bước 1–3b)

```bash
python3 .claude/skills/figma-export/figma_export.py "<figma_url>" [--dest learnflutter/assets/icons] [--fig file.fig]
```

- **Hướng 2 (mặc định):** 1 request `/nodes?geometry=paths` (cache tại `.figma-snapshots/export_<id>/nodes_raw.json`, chạy lại không tốn call), Python tự dựng SVG. Không gọi `/images`, không tải S3 → ít quota hơn.
- **Hướng 1 (fallback):** nếu script thoát với `RATE_LIMIT: Figma 429` → bảo user: Figma → File → Save local copy → chạy lại với `--fig /path/file.fig` (không cần API). Nếu báo zstd → `pip3 install zstandard`.
- Icon = container chỉ chứa vector; wrapper 1 con (vd `Overlay+Border > SVG`) được bỏ qua. Tên file lấy từ TEXT anh em khi tên node generic (`SVG`, `Vector`...).
- `--pick ID=ten_file ...`: chỉ export node chỉ định, đặt tên tay (dùng khi tên node generic `SVG`/`Frame`, hoặc để bỏ icon trùng đã có trong repo). Ví dụ: `--pick 719:61=ic_stat_package 719:71=ic_stat_active`.
- File `.fig` mới thường nén zstd → cần `pip3 install --user zstandard`. File `.fig` đã được gitignore (`*.fig`), không commit.
- Giới hạn: chỉ solid fill/stroke (gradient lấy stop đầu), không rotation/mask/effect. Icon lệch → export tay node đó.
- Sau khi script chạy xong: làm tiếp bước 4 (pubspec), 5 (AppAssets), 6 (SUMMARY), 7 (báo cáo). Bước 0–3b bên dưới chỉ là phương án dự phòng REST `/images` khi script không dùng được.

### 0. Parse arguments + kiểm tra FIGMA_TOKEN

Từ `$ARGUMENTS`:
- `FIGMA_URL` = URL đầy đủ
- `FILE_KEY` = đoạn `/design/<FILE_KEY>/` trong URL
- `NODE_ID` = từ `node-id=` param, chuẩn hoá `-` (thay `%3A`/`:` → `-`)
- `PREFIX` = phần trước `-` của NODE_ID (ví dụ `101`)
- `SUFFIX` = phần sau `-` của NODE_ID (ví dụ `2534`)
- `FORMAT` = `svg` (default) hoặc `png` nếu có `--format png`
- `DEST_DIR` = `learnflutter/assets/icons` (default) hoặc giá trị `--dest`
- `OUTPUT_DIR` = `.figma-snapshots/export_<NODE_ID>/`

**Bắt buộc — đọc và kiểm tra FIGMA_TOKEN từ `.env`:**

```bash
FIGMA_TOKEN=$(grep -E '^FIGMA_TOKEN=' .env 2>/dev/null | cut -d= -f2 | tr -d '"' | tr -d "'")
```

Kiểm tra theo thứ tự:

1. Nếu `.env` không tồn tại:
   ```
   ❌ Chưa có file .env.
   Chạy: cp .env.example .env
   Sau đó điền FIGMA_TOKEN vào .env.
   ```
   → **dừng**.

2. Nếu `FIGMA_TOKEN` rỗng hoặc bằng `your_figma_pat_here`:
   ```
   ❌ FIGMA_TOKEN chưa được cấu hình trong .env.

   Cách lấy token:
   1. Vào https://www.figma.com → Account Settings → Security
   2. Mục "Personal access tokens" → Generate new token
   3. Điền vào .env:
      FIGMA_TOKEN=figd_xxxxxxxxxxxx
   ```
   → **dừng**.

3. Token có giá trị → tiếp tục.

Tạo `OUTPUT_DIR` và `DEST_DIR` nếu chưa có:
```bash
mkdir -p OUTPUT_DIR DEST_DIR
```

---

### 1. Lấy toàn bộ node tree + lọc SVG/PNG candidates

Dùng Bash + curl với `X-Figma-Token` header:

```bash
NODE_ID_COLON=$(echo "$NODE_ID" | tr '-' ':')  # 101-2534 → 101:2534

curl -s \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/$FILE_KEY/nodes?ids=$NODE_ID_COLON" \
  -o "$OUTPUT_DIR/nodes_raw.json"
```

Xử lý lỗi API:
- `"status": 403` → token sai/hết hạn → báo user, **dừng**
- `"status": 404` → FILE_KEY hoặc NODE_ID sai → báo user, **dừng**

**Nguyên tắc:** Icon = COMPONENT/FRAME/GROUP **chứa ít nhất 1 VECTOR/shape node** trong children (bất kỳ độ sâu). Export cả container, không export từng vector con riêng lẻ.

```
Icon (COMPONENT/FRAME)   ← export node này
  ├── VECTOR              ← KHÔNG export riêng
  ├── VECTOR              ← KHÔNG export riêng
  └── BOOLEAN_OPERATION   ← KHÔNG export riêng
```

**Lọc icon candidates — tìm COMPONENT/FRAME/GROUP có chứa vector trong subtree:**

```bash
VECTOR_TYPES='["VECTOR","BOOLEAN_OPERATION","ELLIPSE","LINE","POLYGON","STAR"]'
CONTAINER_TYPES='["COMPONENT","INSTANCE","FRAME","GROUP"]'

# Tìm các node CONTAINER mà trong subtree có ít nhất 1 VECTOR type
jq -r --argjson vtypes "$VECTOR_TYPES" --argjson ctypes "$CONTAINER_TYPES" '
  def has_vector:
    . as $node
    | (($node.children // []) | any(
        . as $child |
        ($vtypes | index($child.type)) != null or ($child | has_vector)
      ));

  .nodes[].document
  | ..
  | objects
  | select(.id != null)
  | select(.type as $t | $ctypes | index($t) != null)
  | select(has_vector)
  | "\(.id)\t\(.name)\t\(.type)"
' "$OUTPUT_DIR/nodes_raw.json" | sort -u > "$OUTPUT_DIR/svg_candidates.tsv"

echo "Icon candidates: $(wc -l < "$OUTPUT_DIR/svg_candidates.tsv")"
cat "$OUTPUT_DIR/svg_candidates.tsv"
```

**Lưu ý dedup:** Node cha và node con có thể cùng match (ví dụ FRAME chứa COMPONENT, COMPONENT chứa VECTOR). Ưu tiên lấy **node gần nhất với root** (ít depth nhất) để tránh export cùng icon nhiều lần. Nếu ID của node A là parent của node B → bỏ node B.

```bash
# Lọc bỏ nodes mà parent của chúng cũng có trong danh sách
# Giữ lại direct children của NODE_ID gốc
jq -r --arg root "101:2713" '
  .nodes[$root].document.children[]?
  | "\(.id)\t\(.name)\t\(.type)"
' "$OUTPUT_DIR/nodes_raw.json" > "$OUTPUT_DIR/direct_children.tsv"

# Intersect: chỉ giữ direct children có trong svg_candidates
comm -12 \
  <(sort "$OUTPUT_DIR/svg_candidates.tsv") \
  <(sort "$OUTPUT_DIR/direct_children.tsv") \
  > "$OUTPUT_DIR/export_nodes.tsv"

# Fallback: nếu direct children không match → dùng toàn bộ svg_candidates
[ ! -s "$OUTPUT_DIR/export_nodes.tsv" ] && cp "$OUTPUT_DIR/svg_candidates.tsv" "$OUTPUT_DIR/export_nodes.tsv"

echo "Final export nodes: $(wc -l < "$OUTPUT_DIR/export_nodes.tsv")"
cat "$OUTPUT_DIR/export_nodes.tsv"
```

Nếu không có candidate nào → node này không chứa icon → **dừng**, báo user.

Ghi lại `export_nodes` từ `export_nodes.tsv` (ID dạng `PREFIX:SUFFIX`).

---

### 2. Batch export qua Figma Images API

Gom `valid_nodes` thành batch 20 IDs, lặp từng batch:

```bash
# Ví dụ batch: ids=101:2535,101:2536,101:2537,...
IDS_PARAM=$(echo "${BATCH_IDS[@]}" | tr ' ' ',')

curl -s \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/$FILE_KEY?ids=$IDS_PARAM&format=$FORMAT&use_absolute_bounds=true" \
  -o "$OUTPUT_DIR/images_batch_${batch_index}.json"
```

Parse S3 URLs:
```bash
jq -r '.images | to_entries[] | "\(.key)\t\(.value)"' \
  "$OUTPUT_DIR/images_batch_${batch_index}.json"
# Kết quả: "101:2535\thttps://s3.amazonaws.com/..."
```

Xử lý:
- Nếu API 429 (rate limit) → `sleep 5` rồi retry
- Nếu URL là `null` → node không export được (group phức tạp) → bỏ qua, log vào SUMMARY.md

---

### 3. Download và lưu assets

Với mỗi `(node_id, s3_url)`:

```bash
# Đặt tên file từ node name (đã lấy ở bước 1)
NAME=$(echo "$NODE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//;s/_$//')
FILENAME="${NAME}.${FORMAT}"

# Download
curl -s "$S3_URL" -o "$DEST_DIR/$FILENAME"

# Backup vào OUTPUT_DIR
cp "$DEST_DIR/$FILENAME" "$OUTPUT_DIR/${index}_${node_id//:/- }.$FORMAT"
```

Sau khi download tất cả → ghi lại `exported_files = [{ node_id, name, filename, size }]`.

---

### 3b. Dedup — xoá file trùng content paths

Figma xuất clip-path ID khác nhau dù content vector giống hệt → MD5 khác nhau nhưng visual trùng.
Phải normalize trước khi so sánh.

```bash
TMP_NORM="/tmp/svg_norm_$$"
mkdir -p "$TMP_NORM"

# Normalize: bỏ clip-path IDs (chỉ giữ paths/shapes)
for f in "$DEST_DIR"/*.svg; do
  fname=$(basename "$f" .svg)
  sed 's/clip0_[0-9_]*//g
       s/id="clip[^"]*"//g
       s/url(#clip[^)]*)//g
       s/id="[^"]*[0-9]\{3,\}[^"]*"//g' "$f" \
    | tr -d ' \t\n' > "$TMP_NORM/$fname.norm"
done

# So sánh từng cặp, xoá file đến sau nếu trùng
REMOVED=()
KEPT=()

for f1 in "$TMP_NORM"/*.norm; do
  n1=$(basename "$f1" .norm)
  # Nếu đã bị xoá → bỏ qua
  echo "${REMOVED[@]}" | grep -qw "$n1" && continue

  for f2 in "$TMP_NORM"/*.norm; do
    n2=$(basename "$f2" .norm)
    # Chỉ compare n1 vs n2 (n1 < n2 alphabetically)
    [ "$n1" \< "$n2" ] || continue
    # Nếu n2 đã bị xoá → bỏ qua
    echo "${REMOVED[@]}" | grep -qw "$n2" && continue

    if diff -q "$f1" "$f2" > /dev/null 2>&1; then
      echo "DUP: $n2 == $n1 → xoá $n2, giữ $n1"
      rm "$DEST_DIR/$n2.svg"
      REMOVED+=("$n2")
    fi
  done
done

rm -rf "$TMP_NORM"
echo "Removed ${#REMOVED[@]} duplicates: ${REMOVED[*]}"
```

Sau bước này → cập nhật `exported_files` (bỏ các file đã xoá).
Ghi `removed_duplicates = [{ removed_file, kept_file }]` vào SUMMARY.md.

---

### 4. Cập nhật pubspec.yaml

```bash
PUBSPEC="learnflutter/pubspec.yaml"
ASSET_DIR=$(dirname "$DEST_DIR" | sed 's|learnflutter/||')  # assets/icons

# Kiểm tra đã có chưa
if ! grep -q "- $ASSET_DIR/" "$PUBSPEC"; then
  # Thêm vào sau dòng "assets:"
  sed -i '' "/assets:/a\\
    - $ASSET_DIR/" "$PUBSPEC"
fi
```

---

### 5. Cập nhật AppAssets

Đọc `learnflutter/lib/app/assets/app_assets.dart`, thêm constants cho từng file vừa export:

```dart
// Thêm vào trong class AppAssets
static const String icNodeName = 'assets/icons/node_name.svg';
```

Rules:
- Prefix `ic` cho icon/SVG nhỏ
- Prefix không có `ic` cho image lớn
- Chỉ thêm constant chưa tồn tại — không xoá constant cũ

---

### 6. Tạo SUMMARY.md

Lưu vào `OUTPUT_DIR/SUMMARY.md`:

```markdown
# Figma Export — Node <NODE_ID>

**File Key:** <FILE_KEY>
**Parent Node:** <NODE_ID>
**Format:** <FORMAT>
**Destination:** <DEST_DIR>/
**Exported:** <ISO timestamp>

## Exported Assets

| # | Node ID | Name | File | Size |
|---|---------|------|------|------|
| 1 | 101:2535 | icon_home | assets/icons/icon_home.svg | 1.2 KB |
...

## Failures
| Node ID | Name | Reason |
|---------|------|--------|
| 101:2540 | Frame 1 | export URL null |

## Duplicates Removed
| Removed | Kept (identical content) |
|---------|--------------------------|
| ic_foo_2.svg | ic_foo_1.svg |

## AppAssets constants added
\`\`\`dart
static const String icIconHome = 'assets/icons/icon_home.svg';
\`\`\`
```

---

### 7. Báo cáo

- Số node export thành công / thất bại
- List file đã tạo trong `DEST_DIR`
- Nhắc kiểm tra `SUMMARY.md` và `AppAssets`

---

## Error Handling

| Lỗi | Xử lý |
|-----|-------|
| `.env` không tồn tại | Dừng, hướng dẫn tạo từ `.env.example` |
| `FIGMA_TOKEN` rỗng | Dừng, hướng dẫn generate PAT |
| API 403 | Token hết hạn, dừng, hướng dẫn generate mới |
| API 404 | FILE_KEY hoặc NODE_ID sai, dừng |
| API 429 | Sleep 5s, retry |
| S3 URL null | Node không export được, bỏ qua, log vào SUMMARY |
| `pubspec.yaml` không tìm thấy | Cảnh báo, vẫn lưu file |
| `app_assets.dart` không tìm thấy | Cảnh báo, in constants để user tự thêm |

## Notes

- Figma Images API batch tối đa 20 IDs/request
- SVG từ Figma có thể chứa `<defs>` với font — OK cho Flutter `flutter_svg`
- PNG default scale=1. Thêm `&scale=2` vào API URL nếu cần 2x
- Frame lớn (screen) không nên export PNG — quá lớn; ưu tiên SVG
- Node type `VECTOR`, `BOOLEAN_OPERATION`, `COMPONENT` nhỏ = icon candidate
- Node type `FRAME`, `GROUP` lớn = thường không export, hoặc export PNG
