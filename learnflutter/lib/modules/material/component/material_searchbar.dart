import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialSearchbar extends StatefulWidget {
  const MaterialSearchbar({super.key, required this.data});
  final RoouterMaterialModel data;
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
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: Column(children: [
        SearchAnchor.bar(
          searchController: searchControler,
          suggestionsBuilder: (context, controller) {
            // return FutureBuilder<List<String>>(
            //   future: fetchSuggestions(controller.text), // Replace with your async function
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (context, index) {
            //           final suggestion = snapshot.data![index];
            //           return ListTile(
            //             title: Text(suggestion),
            //             onTap: () {
            //               // Handle suggestion selection
            //             },
            //           );
            //         },
            //       );
            //     } else if (snapshot.hasError) {
            //       return Text('Error fetching suggestions');
            //     } else {
            //       return CircularProgressIndicator();
            //     }
            //   },
            // );
            return List<Widget>.generate(
              1,
              (int index) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        searchControler.text = 'Initial list item $index';
                      },
                      child: Container(
                        child: ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text('Initial list item $index'),
                        ),
                      ),
                    );
                  },
                  itemCount: lenght,
                  shrinkWrap: true,
                );
              },
            );
          },
          isFullScreen: false,
          viewHintText: 'Search',
          barHintText: "Hine text search",
          viewConstraints: BoxConstraints(maxHeight: context.mediaQuery.size.height / 3),
          onChanged: (value) {
            lenght = 5;
            setState(() {});
          },
          barPadding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
            (states) {
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return EdgeInsets.all(8);
                } else if (states.contains(WidgetState.focused)) {
                  return EdgeInsets.all(8);
                } else {
                  return EdgeInsets.all(8);
                }
              };
              return EdgeInsets.all(8);
            },
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: CarouselView(
            scrollDirection: Axis.horizontal,
            itemExtent: context.mediaQuery.size.width * 0.8,
            controller: carou,
            backgroundColor: Colors.red,
            // shrinkExtent: 200,
            elevation: 0.6,
            itemSnapping: true,
            children: List<Widget>.generate(20, (int index) {
              return ColoredBox(
                color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
                child: const SizedBox.expand(),
              );
            }),
          ),
        ),
      ]),
    );
  }
}
