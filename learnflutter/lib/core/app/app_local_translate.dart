/// Mixin AppLocaleTranslate đóng vai trò là kho lưu trữ tập trung cho tất cả các chuỗi ký tự hiển thị trong ứng dụng.
/// Nó hỗ trợ đa ngôn ngữ bao gồm tiếng Anh, tiếng Khmer, tiếng Nhật và tiếng Việt để phục vụ người dùng toàn cầu.
/// Việc sử dụng các hằng số tĩnh giúp tránh lỗi đánh máy và dễ dàng bảo trì khi cần thay đổi nội dung thông báo.
/// Cơ chế này tích hợp chặt chẽ với thư viện flutter_localization để thực hiện việc chuyển đổi ngôn ngữ động trong thời gian thực.
mixin AppLocaleTranslate {
  static const String title = 'title';
  static const String thisIs = 'thisIs';

  // Login Screen
  static const String loginTitle = 'loginTitle';
  static const String loginSubtitle = 'loginSubtitle';
  static const String emailLabel = 'emailLabel';
  static const String emailHint = 'emailHint';
  static const String passwordLabel = 'passwordLabel';
  static const String passwordHint = 'passwordHint';
  static const String forgotPassword = 'forgotPassword';
  static const String loginButton = 'loginButton';
  static const String noAccount = 'noAccount';
  static const String register = 'register';

  // Messages
  static const String passwordEmptyError = 'passwordEmptyError';
  static const String loginSuccess = 'loginSuccess';
  static const String unknownError = 'unknownError';
  static const String errorPrefix = 'errorPrefix';
  static const String registerSuccess = 'registerSuccess';
  static const String registrationErrorPrefix = 'registrationErrorPrefix';

  // App Root & Intro Splash
  static const String petSocialTitle = 'petSocialTitle';
  static const String petSocialSubtitle = 'petSocialSubtitle';
  static const String startButton = 'startButton';
  static const String petSocialCredits = 'petSocialCredits';
  static const String splashInitialized = 'splashInitialized';
  static const String initializationComplete = 'initializationComplete';
  static const String splashAnimationEnded = 'splashAnimationEnded';
  static const String initDoneReadyNavigate = 'initDoneReadyNavigate';
  static const String transformerExampleTitle = 'transformerExampleTitle';
  static const String pageIndex = 'pageIndex';
  static const String workExcellFile = 'workExcellFile';
  static const String testScreenTitle = 'testScreenTitle';
  static const String testGlobalNoKeyboardRebuild =
      'testGlobalNoKeyboardRebuild';
  static const String cameraWesome = 'cameraWesome';
  static const String codePushPatch = 'codePushPatch';
  static const String mobimapModule = 'mobimapModule';
  static const String colorPickerScreen = 'colorPickerScreen';
  static const String inputHistoryHint = 'inputHistoryHint';
  static const String scrollPhysicScreen = 'scrollPhysicScreen';
  static const String indicatorExample = 'indicatorExample';
  static const String pluginNghiemThu = 'pluginNghiemThu';
  static const String transformerPageViewExample = 'transformerPageViewExample';
  static const String testParseDataIsolate = 'testParseDataIsolate';
  static const String flutter3dScreen = 'flutter3dScreen';
  static const String visibilityDetectorExample = 'visibilityDetectorExample';
  static const String smartLoadmoreScreen = 'smartLoadmoreScreen';
  static const String vietnamMap = 'vietnamMap';
  static const String dropRefreshControl = 'dropRefreshControl';
  static const String chatScreen = 'chatScreen';
  static const String troubleShootingScreen = 'troubleShootingScreen';
  static const String floatingDraggableWidget = 'floatingDraggableWidget';
  static const String treeNode = 'treeNode';
  static const String balanceBar = 'balanceBar';
  static const String getPointIntoFileSvg = 'getPointIntoFileSvg';
  static const String segmented = 'segmented';
  static const String scan = 'scan';
  static const String pickFile = 'pickFile';
  static const String log = 'log';
  static const String sliderAppBar = 'sliderAppBar';
  static const String notificationScrollScreen = 'notificationScrollScreen';
  static const String reducerScreen = 'reducerScreen';
  static const String customPaintScreen = 'customPaintScreen';
  static const String graphicsScreen = 'graphicsScreen';
  static const String material3UI = 'material3UI';
  static const String customScrollScreen = 'customScrollScreen';
  static const String regexExampleScreen = 'regexExampleScreen';
  static const String dragTargetScreen = 'dragTargetScreen';
  static const String chartScreen = 'chartScreen';
  static const String refreshControlScreen = 'refreshControlScreen';
  static const String arKitScreen = 'arKitScreen';
  static const String splitString = 'splitString';
  static const String testTheme = 'testTheme';
  static const String testWebBrowser = 'testWebBrowser';
  static const String testDraggelScrollScreen = 'testDraggelScrollScreen';
  static const String openFile = 'openFile';
  static const String testCamera = 'testCamera';
  static const String pageLoadingScreen = 'pageLoadingScreen';
  static const String awesomeSnackBarExample = 'awesomeSnackBarExample';
  static const String testShimmerWidget = 'testShimmerWidget';
  static const String heroAnimationScreen = 'heroAnimationScreen';
  static const String hiveDemo = 'hiveDemo';
  static const String matixScreen = 'matixScreen';
  static const String progressHudScreen = 'progressHudScreen';
  static const String popoverClick = 'popoverClick';
  static const String nestedScrollScreen = 'nestedScrollScreen';
  static const String couraselScreen = 'couraselScreen';
  static const String menu = 'menu';
  static const String bmProgressHudScreen = 'bmProgressHudScreen';
  static const String interactiveViewer = 'interactiveViewer';
  static const String cupertinoActionSheet = 'cupertinoActionSheet';
  static const String cupertinoAlertDialog = 'cupertinoAlertDialog';
  static const String dateTimePicker = 'dateTimePicker';
  static const String dateTimeInput = 'dateTimeInput';
  static const String calendar = 'calendar';
  static const String actionSheetTitle = 'actionSheetTitle';
  static const String actionSheetMessage = 'actionSheetMessage';
  static const String actionSheetDefault = 'actionSheetDefault';
  static const String actionSheetAction = 'actionSheetAction';
  static const String actionSheetDestructive = 'actionSheetDestructive';
  static const String alertDialogTitle = 'alertDialogTitle';
  static const String alertDialogContent = 'alertDialogContent';
  static const String no = 'no';
  static const String yes = 'yes';
  static const String confirm = 'confirm';
  static const String cancel = 'cancel';
  static const String description = 'description';
  static const String info = 'info';
  static const String success = 'success';
  static const String error = 'error';
  static const String loadingData = 'loadingData';

  static const Map<String, dynamic> EN = {
    title: 'Localization',
    thisIs: 'This is %a package, version %a.',
    loginTitle: 'Login',
    loginSubtitle: 'Please enter email and password to continue',
    emailLabel: 'Email',
    emailHint: 'Enter email',
    passwordLabel: 'Password',
    passwordHint: 'Enter password',
    forgotPassword: 'Forgot password?',
    loginButton: 'Login',
    noAccount: "Don't have an account? ",
    register: 'Register',
    passwordEmptyError: 'Password cannot be empty',
    loginSuccess: 'Login successful',
    unknownError: 'Unknown error',
    errorPrefix: 'Error: ',
    registerSuccess: 'Registration successful. Please login',
    registrationErrorPrefix: 'Registration error: ',
    petSocialTitle: 'PetSocial',
    petSocialSubtitle: 'Where pet owners connect and share knowledge',
    startButton: 'Start',
    petSocialCredits: 'Connecting animal lovers',
    splashInitialized: 'Splash Screen Initialized',
    initializationComplete: 'Initialization Complete',
    splashAnimationEnded: 'Splash animation ended, waiting init...',
    initDoneReadyNavigate: 'Init done, ready to navigate',
    transformerExampleTitle: 'Transformer Page View Example',
    pageIndex: 'Page %a',
    workExcellFile: 'Work Excell File',
    testScreenTitle: 'Test Screen',
    testGlobalNoKeyboardRebuild: 'Test GlobalNoKeyboardRebuild',
    cameraWesome: 'Camera wesome',
    codePushPatch: 'Code Push patch',
    mobimapModule: 'Mobimap Module',
    colorPickerScreen: 'colorPicker Screen',
    inputHistoryHint: 'Enter keyword...',
    scrollPhysicScreen: 'scrollPhysic Screen',
    indicatorExample: 'Indicator Example',
    pluginNghiemThu: 'Plugin Acceptance',
    transformerPageViewExample: 'TransformerPageView Example',
    testParseDataIsolate: 'test parse data isolate',
    flutter3dScreen: 'flutter3dScreen',
    visibilityDetectorExample: 'visibilityDetectorExample',
    smartLoadmoreScreen: 'smartLoadmoreScreen',
    vietnamMap: 'VietNam Map',
    dropRefreshControl: 'Drop Refresh Control',
    chatScreen: 'chat Screen',
    troubleShootingScreen: 'TroubleShootingScreen',
    floatingDraggableWidget: 'FloatingDraggableWidget',
    treeNode: 'Tree Node',
    balanceBar: 'balanceBar',
    getPointIntoFileSvg: 'get point into file svg',
    segmented: 'Segmented',
    scan: 'Scan',
    pickFile: 'Pick File',
    log: 'Log',
    sliderAppBar: 'Slider AppBar',
    notificationScrollScreen: 'NotificationScrollScreen',
    reducerScreen: 'reducer Screen',
    customPaintScreen: 'custom Paint Screen',
    graphicsScreen: 'graphics Screen',
    material3UI: 'material 3 UI',
    customScrollScreen: 'customScrollScreen',
    regexExampleScreen: 'regexExampleScreen',
    dragTargetScreen: 'dragTargetScreen',
    chartScreen: 'chart Screen',
    refreshControlScreen: 'refreshControl Screen',
    arKitScreen: 'AR Kit Screen',
    splitString: 'Split String',
    testTheme: 'Test Theme',
    testWebBrowser: 'Test Web Browser',
    testDraggelScrollScreen: 'Test draggel_scroll_screen',
    openFile: 'Tap to open file',
    testCamera: 'Test Camera',
    pageLoadingScreen: 'Page Loading Screen',
    awesomeSnackBarExample: 'AweseomSnackBarExample',
    testShimmerWidget: 'Test Shimmer Widget',
    heroAnimationScreen: 'Hero Animation Screen',
    hiveDemo: 'Hive Demo',
    matixScreen: 'matix Screen',
    progressHudScreen: 'progressHud Screen',
    popoverClick: 'Popover Click',
    nestedScrollScreen: 'nested_scroll_screen',
    couraselScreen: 'courasel_screen',
    menu: 'Menu',
    bmProgressHudScreen: 'bmprogresshud_screen',
    interactiveViewer: 'InteractiveViewer',
    cupertinoActionSheet: 'CupertinoActionSheet',
    cupertinoAlertDialog: 'CupertinoAlertDialog',
    dateTimePicker: 'Date time Picker',
    dateTimeInput: 'date_time_input',
    calendar: 'calender',
    actionSheetTitle: 'Title',
    actionSheetMessage: 'Message',
    actionSheetDefault: 'Default Action',
    actionSheetAction: 'Action',
    actionSheetDestructive: 'Destructive Action',
    alertDialogTitle: 'Alert',
    alertDialogContent: 'Proceed with destructive action?',
    no: 'No',
    yes: 'Yes',
    confirm: 'Confirm',
    cancel: 'Cancel',
    description: 'Description',
    info: 'Information',
    success: 'Success',
    error: 'Error',
    loadingData: 'Updating data...',
  };
  static const Map<String, dynamic> KM = {
    title: 'ការធ្វើមូលដ្ឋានីយកម្ម',
    thisIs: 'នេះគឺជាកញ្ចប់%a កំណែ%a.',
    loginTitle: 'ចូល',
    loginSubtitle: 'សូមបញ្ចូលអ៊ីមែល និង mật khẩu để tiếp tục',
    emailLabel: 'អ៊ីមែល',
    emailHint: 'បញ្ចូលអ៊ីមែល',
    passwordLabel: 'ពាក្យសម្ងាត់',
    passwordHint: 'បញ្ចូលពាក្យសម្ងាត់',
    forgotPassword: 'ភ្លេចពាក្យសម្ងាត់?',
    loginButton: 'ចូល',
    noAccount: 'មិនទាន់មានគណនី? ',
    register: 'ចុះឈ្មោះ',
    transformerExampleTitle: 'ឧទាហរណ៍ការមើលទំព័រ Transformer',
    pageIndex: 'ទំព័រ %a',
  };
  static const Map<String, dynamic> JA = {
    title: 'ローカリゼーション',
    thisIs: 'これは%aパッケージ、バージョン%aです。',
    loginTitle: 'ログイン',
    loginSubtitle: '続行するにはメールアドレスとパスワードを入力してください',
    emailLabel: 'メールアドレス',
    emailHint: 'メールアドレスを入力してください',
    passwordLabel: 'パスワード',
    passwordHint: 'パスワードを入力してください',
    forgotPassword: 'パスワードをお忘れですか？',
    loginButton: 'ログイン',
    noAccount: 'アカウントをお持ちではありませんか？ ',
    register: '登録',
    passwordEmptyError: 'パスワードを入力してください',
    loginSuccess: 'ログインに成功しました',
    unknownError: '不明なエラーが発生しました',
    errorPrefix: 'エラー: ',
    registerSuccess: '登録が完了しました。ログインしてください',
    registrationErrorPrefix: '登録エラー: ',
    petSocialTitle: 'PetSocial',
    petSocialSubtitle: 'ペットの飼い主がつながり、知識を共有する場所',
    startButton: '開始',
    petSocialCredits: '動物愛好家をつなぐ',
    splashInitialized: 'スプラッシュ画面が初期化されました',
    initializationComplete: '初期化完了',
    splashAnimationEnded: 'スプラッシュアニメーションが終了しました。初期化を待っています...',
    initDoneReadyNavigate: '初期化が完了しました。ナビゲーションの準備ができました',
    transformerExampleTitle: 'Transformerページビューの例',
    pageIndex: 'ページ %a',
  };
  static const Map<String, dynamic> VI = {
    title: 'Tiêu đề',
    thisIs: 'Đây là tiêu đề',
    loginTitle: 'Đăng nhập',
    loginSubtitle: 'Vui lòng nhập email và mật khẩu để tiếp tục',
    emailLabel: 'Email',
    emailHint: 'Nhập email',
    passwordLabel: 'Mật khẩu',
    passwordHint: 'Nhập mật khẩu',
    forgotPassword: 'Quên mật khẩu?',
    loginButton: 'Đăng nhập',
    noAccount: 'Chưa có tài khoản? ',
    register: 'Đăng ký',
    passwordEmptyError: 'Mật khẩu không được để trống',
    loginSuccess: 'Đăng nhập thành công',
    unknownError: 'Lỗi không xác định',
    errorPrefix: 'Lỗi: ',
    registerSuccess: 'Đăng ký thành công. Vui lòng đăng nhập',
    registrationErrorPrefix: 'Lỗi đăng ký: ',
    petSocialTitle: 'PetSocial',
    petSocialSubtitle: 'Nơi chủ thú cưng giao lưu và chia sẻ kiến thức',
    startButton: 'Bắt đầu',
    petSocialCredits: 'Kết nối những người yêu động vật',
    splashInitialized: 'Khởi tạo màn hình chào',
    initializationComplete: 'Khởi tạo hoàn tất',
    splashAnimationEnded: 'Kết thúc hiệu ứng chào, đang đợi khởi tạo...',
    initDoneReadyNavigate: 'Khởi tạo xong, sẵn sàng điều hướng',
    transformerExampleTitle: 'Ví dụ Transformer Page View',
    pageIndex: 'Trang %a',
    workExcellFile: 'Làm việc với tệp Excell',
    testScreenTitle: 'Màn hình thử nghiệm',
    testGlobalNoKeyboardRebuild: 'Thử nghiệm GlobalNoKeyboardRebuild',
    cameraWesome: 'Máy ảnh wesome',
    codePushPatch: 'Bản vá Code Push',
    mobimapModule: 'Mô-đun Mobimap',
    colorPickerScreen: 'Màn hình chọn màu',
    inputHistoryHint: 'Nhập từ khóa...',
    scrollPhysicScreen: 'Màn hình cuộn vật lý',
    indicatorExample: 'Ví dụ chỉ số',
    pluginNghiemThu: 'Plugin Nghiệm thu',
    transformerPageViewExample: 'Ví dụ TransformerPageView',
    testParseDataIsolate: 'Thử nghiệm phân tích dữ liệu isolate',
    flutter3dScreen: 'Màn hình Flutter 3D',
    visibilityDetectorExample: 'Ví dụ phát hiện hiển thị',
    smartLoadmoreScreen: 'Màn hình tải thêm thông minh',
    vietnamMap: 'Bản đồ Việt Nam',
    dropRefreshControl: 'Điều khiển làm mới thả',
    chatScreen: 'Màn hình trò chuyện',
    troubleShootingScreen: 'Màn hình xử lý sự cố',
    floatingDraggableWidget: 'Widget trượt nổi',
    treeNode: 'Nút dạng cây',
    balanceBar: 'Thanh cân bằng',
    getPointIntoFileSvg: 'Lấy điểm trong tệp svg',
    segmented: 'Phân đoạn',
    scan: 'Quét',
    pickFile: 'Chọn tệp',
    log: 'Nhật ký',
    sliderAppBar: 'Thanh ứng dụng trượt',
    notificationScrollScreen: 'Màn hình cuộn thông báo',
    reducerScreen: 'Màn hình rút gọn',
    customPaintScreen: 'Màn hình vẽ tùy chỉnh',
    graphicsScreen: 'Màn hình đồ họa',
    material3UI: 'Giao diện Material 3',
    customScrollScreen: 'Màn hình cuộn tùy chỉnh',
    regexExampleScreen: 'Màn hình ví dụ Regex',
    dragTargetScreen: 'Màn hình mục tiêu kéo',
    chartScreen: 'Màn hình biểu đồ',
    refreshControlScreen: 'Màn hình điều khiển làm mới',
    arKitScreen: 'Màn hình AR Kit',
    splitString: 'Tách chuỗi',
    testTheme: 'Thử nghiệm chủ đề',
    testWebBrowser: 'Thử nghiệm trình duyệt web',
    testDraggelScrollScreen: 'Thử nghiệm màn hình cuộn kéo',
    openFile: 'Chạm để mở tệp',
    testCamera: 'Thử nghiệm máy ảnh',
    pageLoadingScreen: 'Màn hình đang tải trang',
    awesomeSnackBarExample: 'Ví dụ SnackBar tuyệt đẹp',
    testShimmerWidget: 'Thử nghiệm Widget hiệu ứng lấp lánh',
    heroAnimationScreen: 'Màn hình hiệu ứng Hero',
    hiveDemo: 'Bản thử nghiệm Hive',
    matixScreen: 'Màn hình ma trận',
    progressHudScreen: 'Màn hình HUD tiến trình',
    popoverClick: 'Chạm Popover',
    nestedScrollScreen: 'Màn hình cuộn lồng nhau',
    couraselScreen: 'Màn hình băng chuyền',
    menu: 'Danh mục',
    bmProgressHudScreen: 'Màn hình HUD tiến trình BM',
    interactiveViewer: 'Trình xem tương tác',
    cupertinoActionSheet: 'Bảng hành động Cupertino',
    cupertinoAlertDialog: 'Hộp thoại cảnh báo Cupertino',
    dateTimePicker: 'Chọn ngày giờ',
    dateTimeInput: 'Nhập ngày giờ',
    calendar: 'Lịch',
    actionSheetTitle: 'Tiêu đề',
    actionSheetMessage: 'Thông báo',
    actionSheetDefault: 'Hành động mặc định',
    actionSheetAction: 'Hành động',
    actionSheetDestructive: 'Hành động hủy diệt',
    alertDialogTitle: 'Cảnh báo',
    alertDialogContent: 'Tiếp tục với hành động hủy diệt?',
    no: 'Hủy',
    yes: 'Đồng ý',
    confirm: 'Xác nhận',
    cancel: 'Hủy bỏ',
    description: 'Mô tả',
    info: 'Thông báo',
    success: 'Thành công',
    error: 'Lỗi',
    loadingData: 'Đang cập nhật dữ liệu...',
  };
}
