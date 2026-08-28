import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/local_notification/local_notification_widget.dart';
import 'package:learnflutter/shared/widgets/app_avatar.dart';
import 'package:learnflutter/shared/widgets/app_badge.dart';
import 'package:learnflutter/shared/widgets/app_button.dart';
import 'package:learnflutter/shared/widgets/app_chip.dart';
import 'package:learnflutter/shared/widgets/app_dialog.dart';
import 'package:learnflutter/shared/widgets/app_divider.dart';
import 'package:learnflutter/shared/widgets/app_image_viewer.dart';
import 'package:learnflutter/shared/widgets/app_shimmer.dart';
import 'package:learnflutter/shared/widgets/app_text.dart';
import 'package:learnflutter/shared/widgets/detail_container.dart';
import 'package:learnflutter/shared/widgets/empty_widget.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';
import 'package:learnflutter/shared/widgets/expandable_panel.dart';
import 'package:learnflutter/shared/widgets/highlighted_text.dart';
import 'package:learnflutter/shared/widgets/otp_input.dart';
import 'package:learnflutter/shared/widgets/rating_bar.dart';
import 'package:learnflutter/shared/widgets/ripple_override.dart';
import 'package:learnflutter/shared/widgets/step_indicator.dart';
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
  bool _btnLoading = false;
  double _rating = 3.0;
  String _otpValue = '';
  bool _chipFilterSelected = false;
  int _currentStep = 0;

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

          // ── NEW WIDGETS ──────────────────────────────────────────────

          _Section(
            title: '🔘 AppButton',
            description: 'primary / secondary / outline / text + loading state',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.primary(
                  label: 'Primary',
                  isLoading: _btnLoading,
                  onTap: () async {
                    setState(() => _btnLoading = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _btnLoading = false);
                  },
                ),
                const SizedBox(height: 8),
                AppButton.secondary(label: 'Secondary', onTap: () {}),
                const SizedBox(height: 8),
                AppButton.outline(label: 'Outline', onTap: () {}),
                const SizedBox(height: 8),
                AppButton.text(label: 'Text button', onTap: () {}),
                const SizedBox(height: 8),
                AppButton.primary(label: 'Disabled', enable: false, onTap: () {}),
              ],
            ),
          ),

          _Section(
            title: '✨ AppShimmer',
            description: 'Skeleton loading — box / text / circle',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppShimmer.circle(size: 48),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.text(width: 160),
                        const SizedBox(height: 6),
                        AppShimmer.text(width: 100),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppShimmer.box(width: double.infinity, height: 80),
              ],
            ),
          ),

          _Section(
            title: '👤 AppAvatar',
            description: 'Network image + initials fallback',
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: 'https://i.pravatar.cc/150?img=3',
                  size: 56,
                  borderColor: const Color(0xFFFDA758),
                  borderWidth: 2,
                  onTap: () => _toast(context, 'Avatar tapped'),
                ),
                const SizedBox(width: 12),
                const AppAvatar(name: 'Võ Minh Tuấn', size: 56),
                const SizedBox(width: 12),
                const AppAvatar(size: 40),
                const SizedBox(width: 12),
                const AppAvatar(name: 'A', size: 32),
              ],
            ),
          ),

          _Section(
            title: '🔴 AppBadge',
            description: 'Overlay badge với count và maxCount',
            child: Row(
              children: [
                AppBadge(
                  count: 5,
                  child: const Icon(Icons.notifications_outlined, size: 32),
                ),
                const SizedBox(width: 24),
                AppBadge(
                  count: 120,
                  maxCount: 99,
                  child: const Icon(Icons.mail_outline, size: 32),
                ),
                const SizedBox(width: 24),
                AppBadge(
                  count: 0,
                  showZero: true,
                  color: Colors.green,
                  child: const Icon(Icons.shopping_cart_outlined, size: 32),
                ),
              ],
            ),
          ),

          _Section(
            title: '🏷 AppChip',
            description: 'filter (toggle) / label / action (dismissible)',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip.filter(
                  label: 'Flutter',
                  selected: _chipFilterSelected,
                  onTap: () => setState(() => _chipFilterSelected = !_chipFilterSelected),
                ),
                AppChip.filter(label: 'Dart', selected: true),
                AppChip.label(label: 'v3.29.3', color: Colors.green),
                AppChip.action(
                  label: 'Xoá được',
                  onDelete: () => _toast(context, 'Chip deleted'),
                ),
              ],
            ),
          ),

          _Section(
            title: '🔢 OtpInput',
            description: 'Auto-focus next field, backspace support',
            child: Column(
              children: [
                OtpInput(
                  length: 6,
                  onCompleted: (v) => setState(() => _otpValue = v),
                  onChanged: (v) => setState(() => _otpValue = v),
                ),
                const SizedBox(height: 8),
                Text('Value: $_otpValue', style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),

          _Section(
            title: '⭐ RatingBar',
            description: 'Interactive + half-star + readOnly',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBar(
                  rating: _rating,
                  halfStarEnabled: true,
                  onRatingChanged: (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 4),
                Text('Rating: $_rating', style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                const RatingBar(rating: 4.5, readOnly: true, size: 20),
              ],
            ),
          ),

          _Section(
            title: '📂 ExpandablePanel',
            description: 'Animated expand/collapse với chevron',
            child: ExpandablePanel(
              header: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Nhấn để mở rộng', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              body: const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Nội dung được ẩn. ExpandablePanel dùng SizeTransition nên smooth, không giật.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
          ),

          _Section(
            title: '📍 StepIndicator',
            description: 'dot / bar / number — 3 step types',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Step: '),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => setState(() {
                        if (_currentStep > 0) _currentStep--;
                      }),
                    ),
                    Text('$_currentStep'),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => setState(() {
                        if (_currentStep < 4) _currentStep++;
                      }),
                    ),
                  ],
                ),
                StepIndicator(totalSteps: 5, currentStep: _currentStep, type: StepIndicatorType.dot),
                const SizedBox(height: 12),
                StepIndicator(totalSteps: 5, currentStep: _currentStep, type: StepIndicatorType.bar),
                const SizedBox(height: 12),
                StepIndicator(totalSteps: 5, currentStep: _currentStep, type: StepIndicatorType.number),
              ],
            ),
          ),

          _Section(
            title: '💬 AppDialog',
            description: 'confirm / alert / custom',
            child: Wrap(
              spacing: 8,
              children: [
                _miniBtn('Confirm', const Color(0xFFFDA758), () {
                  AppDialog.confirm(
                    context,
                    title: 'Xác nhận',
                    message: 'Bạn có chắc muốn thực hiện thao tác này?',
                    onConfirm: () => _toast(context, 'Confirmed!'),
                  );
                }),
                _miniBtn('Alert', const Color(0xFF6B7280), () {
                  AppDialog.alert(
                    context,
                    title: 'Thông báo',
                    message: 'Thao tác đã hoàn tất thành công.',
                  );
                }),
              ],
            ),
          ),

          _Section(
            title: '🖼 AppImageViewer',
            description: 'Full-screen pinch-to-zoom, swipe-to-dismiss, gallery',
            child: Wrap(
              spacing: 8,
              children: [
                _miniBtn('Single image', const Color(0xFF2563EB), () {
                  AppImageViewer.show(
                    context,
                    imageUrl: 'https://picsum.photos/seed/flutter/800/600',
                  );
                }),
                _miniBtn('Gallery (3 ảnh)', const Color(0xFF7C3AED), () {
                  AppImageViewer.showGallery(
                    context,
                    images: [
                      'https://picsum.photos/seed/a/800/600',
                      'https://picsum.photos/seed/b/800/600',
                      'https://picsum.photos/seed/c/800/600',
                    ],
                  );
                }),
              ],
            ),
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
