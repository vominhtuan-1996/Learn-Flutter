import 'package:flutter/material.dart';
import 'package:learnflutter/component/balance_bar/balance_bar.dart';
import 'package:learnflutter/component/base_loading_draggable/draggable_example_screen.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/tree_view/tree_view_screen.dart';
import 'package:learnflutter/db/hive_demo/screen/info_screen.dart';
import 'package:learnflutter/modules/animation/animation_screen.dart';
import 'package:learnflutter/modules/ar_kit/arkit_screen.dart';
import 'package:learnflutter/modules/balance_bar_screen/balance_bar_screen.dart';
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
import 'package:learnflutter/modules/material/component/material_checkbox/material_checkbox_detail.dart';
import 'package:learnflutter/modules/material/component/material_chip_screen.dart';
import 'package:learnflutter/modules/material/component/material_floating_button.dart';
import 'package:learnflutter/modules/material/component/material_menus_detail.dart';
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
import 'package:learnflutter/modules/material/component/metarial_radio_button_screen.dart';
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
import 'package:learnflutter/modules/trouble_shooting/trouble_shooting_screen.dart';
import 'package:learnflutter/modules/web_browser/web_browser_screen.dart';
import 'package:learnflutter/src/lib/story_router/story_button.dart';
import 'package:learnflutter/src/lib/story_router/story_page_container_builder.dart';
import 'package:learnflutter/src/lib/story_router/story_page_transform.dart.dart';
import 'package:learnflutter/src/lib/story_router/story_route.dart';

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
  static const String materialRadioButton = 'metarial_radio_button_screen';
  static const String materialMenu = 'material_menus_detail';
  static const String graphicsScreen = 'graphics_screen';
  static const String customPaintScreen = "custom_paint_screen";
  static const String reducerScreen = "reducer_screen";
  static const String notificationScrollScreen = "notification_scroll_screen";
  static const String menu = "menu";
  static const String log = "log";
  static const String pickFile = "pick_file_screen";
  static const String scanScreen = 'scan_screen';
  static const String segmented = 'segmented_widget';
  static const String balanceBar = 'balanece_bar';
  static const String treeScreen = 'tree_view_screen';
  static const String draggableExampleScreen = 'draggable_example_screen';
  static const String troubleShootingScreen = 'trouble_shooting_screen';

  static String current(BuildContext context) => ModalRoute.of(context)?.settings.name ?? '';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments != null && settings.arguments is ArgumentsScreenModel ? settings.arguments as ArgumentsScreenModel : ArgumentsScreenModel(title: "unknowns");
    switch (settings.name) {
      case testScreen:
        return MaterialPageRoute(
          settings: RouteSettings(name: testScreen),
          builder: (_) => TestScreen(),
        );
      case courasel:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: courasel),
          builder: (_) => CarouselDemoHome(),
        );
      case nesredScroll:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: nesredScroll),
          builder: (_) => NestedScrollViewExample(),
        );
      case basic:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: basic),
          builder: (_) => BasicDemo(),
        );
      case nocenter:
        return MaterialPageRoute(
          settings: RouteSettings(name: nocenter),
          builder: (_) => NoCenterDemo(),
        );
      case image:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: image),
          builder: (_) => ImageSliderDemo(),
        );
      case complicated:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: complicated),
          builder: (_) => ComplicatedImageDemo(),
        );
      case enlarge:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: enlarge),
          builder: (_) => EnlargeStrategyDemo(),
        );
      // case manual:
      //   return SlideRightRoute(
      //     routeSettings:  RouteSettings(name: manual),
      //     builder: (_) => ManuallyControlledSlider(),
      //   );
      case noloop:
        return MaterialPageRoute(
          settings: RouteSettings(name: noloop),
          builder: (_) => NoonLoopingDemo(),
        );
      case vertical:
        return MaterialPageRoute(
          settings: RouteSettings(name: vertical),
          builder: (_) => VerticalSliderDemo(),
        );
      case fullscreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: fullscreen),
          builder: (_) => FullscreenSliderDemo(),
          vertical: true,
        );
      case ondemand:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: ondemand),
          builder: (_) => OnDemandCarouselDemo(),
        );
      // case indicator:
      //   return SlideRightRoute(
      //     routeSettings:  RouteSettings(name: indicator),
      //     builder: (_) => CarouselWithIndicatorDemo(),
      //   );
      case prefetch:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: prefetch),
          builder: (_) => PrefetchImageDemo(),
        );
      // case reason:
      //   return SlideRightRoute(
      //     routeSettings:  RouteSettings(name: reason),
      //     builder: (_) => CarouselChangeReasonDemo(),
      //   );
      case position:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: position),
          builder: (_) => KeepPageviewPositionDemo(),
        );
      case multiple:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: multiple),
          builder: (_) => MultipleItemDemo(),
        );
      case zoom:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: zoom),
          builder: (_) => EnlargeStrategyZoomDemo(),
        );
      case menuControler:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: menuControler),
          builder: (_) => HomeMenuController(),
        );
      case bmprogresshudScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: bmprogresshudScreen),
          builder: (_) => MBProgressHUD(),
        );
      case intertiveviewScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: intertiveviewScreen),
          builder: (_) => InteractiveViewerExample(),
        );
      case popoverScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: popoverScreen),
          builder: (_) => PopoverExample(),
        );
      case datetimePickerScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: datetimePickerScreen),
          builder: (_) => DatePickerScreen(),
        );
      case dateTimeInput:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: dateTimeInput),
          // vertical: true,
          builder: (_) => DateTimeInputScreen(),
        );
      case calender:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: calender),
          builder: (_) => CalenderScreen(
            title: '',
          ),
        );
      case progressHudScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: progressHudScreen),
          builder: (_) => ProgressHubScreenTest(),
        );
      case shimmerWidget:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: shimmerWidget),
          builder: (_) => ExampleUiLoadingAnimation(),
        );
      case matixScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: matixScreen),
          builder: (_) => MatrixScreen(),
        );
      case heroAnimationScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: heroAnimationScreen),
          builder: (_) => Page1(),
        );
      case infoScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: infoScreen),
          builder: (_) => InfoScreen(),
        );
      case snackBarScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: snackBarScreen),
          builder: (_) => AweseomSnackBarExample(),
        );
      case pageLoadingScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: pageLoadingScreen),
            builder: (_) => PageLoadingScreen(
                  message: 'Đang cập nhật dữ liệu...',
                ));
      case cameraScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: cameraScreen),
          builder: (_) => CameraExampleHome(),
        );
      case openFileScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: openFileScreen),
          builder: (_) => OpenFileScreen(),
        );
      case pathProviderScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: pathProviderScreen),
          builder: (_) => PathProviderScreen(title: 'PathProviderScreen'),
        );

      case webBrowserScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: webBrowserScreen),
          builder: (_) => WebViewExample(),
        );

      case draggelScrollScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: draggelScrollScreen),
          builder: (_) => DraggbleScrollScreen(),
        );
      case pageThemeScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: pageThemeScreen),
          builder: (_) => TestThemeScreen(),
        );
      case numberFormatScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: numberFormatScreen),
          builder: (_) => NumberFormatterScreen(),
        );
      case silderVerticalScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: silderVerticalScreen),
          builder: (_) => SliderVerticalScreen(),
        );
      case materialSegmentedScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: silderVerticalScreen),
          builder: (_) => MaterialSegmentedScreen(),
        );
      case animationScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: animationScreen),
          builder: (_) => TransitionsHomePage(),
        );
      case setting:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: setting),
          builder: (_) => SettingScreen(),
        );
      case arkit:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: arkit),
          builder: (_) => ARKitScreen(),
        );
      case colorPicker:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: colorPicker),
          builder: (_) => ColorPickerScreen(),
        );
      case refreshControl:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: refreshControl),
          builder: (_) => SmartRefreshScreen(),
        );
      case chart:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: chart),
          builder: (_) => ChartScreen(),
        );
      case dragTargetScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: dragTargetScreen),
          builder: (_) => DragTargetScreen(),
        );
      case regexExampleScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: regexExampleScreen),
          builder: (_) => RegexExampleScreen(),
        );
      case customScrollScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: customScrollScreen),
          builder: (_) => CustomScrollScreen(),
        );
      case materialScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialScreen),
          builder: (_) => MaterialScreen(),
        );
      case materialBadge:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          // final data = arguments.da
          routeSettings: RouteSettings(name: materialBadge),
          builder: (_) => MaterialBadge(data: param),
        );
      case materialBottomAppbar:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialBottomAppbar),
          builder: (_) => MaterialBottomAppBar(data: param),
        );
      case materialBottomSheet:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialBottomSheet),
          builder: (_) => MaterialBottomSheet(data: param),
        );
      case materialButton:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialButton),
          builder: (_) => MaterialButtonDetail(data: param),
        );
      case materialCard:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialCard),
          builder: (_) => MaterialCardDetail(data: param),
        );
      case materialCarousel:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialCarousel),
          builder: (_) => MaterialCarouselDetail(data: param),
        );
      case materialCheckbox:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialCheckbox),
          builder: (_) => MaterialCheckBoxDetail(data: param),
        );
      case materialDatePicker:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialDatePicker),
          builder: (_) => MaterialDatePicker(data: param),
        );
      case materialTimePicker:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialTimePicker),
          builder: (_) => (MaterialTimePicker(data: param)),
        );
      case materialSlider:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialSlider),
          builder: (_) => (MaterialSlider(data: param)),
        );
      case materialDialog:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialDialog),
          builder: (_) => (MaterialDialog(data: param)),
        );
      case materialDivider:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialDivider),
          builder: (_) => (MaterialDividerDetail(data: param)),
        );
      case materialFloatingButton:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialFloatingButton),
          builder: (_) => (MaterialFloatingButtonDetail(data: param)),
        );
      case materialProgressIndicators:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialProgressIndicators),
          builder: (_) => (MaterialProgressIndicators(data: param)),
        );
      case materialTextField:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialTextField),
          builder: (_) => (MaterialTextFieldScreen(data: param)),
        );
      case materialSwitch:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialSwitch),
          builder: (_) => (MaterialSwitch(data: param)),
        );
      case materialNavigationDrawer:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialNavigationDrawer),
          builder: (_) => (MaterialNavigationDrawerScreen(data: param)),
        );
      case materialSearchBar:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialSearchBar),
          builder: (_) => (MaterialSearchbar(data: param)),
        );
      case materialChip:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialChip),
          builder: (_) => (MaterialChipScreen(data: param)),
        );

      case materialRadioButton:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialRadioButton),
          builder: (_) => (MaterialRaidoButtonScreen(data: param)),
        );
      case materialMenu:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialMenu),
          builder: (_) => (MaterialMenuDetailScreen(data: param)),
        );

      case graphicsScreen:
        return SlideRightRoute(routeSettings: RouteSettings(name: graphicsScreen), builder: (_) => GraphicsScreen());
      case customPaintScreen:
        return SlideRightRoute(routeSettings: RouteSettings(name: customPaintScreen), builder: (_) => CustomPainterScreen());
      case reducerScreen:
        return SlideRightRoute(routeSettings: RouteSettings(name: reducerScreen), builder: (_) => ReducerScreen());
      case notificationScrollScreen:
        return SlideRightRoute(routeSettings: RouteSettings(name: reducerScreen), builder: (_) => NotificationScrollScreen());
      case menu:
        return SlideRightRoute(routeSettings: RouteSettings(name: reducerScreen), builder: (_) => SliverAppMenu());
      case log:
        return SlideRightRoute(routeSettings: RouteSettings(name: reducerScreen), builder: (_) => LogScreen());
      case pickFile:
        return SlideRightRoute(routeSettings: RouteSettings(name: pickFile), builder: (_) => PickFileScreen());
      case scanScreen:
        return SlideRightRoute(routeSettings: RouteSettings(name: scanScreen), builder: (_) => ScanScreen());
      case segmented:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: segmented),
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
          ),
        );
      case balanceBar:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: balanceBar),
          builder: (_) => BalanceBarScreen(),
        );
      case treeScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: treeScreen),
          builder: (_) => TreeViewScreen(),
        );
      case draggableExampleScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: draggableExampleScreen),
          builder: (_) => DraggableExampleScreen(),
        );
      case troubleShootingScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: troubleShootingScreen),
          builder: (_) => TroubleShootingScreen(),
        );
      default:
        return SlideRightRoute(routeSettings: RouteSettings(name: defaultRoute), builder: (_) => TestScreen());
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
            // const begin = Offset(1.0, 0.0);
            // const end = Offset.zero;
            // const curve = Curves.ease;

            // var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            // var offsetAnimation = animation.drive(tween);

            // return SlideTransition(
            //   position: offsetAnimation,
            //   child: child,
            // );
            // return StoryPageContainerBuilder(
            //   animation: animation,
            //   settings: StoryContainerSettings(
            //       buttonData: StoryButtonData(
            //           storyId: '2',
            //           storyPages: [builder(context)],
            //           child: child,
            //           segmentDuration: [
            //             Duration(milliseconds: 600),
            //           ]),
            //       allButtonDatas: [],
            //       tapPosition: Offset.zero,
            //       storyListScrollController: ScrollController()),
            //   // settings: storyContainerSettings,
            // );
            // return StoryPage3DTransform().transform(context, child, animation, child);
            return SlideTransition(
              position: Tween<Offset>(
                begin: vertical ? Offset(0.0, 1.0) : Offset(1.0, 0.0),
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

class StoryRoute extends ModalRoute {
  final Duration? duration;
  final StoryContainerSettings storyContainerSettings;

  StoryRoute({
    this.duration,
    required this.storyContainerSettings,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return StoryPageContainerBuilder(
      animation: animation,
      settings: storyContainerSettings,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration ?? kThemeAnimationDuration;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;
}
