---
name: testcase-codebase-compare
description: So sánh testcase CSV/XLSX do user chỉ định với codebase của FR do user chỉ định; lập báo cáo theo từng TC về mức độ hiện thực, sai lệch và điểm cần BA/BE hoặc kiểm thử thực tế xác nhận. Dùng khi user yêu cầu đối chiếu testcase với code, không dùng để so sánh PRD với testcase.
---

# Testcase ↔ Codebase Compare

Đối chiếu hành vi mà testcase yêu cầu với code đang chạy của một FR. Đây là review tĩnh: có code tương ứng không đồng nghĩa testcase đã chạy pass.

Trước khi xử lý, đọc [AGENT.md](AGENT.md) để kiểm tra đầu vào và cách ghi nhận bằng chứng. Cách gọi và ví dụ ở [USAGE.md](USAGE.md).

## Đầu vào

- **Bắt buộc:** đường dẫn file testcase và đường dẫn file/thư mục codebase của FR. User chọn cả hai; không tự ghép cặp từ tên file, số FR hay các lượt làm việc trước. Chỉ hỏi phần còn thiếu; không hỏi lại thông tin user đã cung cấp.
- Với XLSX nhiều sheet, user chỉ định sheet cần đọc nếu chưa xác định được từ yêu cầu. Với CSV, xác nhận cột ID, tiêu đề, tiền điều kiện, bước và kết quả mong đợi từ header thực tế; không giả định một mẫu CSV cố định.
- User có thể chỉ định nhiều cặp FR ↔ testcase. Xử lý từng cặp riêng, mỗi FR một báo cáo.
- Báo cáo phải nằm trong **thư mục tài liệu của chính FR** đang đối chiếu, mặc định là `<thư-mục-FR>/testcase-codebase-compare.md`; không lưu cạnh file testcase hoặc ở thư mục ngoài FR. User có thể chỉ định tên/đường dẫn báo cáo khác nếu đường dẫn đó vẫn nằm trong thư mục FR tương ứng.
- Nếu user chưa chỉ định thư mục tài liệu FR, xác định thư mục duy nhất từ cấu trúc tài liệu cùng phiên bản PRD và nội dung FR phù hợp với cặp testcase ↔ codebase đã chọn. Không dùng riêng số FR hoặc tên file để tự ghép cặp đầu vào. Nếu có nhiều thư mục FR phù hợp hoặc không tìm thấy, hỏi user đường dẫn thư mục FR trước khi ghi báo cáo.

## Cách đối chiếu

1. Đọc **toàn bộ** testcase của cặp đã chọn, gồm ID, tiền điều kiện, bước và kết quả mong đợi. Kiểm tra số dòng, ID trùng/rỗng và ghi nhận các dòng không thể đọc; không âm thầm bỏ qua testcase.
2. Bắt đầu từ codebase FR user chọn. Theo dấu các lời gọi thực tế tới route, màn hình, state/cubit, repository, service, DTO, cấu hình và code dùng chung khi cần để xác định hành vi. Chỉ mở rộng ra ngoài phạm vi ban đầu khi luồng chạy của FR tham chiếu tới đó; tôn trọng giới hạn phạm vi nếu user nêu rõ.
3. Phân biệt code chạy thật với `mock/`, demo, comment và test. Test tự động là bằng chứng về kiểm tra đã viết, không thay thế bằng chứng hiện thực trong code chạy thật. Nếu không xác định được entry point hoặc build flavor đang dùng, ghi rõ giới hạn thay vì đoán.
4. Đối chiếu từng điều kiện và kết quả mong đợi, kể cả trường hợp âm, role, dữ liệu rỗng, lỗi mạng, điều hướng và ranh giới giá trị. Một TC có nhiều kỳ vọng chỉ được đánh dấu khớp khi mọi kỳ vọng có bằng chứng.
5. Với hành vi phụ thuộc BE, thiết bị, hệ điều hành, dữ liệu staging hoặc cấu hình runtime, ghi rõ phần code đã xác minh và phần còn cần kiểm tra. Không kết luận code sai chỉ vì thiếu phản hồi hoặc thông tin từ BE. Nếu TC xung đột với PRD hoặc quyết định BA/BE được user cung cấp, ghi `Cần làm rõ`, không tự chọn bên nào đúng.

