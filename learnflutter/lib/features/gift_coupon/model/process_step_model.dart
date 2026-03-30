import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// ProcessStepStatus định nghĩa các trạng thái có thể có của một bước trong quy trình.
enum ProcessStepStatus {
  pending,    // Chờ xử lý (màu xám, có số)
  processing, // Đang xử lý (màu xanh, có số, text xanh)
  completed,  // Đã hoàn thành (màu xanh, dấu tích)
  failed      // Thất bại (màu đỏ, dấu X, có nút thử lại)
}

/// ProcessStepModel định nghĩa cấu trúc dữ liệu cho từng bước trong một quy trình xử lý.
/// Mỗi bước bao gồm tiêu đề chính, thông tin chi tiết (subtitle) và trạng thái hiện tại.
/// Cung cấp onRetry callback để xử lý khi người dùng muốn thực hiện lại bước bị lỗi.
class ProcessStepModel extends Equatable {
  final String title;
  final String? subtitle;
  final ProcessStepStatus status;
  final VoidCallback? onRetry;

  const ProcessStepModel({
    required this.title,
    this.subtitle,
    this.status = ProcessStepStatus.pending,
    this.onRetry,
  });

  /// Phương thức copyWith cho phép tạo một bản sao mới của đối tượng với các thuộc tính được cập nhật.
  /// Đây là mô hình chuẩn trong Flutter để quản lý các trạng thái bất biến (immutable states).
  ProcessStepModel copyWith({
    String? title,
    String? subtitle,
    ProcessStepStatus? status,
    VoidCallback? onRetry,
  }) {
    return ProcessStepModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      onRetry: onRetry ?? this.onRetry,
    );
  }

  @override
  List<Object?> get props => [title, subtitle, status];
}
