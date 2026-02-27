# GlobalNoKeyboardRebuild - Keyboard Management Guide

## 🎯 Vấn Đề Giải Quyết

Khi keyboard show/hide, Flutter trigger rebuild toàn bộ app tree vì `MediaQuery.viewInsets` thay đổi. Điều này gây:
- **Jank/Lag**: App bị lag khi keyboard animation
- **Performance Issue**: Rebuild toàn bộ widgets không cần thiết
- **Flash/Flash**: UI flickering khi keyboard transition

## ✅ Giải Pháp

`GlobalNoKeyboardRebuild` giải quyết bằng 2 cơ chế:

### 1. **Remove MediaQuery Insets** (Prevent Rebuild)
```dart
MediaQuery.removeViewInsets(removeBottom: true)
```
- Loại bỏ bottom inset từ MediaQuery data
- Keyboard vẫn show, nhưng MediaQuery không thay đổi
- ✅ Không trigger rebuild

### 2. **Animated Padding Wrapper** (Smooth Animation)
```dart
_KeyboardPaddingWrapper
  ├── ValueListenableBuilder (listen KeyboardService.visible)
  └── AnimatedContainer (animate padding transition)
```
- Chỉ padding layer rebuild (dưới child)
- Smooth 200ms animation khi keyboard show/hide
- ✅ Parent UI không rebuild

## 📊 Architecture

```
GlobalNoKeyboardRebuild (Core Layer - Keyboard Management)
├── MediaQuery (remove bottom insets)
└── _KeyboardPaddingWrapper (if addBottomPadding=true)
    ├── ValueListenableBuilder<bool> (listen keyboard visibility)
    │   └── Rebuild chỉ khi keyboard show/hide
    └── AnimatedContainer (smooth padding transition)
        └── Animate bottom padding 0 ↔ keyboardHeight
            └── MyApp
                └── (không rebuild khi keyboard change)
```

## 🔧 Usage

### Setup in main.dart
```dart
void main() {
  runApp(
    GlobalNoKeyboardRebuild(
      child: MyApp(),
      addBottomPadding: true,        // Add padding when keyboard visible
      animationDurationMs: 200,       // Animation duration
      animationCurve: Curves.easeInOut,
    ),
  );
}
```

### Option 1: Automatic Padding (Recommended)
```dart
// GlobalNoKeyboardRebuild auto add padding
// Content automatically push up when keyboard show
runApp(
  GlobalNoKeyboardRebuild(
    addBottomPadding: true,  // Default
    child: MyApp(),
  ),
);
```

### Option 2: Manual Padding Control
```dart
// No auto padding, you control via KeyboardService
runApp(
  GlobalNoKeyboardRebuild(
    addBottomPadding: false,
    child: MyApp(),
  ),
);

// In any widget, manually add padding:
ValueListenableBuilder<bool>(
  valueListenable: KeyboardService.instance.keyboardVisible,
  builder: (context, isVisible, _) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isVisible ? MediaQuery.of(context).viewInsets.bottom : 0,
      ),
      child: YourContent(),
    );
  },
)
```

## 🎬 How It Works

### Scenario: User taps TextField

```
1. User taps TextField
   ↓
2. Keyboard starts animating up
   ↓
3. Platform sends viewInsets update (bottom = keyboard height)
   ↓
4. GlobalNoKeyboardRebuild.build() called
   ↓
5. removeViewInsets(removeBottom: true) removes bottom inset
   ↓
6. MediaQuery data stays same → MyApp does NOT rebuild ✅
   ↓
7. But _KeyboardPaddingWrapper listens KeyboardService.visible
   ↓
8. AnimatedContainer smoothly animate padding 0 → keyboardHeight
   ↓
9. Content smoothly pushed up (200ms animation)
   ↓
10. Keyboard animation complete
```

### Result
✅ Smooth keyboard animation
✅ No jank/lag
✅ MyApp doesn't rebuild
✅ Only padding layer rebuilds (minimal cost)

## 📱 Real World Example

### Login Screen with TextField
```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 100),
            Text('Login'),
            SizedBox(height: 20),
            // TextField focus → keyboard show
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
```

**With GlobalNoKeyboardRebuild:**
- User taps TextField
- Keyboard animates up
- Content automatically pushed up (via _KeyboardPaddingWrapper padding)
- No jank, smooth animation ✅
- LoginScreen doesn't rebuild ✅

## 🎛️ Customization

### Custom Animation Duration
```dart
GlobalNoKeyboardRebuild(
  animationDurationMs: 300,  // Slower animation (300ms)
  child: MyApp(),
)
```

### Custom Animation Curve
```dart
GlobalNoKeyboardRebuild(
  animationCurve: Curves.elasticInOut,  // Custom curve
  child: MyApp(),
)
```

### Disable Auto Padding
```dart
GlobalNoKeyboardRebuild(
  addBottomPadding: false,  // Manual control
  child: MyApp(),
)
```

## 🔍 Debugging

### Check Keyboard Visibility
```dart
// In any widget
ValueListenableBuilder<bool>(
  valueListenable: KeyboardService.instance.keyboardVisible,
  builder: (context, isVisible, _) {
    print('Keyboard visible: $isVisible');
    return YourWidget();
  },
)
```

### Check MediaQuery Changes
```dart
// Add print in GlobalNoKeyboardRebuild.build()
@override
Widget build(BuildContext context) {
  final mq = MediaQuery.of(context);
  print('MediaQuery bottom inset: ${mq.viewInsets.bottom}');  // Should be 0
  ...
}
```

## ⚠️ Known Issues & Solutions

### Issue 1: Padding không có effect
**Solution**: Check `addBottomPadding: true` is set (default is true)

### Issue 2: Content bị keyboard che
**Solution**: Ensure parent is `SingleChildScrollView` or `ListView` để content có thể scroll

### Issue 3: Animation không smooth
**Solution**: Check `animationDurationMs` match keyboard animation (typically 200-300ms)

## 📚 Related Services

- **KeyboardService**: Global keyboard visibility listener (Core Layer)
- **GlobalNoKeyboardRebuild**: Wrapper preventing rebuild (Core Layer)
- **_KeyboardPaddingWrapper**: Animated padding layer (Private)

## 🏗️ Architecture Integration

```
Clean Architecture Layers:
├── Presentation (Widgets, Screens)
├── Business Logic (Cubits, Validators)
├── Data (Repositories, Models)
└── Core (Services, Utils)
    └── Keyboard Management
        ├── KeyboardService (listen visibility)
        └── GlobalNoKeyboardRebuild (prevent rebuild + animate)
```

---

**Status**: ✅ COMPLETE - Ready to use
**Last Updated**: 2024
**Test Status**: Code review passed
