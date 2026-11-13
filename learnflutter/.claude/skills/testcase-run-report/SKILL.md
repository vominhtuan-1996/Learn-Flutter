---
name: testcase-run-report
description: Chạy các Maestro flow của một FR trên Simulator/Emulator, rồi ghi báo cáo kết quả theo từng TC vào learnflutter/docs/prd-v1.0 — file summary .md, thư mục evidence/ (ảnh đã loại PII) và CSV kết quả theo Testcase ID để dán vào sheet QC. Dùng khi user yêu cầu chạy testcase/flow của một FR và lưu kết quả, bằng chứng, GAP; không dùng để viết flow mới (dùng testcase-maestro-flow) hay chỉ chạy nhanh một flow (dùng maestro).
---

# Testcase → Run → Report

Chạy flow đã có, đối chiếu từng TC, rồi lưu kết quả có truy vết vào `learnflutter/docs/prd-v1.0`. Skill này **không viết flow mới** và **không sửa code app** trừ khi user yêu cầu riêng (sửa thì commit riêng).

## Đầu vào (hỏi nếu thiếu, không tự đoán)

- **FR folder**, ví dụ `learnflutter/docs/prd-v1.0/02-fr02-trang-chu`.
- **File testcase CSV**, ví dụ `learnflutter/docs/prd-v1.0/testcase-csv/tc-02-trang-chu.csv` (nguồn danh sách 100% TC và Testcase ID).
- **Thư mục flow**, mặc định `learnflutter/lib/features/<module>/.maestro/` (flow `tc_NN_*.yaml`).
- **Thiết bị**: Simulator/Emulator đang boot. Maestro CLI mặc định **không điều khiển được iPhone thật** (Maestro 2.10.0 mặc định: `--device <udid>` báo `not connected`); máy thật cần Maestro 2.0.10 + `maestro-ios-device` hoặc Appium/XCUITest — xem mục "Máy thật iOS" (ghi vào "Chưa chạy" nếu chưa có).
- **Executed By**: hỏi tên người chạy, không tự điền.
- Tài khoản/credential: chỉ từ `.env.maestro` hoặc biến môi trường; không ghi vào báo cáo/CSV/log.

## Quy trình

1. **Chuẩn bị build.** Build lại đúng flavor rồi cài lên thiết bị đang chạy; build cũ làm sai kết quả (thiếu `Semantics`/id mới). Ghi lại lệnh build và flavor.
   `flutter build ios --simulator --flavor staging -t lib/main_staging.dart` → `xcrun simctl install booted build/ios/iphonesimulator/Runner.app`.
2. **Chạy flow** bằng [run_flows.sh](run_flows.sh): chạy từng flow, ghi **exit code** + thời gian vào `results.tsv`. Flow dài thì chạy nền. Kết quả theo exit code, **không** theo grep "FAILED".
3. **Phân loại fail trước khi kết luận** (xem "Chẩn đoán fail" bên dưới). Mở ảnh lúc fail trong `~/.maestro/tests/<ts>/`; phân biệt lỗi flow, lỗi build cũ, lỗi accessibility của app, dữ liệu thay đổi, hay GAP thật.
4. **Chạy lại cả bộ** sau khi sửa flow để chốt kết quả cuối (mọi flow exit 0 mới gọi là chạy xong); flow chập chờn thì chạy lại, ghi nhận là chập chờn.
5. **Đối chiếu từng TC** trong CSV: TC có flow → `Pass` hoặc `Pass một phần`; TC không có flow → `Chưa chạy` hoặc `GAP` kèm lý do.
6. **Ghi file** (mục "Đầu ra"), tự kiểm tra số đếm khớp tổng TC.
7. **Commit** nếu user yêu cầu (xem "Commit").

## Máy thật iOS

