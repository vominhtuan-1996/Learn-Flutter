import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/multi_select/multi_selector.dart';

class MultiSelectCubit<T> extends Cubit<MultiSelectState<T>> {
  MultiSelectCubit(Set<T> selectedItems, this.type, this.selectLength) : super(MultiSelectState(selectedItems: selectedItems));
  final MultiSelectorType type;
  final int selectLength;

  void selectItem(T item) {
    switch (type) {
      case MultiSelectorType.replace:
        if (state.selectedItems.contains(item)) return;
        Set<T> results = Set.from(state.selectedItems);

        if (results.length >= selectLength) results.remove(results.first);
        emit(state.copyWith(selectedItems: results..add(item)));
        break;
      case MultiSelectorType.limit:
        if (state.selectedItems.contains(item)) {
          emit(state.copyWith(selectedItems: Set.from(state.selectedItems)..remove(item)));
        } else {
          if (state.selectedItems.length >= selectLength) return;
          emit(state.copyWith(selectedItems: Set.from(state.selectedItems)..add(item)));
        }
        break;
      case MultiSelectorType.unLimit:
        if (state.selectedItems.contains(item)) {
          emit(state.copyWith(selectedItems: Set.from(state.selectedItems)..remove(item)));
        } else {
          emit(state.copyWith(selectedItems: Set.from(state.selectedItems)..add(item)));
        }
        break;
    }
  }
}

class MultiSelectState<T> extends Equatable {
  final Set<T> selectedItems;

  const MultiSelectState({required this.selectedItems});

  MultiSelectState<T> copyWith({Set<T>? selectedItems}) {
    return MultiSelectState(selectedItems: selectedItems ?? this.selectedItems);
  }

  @override
  List<Object?> get props => [selectedItems];
}
