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
  static const String registerTitle = 'registerTitle';
  static const String nameLabel = 'nameLabel';
  static const String nameHint = 'nameHint';
  static const String keepMeSignedIn = 'keepMeSignedIn';
  static const String createButton = 'createButton';
  static const String alreadyHaveAccount = 'alreadyHaveAccount';
  static const String signUpWith = 'signUpWith';
  static const String passwordHint = 'passwordHint';
  static const String forgotPassword = 'forgotPassword';
  static const String loginButton = 'loginButton';
  static const String noAccount = 'noAccount';
  static const String register = 'register';
  static const String forgotPasswordTitle = 'forgotPasswordTitle';
  static const String forgotPasswordDescription = 'forgotPasswordDescription';
  static const String sendResetLink = 'sendResetLink';
  static const String rememberPassword = 'rememberPassword';
  static const String forgotPasswordEmailHint = 'forgotPasswordEmailHint';
  static const String homeGreeting = 'homeGreeting';
  static const String dailyQuote = 'dailyQuote';
  static const String dailyQuoteAuthor = 'dailyQuoteAuthor';
  static const String inProgress = 'inProgress';
  static const String doneButton = 'doneButton';
  static const String homeTab = 'homeTab';
  static const String coursesTab = 'coursesTab';
  static const String communityTab = 'communityTab';
  static const String settingsTab = 'settingsTab';

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
  static const String onboardingWelcome = 'onboardingWelcome';
  static const String onboardingStep2Title = 'onboardingStep2Title';
  static const String onboardingStep2Body = 'onboardingStep2Body';
  static const String onboardingStep3Title = 'onboardingStep3Title';
  static const String onboardingStep3Body = 'onboardingStep3Body';
  static const String onboardingStep4Title = 'onboardingStep4Title';
  static const String onboardingStep4Body = 'onboardingStep4Body';
  static const String getStarted = 'getStarted';
  static const String loginWelcomeBack = 'loginWelcomeBack';
  static const String continueWithGoogle = 'continueWithGoogle';
  static const String continueWithFacebook = 'continueWithFacebook';

  static const String profileTitle = 'profileTitle';
  static const String editButton = 'editButton';
  static const String habitsStat = 'habitsStat';
  static const String tasksStat = 'tasksStat';
  static const String streakStat = 'streakStat';
  static const String billing = 'billing';
  static const String nightMode = 'nightMode';
  static const String notifications = 'notifications';
  static const String contactUs = 'contactUs';
  static const String aboutUs = 'aboutUs';
  static const String logout = 'logout';
  static const String addHabitTitle = 'addHabitTitle';
  static const String habitNameLabel = 'habitNameLabel';
  static const String habitNameHint = 'habitNameHint';
  static const String buildHabit = 'buildHabit';
  static const String quitHabit = 'quitHabit';
  static const String habitIconLabel = 'habitIconLabel';
  static const String habitFrequencyLabel = 'habitFrequencyLabel';
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String reminderLabel = 'reminderLabel';
  static const String saveButton = 'saveButton';
  static const String coursesTitle = 'coursesTitle';
  static const String allTab = 'allTab';
  static const String popularTab = 'popularTab';
  static const String newTab = 'newTab';
  static const String featuredCourseTitle = 'featuredCourseTitle';
  static const String featuredCourseDesc = 'featuredCourseDesc';
  static const String lessonsCount = 'lessonsCount';
  static const String morningRoutine = 'morningRoutine';
  static const String selfCare = 'selfCare';
  static const String productivity = 'productivity';
  static const String communityTitle = 'communityTitle';
  static const String mindfulnessTab = 'mindfulnessTab';
  static const String fitnessTab = 'fitnessTab';
  static const String journalingTab = 'journalingTab';
  static const String cheerCount = 'cheerCount';
  static const String commentCount = 'commentCount';
  static const String postPlaceholder = 'postPlaceholder';
  static const String rating = 'rating';
  static const String courseDescription = 'courseDescription';
  static const String startNow = 'startNow';
  static const String wakeUpEarly = 'wakeUpEarly';
  static const String drinkWater = 'drinkWater';
  static const String exercise = 'exercise';
  static const String meditation = 'meditation';
  static const String healthyBreakfast = 'healthyBreakfast';
  static const String currentStreak = 'currentStreak';
  static const String bestStreak = 'bestStreak';
  static const String totalCompleted = 'totalCompleted';
  static const String habitSettingsTitle = 'habitSettingsTitle';
  static const String editHabitTitle = 'editHabitTitle';
  static const String deleteHabitConfirm = 'deleteHabitConfirm';
  static const String deleteAndClear = 'deleteAndClear';
  static const String archiveKeepHistory = 'archiveKeepHistory';
  static const String notificationsTitle = 'notificationsTitle';
  static const String todayHeader = 'todayHeader';
  static const String yesterdayHeader = 'yesterdayHeader';
  static const String habitReminderTitle = 'habitReminderTitle';
  static const String habitReminderMessage = 'habitReminderMessage';
  static const String communityCheerTitle = 'communityCheerTitle';
  static const String communityCheerMessage = 'communityCheerMessage';

  static const String readABook = 'readABook';
  static const String achievementUnlocked = 'achievementUnlocked';
  static const String daysStreakMessage = 'daysStreakMessage';
  static const String twentyMin = 'twentyMin';
  static const String fourPointFive = 'fourPointFive';
  static const String fiveLessons = 'fiveLessons';
  static const String lessonStats = 'lessonStats';

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
    registerTitle: 'CREATE YOUR ACCOUNT',
    nameLabel: 'Name',
    nameHint: 'Mina Pasquariello',
    keepMeSignedIn: 'Keep me signed in',
    createButton: 'Create',
    alreadyHaveAccount: 'Already have an account? ',
    signUpWith: 'Or sign up with',
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
    onboardingWelcome: 'WELCOME TO MONUMENTAL HABITS',
    onboardingStep2Title: 'WORK HARD BUT NOT TOO HARD',
    onboardingStep2Body:
        'Working hard is important, but taking care of yourself is also important.',
    onboardingStep3Title:
        'WE FIRST MAKE OUR HABITS, AND THEN OUR HABITS MAKE US',
    onboardingStep3Body:
        'We first make our habits, and then our habits make us. Out of habits, we form our character.',
    onboardingStep4Title: 'JOIN A SUPPORTIVE COMMUNITY',
    onboardingStep4Body:
        'A community of like-minded people to keep you motivated and accountable.',
    getStarted: 'Get Started',
    loginWelcomeBack: 'Welcome back, you\'ve been missed!',
    continueWithGoogle: 'Continue with Google',
    continueWithFacebook: 'Continue with Facebook',
    forgotPasswordTitle: 'FORGOT YOUR PASSWORD?',
    forgotPasswordDescription:
        'Enter your registered email below to receive password reset instruction',
    sendResetLink: 'Send Reset Link',
    rememberPassword: 'Remember password? ',
    forgotPasswordEmailHint: 'jonathansmth@gmail.com',
    homeGreeting: 'Hi Mira',
    dailyQuote: 'WE FIRST MAKE OUR HABITS AND THEN OUR HABITS MAKE US.',
    dailyQuoteAuthor: '- ANONYMOUS',
    inProgress: 'IN PROGRESS',
    doneButton: 'Done!',
    homeTab: 'Home',
    coursesTab: 'Courses',
    communityTab: 'Community',
    settingsTab: 'Settings',
    profileTitle: 'Profile',
    editButton: 'Edit',
    habitsStat: 'Habits',
    tasksStat: 'Tasks Completed',
    streakStat: 'Days Streak',
    billing: 'Billing',
    nightMode: 'Night Mode',
    notifications: 'Notifications',
    contactUs: 'Contact Us',
    aboutUs: 'About Us',
    logout: 'Logout',
    addHabitTitle: 'New Habit',
    habitNameLabel: 'Habit Name',
    habitNameHint: 'Enter habit name',
    buildHabit: 'Build',
    quitHabit: 'Quit',
    habitIconLabel: 'Habit Icon',
    habitFrequencyLabel: 'Habit Frequency',
    daily: 'Daily',
    weekly: 'Weekly',
    monthly: 'Monthly',
    reminderLabel: 'Reminder',
    saveButton: 'Save',
    coursesTitle: 'Courses',
    allTab: 'All',
    popularTab: 'Popular',
    newTab: 'New',
    featuredCourseTitle: '30 Day Journal Challenge',
    featuredCourseDesc: 'Establish a habit of daily journaling',
    lessonsCount: '%a Lessons (%b)',
    morningRoutine: 'Morning Routine',
    selfCare: 'Self Care',
    productivity: 'Productivity',
    communityTitle: 'Community',
    mindfulnessTab: 'Mindfulness',
    fitnessTab: 'Fitness',
    journalingTab: 'Journaling',
    cheerCount: '%a Cheers',
    commentCount: '%a Comments',
    postPlaceholder: 'Share your progress...',
    rating: '%a Rating',
    courseDescription: 'In this course, we will learn how to build a morning routine that lasts. We will cover the importance of waking up early, staying hydrated, and more.',
    startNow: 'Start Now',
    wakeUpEarly: 'Wake up Early',
    drinkWater: 'Drink Water',
    exercise: 'Exercise',
    meditation: 'Meditation',
    healthyBreakfast: 'Healthy Breakfast',
    currentStreak: 'Current Streak',
    bestStreak: 'Best Streak',
    totalCompleted: 'Total',
    habitSettingsTitle: 'Habit Settings',
    editHabitTitle: 'Edit Habit',
    deleteHabitConfirm: 'Delete this habit?',
    deleteAndClear: 'Delete & Clear History',
    archiveKeepHistory: 'Archive / Keep History',
    notificationsTitle: 'Notifications',
    todayHeader: 'Today',
    yesterdayHeader: 'Yesterday',
    habitReminderTitle: 'Habit Reminder',
    habitReminderMessage: 'Don\'t forget to %a today!',
    communityCheerTitle: 'Community Cheer',
    communityCheerMessage: '%a cheered for your progress!',
    readABook: 'Read a book',
    achievementUnlocked: 'Achievement Unlocked',
    daysStreakMessage: 'You completed %a days streak for %b!',
    twentyMin: '20 min',
    fourPointFive: '4.5',
    fiveLessons: '5 Lessons',
    lessonStats: '%a Lessons (%b)',
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
    registerTitle: 'TẠO TÀI KHOẢN CỦA BẠN',
    nameLabel: 'Tên',
    nameHint: 'Mina Pasquariello',
    keepMeSignedIn: 'Duy trì đăng nhập',
    createButton: 'Tạo tài khoản',
    alreadyHaveAccount: 'Đã có tài khoản? ',
    signUpWith: 'Hoặc đăng ký bằng',
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
    onboardingWelcome: 'CHÀO MỪNG BẠN ĐẾN VỚI MONUMENTAL HABITS',
    onboardingStep2Title: 'LÀM VIỆC CHĂM CHỈ NHƯNG ĐỪNG QUÁ SỨC',
    onboardingStep2Body:
        'Làm việc chăm chỉ là quan trọng, nhưng chăm sóc bản thân cũng quan trọng không kém.',
    onboardingStep3Title:
        'CHÚNG TA TẠO RA THÓI QUEN, VÀ RỒI THÓI QUEN TẠO NÊN CHÚNG TA',
    onboardingStep3Body:
        'Đầu tiên chúng ta tạo ra thói quen, và rồi thói quen hình thành nên con người chúng ta.',
    onboardingStep4Title: 'THAM GIA CỘNG ĐỒNG HỖ TRỢ',
    onboardingStep4Body:
        'Một cộng đồng gồm những người cùng chí hướng để giúp bạn luôn có động lực và trách nhiệm.',
    getStarted: 'Bắt đầu ngay',
    loginWelcomeBack: 'Chào mừng trở lại, chúng tôi rất nhớ bạn!',
    continueWithGoogle: 'Tiếp tục với Google',
    continueWithFacebook: 'Tiếp tục với Facebook',
    forgotPasswordTitle: 'QUÊN MẬT KHẨU?',
    forgotPasswordDescription:
        'Nhập email đã đăng ký của bạn bên dưới để nhận hướng dẫn đặt lại mật khẩu',
    sendResetLink: 'Gửi liên kết đặt lại',
    rememberPassword: 'Nhớ mật khẩu? ',
    forgotPasswordEmailHint: 'jonathansmth@gmail.com',
    homeGreeting: 'Chào Mira',
    dailyQuote: 'CHÚNG TA TẠO RA THÓI QUEN, VÀ RỒI THÓI QUEN TẠO NÊN CHÚNG TA.',
    dailyQuoteAuthor: '- KHUYẾT DANH',
    inProgress: 'ĐANG THỰC HIỆN',
    doneButton: 'Xong!',
    homeTab: 'Trang chủ',
    coursesTab: 'Khóa học',
    communityTab: 'Cộng đồng',
    settingsTab: 'Cài đặt',
    profileTitle: 'Hồ sơ',
    editButton: 'Sửa',
    habitsStat: 'Thói quen',
    tasksStat: 'Nhiệm vụ xong',
    streakStat: 'Ngày liên tiếp',
    billing: 'Thanh toán',
    nightMode: 'Chế độ tối',
    notifications: 'Thông báo',
    contactUs: 'Liên hệ',
    aboutUs: 'Về chúng tôi',
    logout: 'Đăng xuất',
    addHabitTitle: 'Thói quen mới',
    habitNameLabel: 'Tên thói quen',
    habitNameHint: 'Nhập tên thói quen',
    buildHabit: 'Xây dựng',
    quitHabit: 'Từ bỏ',
    habitIconLabel: 'Biểu tượng',
    habitFrequencyLabel: 'Tần suất',
    daily: 'Hàng ngày',
    weekly: 'Hàng tuần',
    monthly: 'Hàng tháng',
    reminderLabel: 'Nhắc nhở',
    saveButton: 'Lưu',
    coursesTitle: 'Khóa học',
    allTab: 'Tất cả',
    popularTab: 'Phổ biến',
    newTab: 'Mới nhất',
    featuredCourseTitle: 'Thử thách 30 ngày viết nhật ký',
    featuredCourseDesc: 'Thiết lập thói quen viết nhật ký hàng ngày',
    lessonsCount: '%a Bài học (%b)',
    morningRoutine: 'Thói quen buổi sáng',
    selfCare: 'Chăm sóc bản thân',
    productivity: 'Năng suất',
    communityTitle: 'Cộng đồng',
    mindfulnessTab: 'Chánh niệm',
    fitnessTab: 'Thể hình',
    journalingTab: 'Viết nhật ký',
    cheerCount: '%a Lời cổ vũ',
    commentCount: '%a Bình luận',
    postPlaceholder: 'Chia sẻ tiến trình của bạn...',
    rating: '%a Đánh giá',
    courseDescription: 'Trong khóa học này, chúng ta sẽ học cách xây dựng thói quen buổi sáng bền vững. Chúng ta sẽ tìm hiểu tầm quan trọng của việc dậy sớm, uống đủ nước và nhiều hơn nữa.',
    startNow: 'Bắt đầu ngay',
    wakeUpEarly: 'Dậy sớm',
    drinkWater: 'Uống nước',
    exercise: 'Tập thể dục',
    meditation: 'Thiền định',
    healthyBreakfast: 'Bữa sáng lành mạnh',
    currentStreak: 'Chuỗi hiện tại',
    bestStreak: 'Chuỗi kỷ lục',
    totalCompleted: 'Tổng cộng',
    habitSettingsTitle: 'Cài đặt thói quen',
    editHabitTitle: 'Chỉnh sửa thói quen',
    deleteHabitConfirm: 'Xóa thói quen này?',
    deleteAndClear: 'Xóa & Xóa lịch sử',
    archiveKeepHistory: 'Lưu trữ / Giữ lịch sử',
    notificationsTitle: 'Thông báo',
    todayHeader: 'Hôm nay',
    yesterdayHeader: 'Hôm qua',
    habitReminderTitle: 'Nhắc nhở thói quen',
    habitReminderMessage: 'Đừng quên %a vào hôm nay nhé!',
    communityCheerTitle: 'Cổ vũ từ cộng đồng',
    communityCheerMessage: '%a đã cổ vũ cho tiến trình của bạn!',
    readABook: 'Đọc một cuốn sách',
    achievementUnlocked: 'Đã mở khóa thành tựu',
    daysStreakMessage: 'Bạn đã hoàn thành chuỗi %a ngày cho %b!',
    twentyMin: '20 phút',
    fourPointFive: '4.5',
    fiveLessons: '5 Bài học',
    lessonStats: '%a Bài học (%b)',
  };
}
