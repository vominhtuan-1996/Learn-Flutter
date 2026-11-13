---
name: wireframe-audit
description: "So sánh UI app thực tế với wireframe/Figma snapshot. Dùng Maestro chụp screenshot app, đọc ảnh wireframe do user cung cấp, report diff từng component. Trigger: /wireframe-audit, 'audit wireframe', 'so sánh wireframe', 'UI không match', 'header không match'."
license: MIT
version: 1.0.0
argument-hint: "<wireframe_path> <screen_name> [--device <udid>] [--section <header|body|footer>]"
---

# Wireframe Audit Skill

So sánh UI Flutter app thực tế (chụp qua Maestro) với wireframe do user cung cấp (ảnh PNG/JPG hoặc thư mục `.figma-snapshots/`). Output: diff report từng component, list việc cần fix trong code Flutter.

> 📖 Hướng dẫn: xem [USAGE.md](USAGE.md).

---

## Arguments

`$ARGUMENTS`:
- `<wireframe_path>` — path tới ảnh wireframe hoặc thư mục `.figma-snapshots/<node_id>/`
- `<screen_name>` — tên màn hình / feature (ví dụ: `login`, `home`, `profile`)
- `--device <udid>` — chỉ định simulator (mặc định: booted simulator)
- `--section <header|body|footer|full>` — chỉ audit 1 phần (mặc định: `full`)
- `--flow <path>` — Maestro flow YAML để navigate đến màn hình (mặc định: tự tạo flow launchApp)

**Ví dụ:**
```
/wireframe-audit .figma-snapshots/101-2534 login --section header
/wireframe-audit .figma-snapshots/101-2534 login
/wireframe-audit ~/Desktop/login_wireframe.png login --device EDB06BB0-4C88-4F72-B404-9DF9B2D88E2D
/wireframe-audit .figma-snapshots/101-2534 login --flow lib/features/auth/.maestro/root.yaml
```

---

## Instructions

### 0. Parse Arguments

Từ `$ARGUMENTS`:
- `WIREFRAME_PATH` = first arg (absolute nếu bắt đầu bằng `/` hoặc `~`, sinon prepend project root)
- `SCREEN_NAME` = second arg
- `DEVICE` = `--device` value hoặc `""` (tự detect booted simulator)
- `SECTION` = `--section` value hoặc `"full"`
- `FLOW_PATH` = `--flow` value hoặc `""` (sẽ tạo flow tạm)

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
OUTPUT_DIR="$PROJECT_ROOT/.wireframe-audit-output/${SCREEN_NAME}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"
```

---

### 1. Resolve Wireframe

**Nếu `WIREFRAME_PATH` là thư mục** (`.figma-snapshots/<id>/`):
- Tìm ảnh phù hợp với `SCREEN_NAME` trong thư mục: ưu tiên `*_5x.png`, `*_1x.png`, `SUMMARY.md`
- Đọc `SUMMARY.md` nếu có → extract design tokens (padding, color, typography, sizes)
- Copy ảnh wireframe vào `OUTPUT_DIR/wireframe.png`

**Nếu là file ảnh trực tiếp**:
- Copy vào `OUTPUT_DIR/wireframe.png`
- Không có design tokens → chỉ visual comparison

**Đọc wireframe** bằng Read tool (image) → ghi nhớ visual:
- Layout tổng thể (horizontal/vertical, căn chỉnh)
- Các component nhìn thấy (logo, text, button, input, icon)
- Màu sắc nổi bật
- Kích thước tương đối

---

### 2. Detect Device

Ưu tiên theo thứ tự: `--device` arg → connected physical device → booted simulator → available simulators. **Không tự động boot simulator** — hỏi user trước.

```bash
# 1. Dùng --device arg nếu có
if [ -n "$DEVICE" ]; then
  DEVICE_ARG="$DEVICE"
  echo "Device (from arg): $DEVICE_ARG"
