import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/shared/widgets/multi_select/multi_selector.dart';
import 'package:learnflutter/shared/widgets/multi_select/selector/selector.dart';
import 'package:learnflutter/shared/widgets/multi_select/selector/selector_cubit.dart';
import 'package:learnflutter/shared/widgets/multi_select/selector/selector_state.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/cubit/load_more/load_more/load_more_cubit.dart';
import 'package:learnflutter/core/cubit/load_more/load_more/load_more_state.dart';
import 'package:learnflutter/data/models/load_more_model.dart';
import 'package:learnflutter/data/models/option_model.dart';

class LoadMoreSelector<T extends OptionModel> extends Selector<T> {
  const LoadMoreSelector({
    super.key,
    super.selectLength,
    super.title,
    super.hint,
    super.onChanged,
    required super.selectedItems,
    required super.itemBuilder,
    super.autoFocus,
    super.enable,
    super.hasSearchBar,
    super.hasTitle,
    super.selectorType,
    this.pageSize = 10,
    this.preAnalyzeSearch,
    required this.getItemsFunction,
    this.compareSelectedItem,
    this.enableItem,
    this.onItemTap,
  }) : super(items: const []);

  final int pageSize;

  final bool Function(T item)? enableItem;
  final ValueChanged<List<T>>? onItemTap;

  /// Tiền xử lý trước khi search, có thể dùng để lược bỏ các case search không cần thiết, hoặc thêm debounce
  /// Nếu như không có thì xử lý như bình thường
  ///
  /// preAnalyzeSearch: (searchFunction, keyword) {
  ///  if (keyword.isEmpty) {
  ///    debounce.runAfter(action: searchFunction, rate: 600); // [searchFunction] là func gọi để lấy danh sách item [getAutoFillList]
  ///    return;
  ///  }
  ///  if (keyword.length < 3) return; // return: sẽ không lấy danh sách item [getAutoFillList]
  ///  debounce.runAfter(action: searchFunction, rate: 600);
  ///},
  final Function(VoidCallback searchFunction, String keyword)? preAnalyzeSearch;

  final Future<LoadMoreModel<T>> Function(
      int pageSize, int pageNumber, String keyword) getItemsFunction;
  final bool Function(T item, Iterable<T> selectedItems, int? index)?
      compareSelectedItem;

  @override
  LoadMoreSelectorScreenState<T> createState() =>
      LoadMoreSelectorScreenState<T>();
}

class LoadMoreSelectorScreenState<T extends OptionModel>
    extends SelectorScreenState<T, LoadMoreSelector<T>> {
  late final ScrollController scrollController = ScrollController();
  late final LoadMoreCubit<T> loadMoreCubit = LoadMoreCubit(
    pageSize: widget.pageSize,
    scrollController: scrollController,
    getItemsFunction: widget.getItemsFunction,
  );

  @override
  void initState() {
    loadMoreCubit.initData();
    super.initState();
  }

  @override
  void updateItems({List<T> items = const []}) {
    selectorCubit.changeItems(loadMoreCubit.state.items);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: loadMoreCubit,
      child: BlocListener<LoadMoreCubit<T>, LoadMoreState<T>>(
        bloc: loadMoreCubit,
        listener: (context, state) {
          updateItems(items: state.items);
        },
        child: super.build(context),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return BlocBuilder<SelectorCubit<T>, SelectorState<T>>(
      bloc: selectorCubit,
      builder: (context, state) {
        return BlocBuilder<LoadMoreCubit<T>, LoadMoreState<T>>(
          bloc: loadMoreCubit,
          builder: (context, loadMoreState) {
            if (loadMoreState.isLoading) {
              return Container(
                padding:
                    EdgeInsets.only(top: DeviceDimension.screenHeight * 0.15),
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(color: context.theme.primary),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: MultiSelector<T>(
                    items: state.items,
                    enable: widget.enable,
                    enableItem: widget.enableItem,
                    initialSelectedItems: state.selectedItems,
                    itemBuilder: widget.itemBuilder,
                    itemContainerBuilder: itemContainerBuilder,
                    decoration: const BoxDecoration(),
                    selectLength: widget.selectLength,
                    type: widget.selectorType,
                    onSelectItem: (value) {
                      widget.onItemTap?.call(value);
                      onSelectedItem(value);
                    },
                  ),
                ),
                if (loadMoreState.isLoadingMore)
                  CircularProgressIndicator(color: context.theme.primary),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget itemContainerBuilder(
    Widget Function(T item, bool isSelected) itemBuilder,
    Iterable<T> items,
    Iterable<T> selectedItems,
  ) {
    return ListView.separated(
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = items.elementAt(index);
        // final isSelect = widget.compareSelectedItem.call(item, selectedItems, index ) ?? selectedItems.contains(item);
        final isSelect = selectedItems.contains(item);
        print("$item -- isSelect: $isSelect -- $selectedItems");
        return itemBuilder(item, isSelect);
      },
      separatorBuilder: (context, index) {
        return AppDivider.horizontal();
      },
      itemCount: items.length,
    );
  }

  @override
  void onKeywordChanged(String value) {
    if (searchKeyword == value) return;
    loadMoreCubit.changeKeyword(value);
    searchKeyword = value;

    if (widget.preAnalyzeSearch != null) {
      widget.preAnalyzeSearch!(() {
        loadMoreCubit.initData();
      }, value);
    } else {
      loadMoreCubit.initData();
    }
  }
}
