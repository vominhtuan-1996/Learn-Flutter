/// Lớp AppAssets quản lý tập trung tất cả các đường dẫn tài nguyên tĩnh của ứng dụng như hình ảnh, biểu tượng và tệp cấu hình.
/// Việc sử dụng các hằng số tĩnh giúp tránh các lỗi gõ sai đường dẫn trong quá trình phát triển và hỗ trợ tính năng tự động gợi ý của IDE.
/// Cấu trúc này cũng giúp dễ dàng bảo trì khi cần thay đổi vị trí tệp tin mà không phải tìm kiếm và sửa đổi ở nhiều nơi trong mã nguồn.
/// Đây là một phần quan trọng trong việc xây dựng hệ thống thiết kế nhất quán và chuyên nghiệp cho toàn bộ dự án Flutter.
class AppAssets {
  AppAssets._();

  /// Thư mục chứa các mô hình 3D được sử dụng để hiển thị các thành phần trực quan sinh động trong ứng dụng.
  /// Các tệp tin này thường có định dạng GLB để đảm bảo hiệu suất tải và tương thích tốt nhất với bộ công cụ render.
  /// Việc quản lý riêng biệt giúp các nhà phát triển dễ dàng cập nhật hoặc thay thế các mô hình mà không ảnh hưởng đến phần còn lại.
  static const String modelBusinessMan = 'assets/3d/business_man.glb';

  /// Danh sách các biểu tượng hệ thống được tối ưu hóa cho mục đích hiển thị trong các thành phần giao diện người dùng.
  /// Các tệp tin định dạng WebP và SVG được ưu tiên sử dụng để đảm bảo chất lượng hình ảnh sắc nét trên mọi mật độ điểm ảnh.
  /// Mỗi biểu tượng đều được đặt tên gợi nhớ theo chức năng cụ thể như thông báo, tìm kiếm hoặc điều hướng trong ứng dụng.
  static const String iconMomoMoneyIn = 'assets/icons/momomain_money_in.webp';
  static const String iconMomoWithdraw = 'assets/icons/momomain_withdraw.webp';
  static const String iconHomeWalletInactive =
      'assets/icons/home_wallet_inactive.webp';
  static const String iconNavigationQrCode =
      'assets/icons/navigation_qrcode.webp';
  static const String iconChatComment = 'assets/icons/chat_comment.webp';
  static const String iconHomeRefresh = 'assets/icons/home_refresh.svg';
  static const String iconSearch = 'assets/icons/search.webp';
  static const String iconNotificationsBell =
      'assets/icons/notifications_bell.webp';
  static const String iconPopupSuccess = 'assets/icons/ic_popup_success.svg';

  /// Các tài nguyên hình ảnh dùng cho màn hình đăng nhập và các hoạt ảnh liên quan đến xác thực người dùng.
  /// Hình ảnh GIF được sử dụng để tạo ra nền động bắt mắt, giúp tăng tính tương tác và trải nghiệm người dùng ngay từ lúc bắt đầu.
  /// Chúng tôi lưu trữ riêng biệt để dễ dàng tùy chỉnh giao diện đăng nhập theo các chiến dịch marketing hoặc sự kiện đặc biệt.
  static const String loginBackground =
      'assets/login/background_screen_login.gif';

