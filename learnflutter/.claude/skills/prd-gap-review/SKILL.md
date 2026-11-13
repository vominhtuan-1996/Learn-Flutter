---
name: prd-gap-review
description: So sánh 1 chức năng PRD (file/folder tách bởi skill prd-breakdown) với code Flutter hiện có trong lib/features/ để tìm GAP (thiếu màn hình, thiếu business rule, field/API chưa implement, sai lệch UI spec). Xuất báo cáo .md. Trigger — "review gap PRD", "so sánh PRD với code", "tìm gap chức năng", "/prd-gap-review <FR-code hoặc path>".
---

# PRD Gap Review

Đối chiếu đặc tả nghiệp vụ (PRD, đã tách theo skill `prd-breakdown`) với code Flutter thực tế trong `learnflutter/lib/`, liệt kê chính xác điểm THIẾU / SAI LỆCH / CHƯA RÕ.

## Input

- 1 FR đã tách (ví dụ `docs/prd-v1.0/03-fr03-quan-ly-thiet-bi/index.md`), hoặc user chỉ định FR-code / tên chức năng (VD "FR-03", "quản lý thiết bị").
- Nếu PRD chưa tách theo folder FR → chạy skill `prd-breakdown` trước, hoặc đọc trực tiếp section tương ứng trong PRD gốc.

## Quy trình

1. **Đọc toàn bộ nội dung FR** cần review: Business Rules, Business Workflow, Các bước thực hiện, UI/Field Spec, và các file `_shared/*.md` mà FR này tham chiếu tới (đọc luôn nội dung shared vì đó cũng là 1 phần spec của FR).

2. **Xác định feature code tương ứng** trong `lib/features/`:
   - Map theo tên nghiệp vụ: "Đăng nhập"→`auth`, "Trang chủ"→`home`, "Quản lý thiết bị"→`device`, "Hải trình"→`map`, "Hồ sơ"→`profile`, "Hóa đơn/thanh toán"→`invoice`, "Hợp đồng"→`contract`, "Hỗ trợ"→`support`. Nếu không chắc → `grep -ri` từ khóa tiếng Việt không dấu / tiếng Anh liên quan trong `lib/features/*/screens/*.dart` để xác định đúng folder.
   - Nếu không tìm thấy feature nào khớp → toàn bộ FR là GAP loại "Chưa implement" (feature chưa tồn tại), không cần đọc code, ghi thẳng vào báo cáo.

3. **Đọc code liên quan** của feature xác định được: `cubit/*.dart`, `state/*.dart`, `repos/*.dart`, `screens/*.dart` và `screens/widgets/*.dart`. Dùng Grep để định vị nhanh field/text/business rule trước khi đọc toàn file (tránh đọc dư).

4. **Đối chiếu từng phần**, theo bảng chuẩn:

   | Khía cạnh PRD | Đối chiếu với code |
   |---|---|
   | Mỗi Business Rule (BR-xx) | Có method/logic trong Cubit hoặc Repository hiện thực đúng rule không? Rule về điều kiện/ngưỡng (VD ngưỡng % màu, số ngày sắp hết hạn) có match hằng số/logic trong code không? |
   | Mỗi bước trong "Các bước thực hiện" | Có tương ứng 1 hành động trong Cubit (method) + gọi Repository/API không? |
   | Mỗi field trong "UI/Field Spec" | Có widget tương ứng trong Screen không? Field bắt buộc (Y) có validate không? |
   | Trạng thái/Badge/Enum mô tả trong PRD | Enum/switch-case trong code có đủ toàn bộ giá trị PRD liệt kê không? |
   | Điều hướng ("chi tiết mô tả tại...", lối tắt) | Route đích có tồn tại trong `Routes` (`core/routes/app_routes.dart`) và được `AppNavigator.pushNamed` gọi đúng chỗ không? |
   | Error/Empty state PRD mô tả | Cubit có emit error state tương ứng, Screen có xử lý hiển thị không? |
   | Localization | String hiển thị trong PRD có key tương ứng trong `AppLocale` (vi+en) không, hay đang hardcode/thiếu? |

5. **Phân loại mỗi finding theo severity**:
   - 🔴 **Missing** — PRD có, code hoàn toàn chưa có (thiếu cả method/widget/route).
   - 🟠 **Partial** — có code nhưng thiếu 1 phần (VD thiếu 1 trong nhiều case của BR, thiếu validate, thiếu 1 field).
   - 🟡 **Mismatch** — có code nhưng logic/giá trị SAI so với PRD (VD ngưỡng %, format ngày, điều kiện).
   - 🔵 **Unclear** — PRD mô tả mơ hồ/thiếu chi tiết (VD "N/A", "\[xác nhận với BA\]") không đủ để đối chiếu — liệt kê để BA làm rõ, không tính là lỗi code.
   - ⚪ **Extra** (tùy chọn, chỉ ghi nếu đáng chú ý) — code có nhưng PRD không mô tả (có thể là legacy hoặc chưa cập nhật PRD).

6. **Với mỗi finding**, bắt buộc có: mô tả PRD yêu cầu gì (trích ngắn + mã BR/field nếu có) — code hiện tại ra sao (file:line cụ thể, hoặc "không tìm thấy") — đề xuất việc cần làm.

7. **Xuất báo cáo** `gap-report.md` lưu **cùng folder với FR** đang review (VD `docs/prd-v1.0/03-fr03-quan-ly-thiet-bi/gap-report.md`), theo template:

