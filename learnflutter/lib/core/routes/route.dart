import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:learnflutter/modules/animation/animation_screen.dart';
import 'package:learnflutter/modules/ar_kit/arkit_screen.dart';
import 'package:learnflutter/modules/chart/chart_screen.dart';
import 'package:learnflutter/modules/color_picker/color_picker_screen.dart';
import 'package:learnflutter/modules/custom_scroll/custom_scroll_screen.dart';
import 'package:learnflutter/modules/drag_target/drag_target_screen.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material_segmented/material_segmented_screen.dart';
import 'package:learnflutter/modules/menu/menu_controller.dart';
import 'package:learnflutter/helpper/hive_demo/screen/info_screen.dart';
import 'package:learnflutter/modules/nested/nested_scroll_screen.dart';
import 'package:learnflutter/base_loading_screen/page_loading_screen.dart';
import 'package:learnflutter/modules/bmprogresshud/bmprogresshud_screen.dart';
import 'package:learnflutter/modules/camera/camera_screen.dart';
import 'package:learnflutter/core/routes/argument_screen_model.dart';
import 'package:learnflutter/modules/courasel/courasel_screen.dart';
import 'package:learnflutter/modules/date_picker/calender.dart';
import 'package:learnflutter/modules/date_picker/date_picker.dart';
import 'package:learnflutter/modules/date_picker/date_time_input.dart';
import 'package:learnflutter/modules/datetime_picker/datetime_picker_screen.dart';
import 'package:learnflutter/modules/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/helpper/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/modules/interractive_view/intertiveview_screen.dart';
import 'package:learnflutter/modules/matix/matix_screen.dart';
import 'package:learnflutter/modules/number_formart/number_format_screen.dart';
import 'package:learnflutter/modules/open_file/open_file_screen.dart';
import 'package:learnflutter/modules/path_provider/path_provider_screen.dart';
import 'package:learnflutter/modules/popover/popover_scren.dart';
import 'package:learnflutter/modules/progress_hub/progress_hud_screen.dart';
import 'package:learnflutter/modules/regex/regex_example_screen.dart';
import 'package:learnflutter/modules/setting/setting_screen.dart';
import 'package:learnflutter/modules/shimmer/shimmer_widget.dart';
import 'package:learnflutter/helpper/snack_bar/snack_bar_screen.dart';
import 'package:learnflutter/modules/slider_vertical/slider_vertical_screen.dart';
import 'package:learnflutter/modules/smart_refresh/smart_refresh_screen.dart';
import 'package:learnflutter/test_screen/test_screen.dart';
import 'package:learnflutter/theme/page_theme_screen.dart';
import 'package:learnflutter/modules/tie_picker/tie_picker_screen.dart';
import 'package:learnflutter/modules/web_browser/web_browser_screen.dart';

class Routes {
  Routes._();

  static late String? currentRoot;

