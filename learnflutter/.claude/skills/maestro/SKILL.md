---
name: maestro
description: "Tạo flow Maestro YAML trực tiếp trong module từ mô tả, sau đó chạy test. Credential đọc từ .env.maestro (gitignored). Trigger: /maestro, 'chạy maestro', 'run maestro test', 'tạo maestro flow', 'viết test maestro'."
license: MIT
version: 2.0.0
argument-hint: "<module>/<flow_name> \"<description>\" [--device <id>] [--run] [--env <file>]"
---

# Maestro Skill — learnflutter

Sinh Maestro flow YAML từ mô tả ngôn ngữ tự nhiên, lưu vào đúng module folder, rồi chạy test.

## Arguments

`$ARGUMENTS`:
- `<module>/<flow_name> "<description>"` → tạo flow mới từ mô tả, lưu vào `.maestro/<module>/`
- `<module>/<flow_name>` (không có description) → chạy flow đã có
- `<module>/` → chạy tất cả flow trong module đó
- `--run` → sau khi tạo flow, chạy ngay
- `--device <udid>` → chỉ định device/simulator
- `--env <path>` → env file thay thế (mặc định `.env.maestro`)

**Ví dụ:**
```
/maestro login/root "Đăng nhập thành công với tài khoản Root, assert màn biometric onboarding xuất hiện"
/maestro login/login_fail "Đăng nhập sai mật khẩu, assert snackbar lỗi hiện ra" --run
/maestro login/root --run --device EDB06BB0-4C88-4F72-B404-9DF9B2D88E2D
/maestro login/
```

---

## Instructions

### Bước 1 — Kiểm tra môi trường

```bash
which maestro || echo "MAESTRO_NOT_FOUND"
xcrun simctl list devices | grep "(Booted)" | head -3
```

Nếu maestro chưa install → báo `brew install maestro` và dừng.

---

### Bước 2 — Đọc / khởi tạo .env.maestro

**Kiểm tra:**
```bash
test -f /Users/tuanios_su12/learn_flutter/.env.maestro && echo "EXISTS" || echo "MISSING"
```

**Nếu MISSING** → tạo template từ `.env.maestro.example` (nếu có) hoặc tạo mới:
```bash
# Ưu tiên copy từ example
cp /Users/tuanios_su12/learn_flutter/.env.maestro.example \
   /Users/tuanios_su12/learn_flutter/.env.maestro 2>/dev/null || \
cat > /Users/tuanios_su12/learn_flutter/.env.maestro << 'EOF'
# Maestro test credentials — KHÔNG commit file này
ROOT_USERNAME=
ROOT_PASSWORD=
IT_003_USERNAME=
IT_003_PASSWORD=
IT_005_USERNAME=
IT_005_PASSWORD=
ADMIN_USERNAME=
ADMIN_PASSWORD=
ACCOUNTANT_USERNAME=
ACCOUNTANT_PASSWORD=
EOF
```

Đảm bảo `.env.maestro` có trong `.gitignore`:
```bash
grep -q "^\.env\.maestro$" /Users/tuanios_su12/learn_flutter/.gitignore \
  || echo ".env.maestro" >> /Users/tuanios_su12/learn_flutter/.gitignore
```

Báo user điền credential rồi dừng.

**Nếu EXISTS** → load keys (không in values):
```bash
grep "^[A-Z_]*=" /Users/tuanios_su12/learn_flutter/.env.maestro | cut -d= -f1
```

---

### Bước 3 — Parse arguments

Tách `$ARGUMENTS` thành:
- `MODULE` = phần đầu trước `/` (ví dụ: `login`)
- `FLOW_NAME` = phần sau `/` trước `"` hoặc flag (ví dụ: `root`, `login_fail`)
- `DESCRIPTION` = nội dung trong `"..."` nếu có
- `FLAGS` = `--run`, `--device`, `--env`

**Xác định flow path:**
```
learnflutter/lib/features/<MODULE>/.maestro/<FLOW_NAME>.yaml
```

**Xác định chế độ:**
- Có `DESCRIPTION` → **GEN mode**: sinh flow mới từ mô tả
- Không có `DESCRIPTION` và file đã tồn tại → **RUN mode**: chạy flow có sẵn
- Không có `DESCRIPTION` và file chưa tồn tại → báo lỗi, liệt kê flows có sẵn

