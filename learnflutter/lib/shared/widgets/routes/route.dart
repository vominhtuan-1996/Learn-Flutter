import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/features/auth/screens/login_screen.dart';
import 'package:learnflutter/features/flutter_3d/pages/flutter_3d_screen.dart';
import 'package:learnflutter/features/login/screens/login_page.dart';
import 'package:learnflutter/features/transformer_example/transformer_example_page.dart';
import 'package:learnflutter/shared/widgets/base_loading_draggable/draggable_example_screen.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:learnflutter/shared/widgets/tree_view/tree_view_screen.dart';
import 'package:learnflutter/data/local/hive_demo/screen/info_screen.dart';
import 'package:learnflutter/main_isolate.dart';
import 'package:learnflutter/features/animation/animation_screen.dart';
import 'package:learnflutter/features/balance_bar_screen/balance_bar_screen.dart';
import 'package:learnflutter/features/camera_wesome/camera_wesome_screen.dart';
import 'package:learnflutter/features/chart/chart_screen.dart';
import 'package:learnflutter/features/chart/pages/sf_cartesian_chart_page.dart';
import 'package:learnflutter/features/chart/pages/sf_circular_chart_page.dart';
import 'package:learnflutter/features/chart/pages/sf_pyramid_chart_page.dart';
import 'package:learnflutter/features/chart/pages/sf_spark_bar_chart_page.dart';
import 'package:learnflutter/features/chat/chat_screen.dart';
import 'package:learnflutter/features/color_picker/color_picker_screen.dart';
import 'package:learnflutter/features/custom_paint/custom_paint_screen.dart';
import 'package:learnflutter/features/custom_scroll/custom_scroll_screen.dart';
import 'package:learnflutter/features/drag_target/drag_target_screen.dart';
import 'package:learnflutter/features/drop_refresh_control/drop_refresh_screen.dart';
import 'package:learnflutter/features/excel/excel_screen.dart';
import 'package:learnflutter/features/graphics/graphics_screen.dart';
import 'package:learnflutter/features/indicator/indicator_example_screen.dart';
import 'package:learnflutter/features/indicator/pages/arrow_down_indicator_page.dart';
import 'package:learnflutter/features/indicator/pages/drop_water_indicator.dart';
import 'package:learnflutter/features/indicator/pages/drop_water_lottie_refresh_indicator_page.dart';
import 'package:learnflutter/features/indicator/pages/fetch_more_indicator_page.dart';
import 'package:learnflutter/features/indicator/pages/home_refresh_indicator_page.dart';
import 'package:learnflutter/features/indicator/pages/ice_cream_indicator.dart';
import 'package:learnflutter/features/log/log_screen.dart';
import 'package:learnflutter/features/log/talker_example_screen.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';
// import 'package:learnflutter/features/login/page/login_screen.dart';
import 'package:learnflutter/features/map/map_screen.dart';
import 'package:learnflutter/features/map/example/example_map_screen.dart';
import 'package:learnflutter/features/map/offline/offline_mbtiles_map_screen.dart';
import 'package:learnflutter/features/map/google_map_base/google_map_base_screen.dart';
import 'package:learnflutter/features/map/google_map_offline/google_map_offline_screen.dart';
import 'package:learnflutter/features/map/flutter_map_osm/flutter_map_osm_screen.dart';
import 'package:learnflutter/features/material/component/material_badge.dart';
import 'package:learnflutter/features/material/component/material_bottom_app_bar.dart';
import 'package:learnflutter/features/material/component/material_bottom_sheet.dart';
import 'package:learnflutter/features/material/component/material_button_detail.dart';
import 'package:learnflutter/features/material/component/material_checkbox/material_checkbox_detail.dart';
import 'package:learnflutter/features/material/component/material_chip_screen.dart';
import 'package:learnflutter/features/material/component/material_floating_button.dart';
import 'package:learnflutter/features/material/component/material_icon_button_screen.dart';
import 'package:learnflutter/features/material/component/material_lists/example/fade_search_header_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/header_animation_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/masonry_sliver_grid_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/scroll_spy_sliver_view_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_animation_list_wrapper_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_collapse_FAB_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_effects_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_empty_state.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_map_preview_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_onboarding_with_content_example.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_parallax_sticky_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_pull_torefresh_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sliver_timeline_page.dart';
import 'package:learnflutter/features/material/component/material_lists/example/sticky_header_example.dart';
import 'package:learnflutter/features/material/component/material_lists/widgets/sliver_appbar_collapsing_header_hero.dart';
import 'package:learnflutter/features/material/component/material_lists/widgets/sliver_appbar_persistent_header_tabbar.dart';
import 'package:learnflutter/features/material/component/material_lists_screen.dart';
import 'package:learnflutter/features/material/component/material_menus_detail.dart';
import 'package:learnflutter/features/material/component/material_navigation_drawer_screen.dart';
import 'package:learnflutter/features/material/component/material_navigation_rail_screen.dart';
import 'package:learnflutter/features/material/component/material_progress_indicators.dart';
import 'package:learnflutter/features/material/component/material_searchbar.dart';
import 'package:learnflutter/features/material/component/material_side_sheet_screen.dart';
import 'package:learnflutter/features/material/component/material_switch.dart';
import 'package:learnflutter/features/material/component/metarial_card/material_card_detail.dart';
import 'package:learnflutter/features/material/component/material_date_picker.dart';
import 'package:learnflutter/features/material/component/material_slider.dart';
import 'package:learnflutter/features/material/component/metarial_carousel/metarial_carousel_detail.dart';
import 'package:learnflutter/features/material/component/metarial_dialog.dart';
import 'package:learnflutter/features/material/component/metarial_divider.dart';
import 'package:learnflutter/features/material/component/metarial_radio_button_screen.dart';
import 'package:learnflutter/features/material/component/metarial_snackbar_screen.dart';
import 'package:learnflutter/features/material/component/metarial_textfield_screen.dart';
import 'package:learnflutter/features/material/material_screen.dart';
import 'package:learnflutter/features/material/component/material_time_picker.dart';
import 'package:learnflutter/features/material/component/material_segmented/material_segmented_screen.dart';
import 'package:learnflutter/features/material/component/material_segmented/segmented_widget.dart';
import 'package:learnflutter/features/menu/menu_controller.dart';
import 'package:learnflutter/features/nested/nested_scroll_screen.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/page_loading_screen.dart';
import 'package:learnflutter/features/bmprogresshud/bmprogresshud_screen.dart';
import 'package:learnflutter/features/camera/camera_screen.dart';
import 'package:learnflutter/features/camera/model/camera_mode.dart';
import 'package:learnflutter/features/ar_kit/arkit_screen.dart';
import 'package:learnflutter/features/ar_kit/scanner/scanner_screen.dart';
import 'package:learnflutter/features/photo_3d/photo_3d_screen.dart';
import 'package:learnflutter/features/photo_to_3d/photo_to_3d_screen.dart';
import 'package:learnflutter/shared/widgets/routes/argument_screen_model.dart';
import 'package:learnflutter/features/courasel/courasel_screen.dart';
import 'package:learnflutter/features/date_picker/calender.dart';
import 'package:learnflutter/features/date_picker/date_time_input.dart';
import 'package:learnflutter/features/datetime_picker/datetime_picker_screen.dart';
import 'package:learnflutter/features/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/shared/widgets/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/features/interractive_view/intertiveview_screen.dart';
import 'package:learnflutter/features/matix/matix_screen.dart';
import 'package:learnflutter/features/noti_scroll/notification_scroll_screen.dart';
import 'package:learnflutter/features/number_formart/number_format_screen.dart';
import 'package:learnflutter/features/open_file/open_file_screen.dart';
import 'package:learnflutter/features/path_provider/path_provider_screen.dart';
import 'package:learnflutter/features/pick_file/pick_file_screen.dart';
import 'package:learnflutter/features/popover/popover_scren.dart';
import 'package:learnflutter/features/progress_hub/progress_hud_screen.dart';
import 'package:learnflutter/features/qr_code_example/qr_code_screen.dart';
import 'package:learnflutter/features/reducer/reducer_screen.dart';
import 'package:learnflutter/features/regex/regex_example_screen.dart';
import 'package:learnflutter/features/scan/scan_screen.dart';
import 'package:learnflutter/features/scroll_physic/pages/always_bounce_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/no_scroll_physic_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/nobounce_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/reversed_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/rubber_band_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/rubber_spring_back_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/slow_down_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/pages/snapping_scroll_physics_example.dart';
import 'package:learnflutter/features/scroll_physic/scroll_physic_screen.dart';
import 'package:learnflutter/features/setting/setting_screen.dart';
import 'package:learnflutter/features/shimmer/shimmer_widget.dart';
import 'package:learnflutter/features/shimmer/shimmer_base_test_screen.dart';
import 'package:learnflutter/shared/widgets/snack_bar/snack_bar_screen.dart';
import 'package:learnflutter/features/slider_vertical/slider_vertical_screen.dart';
import 'package:learnflutter/features/smart_loadmore_screen/smart_loadmore_screen.dart';
import 'package:learnflutter/features/smart_refresh/smart_refresh_screen.dart';
import 'package:learnflutter/shared/widgets/sliver_appbar/main-appbar.dart';
import 'package:learnflutter/features/test_screen/test_screen.dart';
import 'package:learnflutter/features/theme/page_theme_screen.dart';
import 'package:learnflutter/features/theme/setting_texttheme_screen.dart';
import 'package:learnflutter/features/trouble_shooting/trouble_shooting_screen.dart';
import 'package:learnflutter/features/visibility_detector_demo/visibility_detector_example.dart';
import 'package:learnflutter/features/web_view/web_view_screen.dart';
import 'package:learnflutter/features/web_view/street_view_screen.dart';
import 'package:learnflutter/shared/widgets/lib/story_router/story_page_container_builder.dart';
import 'package:learnflutter/shared/widgets/lib/story_router/story_route.dart';
import 'package:learnflutter/games/tic_tac_toe/screens/game_screen.dart';
import 'package:learnflutter/games/rubik/screens/rubik_screen.dart';
import 'package:learnflutter/features/news/presentation/news_screen.dart';
import 'package:learnflutter/features/onboarding/screens/splash_v1_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step1_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step2_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_step3_screen.dart';
import 'package:learnflutter/features/onboarding/screens/onboarding_page_view.dart';
import 'package:learnflutter/features/auth/screens/login_v1_screen.dart';
// import 'package:path/path.dart';

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
  static const String shimmerBaseTest = "/shimmer_base_test";
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
  static const String lidarScanner = 'lidar_scanner_screen';
  static const String photo3D = 'photo_3d_screen';
  static const String photoTo3D = 'photo_to_3d_screen';
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
  static const String materialProgressIndicators =
      "material_progress_indicators";
  static const String materialTextField = "metarial_textfield_screen";
  static const String materialSwitch = "material_switch";
  static const String materialNavigationDrawer =
      'material_navigation_drawer_screen';
  static const String materialSearchBar = 'material_searchbar';
  static const String materialChip = 'material_chip_screen';
  static const String materialRadioButton = 'metarial_radio_button_screen';
  static const String materialMenu = 'material_menus_detail';
  static const String materialSnackbar = 'metarial_snackbar_screen';
  static const String materialNavigationRail =
      "material_navigation_rail_screen";
  static const String materialSideSheetScreen = "material_side_sheet_screen";
  static const String materialIConButton = "material_icon_button_screen";
  static const String materialLists = "material_lists_screen";
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
  static const String chatScreen = 'chat_screen';
  static const String dropRefresh = 'drop_refresh_screen';
  static const String mapScreen = 'map_screen';
  static const String exampleMapScreen = 'example_map_screen';
  static const String offlineMbtilesMapScreen = 'offline_mbtiles_map_screen';
  static const String isolateParseScreen = 'isolate_parse_screen';
  static const String smartLoadmoreScreen = "smart_loadmore_screen";
  static const String webViewScreen = "web_view_screen";
  static const String streetViewScreen = "street_view_screen";
  static const String qrScreen = 'qr_code_screen';
  static const String excellScreen = 'excel_screen';
  static const String login = "login_screen";
  static const String transformerPageView = "transformer_page_view";
  static const String googleMapBase = 'google_map_base';
  static const String newLogin = "/new_login";
  static const String newsScreen = "/news_screen";
  static const String googleMapOffline = "/google_map_offline";

  // Monumental Habits Onboarding
  static const String splashV1 = "/splash_v1";
  static const String onboardingStep1 = "/onboarding_step1";
  static const String onboardingStep2 = "/onboarding_step2";
  static const String onboardingStep3 = "/onboarding_step3";
  static const String onboardingPageView = "/onboarding_page_view";
  static const String loginV1 = "/login_v1";

  // flutter_map OSM
  static const String flutterMapOsmScreen = 'flutter_map_osm_screen';

  //*regions Sliver
  static const String sliverAppbarCollapsingHeaderHero =
      "sliver_appbar_collapsing_header_hero";
  static const String sliverAppbarPersistentHeaderTabbar =
      "sliver_appbar_persistent_header_tabbar";
  static const String sliverAnimationListWrapperExample =
      "sliver_animation_list_wrapper_example";
  static const String sliverParalaxSticky = "sliver_parallax_sticky_page";
  static const String sliverMasonryGrid = "masonry_sliver_grid_page";
  static const String sliverEmptyState = "sliver_empty_state";
  static const String sliverHeaderAnimationPage = "header_animation_page";
  static const String sliverEffects = "sliver_effects_page";
  static const String sliverCollapseToFAB = "sliver_collapse_FAB_example";
  static const String sliverPullToRefreshPage = "sliver_pull_torefresh_page";
  static const String sliverTimeLinePage = "sliver_timeline_page";
  static const String scrollSpySliverViewExample =
      "scroll_spy_sliver_view_example";
  static const String stickyHeaderExample = "sticky_header_example";
  static const String sliverOnboardingWithContentExample =
      "sliver_onboarding_with_content_example";
  static const String sliverMapPreviewExample = "sliver_map_preview_example";
  static const String sliverFadeSearchHeaderExample =
      "fade_search_header_example";
  //*regions Sliver

  static const String visibilityDetectorExample = "visibility_detector_example";
  static const String flutter3dScreen = "flutter_3d_screen";

  //*regions Chart
  static const String sfCartesianChartPage = "sf_cartesian_chart_page";
  static const String sfSparkBarChartPage = "sf_spark_bar_chart_page";
  static const String sfCircularChartPage = "sf_circular_chart_page";
  static const String sfPyramidChartPage = "sf_pyramid_chart_page";

  //*regions Chart

  //*regions Indicator
  static const String indicatorExampleScreen = "indicator_example_screen";

  static const String dropWaterIndicator = "drop_water_indicator";
  static const String iceCreamIndicator = "ice_cream_indicator";
  static const String fetchMoreIndicator = "fetch_more_indicator_page";
  static const String dropWaterLottieRefreshIndicator =
      "drop_water_lottie_refresh_indicator_page";
  static const String arrowDownIndicator = "arrow_down_indicator_page";
  static const String homeRefreshIndicator = "home_refresh_indicator_page";

  //*regions Indicator

  //* regions ScrollPhysic
  static const String scrollPhysicScreen = "scroll_physic_screen";
  static const String alwaysBounceScrollPhysicsExample =
      "always_bounce_scroll_physics_example";
  static const String noScrollPhysicExample = "no_scroll_physics_example";
  static const String noBounceScrollPhysicsExample =
      "no_bounce_scroll_physics_example";
  static const String reversedScrollPhysicsExample =
      "reversed_scroll_physics_example";
  static const String rubberBandScrollPhysicsExample =
      "rubber_band_scroll_physics_example";
  static const String slowDownScrollPhysicsExample =
      "slow_down_scroll_physics_example";
  static const String snappingScrollPhysicsExample =
      "snapping_scroll_physics_example";
  static const String rubberSpringBackPhysicsExample =
      "rubber_spring_back_physics_example";
  //* regions ScrollPhysic
  static const String pmsSDKLogin = "pms_login";

  // mobimap_module
  static const String mobimapModule = "mobimap_module_app";

  static const String camerawesome = "camera_wesome_screen";

  // flutter text theme
  static const String settingTextThemeScreen = "setting_text_theme_screen";

  // game tic tac toe
  static const String ticTacToeGame = 'tic_tac_toe_game';

  // game rubik
  static const String rubikGame = 'rubik_game';

  // talker logger example
  static const String talkerScreen = 'talker_example_screen';

  static String current(BuildContext context) =>
      ModalRoute.of(context)?.settings.name ?? '';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final arguments =
        settings.arguments != null && settings.arguments is ArgumentsScreenModel
            ? settings.arguments as ArgumentsScreenModel
            : ArgumentsScreenModel(title: "unknowns");
    switch (settings.name) {
      case talkerScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: talkerScreen),
          builder: (_) => TalkerExampleScreen(talker: AppTalker.instance),
        );
      case rubikGame:
        return MaterialPageRoute(
          settings: RouteSettings(name: rubikGame),
          builder: (_) => const RubikScreen(),
        );
      case ticTacToeGame:
        return MaterialPageRoute(
          settings: RouteSettings(name: ticTacToeGame),
          builder: (_) => const GameScreen(),
        );
      case testScreen:
        return MaterialPageRoute(
          settings: RouteSettings(name: testScreen),
          builder: (_) => TestScreen(),
        );
      case splashV1:
        return MaterialPageRoute(
          settings: RouteSettings(name: splashV1),
          builder: (_) => const SplashV1Screen(),
        );
      case onboardingStep1:
        return MaterialPageRoute(
          settings: RouteSettings(name: onboardingStep1),
          builder: (_) => OnboardingStep1Screen(onNext: () {}, onSkip: () {}),
        );
      case onboardingStep2:
        return MaterialPageRoute(
          settings: RouteSettings(name: onboardingStep2),
          builder: (_) => OnboardingStep2Screen(onNext: () {}, onSkip: () {}),
        );
      case onboardingStep3:
        return MaterialPageRoute(
          settings: RouteSettings(name: onboardingStep3),
          builder: (_) => OnboardingStep3Screen(onGetStarted: () {}),
        );
      case onboardingPageView:
        return MaterialPageRoute(
          settings: RouteSettings(name: onboardingPageView),
          builder: (_) => const OnboardingPageView(),
        );
      case loginV1:
        return MaterialPageRoute(
          settings: RouteSettings(name: loginV1),
          builder: (_) => const LoginV1Screen(),
        );
      case transformerPageView:
        return MaterialPageRoute(
          settings: RouteSettings(name: transformerPageView),
          builder: (_) => TransformerExamplePage(),
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
      case shimmerBaseTest:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: shimmerBaseTest),
          builder: (_) => const ShimmerBaseTestScreen(),
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
        final cameraArgs = settings.arguments as Map<String, dynamic>?;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: cameraScreen),
          builder: (_) => CameraScreen(
            initialMode: cameraArgs?['mode'] as CameraMode? ?? CameraMode.photo,
            onPhotoCaptured:
                cameraArgs?['onPhotoCaptured'] as void Function(XFile)?,
            onVideoRecorded:
                cameraArgs?['onVideoRecorded'] as void Function(XFile)?,
          ),
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

      // case webBrowserScreen:
      //   return SlideRightRoute(
      //     routeSettings: RouteSettings(name: webBrowserScreen),
      //     builder: (_) => WebViewExample(),
      //   );

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
          builder: (_) => const ARKitScreen(),
        );
      case lidarScanner:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: lidarScanner),
          builder: (_) => const ScannerScreen(),
        );
      case photo3D:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: photo3D),
          builder: (_) => const Photo3DScreen(),
        );
      case photoTo3D:
        final file = settings.arguments as XFile;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: photoTo3D),
          builder: (_) => PhotoTo3DScreen(imageFile: file),
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
      case googleMapBase:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: googleMapBase),
          builder: (_) => const GoogleMapBaseScreen(),
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
      case materialSnackbar:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialSnackbar),
          builder: (_) => (MaterialSnackbarScreen(data: param)),
        );
      case materialNavigationRail:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialNavigationRail),
          builder: (_) => (MaterialNavigationRailScreen(data: param)),
        );

      case materialSideSheetScreen:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialSideSheetScreen),
          builder: (_) => (MaterialSideSheetScreen(data: param)),
        );
      case materialIConButton:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialIConButton),
          builder: (_) => (MaterialIconButtonScreen(data: param)),
        );
      case materialLists:
        final param = arguments.data as RouterMaterialModel;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: materialLists),
          builder: (_) => (MaterialListsDetail(data: param)),
        );
      case graphicsScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: graphicsScreen),
            builder: (_) => GraphicsScreen());
      case customPaintScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: customPaintScreen),
            builder: (_) => CustomPainterScreen());
      case reducerScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: reducerScreen),
            builder: (_) => ReducerScreen());
      case notificationScrollScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: reducerScreen),
            builder: (_) => NotificationScrollScreen());
      case menu:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: reducerScreen),
            builder: (_) => SliverAppMenu());
      case log:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: reducerScreen),
            builder: (_) => LogScreen());
      case pickFile:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: pickFile),
            builder: (_) => PickFileScreen());
      case scanScreen:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: scanScreen),
            builder: (_) => ScanScreen());
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
      case chatScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: chatScreen),
          builder: (_) => ChatScreen(),
        );
      case dropRefresh:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: dropRefresh),
          builder: (_) => DropRefreshScreen(),
        );
      case mapScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: mapScreen),
          builder: (_) => VietnamMapScreen(),
        );
      case exampleMapScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: exampleMapScreen),
          builder: (_) => const ExampleMapScreen(),
        );
      case offlineMbtilesMapScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: offlineMbtilesMapScreen),
          builder: (_) => const OfflineMbtilesMapScreen(),
        );
      case flutterMapOsmScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: flutterMapOsmScreen),
          builder: (_) => const FlutterMapOsmScreen(),
        );
      case isolateParseScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: isolateParseScreen),
          builder: (_) => IsolateJsonParsingScreen(),
        );
      case smartLoadmoreScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: smartLoadmoreScreen),
          builder: (_) => SmartLoadmoreScreen(),
        );
      case qrScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: qrScreen),
          builder: (_) => QRViewExample(),
        );
      case webViewScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: webViewScreen),
          builder: (_) => WebViewScreen(),
        );
      case streetViewScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: streetViewScreen),
          builder: (_) => StreetViewScreen(
            initialLat: args?['lat'],
            initialLng: args?['lng'],
          ),
        );
      case excellScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: excellScreen),
          builder: (_) => AutoFormulaExcelViewer(),
        );

      // Sliver Appbar
      case sliverAppbarCollapsingHeaderHero:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverAppbarCollapsingHeaderHero),
          builder: (_) => CollapsingHeaderPage(),
        );
      case sliverAppbarPersistentHeaderTabbar:
        return SlideRightRoute(
          routeSettings:
              RouteSettings(name: sliverAppbarPersistentHeaderTabbar),
          builder: (_) => SliverAppbarPersistentHeaderTabbar(),
        );
      case sliverAnimationListWrapperExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverAnimationListWrapperExample),
          builder: (_) => SliverAnimationListWrapperExample(),
        );
      case sliverParalaxSticky:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverParalaxSticky),
          builder: (_) => SliverParallaxStickyPage(),
        );
      case sliverMasonryGrid:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverMasonryGrid),
          builder: (_) => MasonrySliverGridPage(),
        );
      case sliverEmptyState:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverEmptyState),
          builder: (_) => SliverEmptyStatePage(),
        );
      case sliverHeaderAnimationPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverHeaderAnimationPage),
          builder: (_) => HeaderAnimationPage(),
        );
      case sliverEffects:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverEffects),
          builder: (_) => SliverEffectsPage(),
        );
      case sliverCollapseToFAB:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverCollapseToFAB),
          builder: (_) => SliverCollapseToFABExample(),
        );
      case sliverPullToRefreshPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverPullToRefreshPage),
          builder: (_) => SliverPullToRefreshPage(),
        );
      case sliverTimeLinePage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverTimeLinePage),
          builder: (_) => SliverTimelinePage(),
        );
      case scrollSpySliverViewExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: scrollSpySliverViewExample),
          builder: (_) => ScrollSpySliverViewExample(),
        );
      case stickyHeaderExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: stickyHeaderExample),
          builder: (_) => StickyHeaderExample(),
        );
      case sliverOnboardingWithContentExample:
        return SlideRightRoute(
          routeSettings:
              RouteSettings(name: sliverOnboardingWithContentExample),
          builder: (_) => SliverOnboardingWithContentExample(),
        );
      case sliverMapPreviewExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverMapPreviewExample),
          builder: (_) => SliverMapPreviewExample(),
        );
      case sliverFadeSearchHeaderExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sliverFadeSearchHeaderExample),
          builder: (_) => FadeSearchBarSliverExample(),
        );
      case visibilityDetectorExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: visibilityDetectorExample),
          builder: (_) => VisibilityDetectorDemo(),
        );
      case sfCartesianChartPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sfCartesianChartPage),
          builder: (_) => SFCartesianChartPage(),
        );
      case sfSparkBarChartPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sfSparkBarChartPage),
          builder: (_) => SFSparkBarChartPage(),
        );
      case sfCircularChartPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sfCircularChartPage),
          builder: (_) => SFCircularChartPage(),
        );
      case sfPyramidChartPage:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: sfPyramidChartPage),
          builder: (_) => SFPyramidChartPage(),
        );
      case flutter3dScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: flutter3dScreen),
          builder: (_) => Flutter3dScreen(),
        );

      case indicatorExampleScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: indicatorExampleScreen),
          builder: (_) => IndicatorExampleScreen(),
        );
      case dropWaterIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: dropWaterIndicator),
          builder: (_) => DropWaterIndicatorScreen(),
        );
      case iceCreamIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: iceCreamIndicator),
          builder: (_) => IceCreamIndicatorScreen(
            child: ListView(
              children: List.generate(
                20,
                (index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        );
      case fetchMoreIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: fetchMoreIndicator),
          builder: (_) => FetchMoreIndicatorPage(),
        );
      case dropWaterLottieRefreshIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: dropWaterLottieRefreshIndicator),
          builder: (_) => DropWaterLottieRefreshIndicatorPage(),
        );
      case arrowDownIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: arrowDownIndicator),
          builder: (_) => ArrowDownIndicatorPage(),
        );
      case homeRefreshIndicator:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: homeRefreshIndicator),
          builder: (_) => HomeRefreshIndicatorPage(),
        );
      case scrollPhysicScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: scrollPhysicScreen),
          builder: (_) => ScrollPhysicScreen(),
        );
      case alwaysBounceScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: alwaysBounceScrollPhysicsExample),
          builder: (_) => AlwaysBounceScrollPhysicsExample(),
        );
      case noScrollPhysicExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: noScrollPhysicExample),
          builder: (_) => NoScrollPhysicExample(),
        );
      case noBounceScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: noBounceScrollPhysicsExample),
          builder: (_) => NoBounceScrollPhysicsExample(),
        );
      case reversedScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: reversedScrollPhysicsExample),
          builder: (_) => ReversedScrollPhysicsExample(),
        );
      case rubberBandScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: rubberBandScrollPhysicsExample),
          builder: (_) => RubberBandScrollPhysicsExample(),
        );
      case slowDownScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: slowDownScrollPhysicsExample),
          builder: (_) => SlowDownScrollPhysicsExample(),
        );
      case snappingScrollPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: snappingScrollPhysicsExample),
          builder: (_) => SnappingScrollPhysicsExample(),
        );
      case rubberSpringBackPhysicsExample:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: rubberSpringBackPhysicsExample),
          builder: (_) => RubberSpringBackPhysicsExample(),
        );
      case camerawesome:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: camerawesome),
          builder: (_) => CameraWeSomeScreen(),
        );
      case login:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: login),
          builder: (_) => LoginScreen(),
        );
      case newLogin:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: newLogin),
          builder: (_) => const LoginPage(),
        );
      case settingTextThemeScreen:
        final param = arguments.data as Map;
        return SlideRightRoute(
          routeSettings: RouteSettings(name: settingTextThemeScreen),
          builder: (_) => SettingTextThemeScreen(
            role: param['role'],
          ),
        );
      case newsScreen:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: newsScreen),
          builder: (_) => const NewsScreen(),
        );
      case googleMapOffline:
        return SlideRightRoute(
          routeSettings: RouteSettings(name: googleMapOffline),
          builder: (_) => const GoogleMapOfflineScreen(),
        );
      case defaultRoute:
      default:
        return SlideRightRoute(
            routeSettings: RouteSettings(name: defaultRoute),
            builder: (_) => TestScreen());
    }
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final RouteSettings? routeSettings;
  final bool vertical;

  SlideRightRoute(
      {required this.builder, this.routeSettings, this.vertical = false})
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
            final offsetAnimation =
                Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOut))
                    .animate(animation);

            final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut))
                .animate(animation);
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
            // return SlideTransition(
            //   position: offsetAnimation,
            //   child: FadeTransition(
            //     opacity: opacityAnimation,
            //     child: child,
            //   ),
            // );
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
