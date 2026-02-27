import 'dart:async';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter/material.dart';

class MBProgressHUD extends StatefulWidget {
  const MBProgressHUD({super.key});
  @override
  State<MBProgressHUD> createState() => _MBProgressHUDState();
}

class _MBProgressHUDState extends State<MBProgressHUD> {
  final GlobalKey<ProgressHudState> _hudKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ProgressHud(
        key: _hudKey,
        child: Center(
          child: Builder(builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _showLoadingHud(context);
                  },
                  child: const Text("show loading"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSuccessHud(context);
                  },
                  child: const Text("show success"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showErrorHud(context);
                  },
                  child: const Text("show error"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showProgressHud(context);
                  },
                  child: const Text("show progress"),
                ),
                const Divider(height: 50),
                ElevatedButton(
                  onPressed: () async {
                    ProgressHud.showLoading();
                    await Future.delayed(const Duration(seconds: 1));
                    ProgressHud.dismiss();
                  },
                  child: const Text("show global loading"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ProgressHud.showAndDismiss(ProgressHudType.success, "load success");
                  },
                  child: const Text("show global success"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ProgressHud.showAndDismiss(ProgressHudType.error, "load fail");
                  },
                  child: const Text("show global error"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showProgressHudGlobal();
                  },
                  child: const Text("show global progress"),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

_showLoadingHud(BuildContext context) async {
  ProgressHud.of(context)?.show(ProgressHudType.loading, '');
  await Future.delayed(const Duration(seconds: 3));
  ProgressHud.of(context)?.dismiss();
}

_showSuccessHud(BuildContext context) {
  ProgressHud.of(context)!.showAndDismiss(ProgressHudType.success, "load success");
}

_showErrorHud(BuildContext context) {
  ProgressHud.of(context)?.showAndDismiss(ProgressHudType.error, "load fail");
}

_showProgressHud(BuildContext context) {
  var hud = ProgressHud.of(context);
  hud?.show(ProgressHudType.progress, "loading");

  double current = 0;
  Timer.periodic(const Duration(milliseconds: 1000.0 ~/ 60), (timer) {
    current += 1;
    var progress = current / 100;
    hud?.updateProgress(progress, "loading $current%");
    if (progress == 1) {
      hud?.showAndDismiss(ProgressHudType.success, "load success");
      timer.cancel();
    }
  });
}

_showProgressHudGlobal() {
  ProgressHud.show(ProgressHudType.progress, "loading");

  double current = 0;
  Timer.periodic(const Duration(milliseconds: 1000.0 ~/ 60), (timer) {
    current += 1;
    var progress = current / 100;
    ProgressHud.updateProgress(progress, "loading $current%");
    if (progress == 1) {
      ProgressHud.showAndDismiss(ProgressHudType.success, "load success");
      timer.cancel();
    }
  });
}
