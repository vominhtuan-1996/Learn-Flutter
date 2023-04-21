// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, non_constant_identifier_names, use_full_hex_values_for_flutter_colors, override_on_non_overriding_member, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';
import 'package:learnflutter/Helpper/flutter_section_table_view.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'package:learnflutter/TabbarCustom/TabbarMobiMapCustom.dart';
import 'Menu/MenuController.dart';

void main() {
  AppConfig.init(() {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  MyApp setState() => MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TabbarMobiMapCustom(),
    );
  }
}
