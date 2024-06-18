// ignore_for_file: prefer_equal_for_default_values, file_names, prefer_const_constructors, avoid_unnecessary_containerport, avoid_print, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, use_full_hex_values_for_flutter_colors, sort_child_properties_last, division_optimization, unused_import, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables, prefer_is_empty, prefer_final_fields, duplicate_import, unnecessary_cast, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/helpper/bitmap_utils.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/modules/menu/model/model_menu.dart';
import 'package:learnflutter/helpper/define_constraint.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/notification_center/notification_center.dart';
import 'package:notification_center/notification_center.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Menu_Controller extends StatefulWidget {
  const Menu_Controller({super.key});
  // NotificationCenter().sub
  // .subscribe('updateCounter' {});
  @override
  State<Menu_Controller> createState() => MenuControllerWidgetState();
}

class MenuControllerWidgetState extends State<Menu_Controller> {
  bool isLoading = false;
  TextEditingController _controllerTextField = TextEditingController();
  ItemScrollController _controllerScrollView = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  double fontSizeCell = 12;
  double fontSizeSectionTitile = 16;
  double fontSizeSearchView = 16;
  List categories = [];
  List menus = [];
  List menusSearch = [];
  List recentlyUsed = [];
  bool isSearch = false;

  @override
  void initState() {
    SVProgressHUD.show(status: 'Loadding......');
    getListCategories();
    recentlyUsed = parseChildMenusModel(SharedPreferenceUtils.getObjectList(keysaveCache_childMenus)!);
    super.initState();
  }

  void getListCategories() {
    getHttp().then((value) => {
          categories = value.categories,
          menus = value.menus,
          setState(() {
            isLoading = true;
            SVProgressHUD.dismiss();
          }),
          print(categories)
        });
  }