---

### Bước 4 — GEN MODE: Sinh flow YAML từ mô tả

> Thực hiện khi `$ARGUMENTS` chứa description (chuỗi trong `"..."`)

#### 4a. Đọc context module

Trước khi sinh YAML, đọc:
1. Các subflow đã có trong module:
```bash
ls learnflutter/lib/features/<MODULE>/.maestro/_*.yaml 2>/dev/null
```

2. Xem nội dung subflow để hiểu các step có sẵn:
```bash
# Ví dụ với login module
cat learnflutter/lib/features/auth/.maestro/_login_subflow.yaml 2>/dev/null
```

3. Đọc màn hình liên quan trong `lib/features/<MODULE>/screens/` để biết:
   - Tên text button/field bằng tiếng Việt (từ localization)
   - Các state có thể assert

4. Đọc localization keys:
```bash
grep -E "static const String|vi:" learnflutter/lib/app/localization/app_local_translate.dart | head -60
```

#### 4b. Phân tích description

Từ `DESCRIPTION`, xác định:

| Yếu tố | Cách nhận biết |
|--------|----------------|
| **Module** | "đăng nhập", "login" → `login/` |
| **Account role** | "root", "IT", "admin", "kế toán" → map sang env var prefix |
| **Happy path** | "thành công", "success" → assert màn kết quả |
| **Error path** | "sai", "lỗi", "fail" → assert snackbar/error text |
| **Custom steps** | các action cụ thể user mô tả |
| **Assert target** | những gì "xuất hiện", "visible", "hiển thị" |

**Mapping role → env var:**
| Role trong description | USERNAME var | PASSWORD var |
|-----------------------|--------------|--------------|
| root / Root | `${ROOT_USERNAME}` | `${ROOT_PASSWORD}` |
| IT 003 / it_003 | `${IT_003_USERNAME}` | `${IT_003_PASSWORD}` |
| IT 005 / it_005 | `${IT_005_USERNAME}` | `${IT_005_PASSWORD}` |
| admin / Admin | `${ADMIN_USERNAME}` | `${ADMIN_PASSWORD}` |
| kế toán / accountant | `${ACCOUNTANT_USERNAME}` | `${ACCOUNTANT_PASSWORD}` |

#### 4c. Sinh YAML

**Quy tắc khi sinh YAML:**

1. **Header bắt buộc:**
```yaml
appId: com.fpt.isc.prod   # staging; dùng com.fpt.isc.prod cho prod
name: "[<MODULE_UPPER>] <flow_name> — <description ngắn gọn>"
```

2. **Tên file = `FLOW_NAME`.yaml**, lưu tại `learnflutter/lib/features/<MODULE>/.maestro/`

3. **Credential KHÔNG bao giờ hardcode** — chỉ dùng `${VAR_NAME}` placeholder

4. **Tái dùng subflow** nếu có — dùng `runFlow` thay vì duplicate steps

5. **Maestro commands hợp lệ** (đã kiểm chứng):
   - `launchApp` (với `clearState: false` — `true` gây lỗi khi app chưa chạy)
   - `tapOn: {text: "..."}` — tìm theo text hiển thị trên UI (tiếng Việt nếu locale VI)
   - `inputText: ${VAR}` — nhập text, sau khi đã `tapOn` field
   - `hideKeyboard`
   - `extendedWaitUntil: {visible: {text: "..."}, timeout: 15000}` — wait với timeout
   - `assertVisible: {text: "..."}` — assert ngay (không timeout)
   - `assertNotVisible: {text: "..."}` — assert không có
   - `runFlow: {file: "./_subflow.yaml", env: {KEY: ${VAR}}}`
   - `scrollUntilVisible: {element: {text: "..."}, direction: DOWN}`
   - `pressKey: Enter`
   - `back`

6. **KHÔNG dùng** (lỗi đã biết):
   - `clearText` → invalid command
   - `assertVisible: {text: ..., timeout: ...}` → timeout không phải property của assertVisible

