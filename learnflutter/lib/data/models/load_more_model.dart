import 'package:learnflutter/data/models/base_model.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';

class LoadMoreModel<T extends BaseModel> {
  late int total;
  late int totalItem;
  late int start;
  late int end;
  late List<T> items = [];

  LoadMoreModel.empty()
      : total = 0,
        totalItem = 0,
        start = 0,
        end = 0,
        items = [];

  LoadMoreModel.init(List<T>? childs)
      : total = childs?.length ?? 0,
        totalItem = 0,
        start = 0,
        end = 0,
        items = childs ?? [];

  LoadMoreModel.fromJson(dynamic json, T Function(dynamic json) fromJson) {
    total = UtilsHelper.getJsonValue(json, ['total'], defaultValue: 0);
    totalItem = UtilsHelper.getJsonValue(json, ['totalItem'], defaultValue: 0);
    start = UtilsHelper.getJsonValue(json, ['start'], defaultValue: 0);
    end = UtilsHelper.getJsonValue(json, ['end'], defaultValue: 0);

    final data = UtilsHelper.getJsonValue(json, ['data'], defaultValue: []);
    if (data is List) items = data.map(fromJson).toList();
  }
}
