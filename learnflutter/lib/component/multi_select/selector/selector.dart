import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/multi_select/multi_selector.dart';
import 'package:learnflutter/component/multi_select/selector/selector_cubit.dart';
import 'package:learnflutter/component/multi_select/selector/selector_state.dart';
import 'package:learnflutter/core/app/app_assets.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/utils/extension/extension_list.dart';
import 'package:learnflutter/core/utils/image_helper.dart';
import 'package:learnflutter/data/models/option_model.dart';
import 'package:learnflutter/shared/widgets/app_divider.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';

import 'package:learnflutter/utils_helper/utils_helper.dart';

class Selector<T extends OptionModel> extends StatefulWidget {
  const Selector({
    super.key,
    this.selectLength = 1,
    this.title = 'UtilsHelper.lang.selectInfo',
    this.hint = 'UtilsHelper.lang.selectInfo',
    required this.items,
    required this.selectedItems,
    this.enable = true,
    this.onChanged,
    required this.itemBuilder,
    this.autoFocus = true,
    this.hasTitle = true,
    this.hasSearchBar = true,
    this.selectorType = MultiSelectorType.replace,
  });

  final int selectLength;
  final String title;
  final String hint;
  final List<T> items;
  final List<T> selectedItems;
  final bool enable;
  final bool autoFocus;
  final bool hasTitle;
  final bool hasSearchBar;
  final MultiSelectorType selectorType;
  final ValueChanged<List<T>>? onChanged;
  final Widget Function(T item, bool isSelected) itemBuilder;

  @override
  State<Selector<T>> createState() => SelectorScreenState<T, Selector<T>>();
}

class SelectorScreenState<T extends OptionModel, Screen extends Selector<T>>
    extends State<Screen> {
  final SelectorCubit<T> selectorCubit = SelectorCubit<T>();
  String searchKeyword = '';

  void updateItems({List<T> items = const []}) {
    selectorCubit.changeItems(items);
  }

  @override
  void initState() {
    selectorCubit.init(widget.items, widget.selectedItems);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Screen oldWidget) {
    updateItems(items: widget.items);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: selectorCubit,
      child: EnableWidget(
        enable: widget.enable,
        child: BlocBuilder<SelectorCubit<T>, SelectorState<T>>(
            builder: (context, state) {
          return Column(
            children: [
              if (widget.hasSearchBar) AppDivider.horizontal(),
              if (widget.hasSearchBar) searchBar(),
              Expanded(child: buildBody(context)),
            ],
          );
        }),
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: AppEdgeInserts.normal.copyWith(bottom: 0),
      child: AppTextField(
        text: searchKeyword,
        autoFocus: widget.autoFocus,
        prefix: Padding(
          padding: EdgeInsets.all(DeviceDimension.padding / 1.5),
          child: ImageHelper.loadFromAsset(AppAssets.iconHomeRefresh),
        ),
        onChanged: onKeywordChanged,
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return BlocBuilder<SelectorCubit<T>, SelectorState<T>>(
      bloc: selectorCubit,
      builder: (context, state) {
        return MultiSelector<T>(
          items: state.items,
          initialSelectedItems: state.selectedItems,
          itemBuilder: widget.itemBuilder,
          itemContainerBuilder: itemContainerBuilder,
          decoration: const BoxDecoration(),
          selectLength: widget.selectLength,
          type: widget.selectorType,
          onSelectItem: onSelectedItem,
        );
      },
    );
  }

  Widget itemContainerBuilder(
    Widget Function(T item, bool isSelected) itemBuilder,
    Iterable<T> items,
    Iterable<T> selectedItems,
  ) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final item = items.elementAt(index);
        return itemBuilder(item, selectedItems.contains(item));
      },
      separatorBuilder: (context, index) {
        return AppDivider.horizontal();
      },
      itemCount: items.length,
    );
  }

  void onBackPress() {
    selectorCubit.unConfirmSelected();
    UtilsHelper.pop(context);
  }

  void onConfirmPress() {
    selectorCubit.confirmSelected();
    widget.onChanged?.call(selectorCubit.state.selectedItems);
  }

  void onSelectedItem(List<T> value) {
    selectorCubit.changeSelected(value);
  }

  void onKeywordChanged(String value) {
    if (searchKeyword == value) return;
    searchKeyword = value;
    updateItems(items: widget.items.searchByKeyWord(keyword: value).toList());
  }
}