7. **Assert pattern:**
   - Happy path: `extendedWaitUntil visible` text màn tiếp theo
   - Error path: `extendedWaitUntil visible` text snackbar/error, sau đó `assertVisible` để confirm

**Template cơ bản — happy path login:**
```yaml
appId: com.fpt.isc.prod
name: "[AUTH] <flow_name> — <description>"
---
- launchApp:
    clearState: false
- runFlow:
    file: ./_login_subflow.yaml
    env:
      USERNAME: ${<ROLE>_USERNAME}
      PASSWORD: ${<ROLE>_PASSWORD}
```

**Template — error path (sai password):**
```yaml
appId: com.fpt.isc.prod
name: "[AUTH] login_fail — Đăng nhập sai mật khẩu, assert snackbar lỗi"
---
- launchApp:
    clearState: false
- tapOn:
    text: "Email người dùng"
- inputText: ${ROOT_USERNAME}
- tapOn:
    text: "Mật khẩu"
- inputText: "wrong_password"
- hideKeyboard
- tapOn:
    text: "Đăng nhập"
- extendedWaitUntil:
    visible:
      text: "Mật khẩu không đúng"
    timeout: 10000
- assertNotVisible:
    text: "Đăng nhập nhanh lần sau"
```

**Template — flow tuỳ chỉnh nhiều bước:**
```yaml
appId: com.fpt.isc.prod
name: "[AUTH] <flow_name> — <description>"
---
- launchApp:
    clearState: false

# Step 1: <mô tả>
- tapOn:
    text: "<text button/field>"
- inputText: ${<VAR>}

# Step 2: <mô tả>
- tapOn:
    text: "<next element>"

# Assert: <điều kiện thành công>
- extendedWaitUntil:
    visible:
      text: "<expected text>"
    timeout: 15000
```

#### 4d. Ghi file

Dùng Write tool để tạo file tại đường dẫn đã xác định.

Sau khi tạo, in:
```
✅ Tạo flow: learnflutter/lib/features/<MODULE>/.maestro/<FLOW_NAME>.yaml
   Name: [<MODULE_UPPER>] <flow_name> — <description>
   Credential: dùng ${<ROLE>_USERNAME} / ${<ROLE>_PASSWORD} từ .env.maestro
   
   Chạy: /maestro <module>/<flow_name> --run
```

Nếu `--run` có trong arguments → tiếp tục sang Bước 5.

---

### Bước 5 — RUN MODE: Chạy flow

#### 5a. Xác định device

```bash
# Lấy UDID simulator đang booted
xcrun simctl list devices | grep "(Booted)" | grep -oE "[0-9A-F-]{36}" | head -1
```

Thứ tự ưu tiên:
1. `--device <id>` từ argument
2. Simulator đang booted
3. Không có → hỏi user `xcrun simctl boot <UDID>`

#### 5b. Load env và xác định vars cần thiết

```bash
set -a && source /Users/tuanios_su12/learn_flutter/.env.maestro && set +a
```

Scan file YAML để tìm tất cả `${VAR_NAME}` được dùng:
```bash
grep -oE '\$\{[A-Z_]+\}' learnflutter/lib/features/<MODULE>/.maestro/<FLOW_NAME>.yaml | sort -u
```

Map từng `${VAR}` → `--env VAR=$VAR` flag.

#### 5c. Construct và chạy lệnh

```bash
cd /Users/tuanios_su12/learn_flutter
set -a && source .env.maestro && set +a

maestro test learnflutter/lib/features/<MODULE>/.maestro/<FLOW_NAME>.yaml \
  --device <DEVICE_UDID> \
  $(grep -oE '\$\{[A-Z_]+\}' learnflutter/lib/features/<MODULE>/.maestro/<FLOW_NAME>.yaml \
    | sort -u \
    | sed 's/\${\(.*\)}/--env \1=${\1}/' \
    | envsubst)
```

Hoặc build `--env` flags thủ công từ danh sách vars đã scan.

**Bảo mật:** Shell expand `$VAR` → giá trị thật chỉ tồn tại trong process env, không in ra.

#### 5d. Parse và hiển thị kết quả

