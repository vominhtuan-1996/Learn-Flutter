// ignore_for_file: use_function_type_syntax_for_parameters, curly_braces_in_flow_control_structures

import 'package:learnflutter/core/utils/extension/recase.dart';

/// Extension cho List cung cấp các phương thức tiện ích để thao tác với danh sách.
/// Bao gồm replace, update phần tử tại index, forEach tùy chỉnh, và tìm giá trị max/min.
extension ListExtension<T extends Object> on List<T> {
  /// Thay thế phần tử tại vị trí index bằng item mới.
  /// Trả về danh sách đã được cập nhật.
  List<T> replace({required T item, required int index}) {
    List<T> temp = this;
    temp.removeAt(index);
    temp.insert(index, item);
    return temp;
  }

  /// Thực hiện một hành động cho mỗi phần tử trong danh sách.
  /// Tương tự forEach nhưng với tên gọi khác để tránh nhầm lẫn.
  void forEachExtenstion(void action(T item)) {
    for (T item in this) action(item);
  }

  /// Cập nhật phần tử tại vị trí index bằng item mới.
  /// Sử dụng replaceRange để thay thế một phần tử duy nhất.
  List<T> update({required int index, required T item}) {
    List<T> list = [];
    list.add(item);
    replaceRange(index, index + 1, list);
    return this;
  }

  /// Tìm giá trị lớn nhất trong danh sách (yêu cầu các phần tử là số).
  T? get max => reduce(
      (value, element) => (value as num) > (element as num) ? value : element);

  /// Tìm giá trị nhỏ nhất trong danh sách (yêu cầu các phần tử là số).
  T? get min => reduce(
      (value, element) => (value as num) < (element as num) ? value : element);

  void get removeObjectNull => removeWhere((element) => element == null);
}

extension SearchExtension<E> on Iterable<E> {
  Iterable<E> searchByKeyWord({String? keyword}) {
    // if keyword is null or empty
    // return original Iterable
    if (keyword!.isNullOrEmpty) return this;

    // if keyword contain unicode (a, â, ă, á, ấ, ắ...)
    if (keyword.isContainUnicode) {
      // search exactly match (just contain and up  per case)
      return where((element) =>
          element.toString().toUpperCase().contains(keyword.toUpperCase()));
    } else {
      // search simply match (contain, upper case and remove Vietnamese accent)
      return where((element) => element
          .toString()
          .removeAccent
          .toUpperCase()
          .contains(keyword.toUpperCase()));
    }
  }

  bool isContain(Iterable<E> a) {
    // Create a frequency map for elements in b
    Map<E, int> bFrequency = {};
    for (var element in this) {
      bFrequency[element] = (bFrequency[element] ?? 0) + 1;
    }

    // Check if each element in a exists in b with sufficient count
    for (var element in a) {
      if (!bFrequency.containsKey(element) || bFrequency[element]! <= 0) {
        return false;
      }
      // Decrement the count in bFrequency
      bFrequency[element] = bFrequency[element]! - 1;
    }

    return true;
  }
}