## Trạng thái cho từng TC

| Trạng thái | Khi dùng |
|---|---|
| `Khớp tĩnh` | Tất cả kỳ vọng có luồng code và điều kiện tương ứng; chưa khẳng định chạy pass. |
| `Một phần` | Có luồng code nhưng thiếu ít nhất một kỳ vọng hoặc nhánh. |
| `Lệch` | Code có hành vi trái với kỳ vọng testcase. |
| `Chưa tìm thấy` | Đã rà đúng luồng chạy và các phụ thuộc liên quan nhưng không thấy hiện thực. |
| `Cần làm rõ` | Thiếu hợp đồng BE, quyết định BA, thông tin môi trường hoặc phạm vi để kết luận. |
| `Cần chạy thực tế` | Chỉ có thể xác nhận bằng thiết bị, dữ liệu hoặc thao tác runtime; nêu rõ bằng chứng code đã có. |

Không suy ra `Chưa tìm thấy` chỉ từ một kết quả tìm kiếm rỗng. Nếu không thấy code, nêu phạm vi đã rà và từ khóa/entry point đã tìm. Mỗi dòng báo cáo phải giữ nguyên TC ID, có trạng thái, bằng chứng `file:line` cho kết luận về code, và việc tiếp theo. Gộp các TC giống nhau khi trình bày để dễ đọc, nhưng vẫn liệt kê **mọi ID** và trạng thái của từng TC; tổng theo trạng thái phải bằng tổng TC đọc được.

## Báo cáo

Viết bằng tiếng Việt, một báo cáo trong thư mục tài liệu của mỗi FR ↔ testcase:

```markdown
# So sánh testcase ↔ codebase — <FR>

- Testcase: `<đường dẫn>` — <số TC>
- Codebase: `<đường dẫn>`
- Phiên bản code: `<commit hoặc mô tả snapshot>`
- Phương pháp: review tĩnh; chưa coi là kết quả chạy testcase

## Tổng quan
| Khớp tĩnh | Một phần | Lệch | Chưa tìm thấy | Cần làm rõ | Cần chạy thực tế |
|---:|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 | 0 | 0 |

## Đối chiếu từng testcase
| TC ID | Nhóm / hành vi cần kiểm | Trạng thái | Bằng chứng code hoặc phạm vi đã rà | Việc tiếp theo |
|---|---|---|---|---|
| ... |

## Điểm cần BA/BE làm rõ
<!-- Chỉ ghi câu hỏi có căn cứ từ TC và code; ghi rõ bên cần trả lời. -->

## Kiểm tra runtime còn cần làm
<!-- Thiết bị, OS, dữ liệu staging, API hoặc thao tác không thể chứng minh bằng review tĩnh. -->
```

Ưu tiên nêu các sai lệch có ảnh hưởng lớn ở đầu phần tổng quan, kèm TC ID và vị trí code. Nếu báo cáo đích đã tồn tại, đọc trước và giữ nguyên comment/ghi chú thủ công của BA, QC, BE hoặc user. Chỉ cập nhật phần có thể nhận diện là do skill tạo; nếu không tách được, tạo báo cáo mới với hậu tố ngày thay vì ghi đè.

Không sửa testcase, PRD hoặc code ứng dụng trong bước so sánh. Không chạy testcase hay commit báo cáo trừ khi user yêu cầu. Khi hoàn tất, báo đường dẫn từng báo cáo, số TC theo trạng thái và các điểm cần làm rõ quan trọng nhất.
