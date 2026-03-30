---
description: Quy trình sử dụng ApiClient với nhiều domain (baseUrl) và tích hợp vào Cubit
---

# Quy trình sử dụng ApiClient Multi-Domain

Quy trình này hướng dẫn cách sử dụng `ApiClient` để gọi các API từ nhiều domain khác nhau, xử lý callback response trong Repository và quản lý logic thông qua Cubit.

## Bước 1: Khởi tạo ApiClient (Nếu chưa có)
Trong `main.dart`, đảm bảo `ApiClient` đã được khởi tạo với một `baseUrl` mặc định.
```dart
import 'package:learnflutter/core/network/api_client/api_client.dart';

void main() {
  ApiClient.instance.init(baseUrl: 'https://api.default.com');
}
```

## Bước 2: Tạo Model cho dữ liệu
Định nghĩa class model để parse dữ liệu từ JSON.
```dart
class MyModel {
  final String id;
  final String name;

  MyModel({required this.id, required this.name});

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(id: json['id'], name: json['name']);
  }
}
```

## Bước 3: Tạo Repository xử lý logic mạng
Repository sẽ sử dụng `ApiClient` và có thể chỉ định `baseUrl` riêng cho từng yêu cầu.

```dart
import 'package:learnflutter/core/network/api_client/api_client.dart';

class MyRepository {
  Future<MyModel> fetchData() async {
    final response = await ApiClient.instance.get(
      '/path/to/resource',
      baseUrl: 'https://api.secondary-domain.com', // Chỉ định domain khác ở đây
    );
    return MyModel.fromJson(response);
  }
}
```

## Bước 4: Tạo Cubit để quản lý trạng thái
Cubit gọi Repository và cập nhật trạng thái (`State`) cho UI.

```dart
class MyCubit extends Cubit<MyState> {
  final MyRepository _repository = MyRepository();

  Future<void> loadData() async {
    emit(MyLoading());
    try {
      final data = await _repository.fetchData();
      emit(MySuccess(data));
    } catch (e) {
      emit(MyError(e.toString()));
    }
  }
}
```

## Bước 5: Sử dụng trên Screen (UI)
Sử dụng `BlocProvider` và `BlocBuilder` để hiển thị dữ liệu và kích hoạt logic.

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCubit()..loadData(),
      child: Scaffold(
        body: BlocBuilder<MyCubit, MyState>(
          builder: (context, state) {
            if (state is MyLoading) return Center(child: CircularProgressIndicator());
            if (state is MySuccess) return Text(state.data.name);
            return Text('Error');
          },
        ),
      ),
    );
  }
}
```
