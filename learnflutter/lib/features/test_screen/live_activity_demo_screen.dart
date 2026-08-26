import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/live_activity/live_activity_data.dart';
import 'package:learnflutter/core/services/live_activity/live_activity_service.dart';

class LiveActivityDemoScreen extends StatefulWidget {
  const LiveActivityDemoScreen({super.key});

  @override
  State<LiveActivityDemoScreen> createState() => _LiveActivityDemoScreenState();
}

class _LiveActivityDemoScreenState extends State<LiveActivityDemoScreen> {
  final _service = LiveActivityService.instance;

  final _titleCtrl    = TextEditingController(text: 'Đơn hàng #12345');
  final _subtitleCtrl = TextEditingController(text: 'Cửa hàng Quận 1');
  final _statusCtrl   = TextEditingController(text: 'Shipper đang đến');
  final _etaCtrl      = TextEditingController(text: '10 phút');

  String? _activityId;
  double _progress = 0.3;
  bool _supported = false;
  final List<String> _logs = [];

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

  void _log(String msg) => setState(() => _logs.insert(0, msg));

  Future<void> _start() async {
    final id = await _service.start(LiveActivityData(
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
    ));
    if (id == null) {
      _log('❌ Không khởi động được (device không hỗ trợ hoặc chưa cấp quyền)');
      return;
    }
    setState(() => _activityId = id);
    _log('✅ Started — id: $id');
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
    _log('🔄 Updated → "${_statusCtrl.text}" | ${_etaCtrl.text} | ${(_progress * 100).round()}%');
  }

  Future<void> _end() async {
    if (_activityId == null) return;
    await _service.end(_activityId!);
    _log('🛑 Ended — id: $_activityId');
    setState(() => _activityId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚡ Live Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform warning
            if (!Platform.isIOS)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Text(
                  '⚠️ Live Activity (ActivityKit) chỉ hỗ trợ iOS 16.1+. Android ongoing notification implement riêng.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                ),
              ),

            // Support badge + activity ID
            Row(
              children: [
                _Badge(label: _supported ? 'Supported' : 'Not supported', color: _supported ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                if (_activityId != null)
                  Expanded(
                    child: Text('ID: $_activityId', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Static section
            _SectionTitle('Static data (set once on start)'),
            const SizedBox(height: 6),
            _Field(controller: _titleCtrl, label: 'Title'),
            const SizedBox(height: 8),
            _Field(controller: _subtitleCtrl, label: 'Subtitle'),
            const SizedBox(height: 16),

            // Dynamic section
            _SectionTitle('Dynamic state (update anytime)'),
            const SizedBox(height: 6),
            _Field(controller: _statusCtrl, label: 'Status'),
            const SizedBox(height: 8),
            _Field(controller: _etaCtrl, label: 'ETA'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Progress', style: TextStyle(fontSize: 13, color: Color(0xFF374151))),
                Expanded(
                  child: Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text('${(_progress * 100).round()}%', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                _ActionBtn(label: 'Start',  color: const Color(0xFF3B82F6), enabled: _activityId == null, onTap: _start),
                const SizedBox(width: 8),
                _ActionBtn(label: 'Update', color: const Color(0xFF0D9488), enabled: _activityId != null, onTap: _update),
                const SizedBox(width: 8),
                _ActionBtn(label: 'End',    color: const Color(0xFFEF4444), enabled: _activityId != null, onTap: _end),
              ],
            ),
            const SizedBox(height: 20),

            // Hints
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('💡 Hướng dẫn test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                  SizedBox(height: 4),
                  Text('1. Nhấn Start → Lock Screen banner xuất hiện', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                  Text('2. Lock device hoặc vuốt xuống Notification Center để thấy banner', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                  Text('3. Kéo slider, đổi status/eta → nhấn Update', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                  Text('4. Dynamic Island: cần iPhone 14 Pro+ (simulator hoặc real device)', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                  Text('5. Nhấn End để kết thúc activity', style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Log
            if (_logs.isNotEmpty) ...[
              _SectionTitle('Log'),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF374151), height: 8),
                  itemBuilder: (_, i) => Text(_logs[i], style: const TextStyle(fontSize: 11, color: Color(0xFFD1D5DB), fontFamily: 'monospace')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.5),
      );
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 13),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
      );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.color, required this.enabled, required this.onTap});
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? color : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      );
}
