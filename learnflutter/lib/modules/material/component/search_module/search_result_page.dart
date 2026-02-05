import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/component/search_module/search_option_bottom_sheet.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

/// Lớp SearchResultPage hiển thị kết quả tìm kiếm và cho phép người dùng mở rộng lựa chọn qua Bottom Sheet.
class SearchResultPage extends StatefulWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  /// Danh sách các mục đã được chọn từ Bottom Sheet.
  List<RadioItemModel> selectedResults = [];

  /// Dữ liệu mẫu để hiển thị trong Bottom Sheet.
  final List<RadioItemModel> dummyData = List.generate(
    10,
    (index) => RadioItemModel(id: '$index', title: 'Mục dữ liệu ${index + 1}'),
  );

  /// Hàm mở Bottom Sheet với chế độ lựa chọn tương ứng.
  void _openOptions(RadioType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchOptionBottomSheet(
        type: type,
        data: dummyData.map((e) {
          // Cập nhật trạng thái đã chọn cho các mục dựa trên kết quả hiện tại.
          e.isSelected = selectedResults.any((selected) => selected.id == e.id);
          return e;
        }).toList(),
        onConfirm: (List<RadioItemModel> items) {
          // Cập nhật danh sách kết quả đã chọn khi người dùng xác nhận trên Bottom Sheet.
          setState(() {
            selectedResults = items;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả cho: ${widget.query}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(DeviceDimension.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị hai nút bấm để mở Bottom Sheet ở chế độ Chọn đơn hoặc Chọn nhiều.
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openOptions(RadioType.single),
                    child: const Text('Chọn đơn (Single)'),
                  ),
                ),
                SizedBox(width: DeviceDimension.padding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openOptions(RadioType.multi),
                    child: const Text('Chọn nhiều (Multi)'),
                  ),
                ),
              ],
            ),
            SizedBox(height: DeviceDimension.padding * 2),
            Text(
              'Các mục đã chọn:',
              style: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Danh sách hiển thị các mục đã được người dùng chọn và xác nhận.
            Expanded(
              child: selectedResults.isEmpty
                  ? const Center(child: Text('Chưa có mục nào được chọn'))
                  : ListView.builder(
                      itemCount: selectedResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.check_circle,
                              color: AppColors.green),
                          title: Text(selectedResults[index].title),
                          subtitle: Text('ID: ${selectedResults[index].id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