  static const String defaultRoute = "/";
  static const String testScreen = "/test_screen";
  static const String courasel = "/courasel_screen";
  static const String nesredScroll = "/nested_scroll_screen";
  static const String basic = "/basic";
  static const String nocenter = "/nocenter";
  static const String image = "/image";
  static const String complicated = "/complicated";
  static const String enlarge = "/enlarge";
  static const String manual = "/manual";
  static const String noloop = "/noloop";
  static const String vertical = "/vertical";
  static const String fullscreen = "/fullscreen";
  static const String printQRCode = "/print_qr_code";
  static const String ondemand = "/ondemand";
  static const String indicator = "/indicator";
  static const String prefetch = "/prefetch";
  static const String reason = "/reason";
  static const String position = "/position";
  static const String multiple = "/multiple";
  static const String zoom = "/zoom";
  static const String menuControler = "/MenuController";
  static const String bmprogresshudScreen = "/bmprogresshud_screen";
  static const String intertiveviewScreen = "/intertiveview_screen";
  static const String popoverScreen = "/popover_scren";
  static const String datetimePickerScreen = "/datetime_picker_screen";
  static const String datePicker = "/date_picker";
  static const String dateTimeInput = "/date_time_input";
  static const String calender = "/calender";
  static const String tiePickerScreen = "/tie_picker_screen";
  static const String progressHudScreen = "/progress_hud_screen";
  static const String shimmerWidget = "/shimmer_widget";
  static const String matixScreen = "/matix_screen";
  static const String heroAnimationScreen = "/hero_animation_screen";
  static const String infoScreen = "/info_screen";
  static const String snackBarScreen = "/snack_bar_screen";
  static const String pageLoadingScreen = "/page_loading_screen";
  static const String cameraScreen = "/camera_screen";
  static const String openFileScreen = "/open_file_screen";
  static const String pathProviderScreen = "/path_provider_screen";
  static const String webBrowserScreen = "/web_browser_screen";
  static const String draggelScrollScreen = "/draggel_scroll_screen";
  static const String pageThemeScreen = "/page_theme_screen";
  static const String numberFormatScreen = "/number_format_screen";
  static const String silderVerticalScreen = 'slider_vertical_screen';
  static const String materialSegmentedScreen = 'material_segmented_screen';
  static const String animationScreen = 'animation_screen';
  static const String setting = 'setting_screen';
  static const String arkit = 'arkit_screen';
  static const String colorPicker = 'color_picker_screen';
  static const String refreshControl = 'smart_refresh_screen';
  static const String chart = 'chart_screen';
  static const String dragTargetScreen = 'drag_target_screen';
  static const String regexExampleScreen = 'regex_example_screen';
  static const String customScrollScreen = 'custom_scroll_screen';
  static const String materialScreen = 'material_screen';

