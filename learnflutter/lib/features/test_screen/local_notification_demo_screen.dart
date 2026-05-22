import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_service.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_widget.dart';

/// Demo màn hình test [LocalNotificationService].
///
/// Bao gồm các kịch bản:
/// - Khởi tạo & xin quyền
/// - Hiển thị notification tức thì (đơn giản / có payload)
/// - Hiển thị notification nâng cao (big text)
/// - Hủy 1 notification cụ thể / hủy toàn bộ
class LocalNotificationDemoScreen extends StatefulWidget {
  const LocalNotificationDemoScreen({super.key});

  @override
  State<LocalNotificationDemoScreen> createState() =>
      _LocalNotificationDemoScreenState();
}

class _LocalNotificationDemoScreenState
    extends State<LocalNotificationDemoScreen> {
  final _service = LocalNotificationService.instance;

  bool _initialized = false;
  bool _permissionGranted = false;
  int? _lastShownId;
  String _lastTapPayload = '-';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _service.init(
      onTap: (payload) {
        setState(() => _lastTapPayload = payload ?? '(empty)');
        _log('Notification tapped → payload: ${payload ?? '(empty)'}');
      },
    );
    setState(() => _initialized = true);
    _log('Service initialized');
    // Auto-check trạng thái permission sau khi init.
    final enabled = await _service.isEnabled();
    setState(() => _permissionGranted = enabled);
    _log('isEnabled() = $enabled');
  }

  Future<void> _requestPermission() async {
    final granted = await _service.requestPermission();
    setState(() => _permissionGranted = granted);
    _log('Permission ${granted ? "GRANTED" : "DENIED"}');
  }

  Future<void> _safeShow(Future<int> Function() action, String label) async {
    try {
      final id = await action();
      setState(() => _lastShownId = id);
      _log('✅ Shown $label id=$id');
    } catch (e) {
      _log('❌ Show $label FAILED: $e');
    }
  }

  Future<void> _showSimple() => _safeShow(
        () => _service.show(
          title: '👋 Xin chào',
          body: 'Đây là notification đơn giản',
        ),
        'simple',
      );

  Future<void> _showWithPayload() => _safeShow(
        () => _service.show(
          title: '📦 Có payload',
          body: 'Nhấn để xem payload trên màn hình',
          payload: 'user_id=42&action=open_detail',
        ),
        'payload',
      );

  Future<void> _showBigText() => _safeShow(
        () => _service.show(
          title: '📚 Big Text Style',
          body: 'Tóm tắt ngắn',
          payload: 'big_text_demo',
          details: const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(
                'Đây là nội dung dài hơn rất nhiều dòng để minh họa BigTextStyle '
                'của Android. Người dùng có thể vuốt xuống để xem toàn bộ nội '
                'dung này thay vì chỉ thấy một dòng ngắn gọn ban đầu.',
                contentTitle: '📚 Big Text Style (mở rộng)',
                summaryText: 'Tóm tắt khi mở rộng',
              ),
            ),
            iOS: DarwinNotificationDetails(),
          ),
        ),
        'big-text',
      );

  Future<void> _cancelLast() async {
    if (_lastShownId == null) {
      _log('Không có id nào để hủy');
      return;
    }
    await _service.cancel(_lastShownId!);
    _log('Cancelled id=$_lastShownId');
    setState(() => _lastShownId = null);
  }

  Future<void> _cancelAll() async {
    await _service.cancelAll();
    _log('Cancelled ALL');
    setState(() => _lastShownId = null);
  }

  void _log(String line) {
    setState(() {
      _logs.insert(
        0,
        '${TimeOfDay.now().format(context)}  $line',
      );
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Local Notification Demo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(
              initialized: _initialized,
              permissionGranted: _permissionGranted,
              lastShownId: _lastShownId,
              lastTapPayload: _lastTapPayload,
            ),
            const SizedBox(height: 16),
            const _SectionLabel(label: '🔧 Setup'),
            _ButtonRow(children: [
              _Btn(
                label: 'Xin quyền',
                color: const Color(0xFF2563EB),
                onTap: _requestPermission,
              ),
            ]),
            const SizedBox(height: 12),
            const _SectionLabel(label: '🔔 Hiển thị'),
            _ButtonRow(children: [
              _Btn(
                label: 'Simple',
                color: const Color(0xFF16A34A),
                onTap: _showSimple,
              ),
              _Btn(
                label: 'With Payload',
                color: const Color(0xFF0D9488),
                onTap: _showWithPayload,
              ),
              _Btn(
                label: 'Big Text',
                color: const Color(0xFFEAB308),
                onTap: _showBigText,
              ),
            ]),
            const SizedBox(height: 12),
            const _SectionLabel(label: '🎨 In-App Custom Banner'),
            _ButtonRow(children: [
              _Btn(
                label: 'Info',
                color: const Color(0xFF2563EB),
                onTap: () => LocalNotificationOverlay.show(
                  context,
                  title: 'Thông báo',
                  body: 'Đây là in-app custom banner.',
                  icon: Icons.info_outline,
                  color: const Color(0xFF2563EB),
                  onTap: () => _log('In-app banner tapped'),
                ),
              ),
              _Btn(
                label: 'Success',
                color: const Color(0xFF16A34A),
                onTap: () => LocalNotificationOverlay.show(
                  context,
                  title: 'Thành công',
                  body: 'Đồng bộ dữ liệu hoàn tất.',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF16A34A),
                ),
              ),
              _Btn(
                label: 'Error',
                color: const Color(0xFFEF4444),
                onTap: () => LocalNotificationOverlay.show(
                  context,
                  title: 'Lỗi',
                  body: 'Không kết nối được đến máy chủ.',
                  icon: Icons.error_outline,
                  color: const Color(0xFFEF4444),
                ),
              ),
              _Btn(
                label: 'Dismiss',
                color: const Color(0xFF6B7280),
                onTap: LocalNotificationOverlay.dismiss,
              ),
            ]),
            const SizedBox(height: 12),
            const _SectionLabel(label: '🧹 Hủy'),
            _ButtonRow(children: [
              _Btn(
                label: 'Cancel Last',
                color: const Color(0xFFF59E0B),
                onTap: _cancelLast,
              ),
              _Btn(
                label: 'Cancel All',
                color: const Color(0xFFEF4444),
                onTap: _cancelAll,
              ),
            ]),
            const SizedBox(height: 16),
            const _SectionLabel(label: '📜 Logs'),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có log nào...',
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[i],
                            style: const TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Status Card
// ════════════════════════════════════════════

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.initialized,
    required this.permissionGranted,
    required this.lastShownId,
    required this.lastTapPayload,
  });

  final bool initialized;
  final bool permissionGranted;
  final int? lastShownId;
  final String lastTapPayload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Initialized', initialized ? '✅' : '❌'),
          _row('Permission', permissionGranted ? '✅ granted' : '❔ unknown'),
          _row('Last shown id', lastShownId?.toString() ?? '-'),
          _row('Last tap payload', lastTapPayload),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// Helpers
// ════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
