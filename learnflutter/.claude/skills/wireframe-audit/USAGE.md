# Wireframe Audit Skill — USAGE

So sánh UI app thực tế (chụp qua Maestro/simulator) với wireframe do user cung cấp. Output: diff report + danh sách fix cụ thể trong code Flutter.

---

## Setup (lần đầu)

```bash
# Đảm bảo simulator đang chạy
xcrun simctl list devices booted

# Nếu chưa boot:
xcrun simctl boot <SIMULATOR_UDID>
open -a Simulator

# .wireframe-audit-output/ đã gitignored tự động
echo ".wireframe-audit-output/" >> .gitignore
```

---

## Cách Dùng

### Audit từ Figma snapshot

```bash
# Audit toàn bộ màn hình login
/wireframe-audit .figma-snapshots/101-2534 login

# Chỉ audit header
/wireframe-audit .figma-snapshots/101-2534 login --section header

# Chỉ audit body
/wireframe-audit .figma-snapshots/101-2534 login --section body
```

### Audit từ ảnh PNG/JPG trực tiếp

```bash
/wireframe-audit ~/Desktop/login_wireframe.png login
/wireframe-audit /path/to/figma_export.png home --section header
```

### Với Maestro flow để navigate đúng màn hình

```bash
# Dùng flow login để app ở đúng màn hình trước khi chụp
/wireframe-audit .figma-snapshots/101-2534 login \
  --flow lib/features/auth/.maestro/root.yaml \
  --section header

# Chỉ định device cụ thể
/wireframe-audit .figma-snapshots/101-2534 login \
  --device EDB06BB0-4C88-4F72-B404-9DF9B2D88E2D
```

### Workflow đầy đủ (Figma → Audit → Fix → Re-audit)

```bash
# 1. Inspect Figma để lấy design tokens
/figma-inspect https://www.figma.com/design/... 101-2534

# 2. Audit màn hình
/wireframe-audit .figma-snapshots/101-2534 login --section header

# 3. Review AUDIT_REPORT.md, apply fixes từ Claude

# 4. Re-audit để verify
/wireframe-audit .figma-snapshots/101-2534 login --section header
```

---

## Output

```
.wireframe-audit-output/login_20260917_143022/
├── wireframe.png        ← wireframe (copy từ input)
├── app_actual.png       ← screenshot app thực tế
└── AUDIT_REPORT.md      ← diff report đầy đủ
```

**AUDIT_REPORT.md** bao gồm:
- Ảnh wireframe vs app side-by-side
- List ✅ khớp / ❌ không khớp / ⚠️ cần confirm
- Table chi tiết: component, wireframe value, actual value, file:line cần sửa
- Code snippet fix cụ thể

---

## Ví Dụ Output

```
❌ 3 diffs tìm thấy:

CRITICAL:
  [1] Scaffold backgroundColor: surface (trắng) vs wireframe surfaceContainerHighest (xanh nhạt)
      Fix: login_page.dart:52

MINOR:
  [2] LangSwitcher height: 30.h vs wireframe ~22px
      Fix: app_dimens.dart:65
  [3] Header icon spacing: spacingXS (4px) vs wireframe ~6px
      Fix: login_page.dart:179

Apply fixes? (y/N)
```

---

## Tips

- **Dùng `--section header`** để focus vào 1 phần, tránh noise từ phần khác
- **Kết hợp `/figma-inspect` trước** để có pixel values chính xác trong `SUMMARY.md`
- **Chạy Maestro flow trước khi audit** nếu cần app ở state cụ thể (đã login, v.v.)
- **Re-audit sau khi fix** để xác nhận đã khớp wireframe
