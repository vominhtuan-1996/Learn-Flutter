// ignore_for_file: prefer_equal_for_default_values, file_names, prefer_const_constructors, avoid_unnecessary_containerport, avoid_print, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, use_full_hex_values_for_flutter_colors, sort_child_properties_last, division_optimization, unused_import, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables, prefer_is_empty, prefer_final_fields

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
  late TextEditingController _controllerTextField = TextEditingController();
  late List categories = [];
  late List menus = [];
  late List recentlyUsed = [
    ChildMenusModel(
        iconChildMenu: 'ic_menu_survey',
        titleChildMenu: 'Khảo sát ngoại vi',
        routeName: 'routeName'),
    ChildMenusModel(
        iconChildMenu: 'ic_menu_maintenance',
        titleChildMenu: 'Bảo trì POP',
        routeName: ''),
    ChildMenusModel(
        iconChildMenu: 'ic_menu_survey',
        titleChildMenu: 'Khảo sát ngoại vi XLA',
        routeName: ''),
    ChildMenusModel(
        iconChildMenu: 'ic_menu_mark',
        titleChildMenu: 'Chấm trụ điện',
        routeName: '')
  ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Grouped List View Example'),
        // ),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFF3E9),
        body: Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            initUISearchView(),
            initUICategories(),
            initUIToolRecentlyUsed(),
            initUIMenus(),
          ],
        )));
  }

  Container initUISearchView() {
    return Container(
      height: 100,
      padding: EdgeInsets.fromLTRB(20, 37, 20, 0),
      child: Row(
        children: [
          Expanded(child: initUITextField()),
          SizedBox(width: 11),
          initUiNotification()
        ],
      ),
    );
  }

  GestureDetector initUiNotification() {
    return GestureDetector(
        onTap: () {
          print('action notification');
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0), color: Colors.white),
            child: Center(
              child: Icon(
                Icons.notifications,
                color: Colors.orange,
              ),
            )));
  }

  TextField initUITextField() {
    return TextField(
      controller: _controllerTextField,
      autofocus: false,
      style: TextStyle(
        fontSize: 16.0,
        color: const Color(0xFFFDA758),
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.search, color: Colors.orange),
        hintText: "Tìm kiếm chức năng",
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: const Color(0xFFFDA758),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
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
    return Container(
      alignment: Alignment.center,
      // color: Colors.red,
      child: Column(children: <Widget>[
        Container(
            // color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Tool sử dụng gần đây',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    height: 120,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                      ),
                      itemBuilder: (BuildContext ctxt, int index) {
                        ChildMenusModel childMenusModel = recentlyUsed[index];
                        return childMenusCell(childMenusModel);
                      },
                      itemCount: recentlyUsed.length,
                    ),
                  ),
                ]))
      ]),
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
