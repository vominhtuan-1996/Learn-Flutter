import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/db/hive_demo/model/person.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_list.dart';
import 'package:learnflutter/utils_helper/extension/extension_string.dart';

class NumberFormatterScreen extends StatefulWidget {
  const NumberFormatterScreen({super.key});
  @override
  State<NumberFormatterScreen> createState() => NumberFormatterScreenState();
}

class NumberFormatterScreenState extends State<NumberFormatterScreen> {
  bool rebuild = false;
  List<Person> listExtension = [
    Person(name: 'Tuan', country: 'country'),
    Person(name: 'Tuan1', country: 'country'),
    Person(name: 'Tuan2', country: 'country'),
    Person(name: 'Tuan3', country: 'country'),
  ];

  List<num> listminmax = [1, 3.3, 3.2, 9, 12, 12.2, 1.2];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dynamic customRound(number, place) {
    var valueForPlace = pow(1, place);
    return (number * valueForPlace).round() / valueForPlace;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        appBar: AppBar(
          title: const Text('Number Formatter'),
        ),
        isLoading: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: context.mediaQuery.size.height / 2,
                color: Colors.red,
              ),
              TextField(
                onChanged: (value) {
                  print(customRound(value.toDouble, 2));
                },
                onTapOutside: (event) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                inputFormatters: const [],
              ),
              ElevatedButton(
                onPressed: () {
                  print(listExtension.replace(item: Person(name: 'Tuan6', country: 'country'), index: 1));
                  setState(() {
                    rebuild = !rebuild;
                  });
                },
                child: const Text('Replace Object'),
              ),
              ElevatedButton(
                onPressed: () {
                  listExtension.update(index: 2, item: Person(name: "Tuan10", country: "country"));
                  setState(() {
                    rebuild = !rebuild;
                  });
                },
                onLongPress: () {
                  print('onLongPress');
                },
                child: const Text('Update Object'),
              ),
              ElevatedButton(
                onPressed: () {
                  print(listminmax.max);
                  print(listminmax.min);
                  listExtension.add(Person(name: listminmax.max.toString(), country: "country"));
                  listExtension.add(Person(name: listminmax.min.toString(), country: "country"));
                  setState(() {
                    rebuild = !rebuild;
                  });
                },
                child: const Text('min max list '),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: listExtension.length,
                  itemBuilder: (context, index) {
                    return Text(listExtension[index].name.toString());
                  },
                ),
              )
            ],
          ),
        ));
  }
}
