import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';

/// BaseLoading là một widget bao bọc (wrapper) cung cấp khả năng hiển thị trạng thái đang tải (loading) toàn màn hình.
/// Nó tích hợp chặt chẽ với BLoC để quản lý trạng thái tải và thông điệp hiển thị một cách tập trung.
/// Widget này cho phép các trang con giữ nguyên cấu trúc Scaffold trong khi vẫn hỗ trợ lớp phủ loading đồng nhất.
class BaseLoading extends StatefulWidget {
  const BaseLoading({
    super.key,
    this.isLoading = false,
    this.message = '',
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
  });

  /// Cờ xác định xem lớp phủ loading có đang được hiển thị hay không.
  final bool isLoading;

  /// Thông điệp tùy chỉnh hiển thị kèm theo hiệu ứng loading.
  final String? message;

  /// Nội dung chính của trang web hoặc màn hình.
  final Widget child;

  /// Thanh ứng dụng tùy chỉnh cho màn hình.
  final PreferredSizeWidget? appBar;

  /// Nút hành động nổi tùy chỉnh.
  final Widget? floatingActionButton;

  /// Ngăn kéo (drawer) tùy chỉnh cho màn hình.
  final Widget? drawer;

  /// Thanh điều hướng dưới cùng tùy chỉnh.
  final Widget? bottomNavigationBar;

  /// Vị trí của nút hành động nổi.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  State<BaseLoading> createState() => BaseLoadingScreenState();
}

/// BaseLoadingScreenState quản lý việc tính toán kích thước và hiển thị lớp phủ loading.
/// Nó sử dụng các tiện ích đo lường văn bản để điều chỉnh kích thước hộp thoại loading sao cho phù hợp với nội dung thông điệp.
/// Trạng thái này đảm bảo rằng các hiệu ứng chuyển cảnh và UI không bị giật lag khi chuyển đổi giữa các trạng thái tải.
class BaseLoadingScreenState extends State<BaseLoading> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseLoadingCubit, BaseLoadingState>(
      builder: (context, state) {
        final String displayMessage =
            state.message ?? AppLocaleTranslate.loadingData.getString(context);

        double widthText = UtilsHelper.getTextWidth(
            text: displayMessage,
            textStyle:
                context.textTheme.bodyLarge!.copyWith(color: Colors.white));

        double heightText = UtilsHelper.getTextHeight(
          text: state.message ?? "",
          textStyle:
              context.textTheme.bodyMedium!.copyWith(color: Colors.white),
          maxWidthOfWidget: context.mediaQuery.size.width - 60,
        );

        widthText = widthText > context.mediaQuery.size.width
            ? context.mediaQuery.size.width - DeviceDimension.padding
            : widthText;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Scaffold(
              extendBody: true,
              appBar: widget.appBar ??
                  AppBar(
                    leading: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            DialogUtils.dismissPopup(context);
                          },
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                        );
                      },
                    ),
                  ),
              body: SizedBox(
                width: context.mediaQuery.size.width,
                height: context.mediaQuery.size.height,
                child: widget.child,
              ),
              floatingActionButton: widget.floatingActionButton,
              drawer: widget.drawer,
              extendBodyBehindAppBar: false,
              bottomNavigationBar: widget.bottomNavigationBar,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
            ),
            Visibility(
              visible: state.isLoading ?? false,
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                padding: EdgeInsets.symmetric(
                    horizontal: (context.mediaQuery.size.width -
                            widthText -
                            DeviceDimension.padding) /
                        2),
                child: Center(
                    child: Container(
                  decoration: AppBoxDecoration.boxDecorationBorderRadius(
                    borderRadiusValue: 8.0,
                    colorBackground: Colors.white,
                  ),
                  height: widthText > context.mediaQuery.size.width
                      ? heightText + 100
                      : heightText + 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: AppBoxDecoration.boxDecorationBorderRadius(
                          borderRadiusValue: 8.0,
                          colorBackground: Colors.white.withOpacity(0.8),
                        ),
                        child: Center(
                          child: Image.asset(
                            width: context.mediaQuery.size.width / 2,
                            height: heightText + 90,
                            'assets/images/loading_mobimap_rii.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            state.message ?? "",
                            style: context.textTheme.bodyLarge!
                                .copyWith(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          ],
        );
      },
    );
  }
}
