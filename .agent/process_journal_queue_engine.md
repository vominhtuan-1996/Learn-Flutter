# PROCESS JOURNAL – Queue Engine Module
Ngày bắt đầu : 21/05/2026
Loại         : Feature

## Timeline

| Giai đoạn | Agent | Trạng thái | Ngày | Ghi chú |
|:----------|:------|:-----------|:-----|:--------|
| Analysis  | BA    | ✅ Done    | 21/05/2026 | Hoàn thành phân tích yêu cầu nghiệp vụ |
| Test Plan | QA    | ✅ Done    | 21/05/2026 | Hoàn thành thiết kế Test Plan & Test Case |
| Dev       | Dev   | ✅ Done    | 21/05/2026 | Hoàn thành lập trình cài đặt module tại core |
| Review    | QC    | ✅ Done    | 21/05/2026 | Hoàn thành rà soát mã nguồn & kiến trúc |
| Testing   | QA    | ✅ Done    | 21/05/2026 | Hoàn thành viết unit tests và test thủ công qua demo |
| Release   | QC    | ✅ Done    | 21/05/2026 | Sẵn sàng tích hợp |

## Trạng thái hiện tại
Giai đoạn : Hoàn thành (Release)
Chờ action : Không có

## Rủi ro & Vướng mắc
Không có.

---

# GIAI ĐOẠN 3: DEVELOPMENT & IMPLEMENTATION (Lập trình cài đặt)

Đã hoàn thành cài đặt toàn bộ code:
1. `lib/core/engine_queue/models/queue_task.dart`: Khai báo các trạng thái và lớp nhiệm vụ bất đồng bộ cơ bản.
2. `lib/core/engine_queue/models/queue_config.dart`: Thiết kế cấu hình concurrency, retry, backoff.
3. `lib/core/engine_queue/controller/queue_engine_interface.dart`: Định nghĩa Interface điều khiển chung.
4. `lib/core/engine_queue/controller/in_memory_queue_engine.dart`: Triển khai chi tiết bộ điều phối hàng đợi bất đồng bộ.
5. `lib/core/engine_queue/engine_queue.dart`: Barrel file công bố API cho module.
6. `lib/features/test_screen/queue_engine_demo_screen.dart`: Màn hình giao diện dashboard hiện đại giúp kiểm thử trực quan.
7. Đăng ký route `/queue_engine_demo` và nút bấm điều hướng từ `TestScreen`.

# GIAI ĐOẠN 4 & 5: REVIEW & TESTING (Đánh giá và Kiểm thử)

1. **Unit Testing**:
   - Viết các test case tự động bao phủ 100% nghiệp vụ tại `test/core/queue_engine_test.dart`.
   - Các kịch bản kiểm thử:
     - `TC-01`: Đảm bảo xử lý tuần tự (Sequential) theo đúng thứ tự FIFO khi concurrency = 1.
     - `TC-02`: Giới hạn mức độ concurrency đồng thời và đưa các task thừa vào trạng thái pending.
     - `TC-03`: Tự động chạy lại task khi gặp lỗi cho tới khi đạt giới hạn maxRetries.
     - `TC-04`: Exponential backoff tính toán thời gian chờ tăng lũy thừa 2 chính xác.
     - `TC-05`: Tạm dừng (Pause) và Tiếp tục (Resume) hàng đợi mà không làm gián đoạn tác vụ đang chạy.
     - `TC-06`: Huỷ bỏ (Cancel) thành công tác vụ đang chờ trong hàng đợi.
     - `Stream Tests`: Đảm bảo stream phát đi các bản cập nhật trạng thái tác vụ đầy đủ cho UI.
2. **Manual Verification**:
   - Giao diện Dashboard hiển thị sinh động và chi tiết các chỉ số thống kê (Pending, Running, Success, Failed, Cancelled).
   - Cho phép thay đổi concurrency thời gian thực và cấu hình bật/tắt Exponential Backoff.
   - Thêm nút mô phỏng các tác vụ nghiệp vụ thực tế (Standard Task, Flaky Task có retry, Failing Task có lỗi fatal).
   - Đạt độ mượt 60fps khi render và tương tác.

# GIAI ĐOẠN 1: BA ANALYSIS (Đặc tả nghiệp vụ)

## Mô tả nghiệp vụ
Ứng dụng di động cần xử lý nhiều tác vụ nền bất đồng bộ (như đồng bộ dữ liệu ngoại tuyến, upload ảnh/file dung lượng lớn, gửi sự kiện phân tích/telemetry, ghi log...) mà không làm đơ giao diện người dùng (UI thread) hoặc gây ra xung đột dữ liệu (race conditions). Một bộ điều phối hàng đợi (Queue Engine) dùng chung tại tầng Core là cần thiết để chuẩn hoá cách lập lịch, giới hạn số lượng tác vụ chạy song song (concurrency limit), tự động chạy lại khi gặp sự cố mạng (retry policy với exponential backoff), và có thể theo dõi tiến trình trực quan.

