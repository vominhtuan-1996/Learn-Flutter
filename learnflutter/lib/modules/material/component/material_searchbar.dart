import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/search_bar/cubit/search_bar_cubit.dart';
import 'package:learnflutter/component/search_bar/page/search_bar_builder.dart';
import 'package:learnflutter/component/search_bar/state/search_bar_state.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/material/component/search_module/search_result_page.dart';

/// Lớp MaterialSearchbar trình bày một giao diện thanh tìm kiếm với các gợi ý động.
/// Khi người dùng chọn một gợi ý hoặc gửi truy vấn, hệ thống sẽ điều hướng đến trang kết quả.
class MaterialSearchbar extends StatefulWidget {
  const MaterialSearchbar({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialSearchbar> createState() => _MaterialSearchbarState();
}

class _MaterialSearchbarState extends State<MaterialSearchbar>
    with ComponentMaterialDetail {
  String? value;
  SearchController searchControler = SearchController();

  /// Hàm mô phỏng việc tải dữ liệu gợi ý từ API dựa trên từ khóa tìm kiếm.
  Future<List<dynamic>> fetchSuggestions(String query) async {
    await Future.delayed(const Duration(seconds: 1)); // Mô phỏng độ trễ mạng.
    return List<String>.generate(10, (index) => 'Gợi ý $index cho "$query"');
  }

  /// Hàm thực hiện chuyển hướng người dùng đến trang kết quả tìm kiếm.
  void _navigateToResults(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: DeviceDimension.padding / 4,
                right: DeviceDimension.padding / 2,
                left: DeviceDimension.padding / 2),
            child: SearchBarBuilder(
              searchController: searchControler,
              childBuilder: (context, data) {
                // Xây dựng giao diện hiển thị cho từng mục gợi ý trong danh sách.
                return ListTile(
                  title: Text(data),
                  leading: const Icon(Icons.search),
                );
              },
              onTapChildBuilder: (value) {
                // Điều hướng khi người dùng nhấn chọn một mục gợi ý.
                if (value is String) {
                  _navigateToResults(value);
                }
              },
              getSuggestions: fetchSuggestions,
              onSubmitted: (value) {
                // Điều hướng khi người dùng nhấn nút tìm kiếm trên bàn phím.
                _navigateToResults(value);
              },
              onChanged: (value) {
                print('Từ khóa thay đổi: $value');
              },
            ),
          )
        ],
      ),
    );
  }
}