- **Liệt kê máy**: `xcrun xctrace list devices` (máy iOS < 17 chỉ hiện ở đây hoặc `flutter devices`); `xcrun devicectl list devices` chỉ dùng được cho máy iOS ≥ 17 đã pair (máy cũ hiện `unavailable`). Máy phải ở mục *Devices*, không phải *Offline*, và đã bật Developer Mode + Trust.
- **Build**: `flutter build ios --flavor staging -t lib/main_staging.dart --release` → `build/ios/iphoneos/Runner.app`.
- **Cài và mở app — chọn công cụ theo iOS của máy** (xem version ở `xcrun xctrace list devices`):
  - **iOS ≥ 17** → `devicectl` (UUID CoreDevice lấy từ `xcrun devicectl list devices`, máy phải `available (paired)`):
    `xcrun devicectl device install app --device <uuid> build/ios/iphoneos/Runner.app`
    `xcrun devicectl device process launch --device <uuid> com.fpt.isc.prod`
  - **iOS < 17** → `ideviceinstaller` (UDID lấy từ `xcrun xctrace list devices`; `devicectl` báo `device not found` với máy này):
    `ideviceinstaller -u <udid> install build/ios/iphoneos/Runner.app` (có thể > 5 phút, chạy nền)
    `ideviceinstaller -u <udid> list --user | grep learnflutter` để xác nhận đã cài.
- **Giới hạn của `devicectl`**: chỉ cài/chạy/gỡ app và đọc thông tin máy; không điều khiển UI và không chuyển cổng cho driver XCTest của Maestro.
- **Điều khiển UI bằng Maestro (giữ nguyên flow YAML)** — đã chạy được trên iPhone 13 (iOS 27.0), dùng công cụ cộng đồng không chính thức `maestro-ios-device` (DeviceLab):
  1. Cần Maestro **2.0.9/2.0.10** (bản 2.10.0 mặc định không có cờ máy thật). Cài 2.0.10 từ `https://github.com/mobile-dev-inc/Maestro/releases/download/cli-2.0.10/maestro.zip` vào `~/.maestro` (giữ bản cũ ở `~/.maestro-2.10.0` để quay lại).
  2. Tải `maestro-ios-device-darwin-<arch>` từ `https://github.com/devicelab-dev/maestro-ios-device/releases/latest/download/` vào `~/.maestro/bin/`, chạy `maestro-ios-device setup` (nó vá JAR trong `~/.maestro/lib`; link `devicelab.dev/.../install/*.sh` đã 404).
  3. Bật trên máy: Cài đặt → Nhà phát triển → **Enable UI Automation**; mở khoá máy.
  4. Ký driver: bundle ID gốc `dev.mobile.maestro-driver-ios` đã bị đăng ký nên phải đổi trong `~/.maestro/maestro-ios-xctest-runner/maestro-driver-ios.xcodeproj/project.pbxproj` (vd `com.fpt.isc.maestrodriver`), rồi build 1 lần với `xcodebuild build-for-testing -allowProvisioningUpdates -allowProvisioningDeviceRegistration … DEVELOPMENT_TEAM=<team>` để tạo profile (việc này đăng ký App ID trên team Apple, cần xin phép). Chép `Build/Products` vào `~/.maestro/maestro-iphoneos-driver-build/driver-iphoneos/Build/`.
  5. Terminal 1: `maestro-ios-device --team-id <team> --device <udid>` (chờ "Ready!", `curl localhost:6001/status` trả `ok`).
  6. Terminal 2: `maestro --driver-host-port 6001 --device <udid> --app-file <app.ipa> test flow.yaml` (`.ipa` = zip thư mục `Payload/Runner.app` **bản release**; bản debug bị `signal 11`).
  - Chưa chạy được trên iPhone X (iOS 16.7, UDID 40 ký tự): vẫn báo `not connected` (nghi bản vá chỉ nhận UDID kiểu `00008xxx-…`).
  - Backend staging lỗi sẽ hiện hộp thoại "Không thể sử dụng ứng dụng — Lỗi khi xác thực client", đừng kết luận lỗi flow.
- **Phương án khác**: Appium + XCUITest (FR01 dùng Appium 2.19.0 + XCUITest 9.10.5) nhưng không dùng lại được flow YAML.
- **Android thật**: Maestro gốc chạy được trực tiếp (`maestro --udid <adb-serial> test …`); khi có cả Simulator và Android phải chỉ định `--udid`.

## Trạng thái TC (chỉ dùng 4 giá trị)

