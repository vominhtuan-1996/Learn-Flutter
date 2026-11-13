---
name: review-rule
description: "Review code against learnflutter project rules (convention, security, testing). Use whenever generating, modifying, or reviewing Dart/Flutter code in this project. Trigger: /review-rule, 'review code', 'check rule', 'validate code', 'does this pass rules', sau bất kỳ code generation nào trong learnflutter."
license: MIT
version: 1.0.0
argument-hint: "[file_path | diff | --staged]"
---

# Review Rule — learnflutter

Skill này review code đã gen hoặc modified trong `learnflutter` đảm bảo pass 3 bộ rule:
- `rule_convention.md` — naming, import, code style, commit format, Maestro test ID
- `rule_security.md` — token, secrets, validation, storage
- `rule_testing.md` — cubit/repo/widget test patterns

## Arguments

`$ARGUMENTS`:
- Trống → review `git diff --staged` (code chuẩn bị commit)
- `<file_path>` → review file cụ thể
- `--all` → review toàn bộ `lib/` diff so với main

## Instructions

### Bước 1 — Đọc rules

Đọc 3 file rule (bắt buộc, luôn đọc trước khi review):

```
/Users/tuanios_su12/learn_flutter/.claude/rules/rule_convention.md
/Users/tuanios_su12/learn_flutter/.claude/rules/rule_security.md
/Users/tuanios_su12/learn_flutter/.claude/rules/rule_testing.md
```

### Bước 2 — Lấy code cần review

Tuỳ argument:
- Trống → `git diff --staged` từ `learnflutter/`
- File path → Read file đó
- `--all` → `git diff main...HEAD -- learnflutter/lib/`

Nếu không có staged changes và không có argument → báo user cần specify target.

### Bước 3 — Review theo từng rule category

#### Convention Checklist

```
[ ] Naming: Class PascalCase, file snake_case, Cubit/*State/*Repository/*Page suffix
[ ] Import order: dart: → flutter: → packages → relative
[ ] KHÔNG dùng package:learnflutter/ trong lib/ (phải dùng relative import)
[ ] KHÔNG import feature → feature trực tiếp
[ ] Feature structure: cubit/ state/ model/ repos/ screens/
[ ] File không phải widget (validator/extension/formatter/helper) KHÔNG nằm trong screens/widgets/ — đặt ở features/{feature}/shared/, ưu tiên extension trên kiểu dữ liệu; dùng 2+ feature → lib/shared/utils/
[ ] const constructor khi không có mutable state
[ ] async/await, không .then()
[ ] Không ! operator tùy tiện
[ ] Comment giải thích WHY, không WHAT
[ ] Không block comment /* */
[ ] Text string user-facing dùng AppLocale — không hardcode
[ ] Màu/kích thước dùng AppColors/AppDimens — không hardcode
[ ] Asset path dùng AppAssets — không hardcode string
[ ] Navigation dùng AppNavigator — không dùng Navigator trực tiếp
[ ] Dark/light mode: widget dùng cs.* (colorScheme) — không AppColors.light*/dark*
[ ] TextField nằm trong Container tự vẽ viền/nền → InputDecoration tắt đủ border, enabledBorder, focusedBorder, disabledBorder, errorBorder, focusedErrorBorder + filled: false (theme đè `border` nếu chỉ đặt InputBorder.none)
```

#### Maestro Test ID Checklist

```
[ ] GestureDetector / InkWell không có text con → có Semantics(label: AppTestKeys.xxx)
[ ] IconButton → có tooltip: AppTestKeys.xxx
[ ] Label value lấy từ AppTestKeys (lib/app/testing/app_test_keys.dart) — không hardcode string
[ ] Key mới trong AppTestKeys theo format <screen>_<component> lowercase underscore
[ ] Input field có hintText hoặc labelText (Maestro anchor)
```

#### Security Checklist

```
[ ] Không hardcode secret, API key, token, password
[ ] Không log sensitive data (token, password, PII)
[ ] Input validation tại boundary (user input, API response)
[ ] Token management qua ApiClient.instance (setAuthToken/clearAuthToken)
[ ] Persistent token → flutter_secure_storage, không SharedPreferences
[ ] Không trust API response — null-safe parse
[ ] Production URL → HTTPS only
[ ] Permission request trước khi dùng native API
```

#### Testing Checklist

```
[ ] Cubit có async method → có test file tương ứng
[ ] Repository → mock ApiClient, không real API call
[ ] Test theo AAA pattern (Arrange/Act/Assert)
[ ] Mỗi test kiểm tra 1 behavior
[ ] tearDown gọi cubit.close()
[ ] Không sleep/arbitrary delay trong test
[ ] Tên test mô tả behavior rõ ràng
```

### Bước 4 — Output format

Mỗi finding output theo format:

```
path/to/file.dart:LINE  <SEVERITY>: <vấn đề ngắn gọn>. <fix cụ thể>.
```

Severity levels:
- `🔴 Blocker` — vi phạm security hoặc kiến trúc cốt lõi. Phải fix trước commit.
- `🟠 Required` — vi phạm convention/structure. Phải fix trong MR này.
- `🟡 Nit` — nhỏ, không chặn merge nhưng nên fix.
- `💡 Suggestion` — cải thiện optional.
- `✅ Pass` — không có vấn đề (chỉ in khi toàn bộ file pass).

### Bước 5 — Summary

Sau danh sách findings, in:

```
── Summary ──────────────────────────────
🔴 Blocker:    N
🟠 Required:   N
🟡 Nit:        N
💡 Suggestion: N

[PASS ✅ | NEEDS FIX ❌]
```

Nếu có Blocker → `NEEDS FIX ❌`, không pass commit.
Nếu chỉ có Nit/Suggestion → `PASS ✅` (với ghi chú).

### Bước 6 — Auto-fix (nếu user yêu cầu)

Nếu argument chứa `--fix`:
- Tự động fix các `Required` và `Nit` mà có thể sửa cơ học (naming, import order, const, whitespace).
- KHÔNG tự fix Blocker (security) mà không confirm với user.
- Sau khi fix, chạy lại `flutter analyze` để verify.
- Báo cáo những gì đã fix và những gì cần user tự fix.

## Ví dụ output

```
lib/features/auth/cubit/auth_cubit.dart:15  🟠 Required: Import dùng package:learnflutter/ thay vì relative. Đổi thành '../../../core/network/api_client/api_client.dart'.

lib/features/auth/repos/auth_repository.dart:32  🔴 Blocker: Token lưu vào SharedPreferences. Dùng flutter_secure_storage cho persistent token.

lib/features/auth/cubit/auth_cubit.dart:28  🟡 Nit: Widget build() tính toán heavy — extract sang Cubit hoặc compute 1 lần.

test/features/auth/cubit/auth_cubit_test.dart  🟠 Required: Không có test cho AuthCubit.login() — method async chưa có coverage.

lib/features/home/screens/home_page.dart:44  🟠 Required: GestureDetector không có Semantics label — Maestro không tìm được. Thêm Semantics(label: AppTestKeys.xxx) và khai báo key trong app_test_keys.dart.

lib/features/home/screens/home_page.dart:44  🟠 Required: Semantics label dùng hardcode string 'home_menu_button' — đổi thành AppTestKeys.homeMenuButton.

── Summary ──────────────────────────────
🔴 Blocker:    1
🟠 Required:   4
🟡 Nit:        1
💡 Suggestion: 0

NEEDS FIX ❌
```
