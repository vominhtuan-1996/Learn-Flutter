# Prune Gone Branches — USAGE

Dọn nhánh git local đã mồ côi (nhánh remote bị GitLab xoá sau khi MR merge vào `dev`). Mặc định chỉ liệt kê; xoá khi có `--delete`.

## Cách dùng

Chạy ở gốc repo `learn_flutter/`.

```bash
# 1. Xem trước (không xoá gì)
python3 -I .claude/skills/prune-gone-branches/scripts/prune_gone_branches.py

# 2. Xoá các nhánh gone đã merge vào origin/dev
python3 -I .claude/skills/prune-gone-branches/scripts/prune_gone_branches.py --delete

# Tuỳ chọn
#   --include-local-only    xét cả nhánh chưa từng push (vẫn chỉ xoá nếu đã merge)
#   --force <nhánh>         xoá nhánh CHƯA merge, nêu đích danh từng nhánh
#   --no-fetch              không chạy git fetch --prune
```

Trong Claude Code: `/prune-gone-branches`, hoặc nói "dọn branch local".

## Lưu ý

- Nhánh gốc để so merge là `origin/dev` (không phải `main`).
- Không xoá nhánh đang checkout và nhánh bảo vệ (`main`, `dev`, `staging`, `release/*`...).
- Đọc [AGENT.md](AGENT.md) để biết lưu ý vận hành; quy tắc đầy đủ ở [SKILL.md](SKILL.md).
