# Flutter Mobile Architecture & Coding Style Guide

Tài liệu này định nghĩa các quy chuẩn về cấu trúc thư mục, cách đặt tên, quản lý trạng thái và phong cách viết code (coding style) dành cho dự án Flutter Mobile, nhằm đảm bảo tính nhất quán, dễ bảo trì và mở rộng.

---

## 1. Cấu trúc thư mục (Project Architecture)

Dự án tuân theo kiến trúc **Feature-based** (chia theo tính năng) kết hợp với **Core Layer** cho các thành phần dùng chung.

### 1.1. Thư mục `lib/`

| Thư mục | Mô tả |
| :--- | :--- |
| `app/` | Cấu hình ứng dụng (App root, theme, router configuration). |
| `core/` | Chứa các thành phần cốt lõi (Network, Theme tokens, Global Services, Constants). |
| `features/` | Chia theo từng module chức năng (Login, Map, Settings, v.v.). |
| `component/` | Các widget UI dùng chung toàn dự án (Button, Input, Dialog tiêu chuẩn). |
| `data/` | Quản lý dữ liệu (Base models, Local storage helpers). |
| `utils_helper/` | Các hàm tiện ích logic (Date format, String manipulation, Validators). |
| `extensions/` | Dart extensions để mở rộng chức năng cho các lớp có sẵn (UI, String, Iterable). |
| `l10n/` | Quản lý đa ngôn ngữ (Localization). |

### 1.2. Cấu trúc một Feature (`lib/features/[feature_name]/`)

Mỗi feature nên được đóng gói hoàn chỉnh:
- `cubit/`: Quản lý Logic và State bằng Cubit.
- `state/`: Định nghĩa các trạng thái của UI.
- `repos/`: Giao tiếp với API hoặc Database.
- `model/`: Các data model riêng của feature.
- `widgets/`: Các sub-widgets chỉ dùng trong feature này.
- `view/`: Màn hình chính của feature.

---

## 2. Quy chuẩn đặt tên (Naming Conventions)

Tuân thủ nghiêm ngặt quy tắc của Dart và Flutter:

| Đối tượng | Quy chuẩn | Ví dụ |
| :--- | :--- | :--- |
| **Thư mục & File** | `snake_case` | `login_screen.dart`, `auth_repository.dart` |
| **Class & Extension** | `PascalCase` | `LoginCubit`, `StringExtension` |
| **Biến & Phương thức** | `camelCase` | `isLoading`, `fetchData()` |
| **Hằng số (Constant)** | `lowerCamelCase` | `apiBaseUrl`, `primaryColor` |

> [!WARNING]
> Không đặt tên file theo kiểu PascalCase (ví dụ: `LoginScreen.dart` là SAI).

---

## 3. Quản lý trạng thái (State Management - Cubit)

Dự án sử dụng **Cubit** (một phần của thư viện Bloc) để quản lý logic UI.

### 3.1. Quy tắc State
- State phải kế thừa từ `BaseState` (nếu có) hoặc `Equatable`.
- Luôn có phương thức `cloneWith` (hoặc `copyWith`) để cập nhật state mà không làm mất các thuộc tính cũ.
- Luôn có factory `initial()` để khởi tạo giá trị mặc định.

### 3.2. Quy tắc Cubit
- Kế thừa từ `BaseCubit`.
- Không gọi trực tiếp `Dio` hay `Http` trong Cubit, hãy gọi thông qua `Repository`.
- Sử dụng `emit(state.cloneWith(...))` để thông báo thay đổi cho UI.
- Trình bày logic rõ ràng, tránh logic quá dài trong một method.

---

## 4. Lớp Dữ liệu (Models & Repositories)

- **Models**: Sử dụng `EquatableMixin` để so sánh đối tượng. Khuyến khích kế thừa `SimpleItemModel` cho các đối tượng cơ bản.
- **JSON**: Mỗi model phải có factory `fromJson`.
- **Repositories**: Sử dụng `sl<T>()` (Service Locator - GetIt) để inject các dependencies như `ApiClient`.

---

## 5. Phong cách viết Code (Senior Dev Standards)

### 5.1. Chú thích & Tài liệu (Documentation)
- Các phương thức/lớp quan trọng phải có chú thích rõ ràng bằng **tiếng Việt**.
- Với các logic phức tạp, cần giải thích bằng một đoạn văn từ **3-5 câu** thay vì chỉ ghi chú ngắn gọn 1 dòng.
- Sử dụng `///` cho comment tài liệu để IDE có thể preview.

### 5.2. Clean Code
- **DRY (Don't Repeat Yourself)**: Nếu một logic UI hoặc xử lý dữ liệu xuất hiện > 2 lần, hãy tách thành widget/helper dùng chung.
- **SOLID**: Mỗi lớp chỉ nên làm một nhiệm vụ duy nhất. Ví dụ: UI chỉ hiển thị, Cubit chỉ xử lý logic, Repo chỉ lấy dữ liệu.
- **Constants**: Không để "magic strings" hoặc "magic numbers" trong code. Hãy khai báo chúng trong `core/constants/`.

---

## 6. Giao diện (UI & Styling)

- **Design System**: Sử dụng màu sắc và typography đã định nghĩa trong `core/theme/`. Tránh hardcode màu (ví dụ: `Colors.blue` -> `context.theme.primaryColor`).
- **Responsive**: Sử dụng các widget linh hoạt như `Flexible`, `Expanded`, `LayoutBuilder` hoặc các extension hỗ trợ kích thước màn hình.
- **Assets**: Truy cập file qua một class `AppAssets` để tránh sai sót đường dẫn.

---

## 7. Kiểm soát chất lượng

- **Linting**: Sử dụng bộ quy tắc lint `linter_rules.yaml` của dự án (luôn chạy `flutter analyze`).
- **Formatting**: Luôn chạy `flutter format .` trước khi commit code.
- **Unit Test**: Khuyến khích viết test cho các logic quan trọng trong Cubit và Utils.

---
*Tài liệu được biên soạn để phục vụ quy trình phát triển chuyên nghiệp của dự án Learn Flutter.*
