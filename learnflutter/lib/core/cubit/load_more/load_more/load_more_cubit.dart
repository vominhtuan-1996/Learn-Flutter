import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/shared/widgets/app_dialog/app_dialog_manager.dart';
import 'package:learnflutter/core/cubit/load_more/load_more/load_more_state.dart';

import 'package:learnflutter/data/models/base_model.dart';
import 'package:learnflutter/data/models/load_more_model.dart';

class LoadMoreCubit<T extends BaseModel> extends Cubit<LoadMoreState<T>> {
  final ScrollController scrollController;
  final Future<LoadMoreModel<T>> Function(
      int pageSize, int pageNumber, String keyword) getItemsFunction;

  LoadMoreCubit({
    required int pageSize,
    int pageNumber = 1,
    required this.scrollController,
    required this.getItemsFunction,
  }) : super(
            LoadMoreState<T>.init(pageSize: pageSize, pageNumber: pageNumber)) {
    scrollController.addListener(scrollListener);
  }

  void changeKeyword(String keyword) {
    emit(state.copyWith(keyword: keyword));
  }

  void scrollListener() {
    // Check if we've reached the bottom of the list
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // if it end
      if (state.isEnd) return;
      // If not already loading, start loading more data
      if (state.isLoading) return;
      if (state.isLoadingMore) return;
      loadMoreData(pageNumber: state.pageNumber + 1);
    }
  }

  void loadMoreData({int? pageSize, required int pageNumber}) async {
    try {
      emit(state.copyWith(isLoadingMore: true));
      // call load data here
      final data =
          await getItemsFunction(state.pageSize, pageNumber, state.keyword);
      final List<T> items = List.from(state.items);
      items.addAll(data.items);

      emit(state.copyWith(
        isLoadingMore: false,
        pageNumber: pageNumber,
        items: items,
        pageSize: pageSize,
        isEnd: data.total == items.length,
      ));
    } catch (e) {
      AppDialogManager.error(e.toString());
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void initData() async {
    try {
      emit(state.copyWith(isLoading: true));
      final data = await getItemsFunction(state.pageSize, 1, state.keyword);
      final items = data.items;
      emit(state.copyWith(
          isLoading: false,
          pageNumber: 1,
          isEnd: data.total == items.length,
          items: items));
    } catch (e) {
      AppDialogManager.error(e.toString());
      emit(state.copyWith(isLoading: false));
    }
  }
}
