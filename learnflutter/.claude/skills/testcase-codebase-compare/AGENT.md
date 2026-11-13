# AGENT — testcase-codebase-compare

Đọc cùng `SKILL.md` trước khi đối chiếu. Skill này chỉ review tĩnh testcase với code của FR; không phải kết quả chạy testcase.

## Trình tự làm việc

1. Kiểm tra user đã chỉ định **file testcase** và **đường dẫn codebase FR**. Chỉ hỏi đầu vào còn thiếu; không tự suy ra cặp FR ↔ testcase từ số thứ tự hoặc lịch sử hội thoại. Xác định thư mục tài liệu của FR để lưu báo cáo: dùng đường dẫn user cung cấp, hoặc tìm thư mục duy nhất phù hợp với cặp đã chọn theo cấu trúc và nội dung tài liệu; nếu không xác định duy nhất, hỏi user. Nếu XLSX có nhiều sheet testcase, xác định sheet được chọn trước khi đọc.
2. Đếm toàn bộ TC và kiểm tra ID trùng/rỗng. Đọc Pre-condition, Test Steps, Expected Result của từng TC. Lập danh sách ID để đối chiếu lại với báo cáo cuối, kể cả TC không đọc được đầy đủ.
3. Truy từ entry point của FR qua route, UI, state, repository, service và code dùng chung thực sự được gọi. Dẫn `file:line` cho hành vi thấy trong code. Nếu kết luận `Chưa tìm thấy`, ghi phạm vi và điểm vào đã rà; một lần tìm kiếm rỗng chưa đủ.
4. Gán đúng một trạng thái trong `SKILL.md` cho mỗi TC. TC có nhiều kỳ vọng chỉ `Khớp tĩnh` khi đã thấy bằng chứng cho tất cả; phần phụ thuộc BE hoặc runtime phải được ghi riêng. Không coi unit/widget test hoặc code trong `mock/` là bằng chứng thay cho code chạy thật.
5. Ghi một báo cáo **trong thư mục tài liệu của chính FR** cho mỗi cặp FR ↔ testcase, mặc định là `testcase-codebase-compare.md`; không ghi vào `testcase-csv/` hay ngoài thư mục FR. Tổng các trạng thái phải bằng số TC đọc được; mọi TC ID phải xuất hiện. Nếu báo cáo đã có ghi chú thủ công, giữ nguyên; khi không tách được phần tự sinh, tạo file mới có hậu tố ngày trong cùng thư mục FR.
6. Báo cho user các lệch quan trọng, câu hỏi BA/BE có căn cứ, việc cần kiểm tra runtime và đường dẫn báo cáo.

## Ranh giới

- TC là đối tượng đối chiếu với code, không tự động là nguồn chuẩn khi PRD hoặc quyết định BA/BE đang mâu thuẫn/chưa rõ. Gắn `Cần làm rõ` và nêu căn cứ.
- Không gọi `Khớp tĩnh` là `pass`; không kết luận thiết bị, API staging hay quyền theo role đã hoạt động nếu mới chỉ đọc code.
- Không sửa testcase, PRD, code ứng dụng; không chạy test hoặc commit nếu user chưa yêu cầu.
