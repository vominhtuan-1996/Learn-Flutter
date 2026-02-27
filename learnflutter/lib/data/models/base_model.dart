import 'package:equatable/equatable.dart';
import 'package:learnflutter/core/constants/define_constraint.dart';
import 'package:learnflutter/core/utils/datetime_utils.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';

class BaseModel extends Equatable {
  int? id;
  String? name;
  String? code;
  String? createAt;
  String? updateAt;
  String? createdBy;
  String? updatedBy;

  BaseModel({required this.id, required this.name, this.code});

  BaseModel.empty()
      : id = -1,
        name = '',
        createAt = '',
        updateAt = '',
        code = '',
        createdBy = '',
        updatedBy = '';

  BaseModel.fromJson(dynamic json)
      : id = UtilsHelper.getJsonValue(json, ['id'], defaultValue: -1),
        name = UtilsHelper.getJsonValueString(json, ['name']),
        createAt = DateTimeUtils.parseStringToString(
          UtilsHelper.getJsonValueString(json, ['createdAt']),
          DateTimeType.DATE_TIME_FORMAT,
          DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM,
        ),
        updateAt = DateTimeUtils.parseStringToString(
          UtilsHelper.getJsonValueString(json, ['updatedAt']),
          DateTimeType.DATE_TIME_FORMAT,
          DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM,
        ),
        code = UtilsHelper.getJsonValueString(json, ['code']),
        createdBy = UtilsHelper.getJsonValueString(json, ['createdBy']),
        updatedBy = UtilsHelper.getJsonValueString(json, ['updatedBy']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    map['id'] = id;
    map['name'] = name;
    map['code'] = code;
    map['createdAt'] = DateTimeUtils.parseStringToString(
      createAt,
      DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM,
      DateTimeType.DATE_TIME_FORMAT,
    );
    map['updatedAt'] = DateTimeUtils.parseStringToString(
      updateAt,
      DateTimeType.DATE_TIME_FORMAT_YYYY_MM_DD_HH_MM,
      DateTimeType.DATE_TIME_FORMAT,
    );
    map['createdBy'] = createdBy;
    map['updatedBy'] = updatedBy;

    return map;
  }

  bool get isNew => id == 0;

  bool get isEmpty => id == -1;

  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    if (name == null) return '';
    return name!.isNotEmpty ? name! : '-';
    // if (name == null) return '';
    // if (id == null) return '';
    // return "{name: ${name!.isNotEmpty ? name! : '-'}, id: $id ";
  }

  @override
  List<Object?> get props => [id, name, code];
}
