import 'package:flutter/material.dart';
import 'package:learnflutter/core/keyboard/keyboard_overlay_controller.dart';
import 'keyboard_service.dart';

class GlobalKeyboardWrapper extends StatefulWidget {
  const GlobalKeyboardWrapper({super.key, required this.child});
  final Widget child;
  @override
  State<GlobalKeyboardWrapper> createState() => _GlobalKeyboardWrapperState();
}

class _GlobalKeyboardWrapperState extends State<GlobalKeyboardWrapper> {
  ValueNotifier<double> keyboardHeight = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    // KeyboardService.instance.listener = (visible, height) {
    //   keyboardHeight.value = visible ? height : 0;

    //   /// TODO: xử lý logic toàn app tại đây
    //   /// Ví dụ: show/hide 1 global overlay
    //   /// Example: KeyboardOverlayController.update(visible, height);
    // };
    // KeyboardService.instance.listener = (visible, height) {

    // };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: KeyboardService.instance.keyboardHeight,
      builder: (_, height, child) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: height),
          child: child,
        );
      },
    );
  }
}

// class GlobalKeyboardWrapper extends StatefulWidget {
//   final Widget child;
//   const GlobalKeyboardWrapper({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<double>(
//       stream: KeyboardService.instance.keyboardHeightStream,
//       initialData: 0,
//       builder: (context, snapshot) {
//         final height = snapshot.data ?? 0;

//         return AnimatedPadding(
//           duration: const Duration(milliseconds: 150),
//           curve: Curves.easeOut,
//           padding: EdgeInsets.only(bottom: height),
//           child: child,
//         );
//       },
//     );
//   }
// }
