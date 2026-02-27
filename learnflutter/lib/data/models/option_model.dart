import 'package:learnflutter/data/models/base_model.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';

class OptionModel extends BaseModel {
  late bool? enable;

  OptionModel({
    required super.id,
    required super.name,
    super.code,
    this.enable,
  });

  OptionModel.empty()
      : enable = true,
        super.empty();

  factory OptionModel.allItem() {
    return OptionModel(id: 0, name: "Tất cả");
  }

  OptionModel.fromJson(dynamic json) : super.fromJson(json) {
    enable = UtilsHelper.getJsonValue(json, ['enable'], defaultValue: true);
  }

  get notEmpty => (id ?? 0) > 0;

  get other => id == -1;

  @override
  List<Object?> get props => [id];
}
