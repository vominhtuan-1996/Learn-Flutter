// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

Size size = WidgetsBinding.instance.window.physicalSize;
double widthScreen = size.width;
double heightScreen = size.height;

enum TypeImage { png, jpg }

String loadImageWithImageName(String imageName, TypeImage typeImage) {
  return 'assets/images/' + imageName + '.' + typeImage.name.toString();
}
