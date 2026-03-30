// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/app/app_root.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/shared/widgets/search_bar/cubit/search_bar_cubit.dart';
import 'package:learnflutter/core/keyboard/global_nokeyboard_rebuild.dart';
import 'package:learnflutter/core/keyboard/keyboard_service.dart';
import 'package:learnflutter/data/local/hive_demo/model/person.dart';
import 'package:learnflutter/core/constants/define_constraint.dart';
import 'package:learnflutter/core/app/app_theme.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';
import 'package:learnflutter/features/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/features/setting/state/setting_state.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:notification_center/notification_center.dart';
import 'package:learnflutter/core/network/api_client/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';
import 'package:learnflutter/core/service/log/log_file_service.dart';
import 'package:learnflutter/core/service/log/daily_log_scheduler.dart';
import 'package:learnflutter/core/service/log/log_google_chat.dart';
// import 'package:shorebird/shorebird.dart';

/// Hàm main đóng vai trò là điểm khởi đầu chính thức cho toàn bộ vòng đời của ứng dụng Flutter.
/// Tại đây, chúng tôi thực hiện việc đảm bảo các ràng buộc giao diện được khởi tạo chính xác, thiết lập dịch vụ giám sát bàn phím và khởi động các thông số cấu hình hệ thống.
/// Quá trình này bao gồm cả việc chuẩn bị cơ sở dữ liệu Hive, cấu hình trình khách API và thiết lập trình bao bọc ngăn chặn việc vẽ lại giao diện không cần thiết khi bàn phím xuất hiện.
/// Việc tuân thủ cấu trúc này giúp tách biệt rõ ràng giữa giai đoạn chuẩn bị tài nguyên và giai đoạn hiển thị giao diện người dùng chính thức.
void main() {
  /// Cơ chế WidgetsFlutterBinding.ensureInitialized được kích hoạt đầu tiên để đảm bảo rằng các ràng buộc của framework Flutter đã được thiết lập thành công trước khi truy cập bất kỳ tài nguyên nào của nền tảng.
  /// Ngay sau đó, dịch vụ KeyboardService toàn cục được khởi động để bắt đầu giám sát trạng thái hiển thị của bàn phím trên thiết bị thực tế.
  /// Việc khởi tạo sớm này giúp ứng dụng có thể xử lý chính xác các sự kiện hệ thống và chuẩn bị một môi trường vận hành ổn định cho các thành phần UI phía sau.
  /// Đây là một bước chuẩn bị bắt buộc nhằm tránh các lỗi tiềm ẩn khi ứng dụng cố gắng giao tiếp với các dịch vụ cấp thấp của hệ điều hành.
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Workmanager cho các task chạy ngầm (như gửi log định kỳ)
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode, // Đặt false khi release
  );

  /// Khởi động keyboard listener service toàn cục nhằm mục đích theo dõi và phản hồi linh hoạt với mọi sự kiện đóng hoặc mở bàn phím từ phía người dùng.
  /// Dịch vụ này đóng vai trò then chốt trong việc điều phối giao diện, giúp ngăn chặn các vấn đề về hiển thị hoặc che lấp thông tin quan trọng.
  /// Thông qua việc lắng nghe liên tục, ứng dụng có thể tự động điều chỉnh khoảng trống hoặc ẩn bàn phím khi cần thiết để tối ưu hóa trải nghiệm người dùng.
  KeyboardService.instance.start();

  // Khởi tạo app configuration và dependencies
  AppConfig.init(
    () async {
      /// Tiến hành khởi tạo cơ sở dữ liệu Hive cho nền tảng di động nhằm thiết lập một hệ thống lưu trữ dữ liệu cục bộ hiệu quả và tốc độ cao.
      /// Quá trình này bao gồm việc đăng ký các adapter chuyển đổi dữ liệu để đảm bảo các đối tượng logic có thể được chuyển đổi chính xác sang định dạng nhị phân.
      /// Sau khi cấu hình hoàn tất, một vùng chứa dữ liệu (Box) sẽ được mở ra để sẵn sàng phục vụ cho các tác vụ lưu trữ và truy xuất thông tin người dùng.
      await Hive.initFlutter();
      Hive.registerAdapter(PersonAdapter());
      await Hive.openBox('peopleBox');

      // Initialize ApiClient with base URL and optional token refresh handler
      ApiClient.instance.init(
        baseUrl: 'https://apis-stag.fpt.vn',
        tokenRefreshHandler: () async {
          try {
            // Example refresh flow: read refresh token from SharedPreferences, call refresh endpoint
            final refreshToken = SharedPreferenceUtils.prefs.getString('refresh_token');
            if (refreshToken == null) return null;
            final resp = await ApiClient.instance.post('/auth/refresh', data: {'refreshToken': refreshToken});
            final newToken = resp['accessToken'] ?? resp['token'];
            if (newToken != null && newToken is String) {
              ApiClient.instance.setAuthToken(newToken);
              return newToken;
            }
          } catch (_) {}
          return null;
        },
      );

      /// Ứng dụng được khởi chạy chính thức thông qua trình bao bọc GlobalNoKeyboardRebuild để quản trị tối ưu cơ chế vẽ lại giao diện.
      /// Lớp bao bọc này thực hiện nhiệm vụ quan trọng là ngăn chặn việc xây dựng lại toàn bộ cây widget một cách không cần thiết mỗi khi bàn phím xuất hiện.
      /// Bằng việc thiết lập thời gian hoạt họa và các khoảng đệm phù hợp, nó giúp duy trì sự ổn định về mặt thị giác và nâng cao hiệu suất tổng thể cho thiết bị.
      runApp(GlobalNoKeyboardRebuild(
        addBottomPadding: true,
        animationDurationMs: 50,
        child: MyApp(),
      ));
    },
  );
}

