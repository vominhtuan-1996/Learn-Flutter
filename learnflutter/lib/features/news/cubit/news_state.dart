import 'package:learnflutter/features/news/model/news_model.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsSuccess extends NewsState {
  final List<NewsModel> articles;
  final String message;
  NewsSuccess(this.articles, {this.message = ''});
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}
