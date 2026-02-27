import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/multi_select/multi_selector.dart';
import 'package:learnflutter/component/show_selector_widget/show_selector.dart';
import 'package:learnflutter/core/utils/extension/extension_list.dart';
import 'package:learnflutter/data/models/load_more_model.dart';

import 'package:learnflutter/data/models/option_model.dart';
import 'package:learnflutter/shared/widgets/show_selector_widget/acc_item_finder/show_finder_cubit.dart';

class ShowFinder<T extends OptionModel> extends StatefulWidget {
  const ShowFinder({
    super.key,
    this.autoSelectFirst = false,
    this.hasSearchBar = true,
    this.autoFocusSearch = false,
    this.selectedLength = 1,
    this.selectedItems = const [],
    required this.title,
    this.hint = "Tìm kiếm",
    required this.getListFunction,
    this.itemBuilder,
    this.displayBuilder,
    required this.onChanged,
    this.canReInitData = false,
    this.enableDisplay = true,
    this.showSelectedConfirm = false,
    this.selectorType = MultiSelectorType.replace,
  });

  final bool autoSelectFirst;
  final bool hasSearchBar;
  final bool autoFocusSearch;
  final int selectedLength;
  final String title;
  final String hint;
  final List<T> selectedItems;
  final bool showSelectedConfirm;

  final ValueChanged<List<T>> onChanged;
  final Widget Function(T item, bool isSelceted)? itemBuilder;
  final Widget Function(bool enable, List<T> value)? displayBuilder;
  final Future<List<T>> Function() getListFunction;

  final bool canReInitData;
  final bool enableDisplay;
  final MultiSelectorType selectorType;

  @override
  State<ShowFinder<T>> createState() => _ShowFinderState<T>();
}

class _ShowFinderState<T extends OptionModel> extends State<ShowFinder<T>> {
  final _finderCubit = ShowFinderCubit<T>();

  Future<List<T>> _initData({bool callFromOnOpen = false}) async {
    // if it inited
    if (_finderCubit.state.dataList.isNotEmpty) {
      // but if it can rebuild
      if (!widget.canReInitData) return [];
      if (callFromOnOpen) return [];
      return await _finderCubit.init(
          widget.getListFunction, widget.selectedItems, widget.autoSelectFirst);
    } else {
      return await _finderCubit.init(
          widget.getListFunction, widget.selectedItems, widget.autoSelectFirst);
    }
  }

  @override
  void initState() {
    _finderCubit.updateSelected(widget.selectedItems);
    if (widget.autoSelectFirst &&
        (widget.selectedItems.isEmpty || widget.selectedItems.first.isEmpty)) {
      _initData();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ShowFinder<T> oldWidget) {
    _finderCubit.updateSelected(widget.selectedItems);
    if (widget.canReInitData) {
      _initData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _finderCubit,
      child: BlocListener<ShowFinderCubit<T>, ShowFinderState<T>>(
        listenWhen: (previous, current) =>
            previous.selectedItems != current.selectedItems,
        listener: (context, state) {
          widget.onChanged(state.selectedItems);
        },
        child: BlocBuilder<ShowFinderCubit<T>, ShowFinderState<T>>(
          builder: (context, state) {
            return ShowSelector<T>(
              enableDisplay: widget.enableDisplay,
              selectedItems: state.selectedItems,
              selectedLength: widget.selectedLength,
              hasSearchBar: widget.hasSearchBar,
              autoFocusSearch: widget.autoFocusSearch,
              doPreAnalyzeSearch: false,
              showSelectedConfirm: widget.showSelectedConfirm,
              onChanged: widget.onChanged,
              itemBuilder: widget.itemBuilder,
              displayBuilder: widget.displayBuilder,
              selectorType: widget.selectorType,
              getListFunction: (pageNumber, pageSize, keyword) async {
                List<T> items = await _initData(callFromOnOpen: true);
                if (items.isEmpty) items = state.dataList;
                return LoadMoreModel.empty()
                  ..total = items.length
                  ..items = items.searchByKeyWord(keyword: keyword).toList();
              },
              title: widget.title,
              hint: widget.hint,
            );
          },
        ),
      ),
    );
  }
}