/// Các hằng số khóa tác vụ nền được sử dụng để định danh duy nhất các công việc cần thực hiện thông qua WorkManager.
/// Mỗi khóa tương ứng với một loại logic nghiệp vụ cụ thể như gửi thông báo đẩy, đồng bộ hóa dữ liệu định kỳ hoặc xử lý các tệp tin lớn trong nền.
/// Việc tập trung các khóa này tại một nơi giúp ngăn chặn sự nhầm lẫn giữa các tác vụ và hỗ trợ việc bảo trì điều phối các luồng xử lý nền trở nên dễ dàng hơn.
const String simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const String rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const String failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const String simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const String simplePeriodicTask = "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const String simplePeriodic1HourTask = "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

/// Hàm callbackDispatcher đóng vai trò là trình điều phối các tác vụ chạy ngầm được gọi trực tiếp bởi hệ điều hành thông qua WorkManager.
/// Nó được đánh dấu với chỉ thị vm:entry-point để đảm bảo trình biên dịch không loại bỏ trong quá trình tối ưu hóa mã nguồn.
/// Hàm này lắng nghe các sự kiện tác vụ, phân tích khóa định danh và kích hoạt các hàm xử lý tương ứng để hoàn thành công việc mà không cần giao diện người dùng.
/// Đây là giải pháp quan trọng để thực hiện các công việc như cập nhật bộ đếm, gửi thông báo hoặc xử lý nền trên cả hai nền tảng Android và iOS.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        // Chạy simple task: in log và gửi notification
        print("$simpleTaskKey was executed. inputData = $inputData");
        NotificationCenter().notify('updateCounter');
        break;
      case rescheduledTaskKey:
        // Check xem task đã chạy trước đó không
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          // Lần đầu chạy, reschedule task
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        // Task này luôn fail để test error handling
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        // Delayed task: Chạy sau một delay nào đó
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        // Periodic task: Chạy theo interval định kỳ
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        // Periodic task chạy mỗi giờ
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        // iOS background fetch: Gọi khi iOS trigger background refresh
        stderr.writeln("The iOS background fetch was triggered");
        break;

      // Task gửi log định kỳ hằng ngày hoặc manual trigger
      case DailyLogScheduler.taskNameDaily:
      case DailyLogScheduler.taskNameOneShot:
        try {
          // 1. Lấy file log mới nhất đã được persist từ trước
          final file = await LogFileService.getLatestLogFile();
          if (file != null) {
            // 2. Gửi file log qua Google Chat
            final success = await LogGoogleChat.sendLogFile(file, title: '📬 Background Log Report');
            if (success) {
              // 3. Nếu gửi xong thành công, dọn dẹp log cũ (giữ 7 ngày)
              await LogFileService.clearOldLogFiles();
            }
            return success;
          }
        } catch (e) {
          stderr.writeln("Log background task failed: $e");
          return false;
        }
        break;
    }
    return Future.value(true);
  });
}

