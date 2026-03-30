// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/shared/widgets/search_bar/page/search_bar_builder.dart';
import 'package:learnflutter/shared/widgets/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/shared/widgets/tap_builder/tap_delayed_pressed_button_builder.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/features/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';
import 'package:learnflutter/features/camera/model/camera_mode.dart';
import 'package:learnflutter/shared/widgets/attribute_string/attribute_string_widget.dart';
import 'package:learnflutter/features/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/features/material/component/meterial_button_3/material_button_3.dart';
import 'package:mobimap_module/bridge/mobimap_module.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/shared/widgets/app_dialog/app_dialog_manager.dart';

// import 'package:file';
/// Lớp TestScreen được thiết kế như một không gian thử nghiệm đa năng cho các tính năng mới trong ứng dụng.
/// Nó cung cấp giao diện tập trung để kiểm tra nhanh các thành phần UI, logic xử lý ngoại lệ và các tích hợp bên thứ ba.
/// Thông qua màn hình này, đội ngũ phát triển có thể xác nhận tính đúng đắn của các mô-đun như Code Push, bản đồ hoặc các hiệu ứng chuyển cảnh trước khi đưa vào luồng chính.
/// Việc duy trì một môi trường thử nghiệm riêng biệt giúp giảm thiểu rủi ro lỗi và tăng tốc độ lặp lại trong quá trình phát triển phần mềm.
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  SearchController searchControler = SearchController();

  /// Phương thức _launchURL hỗ trợ việc mở các liên kết ngoại khối trực tiếp từ ứng dụng.
  /// Nó thực hiện kiểm tra tính hợp lệ của URI và đảm bảo hệ thống có thể xử lý việc điều hướng ra trình duyệt ngoài.
  /// Trong trường hợp không thể mở liên kết, một ngoại lệ sẽ được ném ra để thông báo lỗi cho hệ thống giám sát.
  _launchURL() async {
    final Uri url = Uri.parse('https://iam.fpt.vn/auth/realms/fpt/protocol/openid-connect/auth?client_id=fproject_portal&response_type=code&redirect_uri=https://ip.fpt.vn/keycloak/callback');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Hàm fetchSuggestions mô phỏng việc truy vấn dữ liệu gợi ý từ một dịch vụ tìm kiếm.
  /// Nó sử dụng cơ chế trì hoãn thời gian để giả lập độ trễ mạng trong điều kiện thực tế.
  /// Kết quả trả về là một danh sách các chuỗi ký tự được tạo tự động dựa trên từ khóa người dùng nhập vào.
  Future<List<dynamic>> fetchSuggestions(String query) async {
    // Thực hiện yêu cầu đến API tìm kiếm sản phẩm
    // For demonstration, returning a dummy list
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return List<String>.generate(10, (index) => 'Suggestion123 $index for $query');
  }

  List uploadList = [
    RadioItemModel(id: 'id', title: 'start of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '2'),
    RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '4'),
    RadioItemModel(id: 'id', title: '5'),
    RadioItemModel(
        id: 'id',
        title:
            'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '7'),
    RadioItemModel(id: 'id', title: '8'),
    RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '10'),
    RadioItemModel(id: 'id', title: 'end 11 of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
  ];

  /// Phương thức splitCodeString xử lý việc phân tách mã xác thực từ một URL callback phức tạp.
  /// Nó sử dụng các hàm xử lý chuỗi cơ bản để bóc tách các tham số query và lưu trữ chúng vào một Map.
  /// Logic này rất quan trọng trong việc triển khai các luồng đăng nhập OAuth thông qua trình duyệt web.
  void splitCodeString() {
    var value =
        'https://ip.fpt.vn/keycloak/callback?session_state=99b4a2fe-3ba2-41d4-97a8-b4c0031b038f&code=66d06447-8e2d-4914-807f-52d26f65c120.99b4a2fe-3ba2-41d4-97a8-b4c0031b038f.ab352c75-07da-4d36-9912-09e722986f3d';
    var newValue = value.split("?");
    var newValues = newValue.last.split("&");
    Map<String, dynamic> map = {};
    for (var item in newValues) {
      var items = item.split("=");
      map[items.first] = items.last;
    }
    print(map['code']);
  }

  /// Hàm convertCurlToMarkdown giúp chuyển đổi các lệnh cURL thô sang định dạng Markdown dễ đọc hơn.
  /// Quá trình này bao gồm việc xử lý các ký tự thoát và bọc nội dung trong các khối mã chuẩn.
  /// Đây là một công cụ hỗ trợ ghi nhật ký (logging) hiệu quả để theo dõi các yêu cầu API trong quá trình gỡ lỗi.
  String convertCurlToMarkdown(String curlInput) {
    // Loại bỏ khoảng trắng đầu cuối và escape các ký tự đặc biệt
    final escapedCurl = curlInput.trim().replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    // Đưa vào code block markdown
    return '```\n$escapedCurl\n```';
  }

  bool switchValue = true;

  final _updater = ShorebirdUpdater();
  late final bool _isUpdaterAvailable;
  var _currentTrack = UpdateTrack.stable;
  var _isCheckingForUpdates = false;
  Patch? _currentPatch;

  /// Phương thức _checkForUpdate thực hiện việc kiểm tra các bản cập nhật mới từ hệ thống Code Push Shorebird.
  /// Nó cập nhật trạng thái giao diện để người dùng biết quá trình kiểm tra đang diễn ra và xử lý các kết quả trả về.
  /// Dựa trên tình trạng của bản vá (outdated, upToDate, hoặc restartRequired), ứng dụng sẽ hiển thị các thông báo (banners) tương ứng.
  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;

    try {
      setState(() => _isCheckingForUpdates = true);
      // Check if there's an update available.
      final status = await _updater.checkForUpdate(track: _currentTrack);
      _updater.readCurrentPatch().then((currentPatch) {
        debugPrint('Error reading current patch: $currentPatch');
        setState(() => _currentPatch = currentPatch);
      }).catchError((Object error) {
        // If an error occurs, we log it for now.
        debugPrint('Error reading current patch: $error');
      });
      if (!mounted) return;
      // If there is an update available, show a banner.
      switch (status) {
        case UpdateStatus.upToDate:
          _showNoUpdateAvailableBanner();
        case UpdateStatus.outdated:
          _showUpdateAvailableBanner();
        case UpdateStatus.restartRequired:
          _showRestartBanner();
        case UpdateStatus.unavailable:
        // Do nothing, there is already a warning displayed at the top of the
        // screen.
      }
    } catch (error) {
      // If an error occurs, we log it for now.
      debugPrint('Error checking for update: $error');
    } finally {
      setState(() => _isCheckingForUpdates = false);
    }
  }

  void _showDownloadingBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        const MaterialBanner(
          content: Text('Downloading...'),
          actions: [
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
  }

  void _showUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'Update available for the ${_currentTrack.name} track.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                await _downloadUpdate();
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
  }

  void _showNoUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'No update available on the ${_currentTrack.name} track.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  void _showRestartBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text('A new patch is ready! Please restart your app.'),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  void _showErrorBanner(Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            'An error occurred while downloading the update: $error.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  /// Phương thức _downloadUpdate khởi động quá trình tải về bản vá mới nhất từ máy chủ của Shorebird.
  /// Nó hiển thị một thanh thông báo đang tải (downloading banner) để cung cấp phản hồi hình ảnh cho người dùng.
  /// Khi quá trình hoàn tất thành công, một yêu cầu khởi động lại ứng dụng sẽ được gửi tới người dùng để áp dụng thay đổi.
  Future<void> _downloadUpdate() async {
    _showDownloadingBanner();
    try {
      // Perform the update (e.g download the latest patch on [_currentTrack]).
      // Note that [track] is optional. Not passing it will default to the
      // stable track.
      await _updater.update(track: _currentTrack);
      if (!mounted) return;
      // Show a banner to inform the user that the update is ready and that they
      // need to restart the app.
      _showRestartBanner();
    } on UpdateException catch (error) {
      // If an error occurs, we show a banner with the error message.
      _showErrorBanner(error.message);
    }
  }

  @override
  void initState() {
    super.initState();
    // Check whether Shorebird is available.
    setState(() => _isUpdaterAvailable = _updater.isAvailable);

    // Read the current patch (if there is one.)
    // `currentPatch` will be `null` if no patch is installed.
    _updater.readCurrentPatch().then((currentPatch) {
      setState(() => _currentPatch = currentPatch);
    }).catchError((Object error) {
      // If an error occurs, we log it for now.
      debugPrint('Error reading current patch: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: Text(AppLocaleTranslate.testScreenTitle.getString(context)),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () async {},
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.newLogin);
                },
                child: Text(AppLocaleTranslate.testGlobalNoKeyboardRebuild.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.camerawesome);
                },
                child: Text(AppLocaleTranslate.cameraWesome.getString(context)),
              ),

              /// [TextButton] điều hướng tới [CameraScreen] mới với đầy đủ tính năng zoom và 2 chế độ.
              /// Callback [onPhotoCaptured] nhận [XFile] ảnh để xử lý theo nghiệp vụ của màn hình gọi.
              /// Đây là ví dụ minh hoạ cách tái sử dụng [CameraScreen] từ bất kỳ màn hình nào.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.cameraScreen,
                    arguments: {
                      'mode': CameraMode.photo,
                      'onPhotoCaptured': (XFile file) {
                        debugPrint('📸 Ảnh đã chụp: ${file.path}');
                      },
                      'onVideoRecorded': (XFile file) {
                        debugPrint('🎬 Video đã quay: ${file.path}');
                      },
                    },
                  );
                },
                child: const Text('Camera Screen (Zoom + Photo/Video)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.arkit);
                },
                child: const Text('AR Kit (3D Model Overlay)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.photo3D);
                },
                child: const Text('Photo 3D Viewer (Album)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.cameraScreen,
                    arguments: {
                      'mode': CameraMode.photo,
                      'onPhotoCaptured': (XFile file) {
                        // Khi chụp xong, tự động push sang màn hình xử lý 3D
                        Navigator.of(context).pushReplacementNamed(
                          Routes.photoTo3D,
                          arguments: file,
                        );
                      },
                    },
                  );
                },
                child: const Text('Capture to 3D (AI Simulation)'),
              ),
              TextButton(
                onPressed: () {
                  _checkForUpdate();
                },
                child: Text(AppLocaleTranslate.codePushPatch.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  AppDialogManager.showUpdatePatch(
                    version: '1.0.2+5',
                    changelog: [
                      'Sửa lỗi hiển thị trên màn hình iPhone 15 Pro Max.',
                      'Tối ưu hóa tốc độ tải ảnh 3D tăng 20%.',
                      'Bổ sung hiệu ứng Parallax mượt mà cho Depth Map.',
                      'Cập nhật giao diện App Update phong cách Premium.',
                    ],
                    onUpdate: () {
                      // Mô phỏng quá trình tải xuống
                      debugPrint('🚀 Bắt đầu cập nhật...');
                    },
                    showSimulator: true,
                  );
                },
                child: const Text('Show Modern Patch Dialog (Mock)'),
              ),
              TextButton(
                onPressed: () {
                  AppDialogManager.showUpdatePatch(
                    version: '1.0.2+5',
                    changelog: [
                      'Sửa lỗi hiển thị trên màn hình iPhone 15 Pro Max.',
                      'Tối ưu hóa tốc độ tải ảnh 3D tăng 20%.',
                      'Bổ sung hiệu ứng Parallax mượt mà cho Depth Map.',
                      'Cập nhật giao diện App Update phong cách Premium.',
                    ],
                    onUpdate: () {
                      debugPrint('🚀 Simulator: Started update process');
                    },
                    showSimulator: true,
                    isDownloading: false, // Dialog sẽ tự handle việc chuyển sang downloading khi ấn Update
                  );
                },
                child: const Text('💡 Simulation Progress (Slider)'),
              ),
              TextButton(
                onPressed: () {
                  AppDialogManager.showUpdatePatch(
                    version: '1.1.0+9',
                    changelog: [
                      '🆕 Tự động hóa trình mô phỏng tải xuống mượt mà.',
                      '⚡ Tối ưu hiệu ứng "Filling" của Progress Button.',
                      '🎨 Cập nhật màu sắc Gradient cao cấp hơn.',
                    ],
                    onUpdate: () {
                      debugPrint('🚀 Automation: Update initiated');
                    },
                    showSimulator: true,
                    autoSimulate: true,
                  );
                },
                child: const Text('🚀 Automation Progress Simulation'),
              ),
              TextButton(
                onPressed: () {
                  MobiMapModule.open(
                    context,
                    token:
                        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NGI4ZmNkNWIxYjA2Mjc3NDIyMTQ2NCIsInVzZXJuYW1lIjoiMDAxODEzOTAiLCJBY2NvdW50SW5zaWRlIjoiSVNDMDEuVFVBTlZNMzciLCJMb2NhdGlvbklEIjoiOCIsIkRlcHRJRCI6IjE0NzYiLCJTdXBwb3J0ZXIiOiJJU0MgVEVTVCIsIkJsb2NrSUQiOiI2MDU5OTYiLCJDdXJyZW50VmVyc2lvbiI6IiIsIlJlbGVhc2VWZXJpb24iOiIxLjQwLjAuMzAiLCJMaW5rRG93bmxvYWQiOiJodHRwczovL21vYmluZXR3cy1zdGFnLmZwdC52bi9zZXJ2aWNlL21vYmluZXQvZ2F0ZXdheS90cmFuc2l0aW9uLWFwcC9hcGkvZG93bmxvYWQiLCJBY2Nvb3VudFBheSI6IiIsIlN0YWZmSUQiOiIwIiwiRW1haWwiOiJUdWFuVk0zN0BmcHQuY29tIiwiSXNBZG1pbiI6IkZhbHNlIiwiUGFydG5lcklkIjoiMzU3IiwiVXJsSW1hZ2UiOiIiLCJEZXZpY2VOYW1lIjoiIiwiVGl0bGUiOiItMSIsIlBvc2l0aW9uIjoiLTEiLCJyb2xlIjpbIjIiLCIzIl0sIlVzZXJDbGFpbSI6WyIyIiwiMyJdLCJuYmYiOjE3NjY1NjA0ODQsImV4cCI6MTc2OTE1MjQ4NCwiaWF0IjoxNzY2NTYwNDg0LCJpc3MiOiJtb2JpbmV0LWlkZW50aXR5LXNlcnZpY2UiLCJhdWQiOiJtb2JpbmV0LWNsaWVudHMifQ.bomqSxIAKHeRFCKNegV4klE8vnKvjSr6jyMA6vsLV1w",
                    empCode: "00181390",
                    initialRoute: '/mnt_xla_checklist',
                    username: "ISC01.TUANVM37",
                    env: "STAGING",
                    isDarkMode: !getThemeBloc(context).state.tokens.isLight,
                    fontName: getThemeBloc(context).state.tokens.texts.titleLarge.fontFamily.split('_').first,
                    primaryColor: getThemeBloc(context).state.tokens.colors.primary,
                  );
                },
                child: Text(AppLocaleTranslate.mobimapModule.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.colorPicker);
                },
                child: Text(AppLocaleTranslate.colorPickerScreen.getString(context)),
              ),
              InputHistoryTextField(
                historyKey: 'search',
                lockItems: ['Flutter', 'React'],
                enableHistory: true,
                enableSave: true,
                showHistoryList: true,
                hasFocusExpand: true,
                decoration: InputDecoration(
                  hintText: AppLocaleTranslate.inputHistoryHint.getString(context),
                  border: OutlineInputBorder(),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.scrollPhysicScreen);
                },
                child: Text(AppLocaleTranslate.scrollPhysicScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.indicatorExampleScreen);
                },
                child: Text(AppLocaleTranslate.indicatorExample.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pmsSDKLogin);
                },
                child: Text(AppLocaleTranslate.pluginNghiemThu.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.flutter3dScreen);
                },
                child: Text(AppLocaleTranslate.flutter3dScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.visibilityDetectorExample);
                },
                child: Text(AppLocaleTranslate.visibilityDetectorExample.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.login);
                },
                child: Text(AppLocaleTranslate.loginButton.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.excellScreen);
                },
                child: Text(AppLocaleTranslate.workExcellFile.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.qrScreen);
                },
                child: Text(AppLocaleTranslate.scan.getString(context)),
              ),
              //       TextButton(
              //         onPressed: () {
              //           Navigator.of(context).pushNamed(Routes.webViewScreen);
              //         },
              //         child: Text('Open WebView'),
              //       ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.ticTacToeGame);
                },
                child: const Text('Tic Tac Toe Game (Flame)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.rubikGame);
                },
                child: const Text('Rubik 2D Challenge (Flame)'),
              ),
              //       TextButton(
              //         onPressed: () {
              //           String curl = '''"curl -i \
              // -X POST \
              // -H "Content-Type: application/json" \
              // -H "Access-Control_Allow_Origin: *" \
              // -H "Accept: application/json" \
              // -H "Connection: keep-alive" \
              // -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyLWVtYWlsIjoiSHV5TlExMjVAZnB0LmNvbSIsImp0aSI6IjgxMDY0OTkzLTZjMjgtNGNiZi1iYzM3LWEyNWRmNGNkY2FlMCIsImV4cCI6MTc0NzkzMTM2MywiaXNzIjoiaHR0cHM6Ly95b3VyLWlkZW50aXR5LXNlcnZlciIsImF1ZCI6Ik15QXBwVXNlcnMifQ.8ZLqSfqza_cTrMHkN3hfsPAdf4G6hwvkLrKX0gJuKWo" \
              // -H "content-length: 52" \
              // -d "{\"userName\":\"Huynq125@fpt.com \",\"password\":\"123456\"}" \
              // "https://apis.fpt.vn/pms/api/m/v1/users/loginxxx""''';

              //           String markdown = convertCurlToMarkdown(curl);
              //           log(markdown);
              //         },
              //         child: Text("send log to google chat"),
              //       ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.transformerPageView);
                },
                child: Text(AppLocaleTranslate.transformerPageViewExample.getString(context)),
              ),

              /// Nhóm các nút chức năng hỗ trợ việc tải dữ liệu và tương tác bản đồ.
              /// Các thành phần này giúp kiểm tra khả năng phản hồi của giao diện khi xử lý khối lượng dữ liệu lớn.
              /// Đồng thời, nó cũng xác nhận tính ổn định của các dịch vụ định vị và hiển thị bản đồ địa lý.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.smartLoadmoreScreen);
                },
                child: Text(AppLocaleTranslate.smartLoadmoreScreen.getString(context)),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                  .animate() // this wraps the previous Animate in another Animate
                  .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
                  .slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.newsScreen);
                },
                child: const Text('Multi-Domain News Demo'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFFFDFF80)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.newLogin);
                },
                child: const Text('Test New Login Module'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.isolateParseScreen);
                },
                child: Text(AppLocaleTranslate.testParseDataIsolate.getString(context)),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                  .animate() // this wraps the previous Animate in another Animate
                  .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
                  .slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.mapScreen);
                },
                child: Text(AppLocaleTranslate.vietnamMap.getString(context)),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                  .animate() // this wraps the previous Animate in another Animate
                  .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
                  .slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.exampleMapScreen);
                },
                child: const Text('Flutter Map Example (OSM)'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.offlineMbtilesMapScreen);
                },
                child: const Text('Offline MBTiles Map'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.googleMapBase);
                },
                child: const Text('Google Map Base (Custom UI)'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFFFDFF80)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.googleMapOffline);
                },
                child: const Text('Google Map Offline Pin (Hive)'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80FFAD)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.streetViewScreen);
                },
                child: const Text('Street View 360 (WebView)'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  // Rule 1: Chạy PMS ngầm, thành công mới hiện popup
                  AppDialogManager.startGiftCouponProcessFlow();
                },
                child: const Text('🎁 [Rule] PMS Success -> Show Inside Popup'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80FFAD)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  // Rule 2: Đã có mã PMS, hiện popup và tập trung ngay vào Inside
                  AppDialogManager.showGiftCouponAction();
                },
                child: const Text('🎁 [Rule] PMS Already Done -> Direct Inside Popup'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFFFDFF80)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),

              /// Các nút điều khiển tương tác nâng cao như làm mới danh sách và cửa sổ trò chuyện.
              /// Những thành phần này đòi hỏi sự phối hợp chặt chẽ giữa trạng thái ứng dụng và hiệu ứng hoạt ảnh.
              /// Việc thử nghiệm tại đây đảm bảo rằng các tương tác vuốt chạm luôn mang lại cảm giác mượt mà và tự nhiên nhất.
              AnimatedTapButtonBuilder(
                background: context.colorScheme.primaryContainer,
                child: Text(AppLocaleTranslate.dropRefreshControl.getString(context)),
                onTap: () {
                  // Hapit
                  Navigator.of(context).pushNamed(Routes.dropRefresh);
                },
              ),
              AnimatedTapButtonBuilder(
                background: context.colorScheme.primaryContainer,
                child: Text(AppLocaleTranslate.chatScreen.getString(context)),
                onTap: () {
                  // Hapit
                  Navigator.of(context).pushNamed(Routes.chatScreen);
                },
              ),
              AnimatedTapButtonBuilder(
                background: context.colorScheme.primaryContainer,
                child: const Text('AnimatedTapButtonBuilder'),
                onTap: () {
                  // Hapit
                  print('object');
                },
              ),
              TapDelayedPressedButton(
                padding: EdgeInsets.all(DeviceDimension.padding / 2),
                minPressedDuration: Duration(milliseconds: 200),
                inactiveColor: Colors.red,
                pressedColor: Colors.blue,
                child: const Text('TapDelayedPressedButton'),
              ),
              Skeletonizer(
                enabled: true,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.troubleShootingScreen);
                  },
                  child: Text(AppLocaleTranslate.troubleShootingScreen.getString(context)),
                ),
              ),

              /// Nhóm các thành phần giao diện đặc thù như widget trôi nổi và cấu trúc cây dữ liệu.
              /// Những thành phần này thường được sử dụng trong các tình huống quản lý dữ liệu phức tạp hoặc bảng điều khiển.
              /// Thử nghiệm giúp đảm bảo khả năng tổ chức thông tin phân cấp luôn rõ ràng và dễ tiếp cận.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.draggableExampleScreen);
                },
                child: Text(AppLocaleTranslate.floatingDraggableWidget.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.treeScreen);
                },
                child: Text(AppLocaleTranslate.treeNode.getString(context)),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.balanceBar);
                },
                child: Text(AppLocaleTranslate.balanceBar.getString(context)),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.segmented);
                },
                child: Text(AppLocaleTranslate.getPointIntoFileSvg.getString(context)),
              ),
              MaterialButton3.icon(
                fabIcon: Icons.close,
                onPressed: () {},
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.segmented);
                },
                child: Text(AppLocaleTranslate.segmented.getString(context)),
              ),

              /// Các công cụ hệ thống cơ bản như quét mã, chọn tệp và xem nhật ký hoạt động.
              /// Đây là những tiện ích thiết yếu phục vụ cho việc nhập liệu và theo dõi luồng vận hành của ứng dụng.
              /// Việc kiểm tra kỹ lưỡng giúp ngăn ngừa các lỗi liên quan đến quyền truy cập tệp và thiết bị ngoại vi.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.scanScreen);
                },
                child: Text(AppLocaleTranslate.scan.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pickFile);
                },
                child: Text(AppLocaleTranslate.pickFile.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.log);
                },
                child: Text(AppLocaleTranslate.log.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.talkerScreen);
                },
                child: const Text('Talker Logger (Advanced)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.menu);
                },
                child: Text(AppLocaleTranslate.sliderAppBar.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.notificationScrollScreen);
                },
                child: Text(AppLocaleTranslate.notificationScrollScreen.getString(context)),
              ),

              /// Các màn hình minh họa kỹ thuật lập trình nâng cao như Reducer, vẽ tùy chỉnh và đồ họa.
              /// Những ví dụ này đóng vai trò là tài liệu hướng dẫn về cách triển khai các hiệu ứng thị giác phức tạp.
              /// Nó cũng là nơi thử nghiệm hiệu năng của GPU khi xử lý các khung hình đồ họa mật độ cao.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.reducerScreen);
                },
                child: Text(AppLocaleTranslate.reducerScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.customPaintScreen);
                },
                child: Text(AppLocaleTranslate.customPaintScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.graphicsScreen);
                },
                child: Text(AppLocaleTranslate.graphicsScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.materialScreen);
                },
                child: Text(AppLocaleTranslate.material3UI.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.customScrollScreen);
                },
                child: Text(AppLocaleTranslate.customScrollScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.regexExampleScreen);
                },
                child: Text(AppLocaleTranslate.regexExampleScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.dragTargetScreen);
                },
                child: Text(AppLocaleTranslate.dragTargetScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.chart);
                },
                child: Text(AppLocaleTranslate.chartScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.refreshControl);
                },
                child: Text(AppLocaleTranslate.refreshControlScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.colorPicker);
                },
                child: Text(AppLocaleTranslate.colorPickerScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.arkit);
                },
                child: Text(AppLocaleTranslate.arKitScreen.getString(context)),
              ),

              /// Thành phần tìm kiếm và gợi ý dữ liệu tích hợp sẵn trong giao diện.
              /// Bộ công cụ này giúp người dùng dễ dàng lọc và truy cập thông tin nhanh chóng từ hàng nghìn bản ghi.
              /// Logic gợi ý được tối ưu hóa để đảm bảo tốc độ phản hồi ngay lập tức khi người dùng nhập thông tin.
              SearchBarBuilder(
                searchController: searchControler,
                childBuilder: (context, data) {
                  return ListTile(
                    title: Text(data),
                  );
                  // Row(
                  //   children: [
                  //     // Text(data),
                  //     ListTile(
                  //       title: Text(data),
                  //     ),
                  //     // Icon(Icons.access_alarm),
                  //   ],
                  // );
                },
                onSubmitted: (value) {
                  print(value);
                },
                onTapChildBuilder: (value) {
                  print(value);
                },
                // onTapChildBuilder: (va) {
                //   print('Tapped');
                // },
                getSuggestions: fetchSuggestions,
                onChanged: (value) {
                  print(value);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.setting);
                },
                child: Text('Test setting'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.animationScreen);
                },
                child: Text('Test Animation'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.materialSegmentedScreen);
                },
                child: Text(AppLocaleTranslate.segmented.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.silderVerticalScreen);
                },
                child: Text(AppLocaleTranslate.sliderAppBar.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.numberFormatScreen);
                },
                child: const Text('Number Format Screen'),
              ),
              TextButton(
                onPressed: () {
                  splitCodeString();
                },
                child: Text(AppLocaleTranslate.splitString.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pageThemeScreen);
                },
                child: Text(AppLocaleTranslate.testTheme.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.webBrowserScreen);
                },
                child: Text(AppLocaleTranslate.testWebBrowser.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.draggelScrollScreen);
                },
                child: Text(AppLocaleTranslate.testDraggelScrollScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pathProviderScreen);
                },
                child: const Text('path_provider_screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.openFileScreen);
                },
                child: Text(AppLocaleTranslate.openFile.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.cameraScreen);
                },
                child: Text(AppLocaleTranslate.testCamera.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pageLoadingScreen);
                },
                child: Text(AppLocaleTranslate.pageLoadingScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.snackBarScreen);
                },
                child: Text(AppLocaleTranslate.awesomeSnackBarExample.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.shimmerWidget);
                },
                child: Text(AppLocaleTranslate.testShimmerWidget.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.heroAnimationScreen);
                },
                child: Text(AppLocaleTranslate.heroAnimationScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.infoScreen);
                },
                child: Text(AppLocaleTranslate.hiveDemo.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.matixScreen);
                },
                child: Text(AppLocaleTranslate.matixScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.progressHudScreen);
                },
                child: Text(AppLocaleTranslate.progressHudScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.popoverScreen);
                },
                child: Text(AppLocaleTranslate.popoverClick.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.nesredScroll);
                },
                child: Text(AppLocaleTranslate.nestedScrollScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.courasel);
                },
                child: Text(AppLocaleTranslate.couraselScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.bmprogresshudScreen);
                },
                child: Text(AppLocaleTranslate.bmProgressHudScreen.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.intertiveviewScreen);
                },
                child: Text(AppLocaleTranslate.interactiveViewer.getString(context)),
              ),

              /// Các thành phần giao dịch đặc thù của Cupertino (iOS style).
              /// Những widget này giúp ứng dụng có giao diện nhất quán với nền tảng iOS.
              /// Việc thử nghiệm đảm bảo các hiệu ứng bóng mờ và thao tác vuốt hoạt động chính xác.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CupertinoSwitch'),
                    CupertinoSwitch(
                      value: switchValue,
                      onChanged: (bool value) {
                        setState(() {
                          switchValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showActionSheet(context);
                },
                child: Text(AppLocaleTranslate.cupertinoActionSheet.getString(context)),
              ),
              IconAnimationWidget(),
              TextButton(
                onPressed: () {
                  _showAlertDialog(context);
                },
                child: Text(AppLocaleTranslate.cupertinoAlertDialog.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.datetimePickerScreen);
                },
                child: Text(AppLocaleTranslate.dateTimePicker.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.dateTimeInput);
                },
                child: Text(AppLocaleTranslate.dateTimeInput.getString(context)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.calender);
                },
                child: Text(AppLocaleTranslate.calendar.getString(context)),
              ),
              AttributedStringWidget.text(
                message: "Attribute String Widget",
                texthighlight: "Widget",
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị một Action Sheet theo phong cách Cupertino để người dùng lựa chọn hành động.
  /// Đây là một thành phần UI quan trọng giúp tối ưu hóa không gian màn hình trên thiết bị di động.
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(AppLocaleTranslate.actionSheetTitle.getString(context)),
        message: Text(AppLocaleTranslate.actionSheetMessage.getString(context)),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocaleTranslate.actionSheetDefault.getString(context)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocaleTranslate.actionSheetAction.getString(context)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocaleTranslate.actionSheetDestructive.getString(context)),
          ),
        ],
      ),
    );
  }

  /// Hiển thị một hộp thoại cảnh báo (Alert Dialog) phong cách Cupertino.
  /// Hộp thoại này được sử dụng để xác nhận các hành động quan trọng của người dùng.
  /// Nó tuân thủ các nguyên tắc thiết kế Human Interface Guidelines của Apple.
  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(AppLocaleTranslate.alertDialogTitle.getString(context)),
        content: Text(AppLocaleTranslate.alertDialogContent.getString(context)),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocaleTranslate.no.getString(context)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocaleTranslate.yes.getString(context)),
          ),
        ],
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry A')),
            ),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[200],
            child: const Center(child: Text('Entry B')),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[300],
            child: const Center(child: Text('Entry C')),
          ),
        ],
      ),
    );
  }
}
