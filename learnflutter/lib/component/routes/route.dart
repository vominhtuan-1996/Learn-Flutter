import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/db/hive_demo/screen/info_screen.dart';
import 'package:learnflutter/modules/animation/animation_screen.dart';
import 'package:learnflutter/modules/ar_kit/arkit_screen.dart';
import 'package:learnflutter/modules/chart/chart_screen.dart';
import 'package:learnflutter/modules/color_picker/color_picker_screen.dart';
import 'package:learnflutter/modules/custom_paint/custom_paint_screen.dart';
import 'package:learnflutter/modules/custom_scroll/custom_scroll_screen.dart';
import 'package:learnflutter/modules/drag_target/drag_target_screen.dart';
import 'package:learnflutter/modules/graphics/graphics_screen.dart';
import 'package:learnflutter/modules/log/log_screen.dart';
import 'package:learnflutter/modules/material/component/material_badge.dart';
import 'package:learnflutter/modules/material/component/material_bottom_app_bar.dart';
import 'package:learnflutter/modules/material/component/material_bottom_sheet.dart';
import 'package:learnflutter/modules/material/component/material_button_detail.dart';
import 'package:learnflutter/modules/material/component/material_checkbox/material_checkbox.dart';
import 'package:learnflutter/modules/material/component/material_checkbox/material_checkbox_detail.dart';
import 'package:learnflutter/modules/material/component/material_chip_screen.dart';
import 'package:learnflutter/modules/material/component/material_floating_button.dart';
import 'package:learnflutter/modules/material/component/material_navigation_drawer_screen.dart';
import 'package:learnflutter/modules/material/component/material_progress_indicators.dart';
import 'package:learnflutter/modules/material/component/material_searchbar.dart';
import 'package:learnflutter/modules/material/component/material_switch.dart';
import 'package:learnflutter/modules/material/component/metarial_card/material_card_detail.dart';
import 'package:learnflutter/modules/material/component/material_date_picker.dart';
import 'package:learnflutter/modules/material/component/material_slider.dart';
import 'package:learnflutter/modules/material/component/metarial_carousel/metarial_carousel_detail.dart';
import 'package:learnflutter/modules/material/component/metarial_dialog.dart';
import 'package:learnflutter/modules/material/component/metarial_divider.dart';
import 'package:learnflutter/modules/material/component/metarial_textfield_screen.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/component/material_time_picker.dart';
import 'package:learnflutter/modules/material_segmented/material_segmented_screen.dart';
import 'package:learnflutter/modules/material_segmented/segmented_widget.dart';
import 'package:learnflutter/modules/menu/menu_controller.dart';
import 'package:learnflutter/modules/nested/nested_scroll_screen.dart';
import 'package:learnflutter/component/base_loading_screen/page_loading_screen.dart';
import 'package:learnflutter/modules/bmprogresshud/bmprogresshud_screen.dart';
import 'package:learnflutter/modules/camera/camera_screen.dart';
import 'package:learnflutter/component/routes/argument_screen_model.dart';
import 'package:learnflutter/modules/courasel/courasel_screen.dart';
import 'package:learnflutter/modules/date_picker/calender.dart';
import 'package:learnflutter/modules/date_picker/date_time_input.dart';
import 'package:learnflutter/modules/datetime_picker/datetime_picker_screen.dart';
import 'package:learnflutter/modules/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/component/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/modules/interractive_view/intertiveview_screen.dart';
import 'package:learnflutter/modules/matix/matix_screen.dart';
import 'package:learnflutter/modules/noti_scroll/notification_scroll_screen.dart';
import 'package:learnflutter/modules/number_formart/number_format_screen.dart';
import 'package:learnflutter/modules/open_file/open_file_screen.dart';
import 'package:learnflutter/modules/path_provider/path_provider_screen.dart';
import 'package:learnflutter/modules/pick_file/pick_file_screen.dart';
import 'package:learnflutter/modules/pinput/demo/pages/gallery_page.dart';
import 'package:learnflutter/modules/popover/popover_scren.dart';
import 'package:learnflutter/modules/progress_hub/progress_hud_screen.dart';
import 'package:learnflutter/modules/reducer/reducer_screen.dart';
import 'package:learnflutter/modules/regex/regex_example_screen.dart';
import 'package:learnflutter/modules/scan/scan_screen.dart';
import 'package:learnflutter/modules/setting/setting_screen.dart';
import 'package:learnflutter/modules/shimmer/shimmer_widget.dart';
import 'package:learnflutter/component/snack_bar/snack_bar_screen.dart';
import 'package:learnflutter/modules/slider_vertical/slider_vertical_screen.dart';
import 'package:learnflutter/modules/smart_refresh/smart_refresh_screen.dart';
import 'package:learnflutter/component/sliver_appbar/main-appbar.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';
import 'package:learnflutter/modules/theme/page_theme_screen.dart';
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
  static const String materialBadge = 'material_badge';
  static const String materialBottomAppbar = 'material_bottom_app_bar';
  static const String materialBottomSheet = 'material_bottom_sheet';
  static const String materialButton = 'material_button_detail';
  static const String materialCard = 'material_card_detail';
  static const String materialCarousel = 'metarial_carousel_detail';
  static const String materialDatePicker = 'material_date_picker';
  static const String materialTimePicker = 'material_time_picker';
  static const String materialSlider = 'material_slider';
  static const String materialCheckbox = 'material_checkbox_detail';
  static const String materialDialog = 'metarial_dialog';
  static const String materialDivider = 'metarial_divider';
  static const String materialFloatingButton = 'material_floating_button';
  static const String materialProgressIndicators = "material_progress_indicators";
  static const String materialTextField = "metarial_textfield_screen";
  static const String materialSwitch = "material_switch";
  static const String materialNavigationDrawer = 'material_navigation_drawer_screen';
  static const String materialSearchBar = 'material_searchbar';
  static const String materialChip = 'material_chip_screen';
  static const String graphicsScreen = 'graphics_screen';
  static const String customPaintScreen = "custom_paint_screen";
  static const String reducerScreen = "reducer_screen";
  static const String notificationScrollScreen = "notification_scroll_screen";
  static const String menu = "menu";
  static const String log = "log";
  static const String pickFile = "pick_file_screen";
  static const String scanScreen = 'scan_screen';
  static const String segmented = 'segmented_widget';

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
      // case manual:
      //   return SlideRightRoute(
      //     routeSettings: const RouteSettings(name: manual),
      //     builder: (_) => ManuallyControlledSlider(),
      //   );
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
      // case indicator:
      //   return SlideRightRoute(
      //     routeSettings: const RouteSettings(name: indicator),
      //     builder: (_) => CarouselWithIndicatorDemo(),
      //   );
      case prefetch:
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: prefetch),
          builder: (_) => PrefetchImageDemo(),
        );
      // case reason:
      //   return SlideRightRoute(
      //     routeSettings: const RouteSettings(name: reason),
      //     builder: (_) => CarouselChangeReasonDemo(),
      //   );
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
      case materialBadge:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          // final data = arguments.da
          routeSettings: const RouteSettings(name: materialBadge),
          builder: (_) => MaterialBadge(data: param),
        );
      case materialBottomAppbar:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialBottomAppbar),
          builder: (_) => MaterialBottomAppBar(data: param),
        );
      case materialBottomSheet:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialBottomSheet),
          builder: (_) => MaterialBottomSheet(data: param),
        );
      case materialButton:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialButton),
          builder: (_) => MaterialButtonDetail(data: param),
        );
      case materialCard:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialCard),
          builder: (_) => MaterialCardDetail(data: param),
        );
      case materialCarousel:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialCarousel),
          builder: (_) => MaterialCarouselDetail(data: param),
        );
      case materialCheckbox:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialCheckbox),
          builder: (_) => MaterialCheckBoxDetail(data: param),
        );
      case materialDatePicker:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialDatePicker),
          builder: (_) => MaterialDatePicker(data: param),
        );
      case materialTimePicker:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialTimePicker),
          builder: (_) => (MaterialTimePicker(data: param)),
        );
      case materialSlider:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialSlider),
          builder: (_) => (MaterialSlider(data: param)),
        );
      case materialDialog:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialDialog),
          builder: (_) => (MaterialDialog(data: param)),
        );
      case materialDivider:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialDivider),
          builder: (_) => (MaterialDividerDetail(data: param)),
        );
      case materialFloatingButton:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialFloatingButton),
          builder: (_) => (MaterialFloatingButtonDetail(data: param)),
        );
      case materialProgressIndicators:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialProgressIndicators),
          builder: (_) => (MaterialProgressIndicators(data: param)),
        );
      case materialTextField:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialTextField),
          builder: (_) => (MaterialTextFieldScreen(data: param)),
        );
      case materialSwitch:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialSwitch),
          builder: (_) => (MaterialSwitch(data: param)),
        );
      case materialNavigationDrawer:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialNavigationDrawer),
          builder: (_) => (MaterialNavigationDrawerScreen(data: param)),
        );
      case materialSearchBar:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialSearchBar),
          builder: (_) => (MaterialSearchbar(data: param)),
        );
      case materialChip:
        final param = arguments.data as RoouterMaterialModel;
        return SlideRightRoute(
          routeSettings: const RouteSettings(name: materialChip),
          builder: (_) => (MaterialChipScreen(data: param)),
        );

      case graphicsScreen:
        return SlideRightRoute(routeSettings: const RouteSettings(name: graphicsScreen), builder: (_) => GraphicsScreen());
      case customPaintScreen:
        return SlideRightRoute(routeSettings: const RouteSettings(name: customPaintScreen), builder: (_) => CustomPainterScreen());
      case reducerScreen:
        return SlideRightRoute(routeSettings: const RouteSettings(name: reducerScreen), builder: (_) => ReducerScreen());
      case notificationScrollScreen:
        return SlideRightRoute(routeSettings: const RouteSettings(name: reducerScreen), builder: (_) => NotificationScrollScreen());
      case menu:
        return SlideRightRoute(routeSettings: const RouteSettings(name: reducerScreen), builder: (_) => SliverAppMenu());
      case log:
        return SlideRightRoute(routeSettings: const RouteSettings(name: reducerScreen), builder: (_) => LogScreen());
      case pickFile:
        return SlideRightRoute(routeSettings: const RouteSettings(name: pickFile), builder: (_) => PickFileScreen());
      case scanScreen:
        return SlideRightRoute(routeSettings: const RouteSettings(name: scanScreen), builder: (_) => ScanScreen());
      case segmented:
        return SlideRightRoute(
            routeSettings: const RouteSettings(name: segmented),
            builder: (_) => BaseLoading(
                  isLoading: false,
                  child: SizedBox(
                    height: 44,
                    child: SegmentedWidget(
                      splitRatio: 0.2,
                      color1: Colors.red,
                      color2: Colors.blue,
                    ),
                  ),
                ));
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
