---
description: Workflow phát triển Model sử dụng Equatable 
---

# Workflow phát triển Model với Equatable

Tài liệu này hướng dẫn cách tạo các Model dữ liệu sử dụng thư viện `equatable` để so sánh đối tượng, tích hợp với `SimpleItemModel` và xử lý JSON.

## 1. Cấu trúc cơ bản (lib/modules/[module_name]/model/[model_name].dart)

Hầu hết các model trong dự án nên kế thừa từ `SimpleItemModel` (nếu là dạng ID/Name cơ bản) hoặc trực tiếp sử dụng `EquatableMixin`.

### Trường hợp 1: Model kế thừa SimpleItemModel (Dropdown/Search)
Sử dụng khi model cần hiển thị trong các widget tìm kiếm hoặc chọn lựa.

```dart
import 'package:rii_mobimap/model/simple_item_model.dart';
import 'package:rii_mobimap/core/utils/utils_helper.dart';

class MyModel extends SimpleItemModel {
  MyModel({String? id, String? name}) {
    this.id = id;
    this.name = name;
  }

  // Thuộc tính bổ sung nếu có
  bool isEndList = false;

  // Factory tạo model từ JSON
  factory MyModel.fromJson(dynamic json) {
    return MyModel()..initWithJson(json);
  }

  // Factory cho model trống
  static MyModel empty() {
    return MyModel(id: '', name: '');
  }

  // Ghi đè phương thức fromJson của BaseResult
  @override
  MyModel fromJson(dynamic json) => MyModel.fromJson(json);
}
```

### Trường hợp 2: Model sử dụng Equatable trực tiếp
Sử dụng cho các data model phức tạp hơn.

```dart
import 'package:equatable/equatable.dart';

class ComplexModel extends Equatable {
  final String id;
  final String title;
  final List<String> tags;

  ComplexModel({
    required this.id,
    required this.title,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, title, tags];
}
```

## 2. Xử lý Model Response (Page Load)
Nếu model được trả về theo dạng danh sách phân trang (phổ biến trong project), hãy tạo class Response kế thừa `AcceptanceBasePageLoadModel`.

```dart
import 'package:rii_mobimap/modules/acceptance/base_acceptance/model/load_more_model/acc_base_page_load_model.dart';

class MyModelResponse<M extends MyModel> extends AcceptanceBasePageLoadModel<M> {
  MyModelResponse.fromJson(dynamic json, M Function(dynamic json) fromJson) {
    init(json);
    final datas = UtilsHelper.getJsonValue(json, ['data']);
    if (datas is List) {
      data = datas.map((e) => fromJson(e)..isEndList = (currentPage! >= totalPage!)).toList();
    }
  }
}
```

## 3. Quy tắc đặt tên và Coding Style (devflutter.md)
- **Class Name**: `PascalCase` (ví dụ: `WorkContentModel`).
- **File Name**: `snake_case` (ví dụ: `work_content_model.dart`).
- **Comments**: Mỗi comment phức tạp phải được giải thích thành một đoạn văn độc lập từ 3-5 câu (xem mẫu trong `WorkContentModel`).
- **Equatable**: Luôn định nghĩa `props` với các trường quan trọng để so sánh đối tượng đúng cách (thường là `id`).

## 4. Lưu ý quan trọng
- `SimpleItemModel` đã tích hợp sẵn `EquatableMixin`.
- Khi ghi đè `props`, hãy cân nhắc chỉ đưa `id` vào nếu bạn muốn so sánh dựa trên danh tính, hoặc đưa tất cả các field nếu muốn so sánh giá trị toàn bộ.
- Luôn cung cấp một phương thức `empty()` hoặc constructor mặc định để dễ dàng khởi tạo trong Cubit State.