  /// Tập hợp các hình ảnh minh họa, ảnh nền và các biểu tượng giao diện chính được sử dụng xuyên suốt trong ứng dụng.
  /// Các định dạng tải nhanh như WebP và GIF được sử dụng linh hoạt để cân bằng giữa chất lượng hình ảnh và hiệu năng bộ nhớ.
  /// Mỗi hằng số tương ứng với một tệp tin cụ thể trong thư mục images, hỗ trợ việc xây dựng giao diện người dùng nhanh chóng.
  static const String imgTcssLauncherV2 = 'assets/images/tcss_launcher_v2.gif';
  static const String imgTcssLauncherV3 = 'assets/images/tcss_launcher_v3.gif';
  static const String imgTabbarMapSelected =
      'assets/images/ic_tabbar_map_selected.png';
  static const String imgTabbarMapUnselected =
      'assets/images/ic_tabbar_map_unselected.png';
  static const String imgTabbarUserUnselected =
      'assets/images/ic_tabbar_user_unselected.png';
  static const String imgTcssLauncherV4 = 'assets/images/tcss_launcher_v4.gif';
  static const String imgNotification = 'assets/images/ic_notification.png';
  static const String imgFolder = 'assets/images/ic_folder.svg';
  static const String imgTcssLauncher = 'assets/images/tcss_launcher.gif';
  static const String imgTcssLauncherV6 = 'assets/images/tcss_launcher_v6.gif';
  static const String imgTabbarScanQrCode =
      'assets/images/ic_tabbar_scanQRCode.png';
  static const String imgLauncherMobimapRii1 =
      'assets/images/laucher_mobimap_rii_1.gif';
  static const String imgMenuMark = 'assets/images/ic_menu_mark.png';
  static const String imgLauncherMobimapRii2 =
      'assets/images/laucher_mobimap_rii_2.gif';
  static const String imgMenuMaintenance =
      'assets/images/ic_menu_maintenance.png';
  static const String imgLoadingMobimapRii =
      'assets/images/loading_mobimap_rii.gif';
  static const String imgFile = 'assets/images/ic_file.svg';
  static const String imgMenuRatingStar =
      'assets/images/ic_menu_rating_star.png';
  static const String imgTabbarUserSelected =
      'assets/images/ic_tabbar_user_selected.png';
  static const String imgTabbarSearchSelected =
      'assets/images/ic_tabbar_search_selected.png';
  static const String imgTcssSplash = 'assets/images/tcss_splash.gif';
  static const String imgLauncherMobimap = 'assets/images/laucher_mobimap.gif';
  static const String imgLaunchTcssV7 = 'assets/images/launch_tcss_v7.gif';
  static const String imgBackgroundMobi = 'assets/images/background_mobi.png';
  static const String imgTabbarToolUnselected =
      'assets/images/ic_tabbar_tool_unselected.png';
  static const String imgLauncherMobimapRii =
      'assets/images/laucher_mobimap_rii.gif';
  static const String imgMenuAcceptance =
      'assets/images/ic_menu_acceptance.png';
  static const String imgMedia = 'assets/images/Media.svg';
  static const String imgTabbarToolSelected =
      'assets/images/ic_tabbar_tool_selected.png';
  static const String imgHeaderBgr = 'assets/images/header_bgr.webp';
  static const String imgSliderAppbarBgr =
      'assets/images/slier_appbar_bgr.webp';
  static const String imgSearchOrange = 'assets/images/ic_search_organe.png';
  static const String imgTabbarSearchUnselected =
      'assets/images/ic_tabbar_search_unselected.png';
  static const String imgHeaderAppbarBgr =
      'assets/images/header_appbar_bgr.webp';
  static const String imgMenuSurvey = 'assets/images/ic_menu_survey.png';
  static const String imgTest = 'assets/images/test.svg';

  /// Các tệp tin dữ liệu định dạng JSON chứa thông tin bản đồ địa lý và các ranh giới hành chính của Việt Nam.
  /// Dữ liệu này được sử dụng để vẽ các bản đồ nhiệt hoặc hiển thị thông tin khu vực trên bản đồ tương tác trong ứng dụng.
  /// Việc tải dữ liệu từ tệp tin cục bộ giúp ứng dụng hoạt động mượt mà hơn và không phụ thuộc quá nhiều vào kết nối internet.
  static const String jsonVietnamGeo = 'assets/json/vietnam.geo.json';
  static const String jsonVietnamPraracesIslandsGeo =
      'assets/json/vietname_praraces_islands.geo.json';
  static const String jsonVietnamSpratlyIslandsGeo =
      'assets/json/vietname_spratly_islands.geo.json';

  /// Các tệp tin hoạt ảnh Lottie giúp mang lại các chuyển động mượt mà và sinh động cho giao diện ứng dụng.
  /// Hoạt ảnh này đặc biệt hữu dụng trong các trạng thái đang tải hoặc thông báo làm mới dữ liệu để cải thiện trải nghiệm người dùng.
  /// Chúng tôi sử dụng định dạng vector để đảm bảo dung lượng nhẹ nhưng vẫn giữ được độ sắc nét tối đa trên mọi kích thước màn hình.
  static const String lottieRefreshWaterDrop =
      'assets/lottie/refresh_water_drop.json';

  /// Kho tệp tin âm thanh cung cấp các hiệu ứng âm thanh phản hồi cho các tương tác của người dùng trên ứng dụng.
  /// Định dạng WAV được chọn để đảm bảo chất lượng âm thanh trung thực và khả năng phát lại tức thì không có độ trễ lớn.
  /// Những hiệu ứng này góp phần tạo nên sự tương tác sống động, giúp người dùng nhận biết được kết quả của các hành động mình vừa thực hiện.
  static const String soundEffectRefreshing =
      'assets/sound/sound_effect_refreshing.wav';

  static String icEmpty = 'assets/images/ic_empty.png';
}
