import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/component/search_bar/page/search_bar_builder.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialSearchbar extends StatefulWidget {
  const MaterialSearchbar({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialSearchbar> createState() => _MaterialSearchbarState();
}

class _MaterialSearchbarState extends State<MaterialSearchbar> with ComponentMaterialDetail {
  String? value;
  SearchController searchControler = SearchController();
  CarouselController carou = CarouselController(initialItem: 10);
  int lenght = 10;
  @override
  void initState() {
    // carou.
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Widget> _getDrawText() async {
    return Container();
  }

  Future<List<String>> fetchSuggestions(String query) async {
    // Thực hiện yêu cầu đến API tìm kiếm sản phẩm
    // For demonstration, returning a dummy list
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return List<String>.generate(10, (index) => 'Suggestion $index for $query');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: Column(
        children: [
          SearchBarBuilder(
            searchController: searchControler,
            childBuilder: (context, data) {
              return ListTile(
                title: Text(data),
              );
            },
            onTapChildBuilder: () {
              print('Tapped');
            },
          )
        ],
      ),
    );
  }
}
