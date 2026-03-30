/// BaseResponse - Chuẩn hóa định dạng phản hồi từ API của dự án
///
/// Định dạng JSON:
/// {
///    "status": 0,
///    "message": "...",
///    "errorData": null,
///    "data": { ... }
/// }
class BaseResponse<T> {
  final int status;
  final String message;
  final dynamic errorData;
  final T? data;

  BaseResponse({
    required this.status,
    required this.message,
    this.errorData,
    this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json,
      [T Function(dynamic)? fromJsonT]) {
    final rawData = json['data'];
    return BaseResponse<T>(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      errorData: json['errorData'],
      data: (rawData != null && fromJsonT != null)
          ? fromJsonT(rawData)
          : rawData as T?,
    );
  }

  bool get isSuccess => status == 0;
}
