// ignore_for_file: prefer_typing_uninitialized_variables, unused_import

import 'dart:convert';

class ModelMenu {
  final List<dynamic> categories;
  final List<dynamic> menus;

  ModelMenu({
    required this.categories,
    required this.menus,
  });

  factory ModelMenu.fromJson(Map<String, dynamic> json) {
    return ModelMenu(
      categories: parseModelMenuCategories(json['categories']),
      menus: parseModelMenusItem(json['menus']),
    );
  }
}

class ModelMenuCategories {
  final String title;
  late bool isSelected;

  ModelMenuCategories({
    required this.title,
    required this.isSelected,
  });

  factory ModelMenuCategories.fromJson(Map<String, dynamic> json) {
    return ModelMenuCategories(
      title: json['title'],
      isSelected: json['isSelected'],
    );
  }
}

class ModelMenusItem {
  final String parentMenuTitle;
  final List childMenus;

  const ModelMenusItem({
    required this.parentMenuTitle,
    required this.childMenus,
  });

  factory ModelMenusItem.fromJson(Map<String, dynamic> json) {
    return ModelMenusItem(
        parentMenuTitle: json['parentMenuTitle'],
        childMenus: parseChildMenusModel(
          json['childMenus'],
        ));
  }
}

class ChildMenusModel {
  final String iconChildMenu;
  final String titleChildMenu;
  final String routeName;

  const ChildMenusModel({
    required this.iconChildMenu,
    required this.titleChildMenu,
    required this.routeName,
  });

  factory ChildMenusModel.fromJson(Map<String, dynamic> json) {
    return ChildMenusModel(
        iconChildMenu: json['iconChildMenu'],
        titleChildMenu: json['titleChildMenu'],
        routeName: json['routeName']);
  }

  Map<String, dynamic> toJson() {
    return {
      'iconChildMenu': iconChildMenu,
      'titleChildMenu': titleChildMenu,
      'routeName': routeName
    };
  }
}

List<ModelMenusItem> parseModelMenusItem(List responseBody) {
  final parsed = responseBody.cast<Map<String, dynamic>>();
  return parsed
      .map<ModelMenusItem>((json) => ModelMenusItem.fromJson(json))
      .toList();
}

List<ChildMenusModel> parseChildMenusModel(List responseBody) {
  final parsed = responseBody.cast<Map<String, dynamic>>();
  return parsed
      .map<ChildMenusModel>((json) => ChildMenusModel.fromJson(json))
      .toList();
}

List<ModelMenuCategories> parseModelMenuCategories(List responseBody) {
  final parsed = responseBody.cast<Map<String, dynamic>>();
  return parsed
      .map<ModelMenuCategories>((json) => ModelMenuCategories.fromJson(json))
      .toList();
}
