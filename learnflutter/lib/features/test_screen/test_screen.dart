// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:learnflutter/core/utils/device_dimension.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/shared/widgets/search_bar/page/search_bar_builder.dart';
import 'package:learnflutter/shared/components/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/shared/components/tap_builder/tap_delayed_pressed_button_builder.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/features/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';
import 'package:learnflutter/core/services/camera/model/camera_mode.dart';
import 'package:learnflutter/core/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/features/material/component/meterial_button_3/material_button_3.dart';
import 'package:mobimap_module/bridge/mobimap_module.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/app/localization/app_local_translate.dart';
import 'package:learnflutter/core/engines/engine_dialog/engine_dialog.dart';
import 'package:learnflutter/features/gift_coupon/gift_coupon_dialog.dart';

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
              const Text('✨ Monumental Habits Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.splashV1),
                      child: const Text('Splash'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.onboardingStep1),
                      child: const Text('Step 1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.onboardingStep2),
                      child: const Text('Step 2'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.onboardingStep3),
                      child: const Text('Step 3'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.onboardingPageView),
                      child: const Text('PageView'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.loginV1),
                      child: const Text('Login V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.registerV1),
                      child: const Text('Register V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.forgotPasswordV1),
                      child: const Text('Forgot Pw V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.homeV1),
                      child: const Text('Home V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.settingsV1),
                      child: const Text('Settings V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.addHabitV1),
                      child: const Text('Add Habit V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.coursesV1),
                      child: const Text('Courses V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.communityV1),
                      child: const Text('Community V1'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        Routes.habitDetailsV1,
                        arguments: {'habitName': 'Read Books'},
                      ),
                      child: const Text('Habit Details V1'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const _FeatureCard(
                title: 'Global No-Keyboard Rebuild',
                description: 'Tránh rebuild toàn cây khi keyboard show/hide — fix layout shift.',
                routeName: Routes.newLogin,
                accent: Color(0xFF0D9488),
              ),
              const _FeatureCard(
                title: 'Camerawesome',
                description: 'Camera nâng cao với camerawesome package — control filter / focus.',
                routeName: Routes.camerawesome,
                accent: Color(0xFF7C3AED),
              ),

              /// [TextButton] điều hướng tới [CameraScreen] mới với đầy đủ tính năng zoom và 2 chế độ.
              /// Callback [onPhotoCaptured] nhận [XFile] ảnh để xử lý theo nghiệp vụ của màn hình gọi.
              /// Đây là ví dụ minh hoạ cách tái sử dụng [CameraScreen] từ bất kỳ màn hình nào.
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.cameraScreen,
                    arguments: {
                      'initialMode': CameraMode.photo,
                      'onPhotoCaptured': (XFile file) {
                        debugPrint('📸 Ảnh đã chụp: ${file.path}');
                      },
                      'onVideoRecorded': (XFile file) {
                        debugPrint('🎬 Video đã quay: ${file.path}');
                      },
                      'minZoom': 1,
                      'maxZoom': 5,
                      'maxLength': 5,
                    },
                  );
                },
                child: const Text('Camera Screen (Zoom + Photo/Video)'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.cameraScreen,
                    arguments: {
                      'initialMode': CameraMode.photo,
                      'modes': [CameraMode.photo],
                      'onPhotoCaptured': (XFile file) {
                        debugPrint('📸 Ảnh chụp chế độ Photo Only: ${file.path}');
                      },
                      'minZoom': 1,
                      'maxZoom': 3,
                    },
                  );
                },
                child: const Text('📷 Camera Screen (Photo Only - Hide Mode Selector)'),
              ),
              const _FeatureCard(
                title: 'AR Kit (3D Model Overlay)',
                description: 'Overlay model 3D lên camera dùng ARKit.',
                routeName: Routes.arkit,
                accent: Color(0xFF7C3AED),
              ),
              const _FeatureCard(
                title: 'LiDAR Scanner',
                description: 'Quét môi trường 3D bằng LiDAR (iPhone Pro).',
                routeName: Routes.lidarScanner,
                accent: Color(0xFF7C3AED),
              ),

              const _FeatureCard(
                title: 'Photo 3D Viewer (Album)',
                description: 'Xem ảnh dưới dạng 3D với hiệu ứng parallax / depth map.',
                routeName: Routes.photo3D,
                accent: Color(0xFF9333EA),
              ),
              const _FeatureCard(
                title: 'Sliver Animation System',
                description: 'Hệ thống animation tái sử dụng dựa trên Sliver — scroll mượt 60fps.',
                routeName: Routes.sliverAnimationDemo,
                accent: Color(0xFFFF80AB),
              ),
              const _FeatureCard(
                title: '60FPS Guaranteed (Zero Rebuild)',
                description: 'Kỹ thuật loại bỏ rebuild thừa, đảm bảo 60fps trên list lớn.',
                routeName: Routes.fpsGuaranteedDemo,
                accent: Color(0xFF16A34A),
              ),
              const _FeatureCard(
                title: 'TikTok Viewport Animation (PRO)',
                description: 'Animation theo viewport kiểu TikTok — scale/opacity phần tử khi vào khung hình.',
                routeName: Routes.tiktokAnimationDemo,
                accent: Color(0xFFFF6584),
              ),
              const _FeatureCard(
                title: 'Core Anim Playground',
                description: 'Effects + Timeline presets + Full List (swipe/pin/collapse) trong 1 màn hình.',
                routeName: Routes.coreAnimPlayground,
                accent: Color(0xFF6C63FF),
              ),
              const _FeatureCard(
                title: 'Particle Engine',
                description: 'Fire / Snow / Sparkle / Explosion — zero-alloc pool + RenderBox paint.',
                routeName: Routes.particleEngineDemo,
                accent: Color(0xFFFF6B35),
              ),
              const _FeatureCard(
                title: 'Network Module Demo',
                description: 'REST + NetworkQueue + GraphQL trong 1 màn hình.',
                routeName: Routes.networkDemo,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Pagination System (TikTok Style)',
                description: 'Phân trang vô tận theo style TikTok với preload và snap.',
                routeName: Routes.paginationDemo,
                accent: Color(0xFF00B8D4),
              ),
              const _FeatureCard(
                title: 'Engine Dialog System',
                description: 'Hệ thống dialog chuẩn: Info / Error / Success / Warning, dùng chung toàn app.',
                routeName: Routes.engineDialogDemo,
                accent: Color(0xFF9333EA),
              ),
              const _FeatureCard(
                title: '💡 Engine Stepper / Pagination (Premium)',
                description: 'Stepper + pagination engine cao cấp, animation seamless.',
                routeName: Routes.appStepperDemo,
                accent: Color(0xFFEA580C),
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
                  AppDialogEngine.showUpdatePatch(
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
                  AppDialogEngine.showUpdatePatch(
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
                  AppDialogEngine.showUpdatePatch(
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
              const _FeatureCard(
                title: 'Color Picker',
                description: 'Chọn màu với HSV / RGB / Hex preview.',
                routeName: Routes.colorPicker,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'Calendar Picker Test',
                description: 'Kiểm thử các chế độ chọn ngày của component CalendarPicker: single, multi, range.',
                routeName: Routes.calendarPickerTest,
                accent: Color(0xFF2563EB),
              ),
              const _FeatureCard(
                title: 'Notification Center',
                description: 'Pub/sub event bus trong app — subscribe / post / unsubscribe + log realtime.',
                routeName: Routes.notificationCenterTest,
                accent: Color(0xFF7C3AED),
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

              const _FeatureCard(
                title: 'Scroll Physic',
                description: 'Custom ScrollPhysics — tuỳ chỉnh ma sát / bounce / snap.',
                routeName: Routes.scrollPhysicScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Indicator Example',
                description: 'Các kiểu page indicator: dots, line, worm, animated.',
                routeName: Routes.indicatorExampleScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'PMS SDK Login',
                description: 'Plugin nghiệm thu PMS — flow login + signature.',
                routeName: Routes.pmsSDKLogin,
                accent: Color(0xFF0D9488),
              ),
              const _FeatureCard(
                title: 'Flutter 3D Screen',
                description: 'Render mô hình 3D (.glb/.obj) trực tiếp trong Flutter.',
                routeName: Routes.flutter3dScreen,
                accent: Color(0xFF7C3AED),
              ),
              const _FeatureCard(
                title: 'Visibility Detector',
                description: 'Detect widget có đang visible trong viewport hay không.',
                routeName: Routes.visibilityDetectorExample,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Login Screen',
                description: 'Màn hình đăng nhập chuẩn (legacy).',
                routeName: Routes.login,
                accent: Color(0xFF0D9488),
              ),
              const _FeatureCard(
                title: 'Excel File Worker',
                description: 'Đọc/ghi file Excel (.xlsx) bằng Dart thuần.',
                routeName: Routes.excellScreen,
                accent: Color(0xFF16A34A),
              ),
              const _FeatureCard(
                title: 'QR Scanner',
                description: 'Quét mã QR qua camera, decode realtime.',
                routeName: Routes.qrScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'QR Overlays Demo',
                description: 'Preview tất cả overlay quét QR/CCCD trên nền giả camera.',
                routeName: Routes.qrOverlaysDemoScreen,
                accent: Color(0xFF8B5CF6),
              ),
              const _FeatureCard(
                title: '🎨 Engine Rendering (Custom Layer)',
                description: 'Canvas layer engine — background/glow/orbit/starfield, không rebuild widget.',
                routeName: Routes.engineRenderingDemoScreen,
                accent: Color(0xFF8B5CF6),
              ),
              const _FeatureCard(
                title: '🪟 Engine Viewport Transform',
                description: 'Pipeline scale/blur/opacity/rotation/parallax theo vị trí item trong viewport.',
                routeName: Routes.engineViewportTransformDemoScreen,
                accent: Color(0xFF06B6D4),
              ),
              const _FeatureCard(
                title: '⌨️ KeyboardTextField (Toolbar + Counter)',
                description: 'TextField hiển thị toolbar trên keyboard, counter ký tự bên phải, fully customizable.',
                routeName: Routes.keyboardTextFieldDemoScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Tap Builder Demo',
                description: 'AnimatedTapButton 3D + TapDelayedPressedButton.',
                routeName: Routes.tapBuilderDemoScreen,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'Luxury Card Stack Demo',
                description: 'Stack thẻ swipe vật lý kiểu Tinder/Apple Card.',
                routeName: Routes.luxuryCardStackDemoScreen,
                accent: Color(0xFF0EA5E9),
              ),
              //       TextButton(
              //         onPressed: () {
              //           Navigator.of(context).pushNamed(Routes.webViewScreen);
              //         },
              //         child: Text('Open WebView'),
              //       ),
              const _FeatureCard(
                title: 'Tic Tac Toe Game (Flame)',
                description: 'Game cờ caro mini built with Flame engine.',
                routeName: Routes.ticTacToeGame,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Rubik 2D Challenge (Flame)',
                description: 'Mini-game Rubik 2D — sort màu theo cột/hàng.',
                routeName: Routes.rubikGame,
                accent: Color(0xFFEAB308),
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
              const _FeatureCard(
                title: 'Transformer PageView',
                description: 'PageView với hiệu ứng 3D transform khi vuốt giữa các trang.',
                routeName: Routes.transformerPageView,
                accent: Color(0xFF9333EA),
              ),

              /// Nhóm các nút chức năng hỗ trợ việc tải dữ liệu và tương tác bản đồ.
              /// Các thành phần này giúp kiểm tra khả năng phản hồi của giao diện khi xử lý khối lượng dữ liệu lớn.
              /// Đồng thời, nó cũng xác nhận tính ổn định của các dịch vụ định vị và hiển thị bản đồ địa lý.
              const _FeatureCard(
                title: 'Smart Load More',
                description: 'List với loading thông minh: pull-to-refresh + load more khi cuộn cuối.',
                routeName: Routes.smartLoadmoreScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Multi-Domain News Demo',
                description: 'Aggregate tin tức từ nhiều domain, parse RSS/HTML.',
                routeName: Routes.newsScreen,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Test New Login Module',
                description: 'Module login mới được tách package — verify auth flow.',
                routeName: Routes.newLogin,
                accent: Color(0xFF0D9488),
              ),
              const _FeatureCard(
                title: 'Isolate Parse Data',
                description: 'Parse JSON khối lượng lớn trong Isolate, không block UI.',
                routeName: Routes.isolateParseScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Vietnam Map',
                description: 'Bản đồ Việt Nam tuỳ biến — vẽ vùng địa lý.',
                routeName: Routes.mapScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Flutter Map Example (OSM)',
                description: 'flutter_map với OpenStreetMap, marker và polyline.',
                routeName: Routes.exampleMapScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Offline MBTiles Map',
                description: 'Render bản đồ từ file MBTiles offline, không cần mạng.',
                routeName: Routes.offlineMbtilesMapScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Google Map Base (Custom UI)',
                description: 'Google Map với UI/control tuỳ biến phong cách riêng.',
                routeName: Routes.googleMapBase,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Google Map Offline Pin (Hive)',
                description: 'Lưu marker offline qua Hive, sync khi có mạng trở lại.',
                routeName: Routes.googleMapOffline,
                accent: Color(0xFF16A34A),
              ),
              const _FeatureCard(
                title: '🔥 Google Map Engine Demo',
                description: 'Auto Cluster + parse polygon trong Isolate — render 60fps trên data lớn.',
                routeName: Routes.googleMapEngineDemo,
                accent: Color(0xFFEF4444),
              ),
              const _FeatureCard(
                title: '⚙️ Queue Engine Dashboard',
                description: 'Dashboard quản lý queue task: retry / concurrency / priority.',
                routeName: Routes.queueEngineDemo,
                accent: Color(0xFF818CF8),
              ),
              const _FeatureCard(
                title: '🌐 Network Queue',
                description: 'API queue tự động retry & sync khi mất kết nối — không mất request.',
                routeName: Routes.networkQueueDemo,
                accent: Color(0xFF2DD4BF),
              ),
              const _FeatureCard(
                title: '🔔 Local Notification',
                description: 'Service notification cục bộ + custom in-app banner widget.',
                routeName: Routes.localNotificationDemo,
                accent: Color(0xFFFCD34D),
              ),
              const _FeatureCard(
                title: '🎨 Widgets Gallery',
                description: 'Tổng hợp các widget trong shared/widgets — test trực quan.',
                routeName: Routes.widgetsGalleryDemo,
                accent: Color(0xFFA78BFA),
              ),
              const _FeatureCard(
                title: '✨ Shimmer Demo',
                description: 'Skeleton loading: Box / ListTile / Card + flow gọi API thật.',
                routeName: Routes.shimmerDemo,
                accent: Color(0xFF94A3B8),
              ),
              const _FeatureCard(
                title: 'Flutter Map OSM',
                description: 'Demo flutter_map với tile OSM cơ bản.',
                routeName: Routes.flutterMapOsmScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Street View 360 (WebView)',
                description: 'Nhúng Street View 360° qua WebView.',
                routeName: Routes.streetViewScreen,
                accent: Color(0xFF0EA5E9),
              ),
              TextButton(
                onPressed: () {
                  // Rule 1: Chạy PMS ngầm, thành công mới hiện popup
                  GiftCouponDialog.startFlow();
                },
                child: const Text('🎁 [Rule] PMS Success -> Show Inside Popup'),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: const Color(0xFF80FFAD)).animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad).slide(),
              TextButton(
                onPressed: () {
                  // Rule 2: Đã có mã PMS, hiện popup và tập trung ngay vào Inside
                  GiftCouponDialog.showAction();
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
              const _FeatureCard(
                title: 'Floating Draggable Widget',
                description: 'Widget nổi có thể kéo thả khắp màn hình (FAB tuỳ chỉnh).',
                routeName: Routes.draggableExampleScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Tree Node View',
                description: 'Cây dữ liệu phân cấp, expand/collapse, drag-reorder.',
                routeName: Routes.treeScreen,
                accent: Color(0xFF16A34A),
              ),

              const _FeatureCard(
                title: 'Balance Bar',
                description: 'Thanh hiển thị tỉ lệ cân đối (positive/negative).',
                routeName: Routes.balanceBar,
                accent: Color(0xFF0D9488),
              ),

              const _FeatureCard(
                title: 'Get Point Into File SVG',
                description: 'Extract toạ độ điểm từ file SVG để inject lên map.',
                routeName: Routes.segmented,
                accent: Color(0xFFEAB308),
              ),
              MaterialButton3.icon(
                fabIcon: Icons.close,
                onPressed: () {},
              ),

              const _FeatureCard(
                title: 'Segmented Control',
                description: 'Cupertino segmented switch / tab inline kiểu iOS.',
                routeName: Routes.segmented,
                accent: Color(0xFF6366F1),
              ),

              /// Các công cụ hệ thống cơ bản như quét mã, chọn tệp và xem nhật ký hoạt động.
              /// Đây là những tiện ích thiết yếu phục vụ cho việc nhập liệu và theo dõi luồng vận hành của ứng dụng.
              /// Việc kiểm tra kỹ lưỡng giúp ngăn ngừa các lỗi liên quan đến quyền truy cập tệp và thiết bị ngoại vi.
              const _FeatureCard(
                title: 'Scan Screen',
                description: 'Màn hình quét code chung — gateway cho các loại scanner.',
                routeName: Routes.scanScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Pick File',
                description: 'Chọn file từ device qua file_picker, đa dạng định dạng.',
                routeName: Routes.pickFile,
                accent: Color(0xFF16A34A),
              ),
              const _FeatureCard(
                title: 'Log Viewer',
                description: 'Xem log nội bộ của app, filter theo level.',
                routeName: Routes.log,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Talker Logger (Advanced)',
                description: 'Logger nâng cao với Talker — log HTTP / Bloc / Error / Custom.',
                routeName: Routes.talkerScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Slider AppBar Menu',
                description: 'AppBar trượt + menu drawer tuỳ biến.',
                routeName: Routes.menu,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Notification Scroll',
                description: 'List thông báo với scroll-to-load và mark-as-read.',
                routeName: Routes.notificationScrollScreen,
                accent: Color(0xFFEAB308),
              ),

              /// Các màn hình minh họa kỹ thuật lập trình nâng cao như Reducer, vẽ tùy chỉnh và đồ họa.
              /// Những ví dụ này đóng vai trò là tài liệu hướng dẫn về cách triển khai các hiệu ứng thị giác phức tạp.
              /// Nó cũng là nơi thử nghiệm hiệu năng của GPU khi xử lý các khung hình đồ họa mật độ cao.
              const _FeatureCard(
                title: 'Reducer Screen',
                description: 'State management dạng Reducer (Redux-like), action → state.',
                routeName: Routes.reducerScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Custom Paint',
                description: 'Vẽ custom shape bằng CustomPainter — path, gradient, blob.',
                routeName: Routes.customPaintScreen,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'Graphics Screen',
                description: 'GPU graphics test — vẽ frame mật độ cao.',
                routeName: Routes.graphicsScreen,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'Material 3 UI',
                description: 'Showcase các component Material 3 — Card, Chip, Button mới.',
                routeName: Routes.materialScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Custom Scroll',
                description: 'CustomScrollView với Sliver — flexible header, sticky.',
                routeName: Routes.customScrollScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Regex Example',
                description: 'Playground test regex patterns realtime.',
                routeName: Routes.regexExampleScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Drag Target',
                description: 'DragTarget + Draggable — kéo thả widget giữa các vùng.',
                routeName: Routes.dragTargetScreen,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Chart Screen',
                description: 'Biểu đồ dạng line / bar / pie với data động.',
                routeName: Routes.chart,
                accent: Color(0xFF0D9488),
              ),
              const _FeatureCard(
                title: 'Refresh Control',
                description: 'Pull-to-refresh custom với indicator riêng.',
                routeName: Routes.refreshControl,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Color Picker (alt)',
                description: 'Bản color picker khác — duplicate cho test compare.',
                routeName: Routes.colorPicker,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'ARKit Screen',
                description: 'ARKit screen tổng quát — placement model trong không gian thực.',
                routeName: Routes.arkit,
                accent: Color(0xFF7C3AED),
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
              const _FeatureCard(
                title: 'Settings',
                description: 'Màn hình settings tổng — theme, language, notifications.',
                routeName: Routes.setting,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Animation Playground',
                description: 'Tổng hợp các animation cơ bản: tween / curve / staggered.',
                routeName: Routes.animationScreen,
                accent: Color(0xFF9333EA),
              ),
              const _FeatureCard(
                title: 'Material Segmented',
                description: 'Segmented control kiểu Material 3.',
                routeName: Routes.materialSegmentedScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Slider Vertical',
                description: 'Slider chiều dọc tuỳ chỉnh, hữu ích cho volume/brightness.',
                routeName: Routes.silderVerticalScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Number Format',
                description: 'Format số: tiền tệ, %, separator, masking input.',
                routeName: Routes.numberFormatScreen,
                accent: Color(0xFF0D9488),
              ),
              TextButton(
                onPressed: () {
                  splitCodeString();
                },
                child: Text(AppLocaleTranslate.splitString.getString(context)),
              ),
              const _FeatureCard(
                title: 'Page Theme',
                description: 'Test dynamic theme — dark/light, primary swap runtime.',
                routeName: Routes.pageThemeScreen,
                accent: Color(0xFF7C3AED),
              ),
              const _FeatureCard(
                title: 'Web Browser',
                description: 'In-app WebView browser với navigation controls.',
                routeName: Routes.webBrowserScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Draggable Scroll',
                description: 'DraggableScrollableSheet — bottom sheet kéo lên xuống.',
                routeName: Routes.draggelScrollScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Path Provider',
                description: 'Truy cập thư mục hệ thống: documents / cache / temporary.',
                routeName: Routes.pathProviderScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Open File',
                description: 'Mở file ngoài app bằng intent của hệ điều hành.',
                routeName: Routes.openFileScreen,
                accent: Color(0xFF16A34A),
              ),
              const _FeatureCard(
                title: 'Test Camera',
                description: 'Camera screen mặc định — preview + chụp ảnh cơ bản.',
                routeName: Routes.cameraScreen,
                accent: Color(0xFF7C3AED),
              ),
              const _FeatureCard(
                title: 'Page Loading',
                description: 'Các pattern loading: skeleton / spinner / shimmer overlay.',
                routeName: Routes.pageLoadingScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Awesome SnackBar',
                description: 'Snackbar đẹp với icon + color theo type (info/success/error).',
                routeName: Routes.snackBarScreen,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Shimmer Widget (legacy)',
                description: 'Shimmer cũ trước khi tách thành component riêng.',
                routeName: Routes.shimmerWidget,
                accent: Color(0xFF94A3B8),
              ),
              const _FeatureCard(
                title: 'Base Shimmer Test',
                description: 'Test BaseShimmerBuilder + ShimmerBox/Tile/Card.',
                routeName: Routes.shimmerBaseTest,
                accent: Color(0xFF94A3B8),
              ),
              const _FeatureCard(
                title: 'Hero Animation',
                description: 'Hero transition giữa các route — shared element.',
                routeName: Routes.heroAnimationScreen,
                accent: Color(0xFFEC4899),
              ),
              const _FeatureCard(
                title: 'Hive Demo',
                description: 'Lưu trữ local với Hive — box, type adapter.',
                routeName: Routes.infoScreen,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'Matrix Screen',
                description: 'Transform Matrix4 — translate / rotate / scale / perspective.',
                routeName: Routes.matixScreen,
                accent: Color(0xFF9333EA),
              ),
              const _FeatureCard(
                title: 'Progress Hud',
                description: 'Loading HUD overlay toàn màn hình kiểu MBProgressHUD.',
                routeName: Routes.progressHudScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Popover Click',
                description: 'Popover hiển thị bên cạnh element được click — kiểu macOS.',
                routeName: Routes.popoverScreen,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Nested Scroll',
                description: 'NestedScrollView với SliverAppBar + TabBar content.',
                routeName: Routes.nesredScroll,
                accent: Color(0xFF6366F1),
              ),
              const _FeatureCard(
                title: 'Carousel',
                description: 'Slider ảnh tự động chuyển, indicator + zoom hover.',
                routeName: Routes.courasel,
                accent: Color(0xFFEAB308),
              ),
              const _FeatureCard(
                title: 'BM Progress HUD',
                description: 'Modal progress HUD với nhiều style loading.',
                routeName: Routes.bmprogresshudScreen,
                accent: Color(0xFF6B7280),
              ),
              const _FeatureCard(
                title: 'Interactive Viewer',
                description: 'Zoom & pan với InteractiveViewer — ảnh / pdf / canvas.',
                routeName: Routes.intertiveviewScreen,
                accent: Color(0xFF7C3AED),
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
              const _FeatureCard(
                title: 'DateTime Picker',
                description: 'Picker chọn ngày giờ — Cupertino + Material style.',
                routeName: Routes.datetimePickerScreen,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'DateTime Input',
                description: 'Text input có mask DD/MM/YYYY HH:mm, auto-format.',
                routeName: Routes.dateTimeInput,
                accent: Color(0xFF0EA5E9),
              ),
              const _FeatureCard(
                title: 'Calendar',
                description: 'Calendar tháng / tuần với event highlight.',
                routeName: Routes.calender,
                accent: Color(0xFF0EA5E9),
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

/// Card hiển thị mỗi tính năng demo trong [TestScreen].
///
/// Thay cho các [TextButton] đơn giản chỉ điều hướng route — card cung cấp
/// title rõ ràng + description ngắn giúp dev nhanh chóng nhận biết chức năng
/// mà không phải đọc tên route.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.routeName,
    this.icon = Icons.arrow_forward_ios_rounded,
    this.accent = const Color(0xFF2563EB),
  });

  final String title;
  final String description;
  final String routeName;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamed(routeName),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_awesome, color: accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
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