else
  # 2. Physical device thật đang kết nối (iOS + Android)
  PHYSICAL=$(idb list-targets 2>/dev/null | grep -v simulator | grep -oE '[A-F0-9-]{36}' | head -1)

  # 3. Booted simulator
  BOOTED_IOS=$(xcrun simctl list devices booted 2>/dev/null | grep -oE '[A-F0-9-]{36}' | head -1)
  BOOTED_ANDROID=$(adb devices 2>/dev/null | grep -v 'List of devices' | grep 'device$' | awk '{print $1}' | head -1)

  DEVICE_ARG="${PHYSICAL:-${BOOTED_IOS:-$BOOTED_ANDROID}}"
fi
```

**Nếu tìm thấy device** (`DEVICE_ARG` không rỗng):
- Log: `"Found device: <DEVICE_ARG> — proceeding"`
- Tiếp tục sang bước 3

**Nếu KHÔNG tìm thấy device** (`DEVICE_ARG` rỗng):

1. List các simulator/emulator available (chưa boot):
```bash
# iOS simulators available
xcrun simctl list devices available 2>/dev/null | grep -E '(iPhone|iPad)' | grep -v unavailable | head -10

# Android emulators available
emulator -list-avds 2>/dev/null | head -5
```

2. **Hỏi user** (dùng AskUserQuestion tool):
```
Không tìm thấy device/simulator đang chạy.

Available simulators:
  [list từ lệnh trên]

Chọn 1 trong các option:
  A) Boot simulator: <tên simulator> (UDID: <udid>)
  B) Nhập UDID thủ công
  C) Huỷ audit
```

3. Chờ user trả lời:
   - Nếu chọn A → boot simulator được chọn rồi tiếp tục:
     ```bash
     xcrun simctl boot <UDID>
     open -a Simulator
     # Đợi app khởi động (5s)
     ```
   - Nếu chọn B → dùng UDID user nhập làm `DEVICE_ARG`
   - Nếu chọn C hoặc không rõ → dừng, báo lệnh user tự chạy:
     ```
     Huỷ audit. Để chạy lại sau khi có device:
       xcrun simctl boot <UDID>
       /wireframe-audit <args>
     ```

---

### 3. Chụp Screenshot App Thực Tế

**Option A — Dùng Maestro flow có sẵn (`--flow` được cung cấp)**:
```bash
source "$PROJECT_ROOT/.env.maestro" 2>/dev/null || true
ENV_FLAGS=$(grep -v '^#' "$PROJECT_ROOT/.env.maestro" 2>/dev/null | grep '=' | sed 's/^/--env /' | tr '\n' ' ')
maestro --device "$DEVICE_ARG" test $FLOW_PATH $ENV_FLAGS 2>&1
```
Sau khi flow chạy xong, chụp screenshot hiện tại:
```bash
xcrun simctl io "$DEVICE_ARG" screenshot "$OUTPUT_DIR/app_actual.png"
```

**Option B — Không có flow, tạo flow tạm để launchApp + chụp**:

Tạo `$OUTPUT_DIR/_audit_launch.yaml`:
```yaml
appId: com.fpt.isc.prod
name: "[Audit] Launch for screenshot"
---
- launchApp:
    clearState: false
