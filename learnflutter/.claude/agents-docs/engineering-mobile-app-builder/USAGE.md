# Cách dùng: engineering-mobile-app-builder

Xây dựng và tối ưu màn hình/tính năng Flutter: UI theo Figma/PRD, tích hợp native (biometric, FCM, quyền, bản đồ), hiệu năng, kiến trúc feature.

## Gọi agent

Trong Claude Code, nhờ Claude gọi agent "Mobile App Builder" (file `engineering-mobile-app-builder.md`; frontmatter `name: Mobile App Builder`, khác các agent `testing-*` dùng tên dạng slug), hoặc chỉ định `subagent_type` theo tên hiển thị trong danh sách agent của session.
Mở session mới sau khi thêm/sửa agent để được nạp.

Ví dụ yêu cầu:
> Làm màn cấu hình WiFi router theo FR03 trong PRD: Cubit + State + Repository, route trong `Routes`, text qua `AppLocale` (vi/en), màu/kích thước qua `AppColors`/`AppDimens`.

> Danh sách cảnh báo thiết bị cuộn giật: đo, tìm nguyên nhân (rebuild, `Column` thay vì `ListView.builder`) và sửa kèm số liệu trước/sau.

> Thêm luồng xin quyền vị trí cho màn Bản đồ, xử lý bị từ chối và quay lại từ cài đặt.

## Phù hợp / không phù hợp

- **Phù hợp:** dựng màn hình/component theo Figma/PRD, Cubit/State/Repository của một feature, tích hợp native, tối ưu render/bộ nhớ, rà kiến trúc.
- **Không dùng cho:** đo hiệu năng độc lập (`testing-performance-benchmarker`), đối chiếu UI với wireframe (skill `wireframe-audit`, `testing-evidence-collector`), viết Maestro flow (`maestro`, `testing-test-automation-engineer`), đánh giá package (`testing-tool-evaluator`), viết tài liệu (`engineering-technical-writer`).

## Lưu ý riêng cho repo này

`engineering-mobile-app-builder.md` đã viết lại cho Flutter LearnFlutter (kiến trúc Cubit, quy tắc UI repo). Khi giao việc, nhắc thêm ngữ cảnh:

- **App:** Flutter/Dart, `learnflutter/` (flavor `dev`/`staging`/`prod`), kiến trúc Screen → Cubit → Repository → ApiClient, API tầng `lib/services/`.
- **Lệnh kiểm:** `dart analyze lib test`, `flutter test --no-pub` (quality gate dùng đúng 2 lệnh này).
- **Maestro:** flow nằm cạnh feature (`lib/features/<f>/.maestro/`), credential đọc từ `.env.maestro` (gitignored). Dùng skill `maestro`, `testcase-maestro-flow`, `testcase-run-report`.
- **Spec/PRD:** `learnflutter/docs/prd-v1.0/`, API: tài liệu API của dự án, `api-call-map.md`; KB: KB dự án (nếu có).
- **Không đưa vào báo cáo:** token, mật khẩu, PII (số hợp đồng, SĐT, email thật); che trước khi lưu ảnh.
- **Không tự commit/push:** hỏi trước; commit theo `type(scope): subject` và quy tắc ISC (`isc-merge-request-rules`).
- **Chỉ Dart/Flutter:** không viết Swift/Kotlin/React Native cho tính năng; code native chỉ chạm `android/`, `ios/` khi bắt buộc (flavor, FCM, signing).
- **Quy tắc cứng (đọc `.claude/rules/rule_convention.md`):** `*Page` bọc `AppScreen`/`AppBackScreen`/`AppTabScreen`/`AppStepScreen` (không `Scaffold` trực tiếp, ≤ 700 dòng); điều hướng bằng `AppNavigator` + `Routes`; dialog/snackbar qua `AppDialogEngine`/`AppSnackbarEngine`; async action bọc `loadingZone`; danh sách phân trang dùng `LoadMoreCubit`; `fromJson` dùng `JsonUtils`; asset qua `AppAssets`; dark/light qua `Theme.of(context).colorScheme`.
- **Không tự thêm package:** kiểm `pubspec.yaml` trước; không sửa `pubspec.lock` tay. State chỉ `flutter_bloc` (Cubit), không Provider/Riverpod/GetX.
- **Maestro:** widget không text phải bọc `Semantics(label:, identifier:)` cùng giá trị.
- **Cập nhật KB:** đổi route/API/business rule thì sửa KB dự án (nếu có) và `CHANGELOG.md [Unreleased]`.

## Nguồn chuẩn

Định nghĩa agent: [engineering-mobile-app-builder.md](../../agents/engineering-mobile-app-builder.md). Đọc `CLAUDE.md` và `.claude/rules/` của repo trước khi làm; trả lời bằng tiếng Việt.
