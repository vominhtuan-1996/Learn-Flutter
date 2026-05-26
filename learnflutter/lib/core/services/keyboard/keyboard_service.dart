import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_queue/engine_queue.dart';

/// Lớp KeyboardService cung cấp một cơ chế tập trung để theo dõi và quản lý các sự kiện liên quan đến bàn phím ảo trên thiết bị.
/// Nó sử dụng mô hình Singleton để đảm bảo rằng toàn bộ ứng dụng chỉ sử dụng duy nhất một bộ quản lý trạng thái bàn phím nhất quán.
/// Thông qua các đối tượng ValueNotifier, các thành phần giao diện khác có thể dễ dàng đăng ký lắng nghe sự thay đổi về chiều cao và trạng thái hiển thị của bàn phím.
/// Dịch vụ này giúp tự động hóa việc tính toán khoảng trống giao diện, mang lại trải nghiệm nhập liệu tốt hơn cho người dùng.
class KeyboardService {
  /// Singleton instance của KeyboardService.
  static final KeyboardService instance = KeyboardService._internal();
  KeyboardService._internal();

  /// ValueNotifier keyboardHeight lưu trữ thông tin về chiều cao hiện tại của bàn phím theo đơn vị điểm ảnh (pixels).
  final ValueNotifier<double> keyboardHeight = ValueNotifier(0);

  /// ValueNotifier keyboardVisible giúp xác định xem bàn phím có đang được hiển thị trên màn hình hay không.
  final ValueNotifier<bool> keyboardVisible = ValueNotifier(false);

  /// ValueNotifier isBottomBarVisible được sử dụng để điều khiển trạng thái hiển thị của thanh công cụ phía dưới (bottom bar).
  /// Trong thiết kế trải nghiệm người dùng hiện đại, việc ẩn bottom bar khi bàn phím xuất hiện giúp tối ưu hóa diện tích hiển thị cho nội dung nhập liệu.
  /// Dịch vụ sẽ tự động đồng bộ hóa trạng thái này dựa trên các thay đổi về kích thước giao diện được ghi nhận từ hệ thống.
  final ValueNotifier<bool> isBottomBarVisible = ValueNotifier(true);

  /// _lastHeight dùng để ghi nhớ giá trị chiều cao cuối cùng nhằm tránh việc kích hoạt cập nhật giao diện không cần thiết.
  double _lastHeight = 0;

  /// _debounce hỗ trợ việc trì hoãn cập nhật để đợi cho đến khi các hiệu ứng chuyển cảnh của bàn phím thực sự kết thúc.
  Timer? _debounce;

  /// Bộ điều phối hàng đợi tác vụ của bàn phím để chạy các hành động tuần tự
  final InMemoryQueueEngine _keyboardQueueEngine = InMemoryQueueEngine(
    config: const QueueConfig(
      concurrency: 1, // Xử lý tuần tự từng tác vụ
    ),
  );

  /// Đối tượng tác vụ chuyển đổi trạng thái bàn phím hiện tại
  _KeyboardTransitionTask? _activeTransitionTask;

  /// Phương thức start thực hiện việc đăng ký một observer để lắng nghe các thay đổi về kích thước giao diện từ hệ điều hành.
  void start() {
    WidgetsBinding.instance.addObserver(_KeyboardObserver());
  }

  /// Gửi một tác vụ vào hàng đợi của bàn phím.
  /// Tác vụ này sẽ được thực thi khi bàn phím đã kết thúc tất cả các chuyển đổi hiển thị/ẩn.
  void enqueue(QueueTask task) {
    _keyboardQueueEngine.enqueue(task);
  }

