# review-rule — Usage

## Khi nào dùng

- Sau khi gen code mới cho feature
- Trước khi commit / tạo MR
- Review diff của người khác
- Validate 1 file cụ thể

## Commands

```bash
# Review staged changes (trước commit)
/review-rule

# Review file cụ thể
/review-rule lib/features/auth/cubit/auth_cubit.dart

# Review + tự fix
/review-rule --fix

# Review toàn bộ thay đổi so với main
/review-rule --all
```

## Rules được check

| File | Nội dung |
|------|---------|
| `rule_convention.md` | Naming, import, code style, comment, commit format |
| `rule_security.md` | Token, secrets, validation, storage, network |
| `rule_testing.md` | Test pattern, coverage, AAA, mock strategy |

## Severity

| Level | Ý nghĩa | Chặn commit? |
|-------|---------|-------------|
| 🔴 Blocker | Security / kiến trúc cốt lõi | ✅ Phải fix |
| 🟠 Required | Convention / structure | ✅ Phải fix |
| 🟡 Nit | Nhỏ, stylistic | ❌ Khuyến nghị |
| 💡 Suggestion | Optional improvement | ❌ Tùy chọn |