  // UI SearchView
  Container initUISearchView() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [Expanded(child: initUITextField()), SizedBox(width: 11), initUiNotification()],
      ),
    );
  }

  GestureDetector initUiNotification() {
    return GestureDetector(
        onTap: () async {
          print('action notification');
          Uint8List bitmap = await BitmapUtils().generateImagePngAsBytes('action notification');
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              child: Image.memory(bitmap),
            ),
          );
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            width: 50,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: Colors.white),
            child: Center(
              child: Image.asset(loadImageWithImageName('ic_notification', TypeImage.png)),
            )));
  }

  TextField initUITextField() {
    return TextField(
        controller: _controllerTextField,
        autofocus: false,
        style: TextStyle(
          fontSize: fontSizeSearchView,
          color: const Color(0xFFFDA758),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          prefixIcon: Image.asset(loadImageWithImageName('ic_search_organe', TypeImage.png)),
          suffixIcon: _controllerTextField.text.length > 0 ? initUISuffixIconSearchView() : null,
          hintText: "Tìm kiếm chức năng",
          hintStyle: textStyleManrope(Color(0xFFFDA758).withOpacity(0.5), fontSizeSearchView, FontWeight.normal),
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
        onChanged: ((value) {
          FillterSearchViewWithText(value);
        }));
  }

  GestureDetector initUISuffixIconSearchView() {
    return GestureDetector(
        onTap: () {
          setState(() {
            isSearch = false;
            _controllerTextField.clear();
          });
        },
        child: Icon(
          Icons.close,
          color: Color(0xFFFDA758),
        ));
  }

  // Action SearchView

  void FillterSearchViewWithText(String value) {
    bool isAddMenusSearch = false;
    List<dynamic> filter = [];
    menusSearch = [];
    List childMenus = [];
    for (ModelMenusItem itemFiltter in menus) {
      filter.addAll(itemFiltter.childMenus);
    }
    filter.retainWhere((countryone) {
      ChildMenusModel itemchild = countryone;
      childMenus = [];
      return itemchild.titleChildMenu.toLowerCase().contains(value..toLowerCase());
    });
    setState(() {
      for (ModelMenusItem itemMenus in menus) {
        childMenus = [];
        isAddMenusSearch = false;
        if (itemMenus.childMenus.toSet().intersection(filter.toSet()).isNotEmpty) {
          for (ChildMenusModel childFiltter in filter) {
            for (ChildMenusModel childMenuModel in itemMenus.childMenus) {
              if (childFiltter.titleChildMenu == childMenuModel.titleChildMenu) {
                childMenus.add(childFiltter);
                isAddMenusSearch = true;
              }
            }
          }
          if (isAddMenusSearch) {
            menusSearch.add(ModelMenusItem(childMenus: childMenus, parentMenuTitle: itemMenus.parentMenuTitle));
          }
        }
      }
      isSearch = value.length > 0 ? true : false;
    });
  }

  // UICategories
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
          return categoriseCell(categories[index], index);
        });
  }

  GestureDetector categoriseCell(ModelMenuCategories categoriesItem, int index) {
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
            setState(() {
              initUICategories();
            });
          }
          animatejumpToIndex(index);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 7, 0),
          alignment: Alignment.center,
          child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.0), color: (categoriesItem.isSelected) ? Color(0xFFFDA758) : Colors.white),
              child: Center(
                child: Text(
                  categoriesItem.title,
                  textAlign: TextAlign.center,
                  style: textStyleManrope((categoriesItem.isSelected) ? Colors.white : Color(0xFFFDA758), 14, FontWeight.normal),
                ),
              )),
        ));
  }

  // Action Categories
  void animatejumpToIndex(int index) {
    _controllerScrollView.jumpTo(index: index);
  }

  // UIToolRecentlyUsed

  Container initUIToolRecentlyUsed() {
    return Container(
      alignment: Alignment.center,
      child: Column(children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Text('Tool sử dụng gần đây', textAlign: TextAlign.left, style: textStyleManrope(Color(0xFF795675), fontSizeSectionTitile, FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  height: recentlyUsed.length > 0 ? 100 : 0,
                  child: recentlyUsed.length > 0
                      ? GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                          ),
                          itemBuilder: (BuildContext ctxt, int index) {
                            return childMenusCell(recentlyUsed[index], true);
                          },
                          itemCount: recentlyUsed.length,
                        )
                      : Container()),
            ]))
      ]),
    );
  }

  // UIMenus
  Expanded initUIMenus() {
    return Expanded(
      child: ScrollablePositionedList.builder(
        itemScrollController: _controllerScrollView,
        itemPositionsListener: itemPositionsListener,
        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
        scrollDirection: Axis.vertical,
        itemCount: isSearch ? menusSearch.length : menus.length,
        reverse: false,
        itemBuilder: (BuildContext ctxt, int index) {
          ModelMenusItem item = isSearch ? menusSearch[index] : menus[index];
          return Container(
              alignment: Alignment.center,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                Text(item.parentMenuTitle, textAlign: TextAlign.left, style: textStyleManrope(Color(0xFF795675), fontSizeSectionTitile, FontWeight.w600)),
                SizedBox(height: 10),
                Container(
                  height: item.childMenus.length / 4 > 1 ? caculatorHeightWithCount(item.childMenus.length) * 110 : 110,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 5 / 6, crossAxisSpacing: 7),
                    itemBuilder: (BuildContext ctxt, int index) {
                      ChildMenusModel childMenusModel = item.childMenus[index];
                      return childMenusCell(childMenusModel, false);
                    },
                    itemCount: item.childMenus.length,
                  ),
                ),
              ]));
        },
      ),
    );
  }

  GestureDetector childMenusCell(ChildMenusModel data, bool isRecentlyUsed) {
    return GestureDetector(
      onTap: () {
        bool isAddObject = false;
        List<ChildMenusModel> cacheRecentlyUsed = parseChildMenusModel(SharedPreferenceUtils.getObjectList(keysaveCache_childMenus)!);
        for (ChildMenusModel element in cacheRecentlyUsed) {
          if (element.titleChildMenu == data.titleChildMenu) {
            isAddObject = false;
            break;
          } else {
            isAddObject = true;
          }
        }
        if (isAddObject || cacheRecentlyUsed.length == 0) {
          cacheRecentlyUsed.add(data);
          SharedPreferenceUtils.putObjectList(keysaveCache_childMenus, cacheRecentlyUsed);
          setState(() {
            recentlyUsed = parseChildMenusModel(SharedPreferenceUtils.getObjectList(keysaveCache_childMenus)!);
          });
        }
        selectItemChildMenu(data.routeName);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFDA758).withOpacity(0.2)),
              child: Center(
                child: Image.asset(loadImageWithImageName(data.iconChildMenu, TypeImage.png)),
              )),
          SizedBox(
            height: 6,
          ),
          Container(
              child: Center(
            child: Text(data.titleChildMenu, textAlign: TextAlign.center, style: textStyleManrope(Color(0xFF795675), fontSizeCell, FontWeight.normal)),
          ))
        ],
      ),
    );
  }

  //
  int caculatorHeightWithCount(int count) {
    return count % 4 != 0 ? (count / 4).toInt() + 1 : (count / 4).toInt();
  }

  // ACtion Menus Cell
  void selectItemChildMenu(String routeName) {
    print(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      body: SafeArea(
          child: NestedScrollView(
        // Setting floatHeaderSlivers to true is required in order to float
        // the outer slivers over the inner scrollable.
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              expandedHeight: 260,
              forceElevated: innerBoxIsScrolled,
              leading: const BackButton(color: Colors.transparent),
              leadingWidth: 0,
              backgroundColor: const Color(0xFFFFF3E9),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(top: 0),
                collapseMode: CollapseMode.pin,
                background: Column(
                  children: [
                    initUISearchView(),
                    initUICategories(),
                    initUIToolRecentlyUsed(),
                  ],
                ),
              ),
            ),
          ];
        },
        body: initUIMenus(),
        //     ListView.builder(
        //   padding: const EdgeInsets.all(8),
        //   itemCount: 30,
        //   itemBuilder: (BuildContext context, int index) {
        //     return SizedBox(
        //       height: 50,
        //       child: Center(child: Text('Item $index')),
        //     );
        //   },
        // ),
      )),
    );
  }
}

 
// SafeArea(
//         child: Container(
//           child: GestureDetector(
//             onTap: () {
//               dismissKeyboard();
//             },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 initUISearchView(),
//                 initUICategories(),
//                 initUIToolRecentlyUsed(),
//                 SizedBox(height: 20),
//                 initUIMenus(),
//               ],
//             ),
//           ),
//         ),
//       )