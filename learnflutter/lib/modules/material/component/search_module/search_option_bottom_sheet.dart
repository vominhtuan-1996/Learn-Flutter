import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

/// Lớp SearchOptionBottomSheet hiển thị các tùy chọn tìm kiếm trong một Bottom Sheet.
/// Thành phần này cho phép người dùng chọn một hoặc nhiều mục và xác nhận lựa chọn của họ.
class SearchOptionBottomSheet extends StatefulWidget {
  /// Hàm gọi lại khi người dùng nhấn nút xác nhận với danh sách các mục đã chọn.
  final Function(List<RadioItemModel>) onConfirm;

  /// Danh sách các mục dữ liệu ban đầu để hiển thị.
  final List<RadioItemModel> data;

  /// Loại lựa chọn: single (chọn đơn) hoặc multi (chọn nhiều).
  final RadioType type;

  const SearchOptionBottomSheet({
    super.key,
    required this.onConfirm,
    required this.data,
    this.type = RadioType.single,
  });

  @override
  State<SearchOptionBottomSheet> createState() =>
      _SearchOptionBottomSheetState();
}

class _SearchOptionBottomSheetState extends State<SearchOptionBottomSheet> {
  /// Danh sách các mục hiện đang được chọn.
  List<RadioItemModel> selectedItems = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các mục đã chọn từ dữ liệu truyền vào.
    selectedItems = widget.data.where((item) => item.isSelected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phần Header của Bottom Sheet chứa tiêu đề và nút Xác nhận.
          Padding(
            padding: EdgeInsets.all(DeviceDimension.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tùy chọn tìm kiếm',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Trả về danh sách các mục đã chọn thông qua hàm gọi lại onConfirm.
                    widget.onConfirm(selectedItems);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Xác nhận',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Phần nội dung hiển thị danh sách các Radio Button để người dùng lựa chọn.
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding),
              child: MetarialRadioButton(
                enable: true,
                type: widget.type,
                data: widget.data,
                onToggleValue: (items) {
                  // Cập nhật trạng thái các mục đã chọn khi người dùng tương tác.
                  setState(() {
                    selectedItems = items ?? [];
                  });
                },
                onChangeValue: (item) {
                  if (widget.type == RadioType.single) {
                    // Nếu là chế độ chọn đơn, cập nhật danh sách chỉ chứa mục vừa chọn.
                    setState(() {
                      selectedItems = item != null ? [item] : [];
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
