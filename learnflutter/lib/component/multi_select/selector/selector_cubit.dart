import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/multi_select/selector/selector_state.dart';
import 'package:learnflutter/data/models/option_model.dart';

class SelectorCubit<T extends OptionModel> extends Cubit<SelectorState<T>> {
  // final
  SelectorCubit() : super(SelectorState<T>.init());

  void init(List<T> items, List<T> selectedItems) {
    emit(state.copyWith(
        items: items,
        selectedItems: selectedItems,
        lastSelectedItems: selectedItems));
  }

  void changeItems(List<T> items) {
    emit(state.copyWith(items: items));
  }

  void changeSelected(List<T> selectedItems) {
    emit(state.copyWith(selectedItems: selectedItems));
  }

  void confirmSelected() {
    emit(state.copyWith(lastSelectedItems: state.selectedItems));
  }

  void unConfirmSelected() {
    emit(state.copyWith(selectedItems: state.lastSelectedItems));
  }
}
