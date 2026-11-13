---
name: prune-gone-branches
description: Dọn nhánh git local của repo learn_flutter mà nhánh remote tương ứng đã bị xoá khỏi origin (sau khi MR merge vào dev và GitLab xoá nhánh). Liệt kê trước, kiểm đã merge vào origin/dev, chỉ xoá nhánh an toàn. Dùng khi user nói "dọn branch", "xoá branch đã xoá trên origin", "clean branch local", "prune branch".
argument-hint: "[--include-local-only] [--delete] [--force <nhánh>...]"
---

# Prune Gone Branches

Dọn nhánh local đã "mồ côi": nhánh remote trên `origin` đã bị xoá (GitLab xoá sau khi merge MR vào `dev`), còn nhánh local vẫn nằm đó. Dùng script [scripts/prune_gone_branches.py](scripts/prune_gone_branches.py), chỉ cần Python 3 và git.

## Khi nào dùng

User yêu cầu dọn branch local. Đây là thao tác xoá, nên luôn **liệt kê trước, xoá sau**; không tự chạy theo lịch hay giữa lúc làm việc khác.

## Quy trình

Chạy từ gốc repo (`learn_flutter/`, nơi có `.git`), không phải trong `learnflutter/`.

1. **Dry-run** (mặc định, không xoá gì):
   ```bash
   python3 -I .claude/skills/prune-gone-branches/scripts/prune_gone_branches.py
   ```
   Script chạy `git fetch --prune origin` (chỉ cập nhật ref remote), rồi in bảng: nhánh, loại (`gone`/`local-only`), đã merge vào nhánh gốc chưa, số commit riêng, ghi chú.
2. **Đọc bảng và báo user** số nhánh sẽ xoá, số giữ lại và lý do. Nhánh chưa merge thì nêu số commit riêng và commit cuối để user quyết định.
3. **Xoá** các nhánh an toàn (đã merge) khi user đồng ý:
   ```bash
   python3 -I .claude/skills/prune-gone-branches/scripts/prune_gone_branches.py --delete
   ```
4. **Báo kết quả**: số nhánh đã xoá, danh sách còn lại, rồi chạy lại dry-run (`--no-fetch`) để chứng minh không còn nhánh `gone` đã merge.

## Quy tắc an toàn (script tự thực thi, không bỏ qua)

- Nhánh **gone**: có upstream nhưng upstream đã bị xoá trên origin. Đây là nhóm mặc định.
- Nhánh **local-only** (không có upstream, có thể chưa từng push) **không** nằm trong nhóm mặc định; phải thêm `--include-local-only`, và vẫn chỉ xoá nếu đã merge. Hỏi user trước khi thêm cờ này.
- "Đã merge" nghĩa là nhánh là tổ tiên của **`origin/dev`**. LearnFlutter merge MR vào `dev`, còn `origin/HEAD` trỏ `main` (chỉ nhận bản release): so với `main` thì nhánh đã vào `dev` bị báo nhầm là chưa merge. Không có `origin/dev` thì mới rơi về `origin/HEAD`, `origin/main`, `origin/master`, rồi bản local.
- Không bao giờ xoá: nhánh đang checkout (kể cả ở worktree khác) và nhánh được bảo vệ (`main`, `master`, `develop`, `dev`, `staging`, `production/*`, `staging/*`, `release/*`).
- Nhánh **chưa merge** bị giữ lại. Chỉ xoá khi user nêu đích danh nhánh đó (`--force <nhánh>`), sau khi đã thấy số commit riêng; không bao giờ `--force` hàng loạt.
- Nhánh còn tồn tại trên origin không bao giờ bị đụng tới, dù đã merge.
- Xoá bằng `git branch -D` sau khi script tự kiểm merge (`-d` có thể từ chối khi HEAD local tụt hậu dù nhánh đã merge). Commit không mất ngay: nhánh đã merge còn trong `dev`, nhánh `--force` còn trong reflog một thời gian.

## Xác minh

`python3 -I .claude/skills/prune-gone-branches/scripts/test_prune_gone_branches.py` (8 ca trên repo tạm: dry-run không đổi gì, xoá nhánh đã merge, giữ nhánh chưa merge, `--force`, nhánh còn trên origin, `local-only` cần cờ, nhánh bảo vệ và nhánh đang checkout, nhánh gốc là `origin/dev`).

## Gotcha đã gặp

- Lọc nhánh `gone` bằng `git for-each-ref --format='%(refname:short) %(upstream:track)'` rồi `grep '\[gone\]'`; đừng parse `git branch -vv` bằng `awk` (dấu `*` của nhánh hiện tại làm lệch cột).
- Nhánh vừa được merge và push hôm nay cũng thuộc nhóm `gone` khi MR xong: là bình thường, commit đã nằm trong `dev`.
- Hook ISC (`isc_commit_gate.py`) chỉ kiểm lệnh `git commit`; lệnh xoá nhánh của script không bị chặn. Dù vậy vẫn phải được user đồng ý trước khi `--delete`.
