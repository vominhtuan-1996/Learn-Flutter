// ignore_for_file: use_function_type_syntax_for_parameters, curly_braces_in_flow_control_structures

extension ListExtension<T extends Object> on List<T> {
  List<T> replace({required T item, required int index}) {
    List<T> temp = this;
    temp.removeAt(index);
    temp.insert(index, item);
    return temp;
  }

  void forEachExtenstion(void action(T item)) {
    for (T item in this) action(item);
  }

  List<T> update({required int index, required T item}) {
    List<T> list = [];
    list.add(item);
    replaceRange(index, index + 1, list);
    return this;
  }

  T? get max => reduce((value, element) => (value as num) > (element as num) ? value : element);
  T? get min => reduce((value, element) => (value as num) < (element as num) ? value : element);
}
