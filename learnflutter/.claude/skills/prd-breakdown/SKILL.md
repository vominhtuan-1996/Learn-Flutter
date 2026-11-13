---
name: prd-breakdown
description: Tách file PRD (.docx.md) thành từng chức năng (FR) riêng biệt, mỗi FR có 1 folder riêng (dễ tìm), shared riêng của FR nằm chung folder đó, shared dùng nhiều FR nằm ở folder `_shared/` chung. Trigger — "tách PRD", "breakdown PRD", "tách chức năng từ PRD", "/prd-breakdown <path-to-prd.md>".
---

# PRD Breakdown

Tách 1 PRD markdown (convert từ .docx) thành cấu trúc thư mục theo chức năng (FR), lưu tại folder chứa PRD gốc — mỗi FR 1 folder riêng để dễ tìm tài liệu.

## Cấu trúc output

```
docs/prd-v{version}/
├── ISC_..._PRD_v1.0.docx.md          ← PRD gốc, không đổi
├── 00-index.md                       ← mục lục toàn bộ
├── 01-fr01-dang-nhap/
│   └── index.md                      ← nội dung FR01
├── 02-fr02-trang-chu/
│   └── index.md
├── 03-fr03-quan-ly-thiet-bi/
│   ├── index.md
│   └── shared-chi-tiet-thue-bao.md   ← shared CHỈ FR03 dùng nội bộ (nhiều màn con của FR03) → đặt luôn trong folder FR03
├── 04-fr04-hai-trinh/
│   └── index.md
├── 05-fr05-ho-so/
│   └── index.md
├── _shared/                          ← shared dùng bởi ≥ 2 FR KHÁC NHAU
│   ├── bottom-nav.md
│   └── xac-nhan-mat-khau-sinh-trac-hoc.md
└── 97-governance-definition-of-done.md / 98-artifact-reference.md / 99-non-functional.md  (nếu tách phụ lục)
```

Quy tắc đặt shared:
- Shared chỉ được **1 FR duy nhất** tham chiếu tới (dùng lặp lại giữa các màn con/sub-section trong chính FR đó) → file nằm **trong folder của FR đó** (`{fr-folder}/shared-{ten-slug}.md`).
- Shared được **≥ 2 FR khác nhau** tham chiếu tới → file nằm ở **`_shared/{ten-slug}.md`** cấp trên (ngang hàng các folder FR), không thuộc riêng FR nào.

## Input

File PRD dạng `*.docx.md`, section "FEATURE DETAIL" chứa các heading chức năng dạng:

```
### **8.1 FR01 — Đăng nhập**  {#...}
### **8.2 FR-02 — Trang chủ**  {#...}
```

(mã FR không đồng nhất format — có thể `FR01`, `FR-02`, v.v. Nhận diện bằng regex `FR-?\d+`.)

## Quy trình

1. **Đọc toàn bộ file PRD** bằng Read tool.
2. **Xác định block header dùng chung** cho mọi FR con: nội dung từ đầu file đến hết mục `7. FEATURE CATALOGUE` (bối cảnh sản phẩm, personas, scope, traceability) — dùng làm phần "Bối cảnh tham chiếu" ngắn gọn (link/tóm tắt, KHÔNG copy nguyên) ở đầu mỗi file con.
3. **Tìm mọi heading chức năng cấp FR** — pattern `^#{2,4}\s*\*{0,2}[\d.]+\s*FR-?\d+.*` trong section `8. FEATURE DETAIL`. Mỗi heading này là điểm bắt đầu 1 FR; nội dung FR kết thúc ở heading cùng cấp tiếp theo (kể cả sub-heading `8.x.y` thuộc về FR đó, không tách rời).
4. **Với mỗi FR**, tạo 1 folder: `{02d-số-thứ-tự}-{fr-code}-{ten-slug}/` (ví dụ `01-fr01-dang-nhap/`, `03-fr03-quan-ly-thiet-bi/`) ngay trong folder chứa PRD gốc, bên trong tạo file `index.md`.
5. **Nội dung `index.md` mỗi FR** theo template:

```markdown
# {FR-code} — {Tên chức năng}

> Nguồn: `{tên file PRD gốc}` — mục {số mục, ví dụ 8.3}
> Ngày tách: {ngày hiện tại YYYY-MM-DD}

## Business Rules
{copy nguyên nội dung con "Business Rules" của FR}

## Business Workflow / Activity Flow
{copy nguyên, giữ nguyên bảng/ảnh reference nếu có}

## Các bước thực hiện
{copy nguyên}

## UI / Field Spec
{copy nguyên — giữ nguyên bảng, giữ nguyên ảnh reference [image] nếu có}

## Ghi chú khác
{mọi sub-section khác thuộc FR không rơi vào 4 mục trên — copy nguyên, giữ heading gốc}
```

- Giữ nguyên bảng markdown, ký hiệu, numbering AC ID trong nội dung gốc — KHÔNG diễn giải lại, KHÔNG tóm tắt mất thông tin.
- Nếu 1 sub-section không tồn tại trong PRD gốc (VD "N/A") → ghi `N/A` thay vì bỏ trống mục.
- Ảnh (`![][imageN]`) trong nội dung FR: giữ nguyên placeholder, không cần resolve ảnh thật.

