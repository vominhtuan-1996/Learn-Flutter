import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_widget.dart';
import 'package:learnflutter/shared/widgets/app_divider.dart';
import 'package:learnflutter/shared/widgets/app_text.dart';
import 'package:learnflutter/shared/widgets/detail_container.dart';
import 'package:learnflutter/shared/widgets/empty_widget.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';
import 'package:learnflutter/shared/widgets/highlighted_text.dart';
import 'package:learnflutter/shared/widgets/ripple_override.dart';
import 'package:learnflutter/shared/widgets/tap.dart';
import 'package:learnflutter/shared/widgets/zoom_tap_effect.dart';

/// Galley tổng hợp các widget trong [lib/shared/widgets/] để xem trực quan
/// và test nhanh hành vi mỗi widget mà không phải lục từng file.
class WidgetsGalleryDemoScreen extends StatefulWidget {
  const WidgetsGalleryDemoScreen({super.key});

  @override
  State<WidgetsGalleryDemoScreen> createState() => _WidgetsGalleryDemoScreenState();
}

class _WidgetsGalleryDemoScreenState extends State<WidgetsGalleryDemoScreen> {
  bool _enableSample = true;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Widgets Gallery',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: '📝 AppText',
            description: 'Text wrapper với fontSize/weight/color/requiredMark',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Default text'),
                const SizedBox(height: 6),
                AppText('Bold 18 đỏ', fontSize: 18, weight: FontWeight.bold, color: Colors.red),
                const SizedBox(height: 6),
                AppText('Required field', requiredMark: true),
              ],
            ),
          ),
          _Section(
            title: '➖ AppDivider',
            description: 'Divider ngang/dọc tuỳ chỉnh màu & độ dày',
            child: Column(
              children: [
                AppDivider.horizontal(height: 1, color: Colors.grey),
                const SizedBox(height: 12),
                AppDivider.horizontal(height: 3, color: Colors.blue),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      const Text('Trái'),
                      const SizedBox(width: 12),
                      AppDivider.vertical(width: 2.0, height: 30.0, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      const Text('Phải'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: '📦 DetailContainer',
            description: 'Container chuẩn dạng row có title + child + onTap',
            child: Column(
              children: [
                DetailContainer(
                  title: 'Họ tên',
                  requiredMark: true,
                  child: const Text('Võ Minh Tuấn'),
                  onTap: () => _toast(context, 'Tap DetailContainer'),
                ),
                const SizedBox(height: 6),
                DetailContainer(
                  title: 'Disabled',
                  enable: false,
                  child: const Text('Không thể chỉnh sửa'),
                ),
              ],
            ),
          ),
          _Section(
            title: '🪹 EmptyWidget',
            description: 'Placeholder khi không có dữ liệu',
            child: SizedBox(
              height: 140,
              child: EmptyWidget(message: 'Danh sách trống'),
            ),
          ),
          _Section(
            title: '✨ HighlightedText',
            description: 'Highlight từng từ trong câu với style riêng',
            child: const HighlightedText(
              message: 'Flutter giúp tạo UI nhanh và đẹp',
              highlights: {
                'Flutter': TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                'nhanh': TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                'đẹp': TextStyle(color: Colors.pink, fontStyle: FontStyle.italic),
              },
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          _Section(
            title: '🔒 EnableWidget',
            description: 'Toggle enable/disable + overlay mờ',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Enable: '),
                    Switch(
                      value: _enableSample,
                      onChanged: (v) => setState(() => _enableSample = v),
                    ),
                  ],
                ),
                EnableWidget(
                  enable: _enableSample,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Khối nội dung có thể disable'),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: '🎯 ZoomTapEffect',
            description: 'Hiệu ứng phóng to khi nhấn',
            child: ZoomTapEffect(
              onTap: () => _toast(context, 'Zoom tapped!'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nhấn vào tôi (Zoom)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          _Section(
            title: '💧 RippleOverride',
            description: 'Custom ripple effect khi nhấn',
            child: RippleOverride(
              onTap: () => _toast(context, 'Ripple tapped'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nhấn vào tôi (Ripple)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          _Section(
            title: '👆 Tap',
            description: 'Tap với debounce & long-press, đếm số lần tap',
            child: Tap(
              onTap: () => setState(() => _tapCount++),
              onLongTap: () => _toast(context, 'Long pressed!'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tap count: $_tapCount (long-press to alert)',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          _Section(
            title: '🔔 LocalNotificationOverlay',
            description: 'Custom in-app banner notification',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _miniBtn('Info', const Color(0xFF2563EB), () {
                  LocalNotificationOverlay.show(
                    context,
                    title: 'Thông báo',
                    body: 'In-app banner đang hoạt động',
                    icon: Icons.info_outline,
                    color: const Color(0xFF2563EB),
                  );
                }),
                _miniBtn('Success', const Color(0xFF16A34A), () {
                  LocalNotificationOverlay.show(
                    context,
                    title: 'Thành công',
                    body: 'Đã lưu dữ liệu.',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF16A34A),
                  );
                }),
                _miniBtn('Error', const Color(0xFFEF4444), () {
                  LocalNotificationOverlay.show(
                    context,
                    title: 'Lỗi',
                    body: 'Có lỗi xảy ra',
                    icon: Icons.error_outline,
                    color: const Color(0xFFEF4444),
                  );
                }),
              ],
            ),
          ),
          _Section(
            title: '📜 SnackBar (built-in)',
            description: 'Demo ScaffoldMessenger snackbar',
            child: _miniBtn('Show snackbar', const Color(0xFF0D9488), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đây là snackbar demo')),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  Widget _miniBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Section card
// ════════════════════════════════════════════

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
