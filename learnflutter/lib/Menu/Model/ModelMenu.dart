class ModelMenu {
  final List categories;
  final List menus;

  const ModelMenu({
    required this.categories,
    required this.menus,
  });

  factory ModelMenu.fromJson(Map<String, dynamic> json) {
    return ModelMenu(
      categories: json['categories'] as List,
      menus: json['menus'] as List,
    );
  }
}
