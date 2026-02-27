import 'package:equatable/equatable.dart';
import 'package:learnflutter/data/models/option_model.dart';

class SelectorState<T extends OptionModel> extends Equatable {
  final List<T> items;
  final List<T> selectedItems;
  final List<T> lastSelectedItems;

  const SelectorState({
    required this.items,
    required this.selectedItems,
    required this.lastSelectedItems,
  });

  factory SelectorState.init() {
    return SelectorState<T>(
      items: const [],
      selectedItems: const [],
      lastSelectedItems: const [],
    );
  }

  SelectorState<T> copyWith({
    List<T>? items,
    List<T>? selectedItems,
    List<T>? lastSelectedItems,
  }) {
    return SelectorState<T>(
      items: items ?? this.items,
      selectedItems: selectedItems ?? this.selectedItems,
      lastSelectedItems: lastSelectedItems ?? this.lastSelectedItems,
    );
  }

  @override
  List<Object?> get props => [items, selectedItems, lastSelectedItems];
}
