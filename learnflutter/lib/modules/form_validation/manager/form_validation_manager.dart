//

// NOTE: FormValidationManager dùng để quản lý nhiều FormFieldValidator
import 'package:flutter/material.dart';

class FormValidationManager extends ChangeNotifier {
  // HashMap dùng để lưu trữ danh sách các field và validator của chúng
  final Map<String, FormFieldValidator> _fields = {};

  // Thêm field mới vào form
  void addField(String fieldName, dynamic Function(dynamic value) validator) {
    _fields[fieldName] = FormFieldValidator(validator);
  }

  // Cập nhật giá trị của field
  void updateField(String fieldName, dynamic value) {
    if (_fields.containsKey(fieldName)) {
      _fields[fieldName]?.value = value;
      notifyListeners();
    }
  }

  // Lấy lỗi của field
  dynamic getError(String fieldName) {
    return _fields[fieldName]?.error;
  }

  // Kiểm tra toàn bộ các field để biết chúng có hợp lệ không
  bool validate() {
    bool isValid = true;

    for (final field in _fields.values) {
      field.validate();
      if (field.error != null) {
        isValid = false;
      }
    }

    notifyListeners();
    return isValid;
  }
}

// FormFieldValidator dùng để kiểm tra một field của form
class FormFieldValidator {
  // Hàm validator tùy chỉnh
  final dynamic Function(dynamic) _validator;
  dynamic _value;
  dynamic _error;

  FormFieldValidator(this._validator);

  set value(dynamic value) {
    _value = value;
  }

  dynamic get value => _value;
  dynamic get error => _error;

  void validate() {
    _error = _validator(_value);
  }
}
