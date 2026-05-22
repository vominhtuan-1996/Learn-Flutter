import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/notification_center/notification_center_service.dart';

/// Màn hình test trực quan cho [NotificationCenterService] (pub/sub event bus).
///
/// Bao gồm các case:
/// 1. Post → 1 subscriber nhận event không data.
/// 2. Post kèm data (Map / String / int) — hiển thị nội dung nhận được.
/// 3. Nhiều subscriber cùng 1 tên — chỉ subscriber cuối được giữ (do package
///    chỉ lưu 1 callback / tên — case này minh hoạ hành vi).
/// 4. Unsubscribe — verify callback không còn được gọi.
/// 5. Constant name từ [ConstantsNotificationCenterName].
class NotificationCenterTestScreen extends StatefulWidget {
  const NotificationCenterTestScreen({super.key});

  @override
  State<NotificationCenterTestScreen> createState() =>
      _NotificationCenterTestScreenState();
}

class _NotificationCenterTestScreenState
    extends State<NotificationCenterTestScreen> {
  // ── Tên event dùng cho demo ─────────────────────────────
  static const _evtPing = 'demo_ping';
  static const _evtData = 'demo_with_data';
  static const _evtToggle = 'demo_toggle';

  // ── State hiển thị ──────────────────────────────────────
  final List<String> _logs = [];
  int _pingCount = 0;
  bool _toggleSubscribed = false;

  @override
  void initState() {
    super.initState();
    // Subscribe ngay khi mở screen.
    NotificationCenterService.subscribeCenterNotification(
      nameNotification: _evtPing,
      callback: (data) {
        setState(() {
          _pingCount++;
          _addLog('🔔 [$_evtPing] nhận được (#$_pingCount)');
        });
      },
    );

    NotificationCenterService.subscribeCenterNotification(
      nameNotification: _evtData,
      callback: (data) {
        setState(
            () => _addLog('📦 [$_evtData] data = ${data ?? "(null)"} (${data.runtimeType})'));
      },
    );

    NotificationCenterService.subscribeCenterNotification(
      nameNotification:
          ConstantsNotificationCenterName.getCheckListComponent,
      callback: (data) {
        setState(() => _addLog(
            '✅ [getCheckListComponent] triggered (data=${data ?? "-"})'));
      },
    );
  }

  @override
  void dispose() {
    NotificationCenterService.unsubscribeCenterNotification(
        nameNotification: _evtPing);
    NotificationCenterService.unsubscribeCenterNotification(
        nameNotification: _evtData);
    NotificationCenterService.unsubscribeCenterNotification(
        nameNotification: ConstantsNotificationCenterName.getCheckListComponent);
    if (_toggleSubscribed) {
      NotificationCenterService.unsubscribeCenterNotification(
          nameNotification: _evtToggle);
    }
    super.dispose();
  }

  void _addLog(String message) {
    final time = TimeOfDay.now().format(context);
    _logs.insert(0, '[$time] $message');
    if (_logs.length > 30) _logs.removeLast();
  }

  // ── Actions ─────────────────────────────────────────────
  void _post(String name, [dynamic data]) {
    NotificationCenterService.postCenterNotification(
      nameNotification: name,
      data: data,
    );
  }

  void _toggleSubscription() {
    setState(() {
      if (_toggleSubscribed) {
        NotificationCenterService.unsubscribeCenterNotification(
            nameNotification: _evtToggle);
        _addLog('🚫 Unsubscribed [$_evtToggle]');
      } else {
        NotificationCenterService.subscribeCenterNotification(
          nameNotification: _evtToggle,
          callback: (data) => setState(
              () => _addLog('🎯 [$_evtToggle] nhận event với data=$data')),
        );
        _addLog('✅ Subscribed [$_evtToggle]');
      }
      _toggleSubscribed = !_toggleSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('NotificationCenter — Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear logs',
            onPressed: () => setState(() {
              _logs.clear();
              _pingCount = 0;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(
                  '1. Post event không data',
                  'Mỗi lần bấm, subscriber `$_evtPing` tăng counter.',
                  child: Row(
                    children: [
                      Expanded(
                        child: _btn(
                          'Post ping',
                          Icons.notifications_active_rounded,
                          const Color(0xFF2563EB),
                          () => _post(_evtPing),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'Count: $_pingCount',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8)),
                        ),
                      ),
                    ],
                  ),
                ),
                _section(
                  '2. Post kèm data (nhiều kiểu)',
                  'Subscriber `$_evtData` log lại data + runtime type.',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _btn('String', Icons.text_fields_rounded,
                          const Color(0xFF16A34A),
                          () => _post(_evtData, 'Xin chào!')),
                      _btn('int', Icons.numbers_rounded,
                          const Color(0xFFEA580C),
                          () => _post(_evtData, 42)),
                      _btn('Map', Icons.data_object_rounded,
                          const Color(0xFF7C3AED),
                          () => _post(_evtData,
                              {'userId': 1, 'name': 'Tuấn'})),
                      _btn('null', Icons.cancel_outlined,
                          const Color(0xFF6B7280),
                          () => _post(_evtData, null)),
                    ],
                  ),
                ),
                _section(
                  '3. Subscribe / Unsubscribe runtime',
                  'Verify callback ngừng được gọi sau khi unsubscribe.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _btn(
                        _toggleSubscribed
                            ? 'Unsubscribe $_evtToggle'
                            : 'Subscribe $_evtToggle',
                        _toggleSubscribed
                            ? Icons.notifications_off_rounded
                            : Icons.notifications_rounded,
                        _toggleSubscribed
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                        _toggleSubscribed
                            ? _toggleSubscription
                            : _toggleSubscription,
                      ),
                      const SizedBox(height: 8),
                      _btn(
                        'Post $_evtToggle (data=now())',
                        Icons.send_rounded,
                        const Color(0xFF2563EB),
                        () => _post(_evtToggle,
                            DateTime.now().toIso8601String()),
                      ),
                    ],
                  ),
                ),
                _section(
                  '4. Constant name từ ConstantsNotificationCenterName',
                  'Dùng tên đã định nghĩa sẵn — tránh typo, dễ refactor.',
                  child: _btn(
                    'Post getCheckListComponent',
                    Icons.checklist_rounded,
                    const Color(0xFF0EA5E9),
                    () => _post(
                        ConstantsNotificationCenterName.getCheckListComponent,
                        {'screen': 'TestScreen'}),
                  ),
                ),
              ],
            ),
          ),
          _logsPanel(),
        ],
      ),
    );
  }

  Widget _section(String title, String desc, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _logsPanel() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  'Event log (${_logs.length})',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      '(chưa có event)',
                      style: TextStyle(
                          color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[i],
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFFD1FAE5)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
