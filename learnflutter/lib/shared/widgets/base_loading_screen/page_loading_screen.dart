import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';

/// PageLoadingScreen là một màn hình ví dụ dùng để trình diễn khả năng hoạt động của BaseLoading.
/// Nó cung cấp một giao diện đơn giản với nút kích hoạt để giả lập quá trình tải dữ liệu bất đồng bộ.
/// Màn hình này giúp kiểm thử các hiệu ứng chuyển cảnh, thông điệp và thời gian phản hồi của thành phần loading.
class PageLoadingScreen extends StatefulWidget {
  const PageLoadingScreen({
    super.key,
    this.isVisible = true,
    this.message = 'Loading...',
    this.styleMessage = const TextStyle(
        fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
  });

  /// Cờ xác định tính hiển thị mặc định của thành phần.
  final bool isVisible;

  /// Thông điệp hiển thị mặc định khi bắt đầu quá trình tải.
  final String message;

  /// Kiểu dáng văn bản cho thông điệp tải.
  final TextStyle? styleMessage;

  @override
  State<PageLoadingScreen> createState() => _PageLoadingScreenState();
}

/// _PageLoadingScreenState quản lý logic kích hoạt và hủy bỏ trạng thái loading.
/// Nó sử dụng Timer để giả lập việc xử lý dữ liệu trong 12 giây trước khi đóng lớp phủ loading.
/// Trạng thái này minh họa cách kết nối giữa sự kiện người dùng và Cubit quản lý loading toàn cục.
class _PageLoadingScreenState extends State<PageLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final loadingCubit = getLoadingCubit(context);
    return BaseLoading(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocaleTranslate.loadingData.getString(context),
          style: context.textTheme.headlineMedium,
          overflow: TextOverflow.clip,
        ),
      ),
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              loadingCubit.showLoading(
                func: () {
                  debugPrint('Kích hoạt hiệu ứng loading...');
                },
              );
              Timer(const Duration(seconds: 12), () {
                loadingCubit.dissmissLoading();
              });
            },
            child: Text(AppLocaleTranslate.loadingData.getString(context))),
      ),
    );
  }
}
