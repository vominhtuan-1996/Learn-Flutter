# AGENT — prune-gone-branches

Quy tắc cho agent khi chạy skill `prune-gone-branches` trên repo `learn_flutter`.

## Trình tự bắt buộc

1. Đọc `SKILL.md`. Chạy từ gốc repo (nơi có `.git`), không chạy trong `learnflutter/`.
2. Luôn dry-run trước, báo user bảng kết quả, chờ đồng ý rồi mới `--delete`.
3. Không tự thêm `--include-local-only` hay `--force`: hỏi user, và `--force` chỉ với nhánh user nêu đích danh.
4. Sau khi xoá, chạy lại dry-run `--no-fetch` để xác nhận.

## Vấn đề phát sinh

- Nhánh gốc để so merge phải là `origin/dev`. `origin/HEAD` trỏ `main`, nên so với `main` thì mọi nhánh đã merge vào `dev` bị báo "CHƯA merge" và bị giữ lại sai. Đã sửa trong `base_ref()`, có test `test_base_is_origin_dev_when_it_exists`.
