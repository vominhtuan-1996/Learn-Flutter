import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/material_banner/material_banner_overlay.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MaterialSnackbarScreen extends StatefulWidget {
  const MaterialSnackbarScreen({super.key, required this.data, this.enable = true});
  final RouterMaterialModel data;
  final bool enable;
  @override
  State<MaterialSnackbarScreen> createState() => _MaterialRaidoButtonScreenState();
}

class _MaterialRaidoButtonScreenState extends State<MaterialSnackbarScreen>
    with ComponentMaterialDetail {
  String initialValue = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showTopBanner(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          elevation: 10,
          // borderRadius: BorderRadius.circular(12),
          color: Colors.redAccent,
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lỗi đăng nhập: Tài khoản hoặc mật khẩu không đúng.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () => hideTopBanner(),
                child: Icon(Icons.close, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Tự ẩn sau 3 giây
  }

  Future<void> hideTopBanner() async {
    await Future.delayed(Duration(seconds: 3));
    // overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Show Awesome SnackBar'),
              onPressed: () {
                TopOverlayBanner.show(
                  context: context,
                  content: Center(
                    child: Text(
                      'Đây là banner ở trên cùng!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  backgroundColor: Colors.yellow,
                  ratioScreenHeight: 0.35,
                );
              },
            ),
            ElevatedButton(
              child: const Text('Show Awesome SnackBar'),
              onPressed: () {
                TopOverlayBanner.show(
                  context: context,
                  content: Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                  backgroundColor: Colors.yellow,
                  ratioScreenHeight: 0.35,
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Show Awesome Material Banner'),
              onPressed: () {
                const materialBanner = MaterialBanner(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  forceActionsBelow: true,
                  content: AwesomeSnackbarContent(
                    title: 'Oh Hey!!',
                    message:
                        'This is an example error message that will be shown in the body of materialBanner!',

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.warning,
                    // to configure for material banner
                    inMaterialBanner: true,
                  ),
                  actions: [SizedBox.shrink()],
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showMaterialBanner(materialBanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}
