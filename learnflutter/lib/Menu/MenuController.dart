// ignore_for_file: prefer_equal_for_default_values, file_names, prefer_const_constructors, avoid_unnecessary_containerport, avoid_print, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, use_full_hex_values_for_flutter_colors, sort_child_properties_last, division_optimization, unused_import, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'package:learnflutter/Menu/Model/ModelMenu.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';

class MenuController extends StatefulWidget {
  const MenuController({super.key});

  @override
  State<MenuController> createState() => MenuControllerWidgetState();
}

class MenuControllerWidgetState extends State<MenuController> {
  late List categories = [];
  late List menus = [];
  late List recentlyUsed = [];
  @override
  void initState() {
    super.initState();
    getListCategories();
  }

  void getListCategories() {
    getHttp().then((value) => {
          categories = value.categories,
          menus = value.menus,
          setState(() {}),
          print(categories)
        });
  }

  // MARK:

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grouped List View Example'),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFF3E9),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            initUICategories(),
            initUIToolRecentlyUsed(),
            initUIMenus(),
          ],
        ));
  }

  void selectItemChildMenu(String routeName) {
    print(routeName);
  }

  GestureDetector childMenusCell(ChildMenusModel data) {
    return GestureDetector(
      onTap: () {
        selectItemChildMenu(data.routeName);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFDA758).withOpacity(0.2)),
              child: Center(
                child: Image.asset(
                    loadImageWithImageName(data.iconChildMenu, TypeImage.png)),
              )),
          SizedBox(
            height: 6,
          ),
          Container(
              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: Center(
                child: Text(data.titleChildMenu,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    )),
              ))
        ],
      ),
    );
  }

  Expanded initUIMenus() {
    return Expanded(
        child: ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            scrollDirection: Axis.vertical,
            itemCount: menus.length,
            reverse: false,
            itemBuilder: (BuildContext ctxt, int index) {
              ModelMenusItem item = menus[index];
              return Container(
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          item.parentMenuTitle,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height:
                              item.childMenus.length / 4 > 1 ? 2 * 110 : 110,
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, childAspectRatio: 5 / 6),
                            itemBuilder: (BuildContext ctxt, int index) {
                              ChildMenusModel childMenusModel =
                                  item.childMenus[index];
                              return childMenusCell(childMenusModel);
                            },
                            itemCount: item.childMenus.length,
                          ),
                        ),
                      ]));
            }));
  }

  Container initUIToolRecentlyUsed() {
    ModelMenusItem items = ModelMenusItem(parentMenuTitle: '', childMenus: []);
    if (menus.length > 0) {
      items = menus[0];
    }
    return Container(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Text(
                    'Tool sử dụng gần đây',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.childMenus.length > 0
                          ? items.childMenus.length
                          : 0,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return childMenusCell(items.childMenus[index]);
                      }),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 60,
          )
        ],
      ),
    );
  }

  Container initUICategories() {
    return Container(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
        alignment: Alignment.center,
        height: 60,
        child: ListViewCategorise(),
      ),
    );
  }

  ListView ListViewCategorise() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        reverse: false,
        itemBuilder: (BuildContext ctxt, int index) {
          return categoriseCell(categories[index]);
        });
  }

  GestureDetector categoriseCell(ModelMenuCategories categoriesItem) {
    return GestureDetector(
        onTap: () {
          if (categoriesItem.isSelected) {
            return;
          } else {
            categoriesItem.isSelected = !categoriesItem.isSelected;
            for (ModelMenuCategories element in categories) {
              if (categoriesItem.title != element.title) {
                element.isSelected = false;
              }
            }
            setState(() {});
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 7, 0),
          alignment: Alignment.center,
          child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: (categoriesItem.isSelected)
                      ? Color(0xFFFDA758)
                      : Colors.white),
              child: Center(
                child: Text(
                  categoriesItem.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: (categoriesItem.isSelected)
                          ? Colors.white
                          : Color(0xFFFDA758)),
                ),
              )),
        ));
  }
}
