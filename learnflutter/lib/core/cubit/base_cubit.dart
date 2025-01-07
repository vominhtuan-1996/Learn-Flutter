import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubit<E> extends Cubit<E> {
  BaseCubit(super.initialState) {
    final context = GlobalKey<NavigatorState>().currentContext;
    if (context == null) {
      return;
    }
  }
}
