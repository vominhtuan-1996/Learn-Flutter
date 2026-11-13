# Figma Export Skill — USAGE

Export SVG/PNG từ Figma node (và toàn bộ icon children) vào `assets/` dự án Flutter.

---

## Yêu cầu trước khi chạy

### 1. Figma Personal Access Token (bắt buộc)

Skill dùng Figma REST API — cần token để xác thực.

**Tạo token:**
1. Đăng nhập [figma.com](https://www.figma.com)
2. Click avatar góc trên phải → **Settings**
3. Tab **Security** → mục **Personal access tokens**
4. Click **Generate new token** → đặt tên (ví dụ `figma-export`) → **Generate**
5. Copy token (chỉ hiển thị 1 lần)

Token có dạng: `figd_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

### 2. Cấu hình `.env`

**Tạo file `.env` từ template:**
```bash
cp .env.example .env
```

**Điền token vào `.env`:**
```
FIGMA_TOKEN=figd_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> `.env` đã có trong `.gitignore` — không bị commit lên git.

**File `.env.example`** (đã có sẵn trong repo, commit được):
```
# Figma Personal Access Token
# Generate at: figma.com → Account Settings → Security → Personal Access Tokens
FIGMA_TOKEN=your_figma_pat_here
```

---

## Cú pháp

```
/figma-export <figma_url> [--format svg|png] [--dest assets/icons|assets/images]
```

| Option | Default | Mô tả |
|--------|---------|-------|
| `--format svg` | svg | Export format |
| `--format png` | — | Export PNG thay vì SVG |
| `--dest assets/icons` | assets/icons | Thư mục lưu file trong `learnflutter/` |
| `--dest assets/images` | — | Lưu vào images thay vì icons |

---

## Ví dụ

```bash
# Export SVG icons từ node (mặc định)
/figma-export https://www.figma.com/design/TSglut4FUaRQMTiw6qfbxs/Untitled?node-id=101-2534

# Export PNG vào assets/images
/figma-export https://www.figma.com/design/TSglut4FUaRQMTiw6qfbxs/Untitled?node-id=101-2534 --format png --dest assets/images
```

---

## Skill làm gì

1. Đọc `FIGMA_TOKEN` từ `.env` — dừng nếu chưa cấu hình
2. Gọi Figma API lấy node tree của node được chỉ định
3. Tìm icon candidates: FRAME/COMPONENT/GROUP chứa VECTOR trong subtree, ưu tiên node tên `"SVG"`
4. Batch export qua Figma Images API (20 IDs/request, tự retry khi 429)
5. Download SVG/PNG về `learnflutter/assets/icons/` (hoặc `--dest`)
6. **Dedup:** normalize SVG (bỏ clip-path IDs), so sánh content — xoá file trùng
7. Cập nhật `pubspec.yaml` nếu cần thêm asset folder
8. Thêm constants vào `lib/app/assets/app_assets.dart`
9. Tạo `.figma-snapshots/export_<NODE_ID>/SUMMARY.md`

---

## Output

```
learnflutter/assets/icons/
├── ic_home.svg
├── ic_search.svg
└── ...

.figma-snapshots/export_101-2534/
├── nodes_raw.json       ← raw Figma API response
├── icons_final.tsv      ← danh sách nodes được export
├── images_batch_1.json  ← S3 URLs từ Figma
└── SUMMARY.md           ← báo cáo: exported / failed / duplicates
```

---

## Lỗi thường gặp

| Lỗi | Nguyên nhân | Fix |
|-----|-------------|-----|
| `❌ FIGMA_TOKEN chưa cấu hình` | `.env` thiếu token | Điền token vào `.env` |
| API 403 | Token hết hạn hoặc sai | Generate token mới |
| API 404 | FILE_KEY hoặc NODE_ID sai | Kiểm tra URL |
| API 429 | Rate limit | Skill tự retry sau 5s |
| Tên file `ic_vector_1`, `ic_vector_2`... | Node trong Figma chưa đặt tên | Nhờ designer đặt tên cho FRAME/COMPONENT trong Figma |

---

## Lưu ý

- SVG từ Figma tương thích với `flutter_svg` — không cần xử lý thêm
- Tên constants trong `AppAssets` dùng index tạm (`icVector1`, `icBgShadow1`...) — rename thành tên mô tả khi biết icon name
- Nếu Figma node có nhiều variant (light/dark, size...) → mỗi variant export thành file riêng