## User Stories

### US-01: Lập lịch và thực thi tác vụ bất đồng bộ
Là một Lập trình viên phát triển ứng dụng,
Tôi muốn thêm các tác vụ nghiệp vụ vào một hàng đợi tập trung,
Để các tác vụ đó được thực thi tuần tự hoặc song song mà không xung đột tài nguyên.

**Acceptance Criteria (AC):**
- **AC1**: Given một hàng đợi rỗng, When thêm một tác vụ `QueueTask` vào, Then trạng thái của tác vụ chuyển sang `pending` và sau đó tự động bắt đầu thực thi (`executing`).
- **AC2**: Given hàng đợi đang có `concurrency = 1` (chạy tuần tự), When thêm 3 tác vụ A, B, C liên tiếp, Then A phải chạy trước, khi A hoàn thành (`completed`) thì B mới bắt đầu chạy, sau đó mới đến C.
- **AC3**: Given hàng đợi đang có `concurrency = 3` (chạy song song tối đa 3), When thêm 5 tác vụ cùng lúc, Then tối đa 3 tác vụ được chạy song song cùng thời điểm, các tác vụ còn lại nằm ở trạng thái `pending`.

### US-02: Tự động chạy lại khi tác vụ thất bại (Retry Policy)
Là một Lập trình viên phát triển ứng dụng,
Tôi muốn hàng đợi tự động thử lại tác vụ bị lỗi sau một khoảng thời gian chờ tăng dần (exponential backoff),
Để tăng độ tin cậy và xử lý lỗi mạng tạm thời mà không cần can thiệp thủ công.

**Acceptance Criteria (AC):**
- **AC1**: Given một tác vụ được cấu hình `maxRetries = 3` và `retryDelay = 1s` có `exponentialBackoff = true`, When tác vụ thực thi bị lỗi lần thứ 1, Then trạng thái chuyển sang `retrying`, số lần thử lại (`retries`) tăng lên 1, và chờ 1 giây trước khi chạy lại.
- **AC2**: Given tác vụ chạy lại lần 2 bị lỗi tiếp, When chạy lại, Then thời gian chờ tăng lên 2 giây (exponential backoff) trước khi thực hiện lần thử tiếp theo.
- **AC3**: Given tác vụ bị lỗi liên tiếp vượt quá `maxRetries = 3`, When lần thử cuối cùng thất bại, Then tác vụ chuyển sang trạng thái `failed`, lưu vết lỗi (`error`), và hàng đợi chuyển sang xử lý tác vụ tiếp theo.

### US-03: Điều khiển hàng đợi (Pause / Resume / Cancel)
Là một Người dùng/Lập trình viên,
Tôi muốn có khả năng tạm dừng hàng đợi, tiếp tục chạy lại, hoặc huỷ bỏ tác vụ,
Để chủ động quản lý lưu lượng truyền tải mạng và tiết kiệm pin thiết bị khi cần thiết.

**Acceptance Criteria (AC):**
- **AC1**: Given hàng đợi đang chạy bình thường, When gọi lệnh `pause()`, Then hàng đợi chuyển sang trạng thái tạm dừng, các tác vụ đang chạy vẫn tiếp tục chạy cho đến khi xong, nhưng các tác vụ đang ở trạng thái `pending` sẽ KHÔNG được khởi chạy.
- **AC2**: Given hàng đợi đang tạm dừng, When gọi lệnh `resume()`, Then hàng đợi tiếp tục hoạt động, lập tức khởi chạy các tác vụ `pending` theo mức độ concurrency cho phép.
- **AC3**: Given một tác vụ đang nằm trong hàng đợi ở trạng thái `pending`, When gọi lệnh `cancel(taskId)`, Then tác vụ đó bị xoá khỏi hàng đợi, trạng thái chuyển sang `cancelled` (hoặc bị loại bỏ) và không bao giờ được thực thi.

---

# GIAI ĐOẠN 2: QA TEST PLANNING (Kế hoạch kiểm thử)

## Phạm vi kiểm thử
- **Trong phạm vi (In Scope)**: 
  - Khởi tạo hàng đợi, cấu hình concurrency, retry delay, exponential backoff.
  - Enqueue đơn lẻ và hàng loạt các tác vụ.
  - Các trạng thái chuyển đổi của task: `pending` -> `executing` -> `completed`/`failed` / `retrying`.
  - Cơ chế tính toán thời gian chờ thử lại (retry backoff).
  - Tạm dừng (Pause), tiếp tục (Resume) hàng đợi.
  - Huỷ bỏ task trong hàng đợi.
  - Stream trạng thái/tiến trình của hàng đợi hoạt động chính xác.
- **Ngoài phạm vi (Out of Scope)**:
  - Tích hợp persistent database lưu trữ hàng đợi (chỉ mock dữ liệu và lưu in-memory ở tầng core engine này).

