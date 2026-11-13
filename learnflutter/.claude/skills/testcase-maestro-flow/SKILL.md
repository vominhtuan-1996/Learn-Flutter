---
name: testcase-maestro-flow
description: Tạo Maestro flow YAML từ file testcase do user chỉ định, có thể giới hạn bằng TC ID; đối chiếu từng bước với UI/code thật của LearnFlutter và ghi rõ phần kỳ vọng không thể tự động hóa. Dùng khi user yêu cầu gen Maestro flow từ testcase; không dùng cho flow từ mô tả tự do hoặc để chạy test đã có.
---

# Testcase → Maestro Flow

Sinh flow có thể chạy được cho các bước UI trong testcase, đồng thời giữ truy vết tới TC ID và Expected Result gốc. Việc tạo flow không phải là kết quả chạy testcase.

Trước khi tạo flow, đọc [AGENT.md](AGENT.md) để kiểm soát phạm vi và assertions. Cách gọi và ví dụ ở [USAGE.md](USAGE.md).

## Đầu vào và phạm vi

- User chỉ định **file testcase** (`.csv` hoặc `.xlsx`). Nếu user chỉ định TC ID/range, chỉ xử lý các ID đó; nếu chỉ định cả file mà không giới hạn ID, xử lý toàn bộ TC trong file. Không tự chọn file từ tên FR hoặc từ ngữ cảnh cũ.
- Nếu XLSX có nhiều sheet chứa testcase mà user chưa nêu sheet, hỏi sheet trước khi tạo flow. Đọc các cột ID, Pre-condition, Test Steps và Expected Result theo header thực tế; kiểm tra ID trùng/rỗng và báo các dòng không đọc được.
- User có thể chỉ định module, flavor, app ID và thư mục output. Nếu chưa có, xác định từ route/code thực tế và flow hiện có trong module; hỏi user chỉ khi có nhiều lựa chọn mà không thể quyết định an toàn. Mặc định lưu flow tại `learnflutter/lib/features/<module>/.maestro/`.

## Tạo flow

1. Với **mỗi TC được chọn**, tách tiền điều kiện, từng thao tác và từng kết quả mong đợi thành danh sách kiểm. Không chỉ dựa vào Test Title. Xác định bước nào có thể quan sát bằng UI Maestro, bước nào cần dữ liệu staging, BE, thiết bị thật hoặc kiểm tra thủ công.
2. Đọc màn hình, route, localization, `Semantics`/test ID và flow/subflow hiện có của module. Chỉ dùng `text`, `id` hoặc selector khác khi đã xác minh từ code/flow đang chạy; chú ý locale và trạng thái màn hình. Có thể tham khảo phần cú pháp tạo flow trong [skill Maestro](../maestro/SKILL.md), nhưng **không** thực hiện các bước cài môi trường, chạy test hay debug nếu user chỉ yêu cầu gen flow.
3. Lấy `appId` từ build flavor/config hoặc flow hiện có đã đối chiếu với config; không sao chép mặc định từ ví dụ. Chọn `launchApp.clearState` theo tiền điều kiện TC. Dùng `runFlow` cho subflow dùng chung khi phù hợp, nhưng kiểm tra nội dung subflow trước khi tái sử dụng.
4. Tạo **một flow chính cho mỗi TC**; tên file snake_case, bắt đầu bằng TC ID đã chuẩn hóa, ví dụ `tc_01_8_login_success.yaml`. Ghi TC ID gốc, nguồn testcase và các tiền điều kiện quan trọng trong comment đầu file. Giữ các nhánh/biến thể của TC tách riêng nếu một flow không thể biểu diễn rõ ràng.
5. Mỗi Expected Result quan sát được phải có assertion tương ứng, đặt sau hành động gây ra kết quả. Dùng chờ có điều kiện cho thao tác bất đồng bộ; không dùng `sleep` cố định để thay assertion. Không tạo assertion giả cho nội dung ZIP, phản hồi BE, role khác hoặc trạng thái thiết bị mà Maestro UI không chứng minh được.
6. Dữ liệu nhạy cảm (tài khoản, mật khẩu, token, PII) chỉ dùng `${ENV_VAR}` hoặc fixture không chứa giá trị thật. Không chép credential từ testcase vào YAML, log hay phản hồi. Nếu thiếu fixture/credential/selector cần thiết, chỉ tạo phần flow có thể xác minh và báo chính xác phần bị chặn; không bịa dữ liệu để flow có vẻ đầy đủ.
7. Nếu TC mô tả hành vi chưa có trong code, hoặc Expected Result đang chờ BA/BE làm rõ, không tạo flow khẳng định hành vi đó đã tồn tại. Ghi TC ID và lý do chưa thể tạo flow đầy đủ để user xử lý tiếp.

Nếu không có Expected Result nào có thể assert bằng Maestro UI, không tạo flow chỉ gồm thao tác hoặc comment; báo TC đó cần cách kiểm tra khác.

Trước khi ghi file trùng tên, đọc flow hiện có và giữ nguyên comment, chỉnh sửa thủ công, subflow và assertion còn đúng. Nếu không thể cập nhật an toàn, tạo tên mới có hậu tố `_generated` thay vì ghi đè.

## Kiểm tra đầu ra và báo cáo

- Đọc lại YAML để kiểm tra `appId`, dấu `---`, thụt lề, cú pháp lệnh Maestro, biến môi trường, đường dẫn `runFlow` và selector đều có căn cứ. Không dùng lệnh không hợp lệ như `clearText` hoặc đặt `timeout` trong `assertVisible`.
- Đối chiếu lại từng TC đã chọn: ghi flow tương ứng, các Expected Result đã có assertion, các kỳ vọng chưa tự động hóa và dữ liệu/thiết bị cần chuẩn bị. Không gọi flow là `pass` khi chưa chạy.
- Không chạy Maestro, cài công cụ, sửa code ứng dụng/testcase, tạo credential hoặc commit nếu user chỉ yêu cầu gen flow. Chỉ chạy flow khi user yêu cầu rõ và khi đó áp dụng quy trình chạy của skill Maestro.