6. **Phát hiện chức năng / thành phần dùng chung (shared)** — làm sau khi đã tách hết FR, quét toàn bộ nội dung các `index.md` vừa tạo:
   - Dấu hiệu 1 phần tử là "dùng chung": xuất hiện ở ≥ 2 vị trí. Ví dụ điển hình: popup/dialog xác nhận (VD "popup lỗi mạng"), thành phần UI lặp lại (VD "empty state", "loading overlay"), business rule lặp lại (VD "session timeout", "validate OTP"), 1 màn hình/flow được nơi khác gọi tới (VD "Chi tiết thiết bị" mở từ nhiều màn con của FR-03), field/enum dùng chung (VD trạng thái thiết bị).
   - Nhận diện bằng cách so khớp: tên section con giống hệt/tương tự, cụm từ "xem thêm mục", "tương tự FR-xx", "dùng chung với", hoặc nội dung Business Rule/UI Spec trùng lặp gần như nguyên văn.
   - **Xác định phạm vi dùng chung trước khi tạo file** — chỉ 2 trường hợp:
     - **(a) Chỉ 1 FR dùng** (lặp lại giữa các màn/sub-section nội bộ của cùng 1 FR, ví dụ nhiều loại thiết bị trong FR-03 đều gọi tới "Chi tiết thiết bị") → tạo file **trong folder của FR đó**: `{fr-folder}/shared-{ten-slug}.md`.
     - **(b) ≥ 2 FR khác nhau dùng** → tạo file ở **`_shared/{ten-slug}.md`** (folder `_shared/` ngang cấp với các folder FR, tạo nếu chưa có).
   - Nội dung file shared (cả 2 trường hợp):

```markdown
# [Shared] {Tên thành phần/chức năng dùng chung}

> Loại: {Business Rule | UI Component | Flow/Screen | Field-Enum}
> Phạm vi: {Nội bộ FR-xx | Dùng chung nhiều FR}
> Được dùng bởi: {FR-code A}, {FR-code B}, ...

## Mô tả
{nội dung gốc — copy nguyên lần xuất hiện đầy đủ/chi tiết nhất trong PRD}

## Nơi tham chiếu
| FR | Vị trí | Ngữ cảnh sử dụng |
|----|--------|------------------|
| {FR-code A} | [{path}]({path}) | {mô tả ngắn: dùng ở bước nào / màn nào} |
| {FR-code B} | [{path}]({path}) | {mô tả ngắn} |
```

- Cột "Vị trí" LUÔN viết dạng markdown link `[đường-dẫn](đường-dẫn)` (đường dẫn tương đối tới `index.md` của FR đó) để click mở được trực tiếp, KHÔNG để plain text.
```

   - Trong **từng `index.md` FR** có tham chiếu tới phần tử dùng chung: tại đúng vị trí xuất hiện, thêm dòng liên kết rõ ràng, không xóa nội dung gốc. Đường dẫn liên kết phải đúng theo vị trí thực (đường dẫn tương đối):
     - Shared nội bộ (case a, cùng folder): `> 🔗 Dùng chung — xem chi tiết tại [shared-{ten-slug}.md](./shared-{ten-slug}.md)`
     - Shared liên-FR (case b, ở `_shared/`): `> 🔗 Dùng chung (liên FR) — xem chi tiết tại [{ten-slug}.md](../_shared/{ten-slug}.md)`
   - Nếu không tìm thấy phần tử dùng chung nào → bỏ qua bước này, không tạo file shared.

7. **Tạo file index tổng** `00-index.md` tại folder chứa PRD gốc (cấp trên các folder FR), liệt kê toàn bộ FR và toàn bộ shared đã tách:

```markdown
# PRD Breakdown Index — {tên PRD gốc}

## Chức năng (FR)
| # | Folder | FR Code | Tên chức năng |
|---|--------|---------|----------------|
| 1 | 01-fr01-dang-nhap/ | FR01 | Đăng nhập |
| 2 | 02-fr02-trang-chu/ | FR-02 | Trang chủ |
...

## Thành phần dùng chung — nội bộ 1 FR
| File | Tên | Thuộc FR |
|------|-----|----------|
| 03-fr03-quan-ly-thiet-bi/shared-chi-tiet-thue-bao.md | Chi tiết thuê bao | FR-03 |
...

## Thành phần dùng chung — liên FR (`_shared/`)
| File | Tên | Dùng bởi |
|------|-----|----------|
| _shared/bottom-nav.md | Thanh điều hướng chính | FR-02, FR-03, FR-04, FR-05 |
...
```

8. Sau khi tách xong, báo cho user: số FR tách được (kèm tên folder), số shared nội bộ, số shared liên-FR (kèm danh sách FR liên quan mỗi shared), đường dẫn folder gốc.

## Lưu ý

- KHÔNG sửa/tóm tắt nội dung nghiệp vụ gốc — chỉ tách & tổ chức lại.
- Nếu PRD có nhiều version/phụ lục ngoài section FEATURE DETAIL (VD "NON-FUNCTIONAL REQUIREMENTS", "ARTIFACT REFERENCE") → tách riêng thành file `99-non-functional.md`, `98-artifact-reference.md`, `97-governance-...md` tại folder gốc (không nằm trong folder FR nào) nếu user yêu cầu đầy đủ toàn bộ PRD; mặc định skill này chỉ tách phần FEATURE DETAIL (business function).
- File output dùng tiếng Việt giữ nguyên theo PRD gốc (không dịch).
- Mỗi FR PHẢI có folder riêng (không để file FR nằm lẻ ngoài folder) — mục tiêu là dễ tìm tài liệu theo từng chức năng.