/// Lớp MyApp đóng vai trò là Widget gốc của toàn bộ hệ thống phân cấp ứng dụng Flutter.
/// Nó chịu trách nhiệm cấu hình các thành phần quan trọng ở cấp độ cao nhất như hệ thống theme động, các BlocProviders toàn cục và cơ chế định tuyến.
/// Thông qua lớp này, ứng dụng có thể lắng nghe các thay đổi về cấu hình người dùng và tự động cập nhật lại toàn bộ giao diện một cách đồng nhất.
/// Việc tổ chức MyApp như một lớp điều phối giúp duy trì tính mạch lạc giữa các lớp dịch vụ nền và các thành phần hiển thị phía dưới.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Lớp _MyAppState quản lý trạng thái vòng đời và các thiết lập đa ngôn ngữ cho widget MyApp.
/// Nó thực hiện việc khởi tạo dịch vụ FlutterLocalization và đăng ký các bản đồ ngôn ngữ cho tiếng Anh, tiếng Khmer, tiếng Nhật và tiếng Việt.
/// Khi có sự thay đổi về ngôn ngữ hiển thị do người dùng lựa chọn, lớp này sẽ kích hoạt việc vẽ lại toàn bộ ứng dụng để áp dụng các bản dịch mới.
/// Đây là nơi tập trung các logic liên quan đến việc bản địa hóa và đảm bảo trải nghiệm người dùng mượt mà trên nhiều vùng quốc gia khác nhau.
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// Thuộc tính _localization là một thực thể thuộc lớp FlutterLocalization được sử dụng để quản lý toàn bộ cơ chế đa ngôn ngữ của ứng dụng.
  /// Nó đóng vai trò là hạt nhân trung tâm giúp chuyển đổi các chuỗi văn bản giữa nhiều ngôn ngữ khác nhau dựa trên cấu hình của người dùng.
  /// Dịch vụ này cung cấp các tính năng từ việc khởi tạo các bản đồ ngôn ngữ cho đến việc xử lý các sự kiện thay đổi ngôn ngữ trong thời gian thực.
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Khi app chuyển sang trạng thái paused (xuống background)
    // Tự động lưu log từ RAM ra file vật lý để background task có dữ liệu mới nhất.
    if (state == AppLifecycleState.paused) {
      AppTalker.saveHistoryToFile();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Khôi phục lịch gửi log nếu user đã bật trước đó
    DailyLogScheduler.restoreIfEnabled();

    /// Hệ thống localization được khởi tạo đồng thời với việc định nghĩa các mã ngôn ngữ và các bản đồ dịch thuật tương ứng cho từng vùng quốc gia.
    /// Chúng tôi thiết lập tiếng Việt làm ngôn ngữ mặc định khi ứng dụng bắt đầu khởi chạy để tối ưu hóa trải nghiệm cho nhóm đối tượng người dùng chính.
    /// Một bộ lắng nghe sự kiện (listener) cũng được đăng ký để đảm bảo giao diện luôn được cập nhật đồng nhất ngay sau khi người dùng thực hiện thay đổi ngôn ngữ.
    /// Quá trình này giúp nâng cáp tính cá nhân hóa và sự chuyên nghiệp của ứng dụng trên thị trường quốc tế với sự hỗ trợ đa dạng về mặt văn hóa và ngôn ngữ.
    _localization.init(
      mapLocales: [
        const MapLocale(
          'en',
          AppLocaleTranslate.EN,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        const MapLocale(
          'km',
          AppLocaleTranslate.KM,
          countryCode: 'KH',
          fontFamily: 'Font KM',
        ),
        const MapLocale(
          'ja',
          AppLocaleTranslate.JA,
          countryCode: 'JP',
          fontFamily: 'Font JA',
        ),
        const MapLocale(
          'vi',
          AppLocaleTranslate.VI,
          countryCode: 'VI',
          fontFamily: 'Font JA',
        ),
      ],
      initLanguageCode: 'vi',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
  }

  /// _onTranslatedLanguage - Callback khi language thay đổi
  ///
  /// Phương thức này được gọi khi user chọn language khác.
  /// setState() sẽ trigger rebuild toàn bộ MyApp widget tree,
  /// dẫn tới tất cả text string được dịch sang language mới.
  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Widget GestureDetector được sử dụng làm lớp bao bọc ngoài cùng để bắt các sự kiện chạm của người dùng vào các khoảng trống trên màn hình giao diện.
    /// Khi một hành động chạm được phát hiện, hệ thống sẽ tự động gọi lệnh unfocus để thu hồi bàn phím ảo nếu nó đang hiển thị trên thiết bị.
    /// Đây là một kỹ thuật tối ưu hóa giao diện giúp người dùng dễ dàng tắt bàn phím mà không cần phải nhấn vào các nút chức năng cụ thể.
    /// Phương pháp này giúp duy trì một không gian làm việc sạch sẽ và nâng cao tính tiện dụng cho các biểu mẫu nhập liệu phức tạp trong ứng dụng.
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      /// MultiBlocProvider đóng vai trò là một container trung gian chứa tất cả các Cubit cần thiết để cung cấp trạng thái cho toàn bộ cây widget phía dưới.
      /// Các Cubit như SettingThemeCubit, BaseLoadingCubit và SearchCubit được khởi tạo tại đây để đảm bảo tính sẵn sàng của dữ liệu ở mọi cấp độ của ứng dụng.
      /// Việc tập trung quản lý các state provider giúp lập trình viên dễ dàng theo dõi dòng chảy của dữ liệu và duy trì sự nhất quán giữa các thành phần.
      /// Đây là một phần quan trọng của kiến trúc BLoC, giúp tách biệt hoàn toàn giữa logic nghiệp vụ và các thành phần hiển thị giao diện người dùng.
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SettingThemeCubit(),
          ),
          BlocProvider(
            create: (context) => BaseLoadingCubit(),
          ),
          BlocProvider(
            create: (context) => SearchCubit(),
          ),
        ],
        // BlocBuilder lắng nghe SettingThemeCubit state changes
        // Rebuild MaterialApp khi user thay đổi theme (dark/light mode)
        child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
          builder: (context, state) {
            /// Phương thức initValue thuộc lớp DeviceDimension được triệu gọi tại đây để cập nhật các thông số kích thước vật lý của màn hình theo ngữ cảnh thiết bị hiện tại.
            /// Việc xác định chính xác các chỉ số này là điều kiện tiên quyết để đảm bảo các thành phần giao diện sau đó có thể hiển thị một cách cân đối trên mọi loại thiết bị.
            /// Do phương thức này được đặt trong hàm build của MaterialApp, nó cho phép ứng dụng phản hồi linh hoạt với các thay đổi về kích thước cửa sổ của người dùng.
            /// Đây là nền tảng quan trọng giúp xây dựng một giao diện thích ứng thông minh và mang lại trải nghiệm người dùng đồng nhất trên nhiều nền tảng khác động.
            DeviceDimension().initValue(context);

            /// MaterialApp đóng vai trò là thành phần định nghĩa phong cách thiết kế và cấu hình cơ bản nhất cho toàn bộ hệ thống giao diện Flutter.
            /// Tại đây, chúng tôi thiết lập khóa điều hướng toàn cục, các bộ đại diện đa ngôn ngữ, và các chủ đề hiển thị (Theme) cho cả chế độ sáng và tối.
            /// Widget home được gán cho AppRoot để dẫn dắt người dùng vào luồng splash screen đầu tiên ngay khi ứng dụng vừa được khởi chạy thành công.
            /// Ngoài ra, cơ chế onGenerateRoute cũng được tích hợp để tự động điều phối việc chuyển cảnh dựa trên các định danh route đã được đăng ký trước.
            return MaterialApp(
              navigatorKey: UtilsHelper.navigatorKey,
              theme: AppThemes.primaryTheme(context, state),
              darkTheme: AppThemes.primaryTheme(context, state),
              localizationsDelegates: _localization.localizationsDelegates,
              supportedLocales: _localization.supportedLocales,
              debugShowCheckedModeBanner: false,
              home: AppRoot(),
              onGenerateRoute: Routes.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