| Kết quả | Dùng khi |
|---|---|
| `Pass` | Flow exit 0 và assertion phủ **toàn bộ** Expected Result quan sát được. |
| `Pass một phần` | Flow exit 0 nhưng còn phần phải xem bằng mắt (màu, chevron, bản đồ), đối chiếu OPS/BE, hoặc dùng dữ liệu thay thế (ghi rõ). |
| `GAP` | App/code lệch TC hoặc PRD (đã quan sát trên app, hoặc từ review tĩnh — ghi rõ loại nào). |
| `Chưa chạy` | Không chạy được: thiếu fixture, cần BA/BE, cần role khác, cần thiết bị thật, chưa có flow. Ghi lý do cụ thể. |

Không bao giờ ghi `Pass` khi chưa chạy, khi flow chỉ có thao tác không assertion, hoặc khi assertion yếu (`assertNotVisible` có thể pass vô nghĩa — luôn có `assertVisible` trước đó chứng minh trạng thái).

## Đầu ra

Tất cả nằm trong `learnflutter/docs/prd-v1.0`. Ngày `YYYY-MM-DD` là ngày chạy.

1. **`<FR folder>/maestro-test-run-YYYY-MM-DD.md`** — summary. Cấu trúc cố định:
   - Tiêu đề `# Kết quả chạy Maestro — FR<NN> <tên>` + khối thông tin: ngày chạy, thiết bị/OS (kèm UDID), bản chạy (flavor, App ID, build từ entry point nào, đã merge nhánh nào), runner (Maestro version), dữ liệu (chỉ nói "phiên Root", không ghi credential).
   - `## Pass 100%` — bảng `TC | Bằng chứng`.
   - `## Cần theo dõi — chưa Pass 100%` — bảng `TC | Phần đã xác nhận | Việc còn thiếu` (gồm cả tên flow).
   - `## Chưa chạy — thiếu điều kiện` — tổng số TC có flow/tổng, bảng nhóm (fixture, cần BA/BE, code lệch spec, chưa viết được flow) và ghi chú thiết bị thật.
   - `## GAP phát hiện` — bảng `ID | TC liên quan | GAP | Quan sát | Cần xử lý` với ID `GAP-01…`.
   - `## Ghi chú runner` — lỗi lần chạy đầu đã xử lý, lệnh build/cài, ghi chú dữ liệu thay đổi.
   - `## Thay đổi phục vụ automation` — thay đổi code/Semantics (nếu có).
   - `## Ảnh bằng chứng` — bảng `Ảnh | Nội dung`.
   - `## Lưu ý phạm vi` — nêu rõ "không phải Pass toàn bộ FR", số flow Pass, phần còn xem bằng mắt.
2. **`<FR folder>/evidence/`** — ảnh bằng chứng, tên `tc-NN-<số>-<mô-tả>.png` (vd `tc-02-55-support-hotline.png`). Quy tắc:
   - Lấy từ `~/.maestro/tests/<ts>/…/screenshots/` hoặc từ `takeScreenshot:` trong flow (đường dẫn tương đối, lưu trong thư mục debug của Maestro).
   - **Loại ảnh có PII**: tên đăng nhập, họ tên người dùng (vd lời chào Trang chủ), tên công ty khách hàng, email, số điện thoại, token. Ảnh nghi ngờ thì bỏ.
   - Mỗi ảnh phải ứng với một dòng trong bảng "Ảnh bằng chứng".
3. **`testcase-csv/tc-NN-result-YYYY-MM-DD.csv`** — một dòng cho **mọi** TC trong CSV gốc, đúng thứ tự, UTF-8 có BOM. Cột: `Testcase ID, Kết quả, Note, Flow Maestro, Executed By, Ngày chạy`. `Executed By` và `Ngày chạy` chỉ điền cho TC đã chạy; `Note` ghi GAP-ID và phần còn thiếu. Không sửa CSV testcase gốc. Không có connector SharePoint/Excel nên user tự dán theo Testcase ID vào sheet.
4. **Không** ghi `results.tsv`, log thô hay credential vào docs; `results.tsv` chỉ để tính toán trong lúc chạy (đặt trong scratchpad).

## Chẩn đoán fail (bài học LearnFlutter)

