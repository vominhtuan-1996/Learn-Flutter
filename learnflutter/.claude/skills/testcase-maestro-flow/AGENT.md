# AGENT — testcase-maestro-flow

Đọc cùng `SKILL.md` trước khi tạo YAML. Mục tiêu là flow có assertion truy vết được tới Expected Result của testcase, không phải flow chỉ mô phỏng thao tác.

## Trình tự làm việc

1. Xác định file testcase user chọn, sheet XLSX nếu cần, và TC ID được chọn. Nếu user chỉ đưa file, xử lý toàn bộ TC trong file; không tự thay bằng một vài TC mẫu. Ghi nhận ID trùng/rỗng hoặc dòng không đọc được.
2. Với từng TC, lập bảng ngắn: tiền điều kiện, hành động, Expected Result, khả năng assert bằng UI. Xác định phần cần fixture, credential, BE, thiết bị hoặc kiểm tra thủ công trước khi viết YAML.
3. Xác minh module, app ID, route, locale và selector từ code/config/flow hiện có. Đọc subflow trước khi dùng lại. Không sao chép selector, app ID hoặc assertion từ flow cũ nếu không khớp TC hiện tại.
4. Tạo một flow chính cho mỗi TC có ít nhất một Expected Result quan sát được. Giữ TC ID gốc trong comment; mỗi assertion phải tương ứng một kỳ vọng cụ thể. Nếu chỉ tự động hóa được một phần, ghi rõ phần còn thiếu khi báo cáo.
5. Dùng biến môi trường cho dữ liệu nhạy cảm; không tạo hoặc in credential. Đọc flow trùng tên trước khi sửa và giữ các chỉnh sửa thủ công. Kiểm tra lại cú pháp YAML, đường dẫn subflow, biến và selector trước khi kết thúc.
6. Báo TC ID → flow, Expected Result đã assert, phần chưa tự động hóa và điều kiện chạy cần chuẩn bị. TC không tạo được flow phải có lý do riêng.

## Ranh giới

- Không tự tạo assertion giả cho hành vi chưa có code hoặc đang chờ BA/BE xác nhận. Không tạo flow không có assertion.
- Không coi việc sinh YAML là testcase đã pass. Chỉ chạy Maestro khi user yêu cầu rõ; khi đó dùng quy trình chạy của skill `maestro`.
- Không sửa testcase, PRD, code ứng dụng hoặc commit trong bước tạo flow nếu user chưa yêu cầu.