  static String current(BuildContext context) => ModalRoute.of(context)?.settings.name ?? '';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments != null && settings.arguments is ArgumentsScreenModel ? settings.arguments as ArgumentsScreenModel : ArgumentsScreenModel(title: "unknowns");
    switch (settings.name) {
      case testScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: testScreen),
          builder: (_) => const TestScreen(),
        );
      case courasel:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: courasel),
          builder: (_) => CarouselDemoHome(),
        );
      case nesredScroll:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: nesredScroll),
          builder: (_) => const NestedScrollViewExample(),
        );
      case basic:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: basic),
          builder: (_) => BasicDemo(),
        );
      case nocenter:
        return MaterialPageRoute(
          settings: const RouteSettings(name: nocenter),
          builder: (_) => NoCenterDemo(),
        );
      case image:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: image),
          builder: (_) => ImageSliderDemo(),
        );
      case complicated:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: complicated),
          builder: (_) => ComplicatedImageDemo(),
        );
      case enlarge:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: enlarge),
          builder: (_) => EnlargeStrategyDemo(),
        );
      case manual:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: manual),
          builder: (_) => ManuallyControlledSlider(),
        );
      case noloop:
        return MaterialPageRoute(
          settings: const RouteSettings(name: noloop),
          builder: (_) => NoonLoopingDemo(),
        );
      case vertical:
        return MaterialPageRoute(
          settings: const RouteSettings(name: vertical),
          builder: (_) => VerticalSliderDemo(),
        );
      case fullscreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: fullscreen),
          builder: (_) => FullscreenSliderDemo(),
          vertical: true,
        );
      case ondemand:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: ondemand),
          builder: (_) => OnDemandCarouselDemo(),
        );
      case indicator:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: indicator),
          builder: (_) => CarouselWithIndicatorDemo(),
        );
      case prefetch:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: prefetch),
          builder: (_) => PrefetchImageDemo(),
        );
      case reason:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: reason),
          builder: (_) => CarouselChangeReasonDemo(),
        );
      case position:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: position),
          builder: (_) => KeepPageviewPositionDemo(),
        );
      case multiple:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: multiple),
          builder: (_) => MultipleItemDemo(),
        );
      case zoom:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: zoom),
          builder: (_) => EnlargeStrategyZoomDemo(),
        );
      case menuControler:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: menuControler),
          builder: (_) => const Menu_Controller(),
        );
      case bmprogresshudScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: bmprogresshudScreen),
          builder: (_) => const MBProgressHUD(),
        );
      case intertiveviewScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: intertiveviewScreen),
          builder: (_) => const InteractiveViewerExample(),
        );
      case popoverScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: popoverScreen),
          builder: (_) => PopoverExample(),
        );
      case datetimePickerScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: datetimePickerScreen),
          builder: (_) => const DatePickerScreen(),
        );
      case datePicker:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: datePicker),
          vertical: true,
          builder: (_) => const DatePickerScreenExample(),
        );
      case dateTimeInput:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: dateTimeInput),
          // vertical: true,
          builder: (_) => const DateTimeInputScreen(),
        );
      case calender:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: calender),
          builder: (_) => const CalenderScreen(
            title: '',
          ),
        );
      case tiePickerScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: tiePickerScreen),
          builder: (_) => const TiePickerScreen(),
        );
      case progressHudScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: progressHudScreen),
          builder: (_) => ProgressHubScreenTest(),
        );
      case shimmerWidget:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: shimmerWidget),
          builder: (_) => const ExampleUiLoadingAnimation(),
        );
      case matixScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: matixScreen),
          builder: (_) => const MatrixScreen(),
        );
      case heroAnimationScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: heroAnimationScreen),
          builder: (_) => Page1(),
        );
      case infoScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: infoScreen),
          builder: (_) => InfoScreen(),
        );
      case snackBarScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: snackBarScreen),
          builder: (_) => const AweseomSnackBarExample(),
        );
      case pageLoadingScreen:
        return SlideRightRoute(
            routeSettings: const RouteSettings(name: pageLoadingScreen),
            builder: (_) => PageLoadingScreen(
                  message: 'Đang cập nhật dữ liệu...',
                ));
      case cameraScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: cameraScreen),
          builder: (_) => const CameraExampleHome(),
        );
      case openFileScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: openFileScreen),
          builder: (_) => OpenFileScreen(),
        );
      case pathProviderScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: pathProviderScreen),
          builder: (_) => const PathProviderScreen(title: 'PathProviderScreen'),
        );

      case webBrowserScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: webBrowserScreen),
          builder: (_) => const WebViewExample(),
        );

      case draggelScrollScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: draggelScrollScreen),
          builder: (_) => const DraggbleScrollScreen(),
        );
      case pageThemeScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: pageThemeScreen),
          builder: (_) => const TestThemeScreen(),
        );
      case numberFormatScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: numberFormatScreen),
          builder: (_) => const NumberFormatterScreen(),
        );
      case silderVerticalScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: silderVerticalScreen),
          builder: (_) => const SliderVerticalScreen(),
        );
      case materialSegmentedScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: silderVerticalScreen),
          builder: (_) => const MaterialSegmentedScreen(),
        );
      case animationScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: animationScreen),
          builder: (_) => TransitionsHomePage(),
        );
      case setting:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: setting),
          builder: (_) => SettingScreen(),
        );
      case arkit:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: arkit),
          builder: (_) => ARKitScreen(),
        );
      case colorPicker:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: colorPicker),
          builder: (_) => ColorPickerScreen(),
        );
      case refreshControl:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: refreshControl),
          builder: (_) => SmartRefreshScreen(),
        );
      case chart:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: chart),
          builder: (_) => ChartScreen(),
        );
      case dragTargetScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: dragTargetScreen),
          builder: (_) => DragTargetScreen(),
        );
      case regexExampleScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: regexExampleScreen),
          builder: (_) => RegexExampleScreen(),
        );
      case customScrollScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: customScrollScreen),
          builder: (_) => CustomScrollScreen(),
        );
      case materialScreen:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialScreen),
          builder: (_) => MaterialScreen(),
        );

      default:
        return SlideRightRoute(routeSettings: const RouteSettings(name: defaultRoute), builder: (_) => const TestScreen());
    }
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final RouteSettings? routeSettings;
  final bool vertical;

  SlideRightRoute({required this.builder, this.routeSettings, this.vertical = false})
      : super(
          settings: routeSettings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return builder(context);
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: vertical ? const Offset(0.0, 1.0) : const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
          },
        );
}
