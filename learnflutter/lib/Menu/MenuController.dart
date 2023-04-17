// ignore_for_file: prefer_equal_for_default_values, file_names, prefer_const_constructors, avoid_unnecessary_containerport, avoid_print, unused_element, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'package:learnflutter/Menu/Model/ModelMenu.dart';

List _elements = [
  {'name': 'John', 'group': 'Team A'},
  {'name': 'Will', 'group': 'Team B'},
  {'name': 'Beth', 'group': 'Team A'},
  {'name': 'Miranda', 'group': 'Team B'},
  {'name': 'Mike', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
];

ModelMenuCategories itemCategories =
    ModelMenuCategories(title: '', isSelected: true);

class MenuController extends StatefulWidget {
  const MenuController({super.key});

  @override
  State<MenuController> createState() => MenuControllerWidgetState();
}

class MenuControllerWidgetState extends State<MenuController> {
  late List categories = [];
  @override
  void initState() {
    super.initState();
  }

  // getHttp().then((value) => {categories = value.categories, print(categories)});
  @override
  Widget build(BuildContext context) {
    getHttp()
        .then((value) => {categories = value.categories, print(categories)});
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grouped List View Example'),
        ),
        backgroundColor: const Color(0xFFFFF3E9),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Container(
                alignment: Alignment.center,
                height: 60,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    reverse: false,
                    itemBuilder: (BuildContext ctxt, int index) {
                      itemCategories = categories[index];
                      return Container(
                          padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                          alignment: Alignment.center,
                          child: MaterialButton(
                            color: (itemCategories.isSelected)
                                ? Color(0xFFFDA758)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            onPressed: () {},
                            child: Text(
                              itemCategories.title,
                              style: TextStyle(
                                  color: (itemCategories.isSelected)
                                      ? Colors.white
                                      : Color(0xFFFDA758)),
                            ),
                          ));
                    }),
              ),
            ),
            Expanded(
              child: GroupedListView<dynamic, String>(
                stickyHeaderBackgroundColor: const Color(0xFFFFF3E9),
                elements: _elements,
                groupBy: (element) => element['group'],
                groupComparator: (value1, value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item1['name'].compareTo(item2['name']),
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // backgroundColor: Color.fromARGB(0, 0, 0, 0)
                    ),
                  ),
                ),
                itemBuilder: (c, element) {
                  return Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: SizedBox(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: const Icon(Icons.account_circle),
                        title: Text(element['name']),
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}


  

// List categories = [];
// bool isReload = false;
// ModelMenuCategories itemCategories =
//     ModelMenuCategories(title: "", isSelected: true);

// // ignore: non_constant_identifier_names
// Scaffold MenuController(List elements, List categories) {
//   // Scaffold createState() => MenuController(elements);
//   // ListView createState() => ListView();
//   // getHttp().then((value) => {
//   //       // {categories = value.categories, createState(), isReload = true},
//   //       if (!isReload)
//   //         {categories = value.categories, createState(), isReload = true}
//   //       // categories = value.categories, createState(), isReload = true
//   //     });
//   return Scaffold(
//       appBar: AppBar(
//         title: const Text('Grouped List View Example'),
//       ),
//       backgroundColor: const Color(0xFFFFF3E9),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Container(
//             child: Container(
//               alignment: Alignment.center,
//               height: 60,
//               child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: categories.length,
//                   reverse: false,
//                   itemBuilder: (BuildContext ctxt, int index) {
//                     itemCategories = categories[index];
//                     return Container(
//                         padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
//                         alignment: Alignment.center,
//                         child: MaterialButton(
//                           color: (itemCategories.isSelected)
//                               ? Color(0xFFFDA758)
//                               : Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(18.0),
//                           ),
//                           onPressed: () {},
//                           child: Text(
//                             itemCategories.title,
//                             style: TextStyle(
//                                 color: (itemCategories.isSelected)
//                                     ? Colors.white
//                                     : Color(0xFFFDA758)),
//                           ),
//                         ));
//                   }),
//             ),
//           ),
//           Expanded(
//             child: GroupedListView<dynamic, String>(
//               stickyHeaderBackgroundColor: const Color(0xFFFFF3E9),
//               elements: elements,
//               groupBy: (element) => element['group'],
//               groupComparator: (value1, value2) => value2.compareTo(value1),
//               itemComparator: (item1, item2) =>
//                   item1['name'].compareTo(item2['name']),
//               order: GroupedListOrder.DESC,
//               useStickyGroupSeparators: true,
//               groupSeparatorBuilder: (String value) => Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   value,
//                   textAlign: TextAlign.left,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     // backgroundColor: Color.fromARGB(0, 0, 0, 0)
//                   ),
//                 ),
//               ),
//               itemBuilder: (c, element) {
//                 return Card(
//                   elevation: 8.0,
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 10.0, vertical: 6.0),
//                   child: SizedBox(
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20.0, vertical: 10.0),
//                       leading: const Icon(Icons.account_circle),
//                       title: Text(element['name']),
//                       trailing: const Icon(Icons.arrow_forward),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ));

