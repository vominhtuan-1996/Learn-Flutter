import 'package:flutter_bloc/flutter_bloc.dart';

/// Lớp BaseCubit đóng vai trò là một lớp trừu tượng cơ sở cho tất cả các Cubit trong ứng dụng.
/// Nó mở rộng từ lớp Cubit của thư viện flutter_bloc để cung cấp các tính năng quản lý trạng thái chuẩn hóa.
/// Việc kế thừa từ BaseCubit giúp đảm bảo tính nhất quán trong cách khởi tạo và xử lý logic nghiệp vụ cho các màn hình.
/// Hiện tại, lớp này cung cấp một khung sườn cơ bản có thể được mở rộng để tích hợp các tính năng dùng chung như logging hoặc xử lý lỗi tập trung.
abstract class BaseCubit<E> extends Cubit<E> {
  /// Khởi tạo BaseCubit với một trạng thái ban đầu cụ thể.
  /// Constructor này gọi super(initialState) để đăng ký trạng thái mặc định với hệ thống quản lý của Bloc.
  BaseCubit(super.initialState);
}
