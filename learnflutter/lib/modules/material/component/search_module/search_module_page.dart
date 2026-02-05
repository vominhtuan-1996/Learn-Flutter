import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/component/search_bar/page/custom_search_bar.dart';

/// Lớp SearchModulePage là màn hình tìm kiếm đã được tùy chỉnh giao diện.
class SearchModulePage extends StatefulWidget {
  const SearchModulePage({super.key});

  @override
  State<SearchModulePage> createState() => _SearchModulePageState();
}

class _SearchModulePageState extends State<SearchModulePage> {
  final TextEditingController _searchController = TextEditingController();
  List<RadioItemModel> _suggestions = [];
  bool _isLoading = false;

  /// Hàm mô phỏng tải gợi ý, giờ đây được gọi thủ công khi nội dung nhập thay đổi.
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _suggestions = List.generate(
          10,
          (index) => RadioItemModel(
            id: 'search_${query}_$index',
            title: 'Kết quả $index cho "$query"',
          ),
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Nền sáng nhẹ để làm nổi bật thanh search trắng.
      appBar: AppBar(
        title: const Text('Tìm kiếm tùy chỉnh'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sử dụng CustomSearchBar mới thay vì các thành phần Material mặc định.
          Padding(
            padding: EdgeInsets.all(DeviceDimension.padding),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Nhập nội dung cần tìm...',
              isLoading: _isLoading,
              suggestions: _suggestions,
              onChanged: _handleSearch,
              suggestionBuilder: (context, data) {
                final item = data as RadioItemModel;
                return ListTile(
                  title: Text(item.title),
                  leading:
                      const Icon(Icons.history, size: 20, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
          if (_suggestions.isEmpty && !_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Chưa tìm thấy mục nào',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
