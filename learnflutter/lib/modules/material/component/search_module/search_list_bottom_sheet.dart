import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/component/search_module/search_module_page.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

/// Lớp SearchListBottomSheet là giao diện người dùng chính cho việc lựa chọn và tìm kiếm.
/// Nó chứa danh sách các mục có thể chọn và một thanh tìm kiếm giả để kích hoạt chuyển trang.
class SearchListBottomSheet extends StatefulWidget {
  final Function(List<RadioItemModel>) onConfirm;
  final List<RadioItemModel> initialData;
  final RadioType type;

  const SearchListBottomSheet({
    super.key,
    required this.onConfirm,
    this.initialData = const [],
    this.type = RadioType.single,
  });

  @override
  State<SearchListBottomSheet> createState() => _SearchListBottomSheetState();
}

class _SearchListBottomSheetState extends State<SearchListBottomSheet> {
  late List<RadioItemModel> displayData;
  List<RadioItemModel> selectedItems = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu hiển thị và danh sách các mục đã được chọn ban đầu.
    displayData = List.from(widget.initialData);
    selectedItems = displayData.where((item) => item.isSelected).toList();
  }

  /// Hàm điều hướng đến màn hình tìm kiếm chuyên sâu.
  /// Khi quay lại, mục được chọn từ trang tìm kiếm sẽ được thêm vào danh sách hiển thị.
  Future<void> _openSearchPage() async {
    final result = await Navigator.push<RadioItemModel>(
      context,
      MaterialPageRoute(builder: (context) => const SearchModulePage()),
    );

    if (result != null) {
      setState(() {
        // Kiểm tra xem mục tìm thấy đã tồn tại trong danh sách chưa để tránh trùng lặp.
        bool exists = displayData.any((element) => element.id == result.id);
        if (!exists) {
          displayData.insert(0, result);
        }

        // Cập nhật trạng thái chọn cho mục vừa tìm thấy.
        if (widget.type == RadioType.single) {
          for (var item in displayData) {
            item.isSelected = (item.id == result.id);
          }
          selectedItems = [result..isSelected = true];
        } else {
          result.isSelected = true;
          if (!selectedItems.any((e) => e.id == result.id)) {
            selectedItems.add(result);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaQuery.size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header với tiêu đề và hành động Xác nhận để hoàn tất lựa chọn.
          Padding(
            padding: EdgeInsets.all(DeviceDimension.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách lựa chọn',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
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
          // Thành phần tìm kiếm giả, được thiết kế bo tròn và đổ bóng để đồng bộ với CustomSearchBar.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding),
            child: InkWell(
              onTap: _openSearchPage,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Tìm kiếm mục mới...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: DeviceDimension.padding),
          // Danh sách các mục cho phép người dùng thực hiện chọn đơn hoặc chọn nhiều.
          Expanded(
            child: displayData.isEmpty
                ? const Center(child: Text('Danh sách trống'))
                : SingleChildScrollView(
                    child: MetarialRadioButton(
                      enable: true,
                      type: widget.type,
                      data: displayData,
                      onToggleValue: (items) {
                        setState(() {
                          selectedItems = items ?? [];
                        });
                      },
                      onChangeValue: (item) {
                        if (widget.type == RadioType.single) {
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
