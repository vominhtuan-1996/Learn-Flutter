class NewsModel {
  final String title;
  final String description;
  final String? urlToImage;

  NewsModel({
    required this.title,
    required this.description,
    this.urlToImage,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'],
    );
  }
}
