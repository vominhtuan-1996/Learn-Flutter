# Cách dùng: engineering-bug-investigator

Điều tra bug của app LearnFlutter để tìm nguyên nhân gốc: lần theo `Screen → Cubit → Repository → Service`, đối chiếu PRD/API/log, phân loại lỗi app / BE / lệch spec, ghi `be-handoff` khi lỗi ở backend. Mặc định chỉ đọc, không sửa code.

## Gọi agent

Trong Claude Code, nhờ Claude gọi bằng tên agent, hoặc chỉ định `subagent_type: engineering-bug-investigator`.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Radar thời tiết ở màn Hải trình không cập nhật khi bật lại. Tìm nguyên nhân gốc, chưa sửa.

> Bug FE-123: số liệu thống kê hôm nay hiện 0 dù thiết bị có data. Điều tra, phân loại lỗi app hay BE.

## Khi nào dùng agent này

| Tình huống | Agent |
|---|---|
| Không biết vì sao bug xảy ra | `engineering-bug-investigator` |
| Đã biết nguyên nhân, cần sửa | `engineering-mobile-app-builder` |
| Cần gọi API thật để so spec | `testing-api-tester` |
| Cần ảnh/video/log tái hiện | `testing-evidence-collector` |
| Cần xác nhận đã sửa xong | `testing-reality-checker` |
| Bug có mã Jira, so với PRD | skill `bug-vs-brd` |

## Lưu ý riêng cho repo này

Agent đã viết cho LearnFlutter. Khi giao việc, nên nêu:

- **Triệu chứng cụ thể:** màn nào, thao tác nào, flavor (`dev`/`staging`/`prod`), iOS hay Android, phiên bản app, có tái hiện được không.
- **Tài liệu liên quan:** FR trong `learnflutter/docs/prd-v1.0/`, endpoint trong `docs/api-call-map.md`.
- **Dữ liệu thật (nếu có):** log (ví dụ `WeatherV2 lỗi (HTTP …)`), ảnh màn hình. Che token, số hợp đồng, SĐT, email, serial thiết bị trước khi gửi.
- **Phạm vi hành động:** mặc định chỉ đọc. Muốn agent viết test tái hiện, ghi `be-handoff` hay sửa code thì nói rõ.
- **Token/API:** token do user cung cấp qua biến môi trường, không ghi vào file. Agent không gọi API ghi dữ liệu; việc gọi API thật giao `testing-api-tester`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject [AI]` và quy tắc ISC (`isc-merge-request-rules`).
- **Mức độ tin cậy:** báo cáo luôn tách "Đã chứng minh", "Suy ra từ code" và "Chưa kiểm". Chưa chạy trên máy thật thì nói thẳng.

## Nguồn chuẩn

Định nghĩa agent: [engineering-bug-investigator.md](../../agents/engineering-bug-investigator.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
