import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/shared/widgets/app_dialog/app_dialog_manager.dart';
import 'package:learnflutter/data/models/option_model.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';

class ShowFinderCubit<M extends OptionModel> extends Cubit<ShowFinderState<M>> {
  ShowFinderCubit()
      : super(
            ShowFinderState(isLoading: false, dataList: [], selectedItems: []));

  Future<List<M>> init(Future<List<M>> Function() getList,
      List<M> selectedItems, bool autoSelectFirst) async {
    try {
      emit(state.copyWith(isLoading: true, dataList: []));
      final dataList = await getList();
      emit(state.copyWith(
        isLoading: false,
        dataList: dataList,
        selectedItems:
            getInitialValue(dataList, selectedItems, autoSelectFirst),
      ));
      return dataList;
    } catch (e) {
      AppDialogManager.error(e.toString());
      emit(state.copyWith(isLoading: false));
      return [];
    }
  }

  void updateSelected(List<M> selectedItems) {
    emit(state.copyWith(selectedItems: selectedItems));
  }

  List<M> getInitialValue(
      List<M> dataList, List<M> selectedItems, bool autoSelectFirst) {
    if (selectedItems.isNotEmpty &&
        selectedItems.every((element) => element.isNotEmpty))
      return selectedItems;

    if (autoSelectFirst && dataList.isNotEmpty) {
      return [dataList.first];
    }

    return [];
  }
}

class ShowFinderState<M extends OptionModel> extends Equatable {
  final bool isLoading;
  final List<M> dataList;
  final List<M> selectedItems;

  const ShowFinderState(
      {required this.isLoading,
      required this.dataList,
      required this.selectedItems});

  ShowFinderState<M> copyWith({
    bool? isLoading,
    List<M>? dataList,
    List<M>? selectedItems,
  }) {
    return ShowFinderState(
      isLoading: isLoading ?? this.isLoading,
      dataList: dataList ?? this.dataList,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }

  @override
  List<Object?> get props => [isLoading, dataList, selectedItems];
}