- takeScreenshot: <path>
```
Thay `<path>` bằng `$OUTPUT_DIR/app_actual.png`.

```bash
maestro --device "$DEVICE_ARG" test "$OUTPUT_DIR/_audit_launch.yaml" 2>&1
```

**Fallback** nếu Maestro không available:
```bash
xcrun simctl io "$DEVICE_ARG" screenshot "$OUTPUT_DIR/app_actual.png"
echo "Maestro không available, chụp trực tiếp từ simulator"
```

---

### 4. Đọc Cả Hai Ảnh

Dùng Read tool để đọc:
1. `OUTPUT_DIR/wireframe.png` → visual analysis wireframe
2. `OUTPUT_DIR/app_actual.png` → visual analysis app thực tế

---

### 5. So Sánh Từng Section

Tùy `SECTION`:

#### `header` — chỉ phân tích phần header/app bar
Phân tích (wireframe vs app):
- Logo: đúng asset? đúng size?
- Divider: có/không, màu đúng?
- Icon + text branding: đúng font weight? đúng spacing?
- Actions bên phải (lang switcher, theme toggle): đúng style?
- Background màu header

#### `body` — phần nội dung chính
- Layout tổng thể: padding, alignment
- Từng component: form fields, buttons, cards
- Spacing giữa các element
- Typography: font size, weight

#### `footer` — phần cuối
- Button CTA: size, color, corner radius, text
- Secondary actions

#### `full` — toàn bộ màn hình
Phân tích tất cả sections trên.

---

### 6. Tạo Audit Report

Lưu `OUTPUT_DIR/AUDIT_REPORT.md`:

````markdown
# Wireframe Audit — <SCREEN_NAME>

**Date:** <timestamp>
**Section audited:** <SECTION>
**Wireframe:** <WIREFRAME_PATH>
**Device:** <DEVICE_ARG>

---

## Screenshots

| Wireframe | App Thực Tế |
|-----------|-------------|
| ![wireframe](wireframe.png) | ![actual](app_actual.png) |

---

## Diff Report

### ✅ Khớp
- (list các component đúng)

### ❌ Không Khớp — Cần Fix

| # | Component | Wireframe | App Thực Tế | File cần sửa | Fix |
|---|-----------|-----------|-------------|--------------|-----|
| 1 | Header background | surface white | ... | login_page.dart | ... |
| 2 | Lang switcher style | orange pill | ... | login_page.dart:221 | ... |

### ⚠️ Không Xác Định (cần confirm)
- (list ambiguous diffs)

---

## Action Items

```dart
// Fix 1: <mô tả>
// File: lib/features/auth/screens/login_page.dart:163
```

### Priority
- 🔴 Critical (layout sai rõ ràng)
- 🟡 Minor (color/spacing nhỏ)
- 🟢 Cosmetic (pixel perfect)
````

---

### 7. Đề Xuất Fix Code

Với mỗi diff tìm thấy:
1. **Locate file:line** — grep codebase tìm component liên quan
2. **Show current code** vs **expected per wireframe**
3. **Propose minimal fix** — chỉ sửa diff, không refactor thêm

Ví dụ output:
```
❌ Header: Scaffold background không set → body dùng surface thay vì surfaceContainerHighest

Fix tại login_page.dart:52:
  Scaffold(
+   backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    body: ...

❌ LangSwitcher height: 30.h vs wireframe 22px

Fix tại app_dimens.dart:
- static double get langSwitcherHeight => 30.h;
+ static double get langSwitcherHeight => 22.h;
```

Sau khi list tất cả fixes → hỏi user: **"Apply fixes? [y/N]"** trước khi chỉnh code.

---

### 8. Báo Cáo

Output cuối:
- Tổng số diff tìm thấy (critical / minor / cosmetic)
- Path `AUDIT_REPORT.md`
- Danh sách file Flutter cần sửa
- Lệnh re-run audit sau khi fix: `/wireframe-audit <args>`

---

## Error Handling

| Lỗi | Xử lý |
|-----|-------|
| Không có simulator booted | List available simulators → hỏi user chọn hoặc huỷ — KHÔNG tự boot |
| Maestro không install | Fallback: `xcrun simctl io screenshot` |
| Wireframe path không tồn tại | Báo lỗi path, list .figma-snapshots/ có sẵn |
| App chưa install trên simulator | Báo lỗi + hướng dẫn build |
| Ảnh quá nhỏ/mờ để phân tích | Log warning, tiếp tục với best effort |

---

## Output Files

```
.wireframe-audit-output/<screen>_<timestamp>/
├── wireframe.png          ← ảnh wireframe (copy)
├── app_actual.png         ← screenshot app thực tế
├── _audit_launch.yaml     ← Maestro flow tạm (nếu dùng)
└── AUDIT_REPORT.md        ← full diff report
```

`.wireframe-audit-output/` đã gitignored.

---

## Notes

- Skill **không tự apply fix** — chỉ propose, hỏi user trước.
- Nếu có `SUMMARY.md` từ figma-inspect → dùng design tokens để diff chính xác hơn (pixel values thay vì visual estimate).
- Re-run audit sau khi fix để verify — `/wireframe-audit <args>` lại.
- Kết hợp với `/figma-inspect` để có design tokens đầy đủ trước khi audit.
