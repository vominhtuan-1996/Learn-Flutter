// ignore_for_file: prefer_equal_for_default_values, file_names, prefer_const_constructors, avoid_unnecessary_containers, unused_import

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';

// ignore: non_constant_identifier_names
Scaffold MenuController(List elements) {
  List categories = [
    {"title": "Bảo trì", "isSelected": true},
    {"title": "Khảo sát", "isSelected": false},
    {"title": "Nghiệm thu", "isSelected": false},
    {"title": "Chấm", "isSelected": false},
    {"title": "Đánh sao", "isSelected": false}
  ];
  getHttp();
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
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
                        padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                        alignment: Alignment.center,
                        child: MaterialButton(
                          color: Color(0xFFFDA758),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          onPressed: () {},
                          child: Text(
                            categories[index].toString(),
                            // categories[index].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                  }),
            ),
          ),
          Expanded(
            child: GroupedListView<dynamic, String>(
              stickyHeaderBackgroundColor: const Color(0xFFFFF3E9),
              elements: elements,
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
