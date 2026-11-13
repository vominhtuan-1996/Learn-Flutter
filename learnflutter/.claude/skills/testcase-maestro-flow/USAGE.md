# USAGE — testcase-maestro-flow

Tạo Maestro YAML từ các bước và Expected Result trong testcase do user chọn. Flow được lưu trong `.maestro/` của module tương ứng; skill không tự chạy flow.

## Chọn testcase

Một hoặc nhiều TC ID từ CSV:

```text
/testcase-maestro-flow
File: learnflutter/docs/prd-v1.0/testcase-csv/tc-01-dang-nhap.csv
TC ID: TC_01.8, TC_01.12
Module: learnflutter/lib/features/auth
```

Muốn xử lý toàn bộ file, chỉ nêu file. Với XLSX nhiều sheet, nêu thêm tên sheet:

```text
/testcase-maestro-flow
File: /path/to/testcases.xlsx
Sheet: Đăng nhập
TC ID: TC_01.8
```

Có thể chỉ định flavor, app ID hoặc thư mục output nếu khác cấu hình module. Khi không chỉ định, skill xác minh từ code và các flow hiện có trước khi chọn.

## Kết quả

Mỗi TC có thể tự động hóa có một YAML tên bắt đầu bằng TC ID chuẩn hóa, ví dụ `learnflutter/lib/features/auth/.maestro/tc_01_8_login_success.yaml`. Phản hồi liệt kê assertion đã tạo, biến môi trường/fixture cần chuẩn bị và phần kỳ vọng Maestro UI không kiểm được. TC không có assertion khả thi sẽ được báo rõ, không sinh flow rỗng.

Để chạy flow sau khi tạo, yêu cầu riêng và chỉ định thiết bị/flavor nếu cần; lúc đó dùng skill `maestro`.
