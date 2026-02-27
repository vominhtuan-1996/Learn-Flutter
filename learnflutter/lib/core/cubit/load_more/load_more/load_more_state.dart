import 'package:equatable/equatable.dart';
import 'package:learnflutter/data/models/base_model.dart';

class LoadMoreState<T extends BaseModel> extends Equatable {
  final int pageSize;
  final int pageNumber;
  final String keyword;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isEnd;
  final List<T> items;

  const LoadMoreState({
    required this.pageSize,
    required this.pageNumber,
    required this.keyword,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isEnd,
    required this.items,
  });

  factory LoadMoreState.init({required int pageSize, required int pageNumber}) {
    return LoadMoreState<T>(
      pageSize: pageSize,
      pageNumber: pageNumber,
      keyword: '',
      isLoading: false,
      isLoadingMore: false,
      isEnd: false,
      items: <T>[],
    );
  }

  LoadMoreState<T> copyWith({
    int? pageSize,
    int? pageNumber,
    String? keyword,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isEnd,
    List<T>? items,
  }) {
    return LoadMoreState<T>(
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
      keyword: keyword ?? this.keyword,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isEnd: isEnd ?? this.isEnd,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [pageSize, pageNumber, keyword, isLoading, isLoadingMore, isEnd, items];
}
