# AGENT — prd-update

Quy tắc cho agent khi chạy skill `prd-update`.

## Trình tự bắt buộc

0. Đã đọc file này trước mọi bước khác.
1. **Hỏi user, chờ trả lời, không đoán:** path PRD bản mới; folder breakdown + PRD bản trước; có TC CSV/code để rà tác động không; tên bản mới (vd `v2`). Mục user đã nêu thì không hỏi lại. Thiếu breakdown → dừng, đề nghị `prd-breakdown`.
2. Chạy `docx2md.py` → `prd_effective.py` → `docx_comments.py` → `prd_diff.py` (cú pháp trong SKILL.md). File tạm đặt trong scratchpad, không trong repo. File docx không tin cậy: `python3 -I`, path qua tham số.
3. **Kiểm tra chuyển đổi** trước khi tin diff: mỗi FR có số từ cùng bậc với bản cũ; nếu một FR rút ngắn hàng chục lần → nội dung bị sót, sửa script chứ không báo "PRD bỏ nội dung".
4. **Lập danh sách thay đổi** từ 4 nguồn (Revision History, comment, gạch ngang, diff). Đọc từng chỗ khác; đừng tin diff cuối cùng khi nó chỉ là nhiễu định dạng. Với mỗi thay đổi ghi: mục, cũ, mới, nguồn.
5. **Áp dụng bằng patch có kiểm tra** (`patchlib.P.rep/del_rows`). Lấy chuỗi cũ nguyên văn từ file hiện có (`grep`/`sed`), chuỗi mới từ `eff.md`; giữ kiểu định dạng của file đích. Một lỗi khớp = dừng, xem lại, không ép.
6. Sau patch: `git diff --stat`, `grep` mã/nhãn cũ trong file đã sửa, kiểm link `_shared`.
7. Viết `prd-<ver>-changes.md` rồi (nếu có TC/code) `prd-<ver>-impact.md`.
8. Báo cáo ngắn: số thay đổi theo FR, thay đổi ngoài Revision History, mục "Chưa" và lý do, câu hỏi cho BA, đường dẫn báo cáo.

## Quy tắc diễn giải PRD

- **Gạch ngang = bị bỏ.** Gạch cả dòng bảng → xóa dòng; gạch một cụm → bỏ cụm; cụm thay thế đi kèm (vd `~~service line~~ thuê bao`) → lấy cụm mới.
- **Comment là lý do thay đổi**, không phải yêu cầu mới. Comment không gắn văn bản → "hỏi BA".
- **Revision History không đầy đủ:** vẫn phải ghi thay đổi nằm ngoài danh sách đó.
- **Mã BR đổi** (renumber, gộp, chèn) → ghi bảng ánh xạ cũ→mới trong báo cáo và sửa mọi tham chiếu trong breakdown. Đừng đổi mã trong TC/RTM/báo cáo khác; ghi vào impact.
- **PRD là nguồn chuẩn.** Lệch với TC/code → ghi ở phía TC/code, không đề xuất sửa PRD.

## Không làm

- Không ghi đè nguyên file bằng bản chuyển đổi; không sửa TC, RTM, báo cáo compare/gap, code, trừ khi user yêu cầu riêng.
- Không đoán path, nội dung comment trống, ý nghĩa ký hiệu bị mất.
- Không dùng `Undo`/hoàn nguyên hàng loạt; file đã nằm trong git, dùng `git diff`/`git checkout` để hoàn tác.
- Không commit trừ khi user yêu cầu.

## Files

- `SKILL.md` — định nghĩa skill, quy trình, mẫu báo cáo
- `USAGE.md` — hướng dẫn người dùng
- `AGENT.md` — quy tắc agent (file này)
- `scripts/docx2md.py` — docx → markdown (gạch ngang `~~`, content control `w:sdt`)
- `scripts/prd_effective.py` — bỏ phần gạch ngang, ra bản hiệu lực
- `scripts/docx_comments.py` — comment kèm đoạn được gắn
- `scripts/prd_diff.py` — so sánh theo từ, gộp theo FR
- `scripts/patchlib.py`, `scripts/patch_template.py` — sửa file có kiểm tra khớp
- `scripts/impact_scan.py` — quét TC CSV theo từ khóa
