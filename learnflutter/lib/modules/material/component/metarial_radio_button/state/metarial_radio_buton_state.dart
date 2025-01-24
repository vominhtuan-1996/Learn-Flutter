import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';

class MetarialRadioButonState<M extends RadioItemModel> {
  List<M>? listData;
  RadioType type;
  MetarialRadioButonState({this.listData, this.type = RadioType.single});

  factory MetarialRadioButonState.initial(List<M>? listData, RadioType type) {
    return MetarialRadioButonState(
      listData: listData,
      type: type,
    );
  }
  MetarialRadioButonState copyWith({
    List<M>? listData,
  }) {
    return MetarialRadioButonState(
      listData: listData ?? this.listData,
      type: type,
    );
  }

  List<Object?> get props => [listData, type];
}
