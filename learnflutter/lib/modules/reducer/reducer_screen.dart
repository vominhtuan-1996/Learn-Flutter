import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum Actions {
  init,
  add,
  remove,
}

int counterReducer(int state, dynamic action) {
  if (action == Actions.add) {
    return state + 1;
  } else if (action == Actions.remove) {
    return state - 1;
  }
  return state;
}

class ReducerScreen extends HookWidget {
  const ReducerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = useReducer<int, Actions>((value, action) => counterReducer(value, action), initialAction: Actions.init, initialState: 0);
    return BaseLoading(
        child: Column(
      children: [
        Center(
          child: Text(
            "Count: ${counter.state}",
            style: TextStyle(fontSize: 24),
          ),
        ),
        MaterialButton3(
          type: MaterialButtonType.commonbutton,
          borderRadius: 10,
          lableText: 'add',
          backgoundColor: Colors.white,
          textAlign: TextAlign.center,
          onTap: () {
            getLoadingCubit(context).showLoading(
              func: () {
                counter.dispatch(Actions.add);
                return 64;
              },
              onSuccess: (e) {
                print(e);
              },
              onFailed: (error) {},
            );
          },
        ),
        MaterialButton3(
          type: MaterialButtonType.commonbutton,
          borderRadius: 10,
          lableText: 'remove',
          backgoundColor: Colors.white,
          textAlign: TextAlign.center,
          onTap: () {
            counter.dispatch(Actions.remove);
          },
        ),
        MaterialButton3(
          type: MaterialButtonType.commonbutton,
          borderRadius: 10,
          lableText: 'File Picker',
          backgoundColor: Colors.white,
          textAlign: TextAlign.center,
          onTap: () async {},
        )
      ],
    ));
  }
}