```
══ Maestro Test Results ════════════════════════════
Flow:    <module>/<flow_name>.yaml
Name:    [<MODULE>] <description>
Device:  <simulator_name> (<UDID_short>)

  ✅ Launch app
  ✅ <step description>
  ...
  ✅/❌ Assert "<expected text>" visible

PASSED ✅  (N/N steps)   hoặc   FAILED ❌  (M/N steps)
════════════════════════════════════════════════════
```

#### 5e. Nếu FAILED — tự debug

1. Đọc screenshot cuối:
```bash
LATEST=$(ls -t ~/.maestro/tests/ | head -1)
FLOW_DIR=$(ls "/Users/tuanios_su12/.maestro/tests/$LATEST/")
LAST_SS=$(ls -t "/Users/tuanios_su12/.maestro/tests/$LATEST/$FLOW_DIR/screenshots/" | head -1)
```
→ Dùng Read tool đọc screenshot, mô tả trạng thái UI.

2. Chẩn đoán và gợi ý:

| Triệu chứng | Nguyên nhân | Fix |
|------------|-------------|-----|
| Assert text fail, UI vẫn ở login | API trả lỗi | curl test endpoint, kiểm tra `.env.maestro` |
| `Tap on "X"` fail | Text không tìm thấy | Kiểm tra locale (VI/EN), thử `index: N` |
| `Launch app` fail | Bundle ID sai | `xcrun simctl listapps <UDID> \| grep learnflutter` |
| `Config Section Required` | Subflow thiếu header | Thêm `appId:\n---` đầu file |
| Text VI không tìm thấy | App đang dùng EN locale | Đổi device sang VI locale |

---

### Bước 6 — Liệt kê flows (không có argument)

Nếu không có argument hoặc chỉ có module:
```bash
find learnflutter/lib/features -path "*/.maestro/*.yaml" ! -name "_*" | sort | while read f; do
  name=$(grep "^name:" "$f" | sed 's/name: //')
  echo "$f  →  $name"
done
```

---

## Cấu trúc .maestro/

```
learnflutter/lib/features/
└── <module>/
    ├── cubit/
    ├── state/
    ├── repos/
    ├── screens/
    └── .maestro/                      ← co-located với feature code
        ├── _<module>_subflow.yaml     ← subflow tái dùng (không chạy trực tiếp)
        ├── <flow_name>.yaml           ← flow sinh từ description
        ├── ...
        └── all_roles.yaml             ← chạy tất cả flows
```

Ví dụ auth feature:
```
learnflutter/lib/features/auth/
└── .maestro/
    ├── _login_subflow.yaml
    ├── root.yaml
    ├── it_003.yaml
    ├── it_005.yaml
    ├── admin.yaml
    ├── accountant.yaml
    └── all_roles.yaml
```

**Naming convention:**
- Subflow: tiền tố `_` (bị skip khi chạy folder)
- Flow file: snake_case, mô tả ngắn scenario (`login_success`, `login_wrong_pass`, `login_2fa`)
- `name` trong YAML: `[MODULE_UPPER] flow_name — mô tả`

---

## Quy tắc bảo mật credential (bất biến)

1. **KHÔNG** hardcode credential trong bất kỳ YAML file nào — kể cả test data
2. **CHỈ** dùng `${ENV_VAR_NAME}` placeholder trong YAML
3. **KHÔNG** in giá trị credential vào output terminal
4. `.env.maestro` bắt buộc có trong `.gitignore`
5. Chỉ commit `.env.maestro.example` (không có giá trị thật)

---

## Lỗi đã biết & fix

| Lỗi | Fix |
|-----|-----|
| `0 devices connected` | `xcrun simctl boot <UDID> && open -a Simulator` |
| `Config Section Required` | Thêm `appId: ...\n---` trước steps (ngay dòng 1, trước cả comment) |
| `Invalid Command: clearText` | Bỏ — field trống sau `launchApp` fresh |
| `Unknown Property: timeout` trong assertVisible | Dùng `extendedWaitUntil` |
| `Failed to launch app` | Sai bundle ID → check với `xcrun simctl listapps <UDID> \| grep learnflutter` |
| `clearState: true` lỗi | Đổi `clearState: false` |
| Assert fail ngay sau tap login | API lỗi hoặc timeout — curl test credential trước |
