import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/utils/extension/extension_string.dart';
import 'package:learnflutter/shared/widgets/multi_select/multi_select_cubit.dart';
import 'package:learnflutter/core/app/device_dimension.dart';

enum MultiSelectorType {
  // if length = 2, and next select is do nothing, must unselect and reselect
  limit,
  // if length = 2, next select is remove the first then select
  replace,
  // select or unSelect without length
  unLimit,
}

class MultiSelector<T> extends StatefulWidget {
  const MultiSelector({
    super.key,
    this.enable = true,
    required this.items,
    required this.initialSelectedItems,
    this.enableItem,
    this.itemBuilder,
    this.itemContainerBuilder,
    this.onSelectItem,
    this.selectLength = 1,
    this.decoration,
    this.padding,
    this.type = MultiSelectorType.replace,
    this.selectedColor,
    this.unselectedColor,
  });

  final bool enable;
  final List<T> items;

  // length of max selected item
  final int selectLength;
  final Color? selectedColor;
  final Color? unselectedColor;
  final MultiSelectorType type;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final List<T> initialSelectedItems;
  final ValueChanged<List<T>>? onSelectItem;
  final bool Function(T item)? enableItem;
  final Widget Function(T item, bool isSelected)? itemBuilder;
  final Widget Function(Widget Function(T item, bool isSelected) itemBuilder,
      Iterable<T> items, Iterable<T> selectedItems)? itemContainerBuilder;

  @override
  State<MultiSelector<T>> createState() => _MultiSelectorState<T>();
}

class _MultiSelectorState<T> extends State<MultiSelector<T>> {
  late List<T> items = widget.items;
  late MultiSelectCubit<T> selectCubit = MultiSelectCubit<T>(
    Set.from(widget.initialSelectedItems),
    widget.type,
    widget.selectLength,
  );

  @override
  void didUpdateWidget(covariant MultiSelector<T> oldWidget) {
    // re init items
    items = widget.items;
    selectCubit = MultiSelectCubit<T>(
      Set.from(widget.initialSelectedItems),
      widget.type,
      widget.selectLength,
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: selectCubit,
      child: BlocListener<MultiSelectCubit<T>, MultiSelectState<T>>(
        listenWhen: (previous, current) {
          return previous.selectedItems != current.selectedItems;
        },
        listener: (context, state) {
          widget.onSelectItem?.call(state.selectedItems.toList());
        },
        child: Container(
          width: double.infinity,
          padding:
              widget.padding ?? EdgeInsets.all(DeviceDimension.padding / 2),
          decoration: widget.decoration ??
              BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: context.theme.borderPrimary, width: 0.5),
              ),
          child: BlocBuilder<MultiSelectCubit<T>, MultiSelectState<T>>(
              builder: (context, state) {
            if (items.isEmpty) return const EmptyWidget();
            return buildContainerItems();
          }),
        ),
      ),
    );
  }

  Widget buildContainerItems() {
    if (widget.itemContainerBuilder != null)
      return widget.itemContainerBuilder!(
          buildItem, items, selectCubit.state.selectedItems);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(
        (e) {
          final isSelected = selectCubit.state.selectedItems.contains(e);
          return buildItem(e, isSelected);
        },
      ).toList(),
    );
  }

  Widget buildItem(T item, bool isSelected) {
    final itemEnable = widget.enableItem?.call(item) ?? true;
    return Tap(
      dismissKeyboard: false,
      enable: widget.enable && itemEnable,
      disableColor: context.theme.background.withValues(alpha: 0.5),
      onTap: () => selectCubit.selectItem(item),
      child: Builder(
        builder: (context) {
          if (widget.itemBuilder != null)
            return widget.itemBuilder!(item, isSelected);
          Color color = isSelected
              ? (widget.selectedColor ?? context.theme.primary)
              : (widget.unselectedColor ?? context.theme.titleColor);
          if (!widget.enable) {
            color = color.lighter;
          }
          final circleSize = DeviceDimension.defaultSize(22);

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _Circle(
                  circleSize: circleSize, color: color, isSelected: isSelected),
              Space.horizontal(width: DeviceDimension.padding / 2),
              Expanded(child: AppText(item.toString())),
            ],
          );
        },
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(
      {required this.circleSize,
      required this.color,
      required this.isSelected});

  final double circleSize;
  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final borderSize = circleSize / 8;
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(circleSize / 2),
        border: Border.all(width: borderSize, color: color),
      ),
      margin: EdgeInsets.symmetric(vertical: borderSize),
      padding: EdgeInsets.all(borderSize),
      child: isSelected
          ? Container(
              width: circleSize / 2,
              height: circleSize / 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(circleSize / 4),
              ),
            )
          : null,
    );
  }
}
