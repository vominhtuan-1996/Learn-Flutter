// ignore_for_file: constant_identifier_names

import 'dart:io';

enum TypeDirectory {
  Directory,
  File,
}

class ItemDirectoryModel {
  String? title;
  String? type;
  String? path;
  Directory? absolute;
  List? listDirectory;
  ItemDirectoryModel({this.title, this.type, this.path, this.absolute, this.listDirectory});
}