  /// Thực thi một hành động bất đồng bộ ngay sau khi các chuyển đổi hiển thị/ẩn bàn phím hiện tại đã hoàn tất.
  Future<void> runAfterKeyboardTransition(Future<void> Function() action, {String? taskName}) async {
    final completer = Completer<void>();
    final task = CallbackQueueTask(
      id: 'keyboard_action_${DateTime.now().millisecondsSinceEpoch}_${action.hashCode}',
      name: taskName ?? 'Tác vụ sau khi chuyển cảnh bàn phím',
      maxRetries: 0,
      callback: () async {
        try {
          await action();
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      },
    );
    enqueue(task);
    await completer.future;
  }

  /// Hỗ trợ kiểm thử để mô phỏng sự kiện bàn phím thay đổi từ hệ điều hành.
  @visibleForTesting
  void updateFromInsetsForTesting(double inset) {
    _updateFromInsets(inset);
  }

  /// Phương thức _updateFromInsets xử lý dữ liệu thô về khoảng đệm từ hệ thống và thực hiện cập nhật các Notifier sau khi đã qua bộ lọc debounce.
  void _updateFromInsets(double inset) {
    // Nếu có sự dịch chuyển chiều cao bàn phím đáng kể và chưa có task chuyển cảnh active, tạo mới task chuyển cảnh
    if (_activeTransitionTask == null && (inset - _lastHeight).abs() > 2) {
      final isShowing = inset > _lastHeight;
      _activeTransitionTask = _KeyboardTransitionTask(
        id: 'keyboard_transition_${DateTime.now().millisecondsSinceEpoch}',
        name: isShowing ? 'Bàn phím đang hiển thị' : 'Bàn phím đang ẩn',
      );
      enqueue(_activeTransitionTask!);
    }

    _debounce?.cancel();

    // Đợi hiệu ứng chuyển cảnh của bàn phím ổn định hoàn toàn (120ms không có thay đổi metric)
    _debounce = Timer(const Duration(milliseconds: 120), () {
      final visible = inset > 0;

      if (visible != keyboardVisible.value) {
        keyboardVisible.value = visible;
        isBottomBarVisible.value = !visible;
      }

      if ((_lastHeight - inset).abs() > 5) {
        _lastHeight = inset;
        keyboardHeight.value = inset;
      }

      // Đánh dấu hoàn tất task chuyển cảnh hiện tại
      _activeTransitionTask?.complete();
      _activeTransitionTask = null;
    });
  }
}

/// Tác vụ đại diện cho quá trình bàn phím đang hiển thị hoặc ẩn đi.
/// Tác vụ này tự động hoàn thành khi bàn phím đã kết thúc hoạt hoạt ảnh native.
class _KeyboardTransitionTask extends QueueTask {
  final Completer<void> _completer = Completer<void>();

  _KeyboardTransitionTask({
    required super.id,
    required super.name,
  }) : super(maxRetries: 0);

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> execute() async {
    // Đặt thêm timeout tối đa 500ms để đảm bảo không bao giờ bị nghẽn hàng đợi vĩnh viễn
    await _completer.future.timeout(
      const Duration(milliseconds: 500),
      onTimeout: () {
        if (!_completer.isCompleted) {
          _completer.complete();
        }
      },
    );
  }

  @override
  _KeyboardTransitionTask copyWith({
    QueueTaskStatus? status,
    int? retries,
    String? error,
  }) {
    final copy = _KeyboardTransitionTask(
      id: id,
      name: name,
    );
    copy.status = status ?? this.status;
    copy.retries = retries ?? this.retries;
    copy.error = error ?? this.error;
    if (_completer.isCompleted) {
      copy.complete();
    }
    return copy;
  }
}

/// Lớp nội bộ _KeyboardObserver thực hiện việc theo dõi các thay đổi về thông số vật lý của ứng dụng thông qua WidgetsBindingObserver.
/// Nó tiến hành trích xuất thông tin khoảng đệm phía dưới của màn hình chính và chuyển tiếp dữ liệu đến KeyboardService để xử lý logic tiếp theo.
class _KeyboardObserver with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final inset = view.viewInsets.bottom;

    KeyboardService.instance._updateFromInsets(inset);
  }
}
