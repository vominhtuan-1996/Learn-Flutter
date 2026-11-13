# Maestro Skill — USAGE

Sinh Maestro flow YAML từ mô tả, lưu vào module folder, chạy test. Credential từ `.env.maestro`.

---

## Setup (lần đầu)

```bash
# 1. Install Maestro
brew install maestro

# 2. Tạo .env.maestro
cp .env.maestro.example .env.maestro
# điền credential vào .env.maestro

# 3. Build app lên simulator
cd learnflutter
flutter build ios --flavor staging -t lib/main_staging.dart --simulator --no-codesign
xcrun simctl boot <SIMULATOR_UDID>
xcrun simctl install <SIMULATOR_UDID> build/ios/iphonesimulator/Runner.app
open -a Simulator
```

---

## Cách dùng

### Tạo flow từ mô tả

```bash
# Tạo flow + chạy ngay
/maestro login/root "Đăng nhập thành công với tài khoản Root, assert màn biometric xuất hiện" --run

# Chỉ tạo flow (chưa chạy)
/maestro login/login_wrong_pass "Nhập sai mật khẩu, assert snackbar lỗi hiển thị, không navigate"

# Tạo flow tuỳ chỉnh nhiều bước
/maestro login/it_003 "Đăng nhập IT 003, kiểm tra role IT có quyền vào app" --run
```

### Chạy flow đã có

```bash
/maestro login/root --run
/maestro login/root --run --device EDB06BB0-4C88-4F72-B404-9DF9B2D88E2D

# Chạy cả folder
/maestro login/

# Chạy tất cả
/maestro --all
```

### Xem danh sách flows

```bash
/maestro
```

---

## Flow được sinh tự động

Skill đọc description → hiểu intent → sinh YAML phù hợp:

| Description | Flow sinh ra |
|-------------|-------------|
| "Đăng nhập Root thành công" | launchApp → login subflow với ROOT creds → assert biometric page |
| "Sai mật khẩu, assert lỗi" | launchApp → nhập sai pass → assert snackbar error text |
| "IT 003 đăng nhập, kiểm tra role" | launchApp → login IT_003 → assert màn chính |

Flow lưu tại: `learnflutter/.maestro/<module>/<flow_name>.yaml`

---

## Credential model

```
.env.maestro.example   ← commit được (template, không có giá trị)
.env.maestro           ← gitignored, điền giá trị thật

Flow YAML dùng: ${ROOT_USERNAME}, ${ROOT_PASSWORD}, ${IT_003_USERNAME}, ...
Giá trị thật KHÔNG bao giờ xuất hiện trong YAML hay output terminal.
```

---

## Flows login có sẵn

| Flow | Account | Mô tả |
|------|---------|-------|
| `login/root` | fti250171 (Root) | Happy path login root |
| `login/it_003` | fti250171-003 (IT) | Happy path login IT 003 |
| `login/it_005` | fti250171-005 (IT) | Happy path login IT 005 |
| `login/admin` | fti250171-1 (Admin) | Happy path login Admin |
| `login/accountant` | fti250171-002 (Kế toán) | Happy path login Kế toán |

---

## Debug khi fail

Skill tự động:
1. Đọc screenshot cuối cùng → mô tả trạng thái UI
2. Chẩn đoán nguyên nhân (API lỗi / element không tìm thấy / bundle ID sai)
3. Gợi ý fix cụ thể

Xem debug artifacts thủ công:
```bash
open ~/.maestro/tests/$(ls -t ~/.maestro/tests/ | head -1)
```

Test API credential trực tiếp:
```bash
source .env.maestro
curl -s -X POST "https://apis-stag.fpt.vn/api/v1/Account/SignInbyEmail" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ROOT_USERNAME\",\"username\":\"$ROOT_USERNAME\",\"password\":\"$ROOT_PASSWORD\",\"d_os\":\"ios\",\"d_ver\":\"1.0.0\",\"d_id\":\"\",\"d_lang\":\"vi\",\"d_res\":\"\"}" \
  | python3 -m json.tool
```
