class RadioItemModel {
  final String id;
  final String title;
  bool isSelected;

  RadioItemModel({
    required this.id,
    required this.title,
    this.isSelected = false,
  });
}
