import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/component/multi_select/multi_selector.dart';
import 'package:learnflutter/component/multi_select/selector/load_more_selector.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';
import 'package:learnflutter/custom_widget/app_text.dart';
import 'package:learnflutter/custom_widget/detail_container.dart';
import 'package:learnflutter/custom_widget/tap.dart';
import 'package:learnflutter/data/models/load_more_model.dart';
import 'package:learnflutter/data/models/option_model.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

///
class ShowSelector<T extends OptionModel> extends StatefulWidget {
  const ShowSelector({
    super.key,
    this.minTextLength = 1,
    this.hasTitle = true,
    this.hasSearchBar = true,
    this.autoFocusSearch = false,
    this.hint = '',
    this.doPreAnalyzeSearch = true,
    this.selectedLength = 1,
    required this.selectedItems,
    required this.onChanged,
    this.displayBuilder,
    required this.getListFunction,
    required this.title,
    this.enableItem,
    this.enableDisplay = true,
    this.showSelectedConfirm = false,
    this.dismissWhenClickOutside = true,
    this.itemBuilder,
    this.heightRatio = 0.6,
    this.selectorType = MultiSelectorType.replace,
  });

  final String title;
  final String hint;
  final bool hasTitle;
  final bool hasSearchBar;
  final bool autoFocusSearch;
  final bool doPreAnalyzeSearch;
  final bool showSelectedConfirm;
  final int selectedLength;
  final double heightRatio;
  final bool dismissWhenClickOutside;

  // min text to search
  final int minTextLength;
  final List<T> selectedItems;
  final ValueChanged<List<T>>? onChanged;
  final Widget Function(T value, bool isSelected)? itemBuilder;
  final Widget Function(bool enable, List<T> value)? displayBuilder;
  final Future<LoadMoreModel<T>> Function(
      int pageSize, int pageNumber, String keyword) getListFunction;

  final bool Function(T item)? enableItem;
  final bool enableDisplay;
  final MultiSelectorType selectorType;

  @override
  State<ShowSelector> createState() => _ShowSelectorState<T>();
}

class _ShowSelectorState<T extends OptionModel> extends State<ShowSelector<T>> {
  late List<T> value;
  late final debounce = SingleDebounce();
  late final selectorKey = GlobalKey<LoadMoreSelectorScreenState>();

  void initData() {
    value = List.from(widget.selectedItems);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ShowSelector<T> oldWidget) {
    initData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return EnableWidget(
      enable: widget.enableDisplay,
      child: Tap(onTap: find, child: displayBuilder(value)),
    );
  }

  Widget displayBuilder(List<T> value) {
    if (widget.displayBuilder != null) {
      return widget.displayBuilder!(widget.enableDisplay, value);
    }
    return DetailContainer.arrowDown(
      enable: widget.enableDisplay,
      title: widget.title,
      child: AppText(value.toString(), color: context.theme.primary),
    );
  }

  Widget itemBuilder(T item, bool isSelected) {
    if (widget.itemBuilder != null)
      return widget.itemBuilder!(item, isSelected);
    return AppText(item.toString(),
        color: isSelected ? context.theme.primary : null);
  }

  void find() {
    DialogUtils.showBottomSheet(
      title: widget.title,
      heightRatio: widget.heightRatio,
      isDismissible: widget.dismissWhenClickOutside,
      onBackPress: UtilsHelpers.pop,
      titleRightAction: titleRightAction(context),
      child: LoadMoreSelector<T>(
        key: selectorKey,
        itemBuilder: itemBuilder,
        getItemsFunction: widget.getListFunction,
        selectedItems: value,
        selectLength: widget.selectedLength,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          widget.onChanged?.call(value);
          if (mounted) {
            setState(() {
              this.value = value;
            });
          }
        },
        title: widget.title,
        hasTitle: widget.hasTitle,
        enable: widget.enableDisplay,
        enableItem: widget.enableItem,
        hasSearchBar: widget.hasSearchBar,
        autoFocus: widget.autoFocusSearch,
        selectorType: widget.selectorType,
        hint: widget.hint,
        preAnalyzeSearch: (searchFunction, keyword) {
          if (!widget.doPreAnalyzeSearch) return searchFunction();
          if (keyword.isEmpty) {
            debounce.runAfter(action: searchFunction, rate: 600);
            return;
          }
          if (keyword.length < widget.minTextLength) return;
          debounce.runAfter(action: searchFunction, rate: 600);
        },
        onItemTap: (value) {
          if (!widget.showSelectedConfirm) {
            selectorKey.currentState?.onSelectedItem(value);
            selectorKey.currentState?.onConfirmPress();
            UtilsHelper.pop(context);
          }
        },
      ),
    );
  }

  Widget? titleRightAction(BuildContext context) {
    if (!widget.showSelectedConfirm) return null;
    return Tap(
      onTap: () {
        selectorKey.currentState?.onConfirmPress();
        UtilsHelper.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(DeviceDimension.padding / 2).copyWith(right: 0),
        color: Colors.transparent,
        child: AppText('Xác nhận', color: getThemeBloc(context).state.tokens.colors.primary),
      ),
    );
  }
}