```markdown
# GAP Review — {FR-code} {Tên chức năng}

> PRD: `{đường dẫn index.md}`
> Code: `learnflutter/lib/features/{feature}/`
> Ngày review: {YYYY-MM-DD}
> Tổng: {n} Missing, {n} Partial, {n} Mismatch, {n} Unclear

## 🔴 Missing
| # | PRD yêu cầu | Ghi chú |
|---|---|---|
| 1 | BR-xx: {mô tả ngắn} | Chưa có method/widget nào tương ứng |

## 🟠 Partial
| # | PRD yêu cầu | Code hiện tại | Việc cần làm |
|---|---|---|---|
| 1 | {mô tả} | `{file}:{line}` — {mô tả thiếu gì} | {đề xuất} |

## 🟡 Mismatch
| # | PRD yêu cầu | Code hiện tại | Sai lệch |
|---|---|---|---|
| 1 | {mô tả, VD ngưỡng >=90% đỏ} | `{file}:{line}` — {giá trị thực tế trong code} | {mô tả sai lệch} |

## 🔵 Unclear (cần BA làm rõ)
| # | Nội dung PRD mơ hồ |
|---|---|
| 1 | {trích PRD, VD "Out of scope actor cần xác nhận với BA"} |

## ⚪ Extra (code có, PRD chưa mô tả)
| # | Code | Ghi chú |
|---|---|---|
| 1 | `{file}` | {mô tả} |
```

8. **Sau khi tổng hợp xong `gap-report.md`**, viết luôn Maestro flow cho FR vừa review, lưu **tại folder code** theo đúng convention của skill `maestro`:
   - Vị trí: `learnflutter/lib/features/{feature}/.maestro/{flow_name}.yaml` (không lưu trong `docs/`).
   - Tối thiểu tạo 1 flow **happy path** theo đúng "Các bước thực hiện" trong PRD (dùng tên `{feature}_happy_path.yaml` hoặc theo tên nghiệp vụ, VD `login_success.yaml`).
   - Với mỗi finding 🔴 Missing hoặc 🟡 Mismatch có thể quan sát được qua UI (không phải gap kiểu thiếu validate ẩn/thiếu config build) → thêm 1 flow riêng để tái hiện gap đó (VD `{flow_name}_gap_<mô_tả_ngắn>.yaml`), assert đúng hành vi SAI hiện tại hoặc đúng hành vi ĐÚNG cần đạt — ghi rõ trong comment đầu file flow là flow test cho gap nào (trích `# GAP-ref: {FR-code} mismatch #2`).
   - Gọi/áp dụng đúng quy trình của skill `maestro` (đọc `.env.maestro`, kiểm tra `semanticsLabel`/`testID` tồn tại trong code trước khi viết `tapOn`/`assertVisible`, không bịa selector) — không tự chế format flow khác đi.
   - Nếu feature chưa có `Semantics`/`testID` cho 1 bước cần assert (thường xảy ra khi gap là 🔴 Missing — chưa có UI để test) → bỏ qua bước đó trong flow, ghi chú lại trong `gap-report.md` mục tương ứng: "Chưa viết được Maestro test vì UI/testID chưa tồn tại".
   - Liệt kê các flow đã tạo trong 1 mục mới `## Maestro Flows` ở cuối `gap-report.md`:

```markdown
## Maestro Flows
| File | Mục đích |
|------|----------|
| `lib/features/{feature}/.maestro/{flow}.yaml` | Happy path theo "Các bước thực hiện" |
| `lib/features/{feature}/.maestro/{flow}_gap_xxx.yaml` | Tái hiện gap #{n} ({loại: Missing/Mismatch}) |
```

9. **Với mỗi finding mà FE KHÔNG tự fix được vì thiếu API/field từ BE** (thường là 🔴 Missing do backend chưa trả data, không phải do FE quên code) — tạo 1 file handoff riêng cho BE:
   - Vị trí: `learnflutter/be-handoff/{fr-code}-{ten-slug}.md` — **ngang cấp với `docs/`, KHÔNG nằm trong `docs/`** (BE đọc riêng, tách khỏi tài liệu PRD/FE).
   - Nội dung tối thiểu: yêu cầu PRD gốc (trích + link `gap-report.md`), tình trạng hiện tại phía FE (model/DTO nào thiếu field gì, đã grep xác nhận chưa có nguồn data), đề xuất field/API cần BE bổ sung, câu hỏi nghiệp vụ cần làm rõ nếu có, việc FE sẽ làm sau khi có data, và mục cuối `## Trạng thái BE` (để trống, BE tự cập nhật khi tiếp nhận — không tạo file mới cho phản hồi).
   - Cập nhật `learnflutter/be-handoff/00-index.md` (tạo mới nếu chưa có) — bảng liệt kê toàn bộ gap đang chờ BE: FR, link file, field/API cần bổ sung, trạng thái.
   - KHÔNG tạo file handoff cho gap FE tự fix được (thiếu validate, sai text, sai logic hiển thị...) — chỉ dùng khi bằng chứng rõ ràng là thiếu nguồn dữ liệu/API từ backend.

10. Sau khi xong, báo cho user: đường dẫn báo cáo, tổng số finding theo từng loại, top 3 gap nghiêm trọng nhất (Missing), danh sách flow Maestro đã tạo, danh sách file handoff BE đã tạo (nếu có).

## Nguyên tắc

- CHỈ báo cáo gap có bằng chứng cụ thể (đọc thật code, trích file:line) — KHÔNG suy đoán "có thể chưa có".
- Không tự sửa code trong skill này — đây là skill REVIEW, chỉ xuất báo cáo. Nếu user muốn fix gap, đó là task riêng sau khi có báo cáo.
- Nếu 1 FR quá lớn (nhiều màn hình, VD FR-03 Quản lý thiết bị), có thể chia review theo từng sub-section (screens/widgets con) để tránh bỏ sót — vẫn gộp chung 1 `gap-report.md`.
- Giữ nguyên thuật ngữ/mã BR-ID/AC-ID từ PRD trong báo cáo để dễ truy vết ngược.
