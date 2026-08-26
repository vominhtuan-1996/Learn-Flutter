import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learnflutter/core/services/home_widget/home_widget_service.dart';
import 'package:learnflutter/core/services/live_activity/live_activity_data.dart';
import 'package:learnflutter/core/services/live_activity/live_activity_service.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_service.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_widget.dart';
import 'package:learnflutter/shared/widgets/keyboard_textfield/keyboard_textfield.dart';
import 'package:learnflutter/core/services/local_notification/custom_notification_service.dart';

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

  final _titleCtrl = TextEditingController(text: 'Test Notification');
  final _bodyCtrl = TextEditingController(text: 'Nội dung thông báo');
  int _delaySeconds = 5;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
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

  Future<void> _showCustom() => _safeShow(
        () => _service.show(
          title: _titleCtrl.text.trim().isEmpty ? 'Custom' : _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim().isEmpty ? '...' : _bodyCtrl.text.trim(),
          payload: 'custom',
        ),
        'custom',
      );

  Future<void> _showDelayed() async {
    _log('⏱ Sẽ hiện sau $_delaySeconds giây...');
    Future.delayed(Duration(seconds: _delaySeconds), () {
      if (!mounted) return;
      _safeShow(
        () => _service.show(
          title: '⏰ Delayed +${_delaySeconds}s',
          body: _titleCtrl.text.trim().isEmpty ? 'Hẹn giờ thành công!' : _bodyCtrl.text.trim(),
          payload: 'delayed',
        ),
        'delayed',
      );
    });
  }

  void _showAddWidgetGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddWidgetGuideSheet(),
    );
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
      body: SingleChildScrollView(
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
            const _SectionLabel(label: '✏️ Custom Input'),
            _CustomInputSection(
              titleCtrl: _titleCtrl,
              bodyCtrl: _bodyCtrl,
              delaySeconds: _delaySeconds,
              onDelayChanged: (v) => setState(() => _delaySeconds = v),
              onSend: _showCustom,
              onDelayed: _showDelayed,
            ),
            const SizedBox(height: 12),
            const _SectionLabel(label: '🎨 Custom Native View'),
            _ButtonRow(children: [
              _Btn(
                label: 'ℹ️ Info',
                color: const Color(0xFF6366F1),
                onTap: () async {
                  final id = await CustomNotificationService.instance.show(
                    title: _titleCtrl.text.trim().isEmpty ? 'Thông báo mới' : _titleCtrl.text.trim(),
                    body: _bodyCtrl.text.trim().isEmpty ? 'Bạn có tin nhắn mới từ hệ thống.' : _bodyCtrl.text.trim(),
                    type: NotifType.info,
                    payload: 'notif_info',
                  );
                  _log(id != null ? '✅ Info id=$id' : '⚠️ Thất bại');
                },
              ),
              _Btn(
                label: '✅ Success',
                color: const Color(0xFF16A34A),
                onTap: () async {
                  final id = await CustomNotificationService.instance.show(
                    title: 'Thành công',
                    body: 'Đồng bộ dữ liệu hoàn tất. Tất cả thay đổi đã được lưu.',
                    type: NotifType.success,
                    payload: 'notif_success',
                  );
                  _log(id != null ? '✅ Success id=$id' : '⚠️ Thất bại');
                },
              ),
              _Btn(
                label: '⚠️ Warning',
                color: const Color(0xFFEA580C),
                onTap: () async {
                  final id = await CustomNotificationService.instance.show(
                    title: 'Cảnh báo hệ thống',
                    body: 'Phiên đăng nhập sắp hết hạn sau 5 phút. Vui lòng lưu công việc và đăng nhập lại.',
                    type: NotifType.warning,
                    payload: 'notif_warning',
                  );
                  _log(id != null ? '✅ Warning id=$id' : '⚠️ Thất bại');
                },
              ),
              _Btn(
                label: '🎁 Promo',
                color: const Color(0xFF7C3AED),
                onTap: () async {
                  final id = await CustomNotificationService.instance.show(
                    title: 'Ưu đãi đặc biệt hôm nay!',
                    body: 'Giảm 30% cho tất cả gói dịch vụ cao cấp. Chỉ còn 2 giờ để nhận ưu đãi này.',
                    type: NotifType.promo,
                    payload: 'notif_promo',
                  );
                  _log(id != null ? '✅ Promo id=$id' : '⚠️ Thất bại');
                },
              ),
              _Btn(
                label: '🖼️ Image',
                color: const Color(0xFF0EA5E9),
                onTap: () async {
                  final id = await CustomNotificationService.instance.show(
                    title: 'Ảnh mới từ hệ thống',
                    body: 'Nhấn để xem chi tiết hình ảnh.',
                    type: NotifType.image,
                    imageUrl: 'https://picsum.photos/seed/notif/800/400',
                  );
                  _log(id != null ? '✅ Image id=$id' : '⚠️ Thất bại');
                },
              ),
            ]),
            const SizedBox(height: 12),
            const _SectionLabel(label: '🔔 Hiển thị nhanh'),
            _ButtonRow(children: [
              _Btn(label: 'Simple', color: const Color(0xFF16A34A), onTap: _showSimple),
              _Btn(label: 'Payload', color: const Color(0xFF0D9488), onTap: _showWithPayload),
              _Btn(label: 'Big Text', color: const Color(0xFFEAB308), onTap: _showBigText),
              _Btn(
                label: 'Inbox',
                color: const Color(0xFF2563EB),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '📥 Inbox (3 tin nhắn)',
                    body: 'Bạn có 3 tin nhắn mới',
                    details: const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.high,
                        priority: Priority.high,
                        styleInformation: InboxStyleInformation(
                          ['Tuấn: Hey, bạn có rảnh không?', 'An: Meeting lúc 3h nhé!', 'System: Cập nhật thành công.'],
                          contentTitle: '📥 3 tin nhắn mới',
                          summaryText: '3 messages',
                        ),
                      ),
                      iOS: DarwinNotificationDetails(),
                    ),
                  ),
                  'inbox',
                ),
              ),
              _Btn(
                label: 'Progress',
                color: const Color(0xFF7C3AED),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '⬇️ Đang tải xuống...',
                    body: 'learnflutter_update_v2.apk',
                    details: const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.low,
                        priority: Priority.low,
                        showProgress: true,
                        maxProgress: 100,
                        progress: 65,
                        onlyAlertOnce: true,
                      ),
                      iOS: DarwinNotificationDetails(),
                    ),
                  ),
                  'progress',
                ),
              ),
              _Btn(
                label: 'Indeterminate',
                color: const Color(0xFF0891B2),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '🔄 Đang xử lý...',
                    body: 'Vui lòng chờ trong giây lát',
                    details: const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.low,
                        priority: Priority.low,
                        showProgress: true,
                        maxProgress: 0,
                        progress: 0,
                        indeterminate: true,
                        onlyAlertOnce: true,
                      ),
                      iOS: DarwinNotificationDetails(),
                    ),
                  ),
                  'indeterminate',
                ),
              ),
              _Btn(
                label: 'Silent',
                color: const Color(0xFF6B7280),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '🔕 Silent Notification',
                    body: 'Không có âm thanh, không rung',
                    details: const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.low,
                        priority: Priority.low,
                        playSound: false,
                        enableVibration: false,
                      ),
                      iOS: DarwinNotificationDetails(
                        presentSound: false,
                        presentBadge: false,
                        presentBanner: true,
                      ),
                    ),
                  ),
                  'silent',
                ),
              ),
              _Btn(
                label: 'With Actions',
                color: const Color(0xFFD97706),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '❓ Xác nhận',
                    body: 'Bạn có muốn đặt lịch nhắc cho ngày mai không?',
                    details: NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.high,
                        priority: Priority.high,
                        actions: [
                          const AndroidNotificationAction('yes', '✅ Đồng ý', showsUserInterface: true),
                          const AndroidNotificationAction('no', '❌ Không', cancelNotification: true),
                        ],
                      ),
                      iOS: const DarwinNotificationDetails(categoryIdentifier: 'CUSTOM_NOTIFICATION'),
                    ),
                  ),
                  'with-actions',
                ),
              ),
              _Btn(
                label: 'Big Picture',
                color: const Color(0xFFDB2777),
                onTap: () => _safeShow(
                  () => _service.show(
                    title: '🖼 Big Picture',
                    body: 'Ảnh preview trong notification (Android)',
                    details: const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'default_channel', 'Default',
                        importance: Importance.high,
                        priority: Priority.high,
                        styleInformation: BigPictureStyleInformation(
                          DrawableResourceAndroidBitmap('@drawable/ic_notification'),
                          largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification'),
                          contentTitle: '🖼 Big Picture Style',
                          summaryText: 'Ảnh preview',
                          hideExpandedLargeIcon: true,
                        ),
                      ),
                      iOS: DarwinNotificationDetails(),
                    ),
                  ),
                  'big-picture',
                ),
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
            const _SectionLabel(label: '🏠 Home Widget'),
            _HomeWidgetForm(
              onUpdate: (data) async {
                await HomeWidgetService.instance.update(data);
                _log('✅ Home Widget updated: ${data.userName}');
              },
              onClear: () async {
                await HomeWidgetService.instance.clear();
                _log('🗑️ Home Widget cleared');
              },
              onGuide: () => _showAddWidgetGuide(context),
            ),
            const SizedBox(height: 12),
            const _SectionLabel(label: '⚡ Live Activity'),
            _LiveActivitySection(
              onLog: _log,
            ),
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
            SizedBox(
              height: 220,
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
// Home Widget Form
// ════════════════════════════════════════════

class _HomeWidgetForm extends StatefulWidget {
  const _HomeWidgetForm({
    required this.onUpdate,
    required this.onClear,
    required this.onGuide,
  });
  final Future<void> Function(WidgetUserData) onUpdate;
  final Future<void> Function() onClear;
  final VoidCallback onGuide;

  @override
  State<_HomeWidgetForm> createState() => _HomeWidgetFormState();
}

class _HomeWidgetFormState extends State<_HomeWidgetForm> {
  final _nameCtrl    = TextEditingController(text: 'Nguyễn Văn A');
  final _balanceCtrl = TextEditingController(text: '1,234,567 ₫');

  // Mỗi stat có 2 controller: label + value
  final List<(TextEditingController, TextEditingController)> _stats = [
    (TextEditingController(text: 'Đơn hàng'),   TextEditingController(text: '12')),
    (TextEditingController(text: 'Điểm thưởng'), TextEditingController(text: '850')),
    (TextEditingController(text: 'Voucher'),     TextEditingController(text: '3')),
    (TextEditingController(text: 'Thông báo'),   TextEditingController(text: '5')),
  ];

  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    for (final (l, v) in _stats) { l.dispose(); v.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await widget.onUpdate(WidgetUserData(
      userName: _nameCtrl.text.trim().isEmpty ? '—' : _nameCtrl.text.trim(),
      balance:  _balanceCtrl.text.trim().isEmpty ? '—' : _balanceCtrl.text.trim(),
      stats: _stats
          .where((s) => s.$1.text.trim().isNotEmpty)
          .map((s) => {'label': s.$1.text.trim(), 'value': s.$2.text.trim()})
          .toList(),
    ));
    if (mounted) setState(() => _loading = false);
  }

  void _addStat() {
    if (_stats.length >= 6) return;
    setState(() => _stats.add((TextEditingController(), TextEditingController())));
  }

  void _removeStat(int i) {
    final (l, v) = _stats[i];
    l.dispose(); v.dispose();
    setState(() => _stats.removeAt(i));
  }

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
  );
  static const _focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Color(0xFF0F766E), width: 1.5),
  );
  static const _decoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    border: _border,
    enabledBorder: _border,
    focusedBorder: _focusBorder,
    filled: true,
    fillColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên + Số dư
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: _decoration.copyWith(hintText: 'Tên người dùng'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _balanceCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: _decoration.copyWith(hintText: 'Số dư (vd: 1,234,567 ₫)'),
          ),
          const SizedBox(height: 10),
          // Stats
          Row(
            children: [
              const Text('Thống kê', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const Spacer(),
              if (_stats.length < 6)
                GestureDetector(
                  onTap: _addStat,
                  child: const Text('+ Thêm', style: TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ...List.generate(_stats.length, (i) {
            final (lCtrl, vCtrl) = _stats[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: lCtrl,
                      style: const TextStyle(fontSize: 12),
                      decoration: _decoration.copyWith(hintText: 'Label'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: vCtrl,
                      style: const TextStyle(fontSize: 12),
                      decoration: _decoration.copyWith(hintText: 'Value'),
                    ),
                  ),
                  if (_stats.length > 1) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeStat(i),
                      child: const Icon(Icons.remove_circle_outline, size: 18, color: Color(0xFFEF4444)),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          // Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _loading ? const Color(0xFF9CA3AF) : const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('📊 Cập nhật Widget', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: widget.onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text('🗑️', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: widget.onGuide,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text('➕', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// Add Widget Guide Bottom Sheet
// ════════════════════════════════════════════

class _AddWidgetGuideSheet extends StatelessWidget {
  const _AddWidgetGuideSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '🏠 Thêm Widget vào Home Screen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _step('1', 'Về màn hình Home (nhấn nút Home)'),
          _step('2', 'Giữ ngón tay vào vùng trống trên màn hình'),
          _step('3', 'Nhấn nút [+] ở góc trên bên trái'),
          _step('4', 'Tìm kiếm "Market" hoặc tên app'),
          _step('5', 'Chọn widget "Tổng quan" → Add Widget'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Color(0xFF16A34A), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhấn "📊 Ghi data mẫu" trước để widget hiển thị data ngay khi thêm vào.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
            ),
          ),
        ],
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

// ════════════════════════════════════════════
// Custom Input Section
// ════════════════════════════════════════════

class _CustomInputSection extends StatelessWidget {
  const _CustomInputSection({
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.delaySeconds,
    required this.onDelayChanged,
    required this.onSend,
    required this.onDelayed,
  });

  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;
  final int delaySeconds;
  final ValueChanged<int> onDelayChanged;
  final VoidCallback onSend;
  final VoidCallback onDelayed;

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyboardTextField(
            controller: titleCtrl,
            style: const TextStyle(fontSize: 13),
            showNavigation: false,
            showDone: true,
            decoration: inputDecoration.copyWith(hintText: 'Tiêu đề'),
          ),
          const SizedBox(height: 8),
          KeyboardTextField(
            controller: bodyCtrl,
            style: const TextStyle(fontSize: 13),
            showNavigation: false,
            showDone: true,
            decoration: inputDecoration.copyWith(hintText: 'Nội dung'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Send now
              Expanded(
                child: GestureDetector(
                  onTap: onSend,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Send Now', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delay picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF9FAFB),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DelayBtn(icon: Icons.remove, onTap: () { if (delaySeconds > 1) onDelayChanged(delaySeconds - 1); }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${delaySeconds}s', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    _DelayBtn(icon: Icons.add, onTap: () { if (delaySeconds < 60) onDelayChanged(delaySeconds + 1); }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Send delayed
              GestureDetector(
                onTap: onDelayed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Delay', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DelayBtn extends StatelessWidget {
  const _DelayBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, size: 16, color: const Color(0xFF374151)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live Activity Section
// ---------------------------------------------------------------------------

class _LiveActivitySection extends StatefulWidget {
  const _LiveActivitySection({required this.onLog});
  final void Function(String) onLog;

  @override
  State<_LiveActivitySection> createState() => _LiveActivitySectionState();
}

class _LiveActivitySectionState extends State<_LiveActivitySection> {
  final _service = LiveActivityService.instance;

  final _titleCtrl    = TextEditingController(text: 'Đơn hàng #12345');
  final _subtitleCtrl = TextEditingController(text: 'Cửa hàng Quận 1');
  final _statusCtrl   = TextEditingController(text: 'Shipper đang đến');
  final _etaCtrl      = TextEditingController(text: '10 phút');

  String? _activityId;
  double _progress = 0.3;
  bool _supported = false;

  @override
  void initState() {
    super.initState();
    _service.areActivitiesEnabled().then((v) => setState(() => _supported = v));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _statusCtrl.dispose();
    _etaCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final id = await _service.start(LiveActivityData(
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
    ));
    if (id == null) {
      widget.onLog('❌ Live Activity không khởi động được (device không hỗ trợ hoặc chưa cấp quyền)');
      return;
    }
    setState(() => _activityId = id);
    widget.onLog('✅ Live Activity started — id: $id');
  }

  Future<void> _update() async {
    if (_activityId == null) return;
    await _service.update(
      _activityId!,
      LiveActivityState(
        status: _statusCtrl.text.trim(),
        eta: _etaCtrl.text.trim(),
        progress: _progress,
      ),
    );
    widget.onLog('🔄 Updated → status="${_statusCtrl.text}" eta="${_etaCtrl.text}" progress=${(_progress * 100).round()}%');
  }

  Future<void> _end() async {
    if (_activityId == null) return;
    await _service.end(_activityId!);
    widget.onLog('🛑 Live Activity ended — id: $_activityId');
    setState(() => _activityId = null);
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 12, color: Color(0xFF6B7280));
    const inputDecoration = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _supported ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _supported ? 'Supported' : 'Not supported',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              if (_activityId != null)
                Expanded(
                  child: Text(
                    'ID: $_activityId',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Static data (title + subtitle)
          const Text('Static data', style: labelStyle),
          const SizedBox(height: 4),
          TextField(controller: _titleCtrl,    decoration: inputDecoration.copyWith(labelText: 'Title'),    style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _subtitleCtrl, decoration: inputDecoration.copyWith(labelText: 'Subtitle'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),

          // Dynamic state
          const Text('Dynamic state', style: labelStyle),
          const SizedBox(height: 4),
          TextField(controller: _statusCtrl, decoration: inputDecoration.copyWith(labelText: 'Status'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _etaCtrl,    decoration: inputDecoration.copyWith(labelText: 'ETA'),    style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Progress', style: labelStyle),
              Expanded(
                child: Slider(
                  value: _progress,
                  onChanged: (v) => setState(() => _progress = v),
                  activeColor: const Color(0xFF3B82F6),
                ),
              ),
              Text('${(_progress * 100).round()}%', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
            ],
          ),
          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              _LiveBtn(
                label: 'Start',
                color: const Color(0xFF3B82F6),
                onTap: _activityId == null ? _start : null,
              ),
              const SizedBox(width: 8),
              _LiveBtn(
                label: 'Update',
                color: const Color(0xFF0D9488),
                onTap: _activityId != null ? _update : null,
              ),
              const SizedBox(width: 8),
              _LiveBtn(
                label: 'End',
                color: const Color(0xFFEF4444),
                onTap: _activityId != null ? _end : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveBtn extends StatelessWidget {
  const _LiveBtn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null ? color : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