- **Build cũ**: assert id mới fail dù code có → rebuild và cài lại.
- **iOS `id:` chỉ khớp `Semantics.identifier`**, không khớp `label`. Widget chỉ có `label` thì tap/assert theo `id:` sẽ fail; dùng `text` với regex hoặc thêm `identifier` (commit code riêng).
- **Node bị gộp semantics** (title + card): tâm node rơi vào widget khác, tap nhầm. Thêm `container: true` cho `Semantics`.
- **Text nhiều dòng/nhãn kèm hậu tố** (`"Thiết bị\nThiết bị"`, `"… Tab 1 of 2"`): dùng regex `(?s)<text>.*`; nhãn và giá trị có thể là hai node riêng nên assert từng giá trị.
- **Phần tử nằm dưới thanh nav nổi / ngoài màn hình**: tap rơi vào nav → `scrollUntilVisible` (ví dụ `centerElement: true`) trước khi tap.
- **Overlay/sheet che nội dung**: đóng sheet trước khi assert phần nằm sau.
- **Swipe carousel**: swipe mặc định ở giữa màn hình không nằm trên carousel → dùng toạ độ (`start: 85%, 65%` → `end: 15%, 65%`); sau swipe có thể cần chờ animation, chập chờn thì chạy lại.
- **`copyTextFrom` + `evalScript`** để so sánh giá trị động giữa hai màn (không hardcode dữ liệu staging).
- **Dữ liệu staging đổi liên tục** (số gói, thứ tự thẻ, SL gắn thiết bị): flow phụ thuộc chỉ số thẻ cố định có thể sai điều kiện — ghi vào "Ghi chú runner".
- **API staging chậm**: ảnh lúc fail còn overlay loading, banner "0/0", header "CUSTOMER PORTAL" → fail ở bước đăng nhập/tải Trang chủ, không phải lỗi flow. Chạy lại đúng flow đó 1 lần; pass thì ghi "chập chờn do API chậm" vào Ghi chú runner, không đổi trạng thái TC.
- Log `xcTestDriverStatusCheck … ConnectException` đầu mỗi lượt là probe driver, không phải lỗi.
- **Máy quá tải làm driver chết giữa flow** (log có `iOS driver not ready in time … MAESTRO_DRIVER_STARTUP_TIMEOUT`, flow dừng ở bước ngẫu nhiên, không có dòng assertion FAILED): không phải lỗi flow. `export MAESTRO_DRIVER_STARTUP_TIMEOUT=180000`, không build/cài app song song lúc chạy, chạy lại riêng các flow đó.
- **Nút nằm dưới màn hình** (vd Chỉnh sửa/Mặc định ở tab Cấu hình router): `assertVisible` fail dù app đúng; dùng `scrollUntilVisible` trước.
- **Nút của confirm sheet** (Huỷ/Giữ lại/Xác nhận): text bị `Semantics(label:)` che, tap theo `id: confirm_sheet_cancel_btn` / `confirm_sheet_confirm_btn`.
- `takeScreenshot:` dùng đường dẫn tương đối (tên file); đường dẫn tuyệt đối làm lệnh fail.

## Commit (khi user yêu cầu)

Hook ISC chặn commit sai format. Tuân thủ:
- Mỗi `git commit` chạy **trong một lệnh Bash riêng**, không ghép với `git add`, `cd`, `&&`, `$(...)`; không dùng `git -C`.
- Subject `type(scope): mô tả` (type hợp lệ: feat, fix, refactor, test, docs, style, chore), **kết thúc bằng ` [AI]`**, ≤50 ký tự khuyến nghị.
- Thêm dòng `Co-Authored-By` theo hướng dẫn của phiên.
- Tách commit: code app / flow / docs-kết quả.
- Không commit lên `dev`/`main`; đang ở nhánh đó thì tạo nhánh `feature/<ticket>-<author>-<mô tả>` trước.
- Không commit credential, `.env.maestro`, ảnh có PII, `build/`.

## Báo cáo cho user

Nêu: số flow chạy và exit code, số TC theo 4 trạng thái, danh sách GAP mới, thay đổi code (nếu có) và đường dẫn các file đã ghi. Nói rõ phần chưa kiểm chứng và giả định (ví dụ đơn vị dữ liệu, `Executed By`).
