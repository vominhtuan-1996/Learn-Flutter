import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/state/metarial_radio_buton_state.dart';

class MetarialRadioButtonCubit extends BaseCubit<MetarialRadioButonState> {
  MetarialRadioButtonCubit(super.initialState);

  Future<void> toggleValue(String id) async {
    if (state.type == RadioType.single) {
      final updatedList = state.listData?.map((item) {
        if (item.id == id) {
          return RadioItemModel(
            id: item.id,
            title: item.title,
            isSelected: true,
          );
        }
        return RadioItemModel(
          id: item.id,
          title: item.title,
          isSelected: false,
        );
      }).toList();
      emit(state.copyWith(listData: updatedList));
    } else if (state.type == RadioType.multi) {
      final updatedList = state.listData?.map((item) {
        if (item.id == id) {
          return RadioItemModel(
            id: item.id,
            title: item.title,
            isSelected: !item.isSelected,
          );
        }
        return item;
      }).toList();
      state.listData = updatedList;
      emit(state.copyWith(listData: updatedList));
    }
  }
}
