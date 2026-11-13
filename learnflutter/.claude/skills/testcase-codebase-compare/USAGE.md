# USAGE — testcase-codebase-compare

So sánh testcase với code đang triển khai của một FR, xuất báo cáo review tĩnh theo từng TC ID.

## Đầu vào

Cần chỉ định cả file testcase (`.csv`/`.xlsx`) và file hoặc thư mục codebase của FR. Có thể chỉ định thêm thư mục tài liệu FR, sheet XLSX, phạm vi code và tên báo cáo trong thư mục FR.

Ví dụ với FR đăng nhập:

```text
/testcase-codebase-compare
Testcase: learnflutter/docs/prd-v1.0/testcase-csv/tc-01-dang-nhap.csv
Codebase FR: learnflutter/lib/features/auth
Thư mục FR: learnflutter/docs/prd-v1.0/01-fr01-dang-nhap
```

Ví dụ giới hạn phạm vi và chọn đường dẫn báo cáo:

```text
/testcase-codebase-compare
Testcase: /path/to/testcases.xlsx, sheet "Quản lý thiết bị"
Codebase FR: learnflutter/lib/features/device
Thư mục FR: learnflutter/docs/prd-v1.0/03-fr03-quan-ly-thiet-bi
Báo cáo: learnflutter/docs/prd-v1.0/03-fr03-quan-ly-thiet-bi/testcase-codebase-compare.md
```

Nếu muốn so sánh nhiều FR, nêu rõ từng **cặp** testcase ↔ codebase. Skill tạo một báo cáo trong thư mục tài liệu của từng FR. Nếu không chỉ định đường dẫn báo cáo, mặc định là `<thư-mục-FR>/testcase-codebase-compare.md`. Khi chưa có đường dẫn thư mục FR, skill chỉ tự xác định nếu tìm được đúng một thư mục phù hợp; trường hợp mơ hồ sẽ hỏi user trước khi ghi.

## Đọc kết quả

Bảng báo cáo liệt kê mỗi TC ID, trạng thái, bằng chứng code `file:line` và việc tiếp theo. `Khớp tĩnh` chỉ có nghĩa là code đọc được phù hợp với kỳ vọng; `Cần chạy thực tế` dành cho phần phải xác nhận trên thiết bị, API hoặc dữ liệu thật. Các câu hỏi chờ BA/BE được ghi riêng, không biến thành lỗi code khi chưa đủ căn cứ.