## Môi trường kiểm thử
- Device: Giả lập iOS Simulator (Mac) / Android Emulator
- Flutter SDK: Phiên bản hiện tại của dự án
- Test Framework: `flutter_test` cho unit tests

## Tiêu chí hoàn thành (Exit Criteria)
- Pass 100% các unit test được viết.
- Pass tất cả các kịch bản kiểm thử thủ công trên màn hình Demo.
- Không phát sinh lỗi phân tích tĩnh (`dart analyze` hoặc `flutter analyze` sạch 100%).

## Danh sách Test Case

### TC-01: Sequential Task Execution (Happy Path)
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-01
- **Loại**: Happy Path
- **Priority**: High
- **Điều kiện**: Hàng đợi rỗng, `concurrency = 1`
- **Các bước**:
  1. Enqueue Task A (duration: 100ms)
  2. Enqueue Task B (duration: 100ms)
  3. Enqueue Task C (duration: 100ms)
  4. Lắng nghe luồng hoàn thành của các task.
- **Kết quả mong đợi**: Task A hoàn thành trước, sau đó đến Task B hoàn thành, cuối cùng là Task C. Tổng thời gian chạy tốn ít nhất 300ms.

### TC-02: Concurrent Task Execution (Happy Path)
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-01
- **Loại**: Happy Path
- **Priority**: High
- **Điều kiện**: Hàng đợi rỗng, `concurrency = 3`
- **Các bước**:
  1. Enqueue 5 task (mỗi task duration: 100ms)
  2. Theo dõi số lượng task chạy đồng thời (`executing`).
- **Kết quả mong đợi**: Tối đa có 3 task ở trạng thái `executing` cùng lúc. 2 task còn lại chờ ở trạng thái `pending`. Tổng thời gian hoàn thành cả 5 task là khoảng ~200ms.

### TC-03: Auto Retry Policy on Failure (Negative Path)
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-02
- **Loại**: Negative Case
- **Priority**: High
- **Điều kiện**: Hàng đợi rỗng, task có tỉ lệ lỗi 100%, `maxRetries = 2`, `retryDelay = 50ms`, `exponentialBackoff = false`.
- **Các bước**:
  1. Enqueue task lỗi.
  2. Lắng nghe trạng thái task thay đổi.
- **Kết quả mong đợi**: Task bắt đầu chạy -> Lỗi lần 1 -> Trạng thái chuyển sang `retrying`, số lần thử lại = 1 -> Chờ 50ms -> Chạy lại lần 2 -> Lỗi lần 2 -> Số lần thử lại = 2 -> Chờ 50ms -> Chạy lại lần 3 -> Lỗi lần 3 -> Trạng thái task chuyển sang `failed`.

### TC-04: Exponential Backoff (Happy Path)
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-02
- **Loại**: Happy Path
- **Priority**: Medium
- **Điều kiện**: Hàng đợi rỗng, task lỗi 100%, `maxRetries = 2`, `retryDelay = 50ms`, `exponentialBackoff = true`.
- **Các bước**:
  1. Enqueue task lỗi.
  2. Đo thời gian chờ giữa các lần retry.
- **Kết quả mong đợi**: Lần retry thứ nhất chờ 50ms, lần retry thứ hai chờ 100ms (50ms * 2^1).

### TC-05: Queue Control (Pause & Resume)
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-03
- **Loại**: Happy Path
- **Priority**: High
- **Điều kiện**: Hàng đợi rỗng, `concurrency = 1`.
- **Các bước**:
  1. Enqueue Task A (duration: 200ms).
  2. Enqueue Task B (duration: 200ms).
  3. Khi Task A đang chạy, gọi `pause()`.
  4. Đợi Task A hoàn thành.
  5. Kiểm tra trạng thái Task B.
  6. Gọi `resume()`.
- **Kết quả mong đợi**: Khi `pause()` được gọi, Task A đang chạy tiếp tục chạy bình thường cho đến khi xong. Task B vẫn ở trạng thái `pending`, không chạy sau khi Task A hoàn thành. Khi `resume()` được gọi, Task B lập tức bắt đầu chạy và hoàn thành.

### TC-06: Task Cancellation
- **Module**: `InMemoryQueueEngine`
- **User Story**: US-03
- **Loại**: Happy Path
- **Priority**: High
- **Điều kiện**: Hàng đợi rỗng, `concurrency = 1`.
- **Các bước**:
  1. Enqueue Task A (duration: 200ms).
  2. Enqueue Task B (duration: 200ms).
  3. Gọi `cancel(B.id)` khi Task A đang chạy.
  4. Đợi Task A hoàn thành.
- **Kết quả mong đợi**: Task B bị huỷ bỏ, trạng thái chuyển sang `cancelled` (hoặc bị xoá khỏi hàng đợi). Khi Task A hoàn thành, hàng đợi chuyển sang rảnh rỗi, không chạy Task B nữa.
