import 'package:flutter/material.dart';
import 'package:learnflutter/core/engine_dialog/engine_dialog.dart';
import 'package:learnflutter/core/engine_bottom_sheet/engine_bottom_sheet.dart';
import 'package:learnflutter/shared/components/show_selector_widget/show_selector.dart';
import 'package:learnflutter/shared/models/option_model.dart';
import 'package:learnflutter/shared/models/load_more_model.dart';

/// EngineDialogDemoScreen – Màn hình demo toàn bộ bộ Engine Dialog.
///
/// Hiển thị tất cả các loại dialog và snackbar với các cấu hình khác nhau.
class EngineDialogDemoScreen extends StatelessWidget {
  const EngineDialogDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Engine Dialog System',
          style: TextStyle(fontWeight: FontWeight.w700),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DIALOGS ─────────────────────────────────
            _SectionTitle(title: '🗂 Dialogs', subtitle: 'AppDialogEngine'),
            const SizedBox(height: 12),

            _DemoRow(children: [
              _DemoCard(
                label: 'Info',
                icon: Icons.info_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => AppDialogEngine.showInfo(
                  context,
                  title: 'Thông báo hệ thống',
                  message: 'Phiên làm việc của bạn sẽ hết hạn sau 5 phút. Vui lòng lưu dữ liệu trước khi tiếp tục.',
                ),
              ),
              _DemoCard(
                label: 'Error',
                icon: Icons.error_rounded,
                color: const Color(0xFFEF4444),
                onTap: () => AppDialogEngine.showError(
                  context,
                  title: 'Kết nối thất bại',
                  message: 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.',
                ),
              ),
              _DemoCard(
                label: 'Success',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF22C55E),
                onTap: () => AppDialogEngine.showSuccess(
                  context,
                  title: 'Thanh toán thành công!',
                  message: 'Đơn hàng #12345 của bạn đã được xác nhận. Chúng tôi sẽ giao hàng trong 2-3 ngày làm việc.',
                ),
              ),
              _DemoCard(
                label: 'Warning',
                icon: Icons.warning_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => AppDialogEngine.showWarning(
                  context,
                  title: 'Xác nhận xoá',
                  message: 'Bạn có chắc muốn xoá tất cả dữ liệu? Hành động này không thể hoàn tác.',
                  showCancelButton: true,
                  onConfirm: () => debugPrint('✅ Đã xác nhận xoá'),
                  onCancel: () => debugPrint('❌ Đã huỷ'),
                ),
              ),
            ]),

            const SizedBox(height: 28),

            // ── DIALOGS ADVANCED ────────────────────────
            _SectionTitle(title: '⚙️ Dialog – Nâng cao', subtitle: 'Custom config'),
            const SizedBox(height: 12),

            _ListTile(
              label: 'Info – 2 nút (Confirm + Cancel)',
              color: const Color(0xFF3B82F6),
              onTap: () => AppDialogEngine.showInfo(
                context,
                title: 'Cập nhật ứng dụng',
                message: 'Phiên bản 2.1.0 đã sẵn sàng. Cập nhật ngay để trải nghiệm tính năng mới nhất?',
                showCancelButton: true,
                confirmText: 'Cập nhật ngay',
                cancelText: 'Để sau',
                onConfirm: () => debugPrint('🚀 Bắt đầu cập nhật'),
              ),
            ),
            _ListTile(
              label: 'Error – Không thể đóng bằng tap ngoài',
              color: const Color(0xFFEF4444),
              onTap: () => AppDialogEngine.showError(
                context,
                title: 'Lỗi xác thực',
                message: 'Token của bạn đã hết hạn. Vui lòng đăng nhập lại để tiếp tục sử dụng.',
                barrierDismissible: false,
                confirmText: 'Đăng nhập lại',
                onConfirm: () => debugPrint('🔑 Redirect to Login'),
              ),
            ),
            _ListTile(
              label: 'Highlight – Làm nổi bật từ khóa trong nội dung',
              color: const Color(0xFF0EA5E9),
              onTap: () => AppDialogEngine.showHighlightMessage(
                context,
                title: 'Xóa tài khoản',
                message: 'Hành động này sẽ xóa vĩnh viễn tài khoản của bạn. Mọi dữ liệu không thể khôi phục.',
                highlights: {
                  'xóa vĩnh viễn': const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  'không thể khôi phục': const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                },
                showCancelButton: true,
                confirmText: 'Đã hiểu và xóa',
                cancelText: 'Hủy bỏ',
              ),
            ),
            _ListTile(
              label: 'Success – Custom widget content',
              color: const Color(0xFF22C55E),
              onTap: () => AppDialogEngine.show(
                context,
                config: AppDialogConfig(
                  title: 'Tải lên hoàn tất!',
                  message: '',
                  type: AppDialogType.success,
                  confirmText: 'Xem kết quả',
                  contentWidget: Column(
                    children: [
                      const Text(
                        '3 tệp đã được tải lên thành công',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(label: 'Tệp', value: '3'),
                            _StatItem(label: 'Kích thước', value: '12.4 MB'),
                            _StatItem(label: 'Thời gian', value: '2.3s'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _ListTile(
              label: 'Warning – Custom icon',
              color: const Color(0xFFF59E0B),
              onTap: () => AppDialogEngine.show(
                context,
                config: AppDialogConfig(
                  title: 'Pin sắp hết',
                  message: 'Thiết bị của bạn chỉ còn 8% pin. Vui lòng sạc để tránh gián đoạn.',
                  type: AppDialogType.warning,
                  confirmText: 'Tôi biết rồi',
                  customIcon: const Icon(Icons.battery_alert_rounded, color: Color(0xFFF59E0B), size: 32),
                ),
              ),
            ),
            _ListTile(
              label: '⚙️ Process Stepper – Quy trình nhiều bước động (Config-driven)',
              color: const Color(0xFF7C3AED),
              onTap: () {
                AppDialogEngine.showStepper(
                  context,
                  title: 'Đang triển khai dịch vụ Cloud',
                  steps: [
                    AppProcessStepConfig(
                      title: 'Khởi tạo cụm Server Kubernetes',
                      processingSubtitle: 'Đang khởi tạo cụm server...',
                      action: () async {
                        await Future.delayed(const Duration(seconds: 2));
                        return {'clusterId': 'K8S-CLUSTER-V9', 'nodeCount': 3};
                      },
                      subtitleBuilder: (result) => 'Đã kích hoạt cụm ${result['clusterId']} (${result['nodeCount']} Node)',
                    ),
                    AppProcessStepConfig(
                      title: 'Cấu hình CDN & SSL Certificates',
                      processingSubtitle: 'Đang thiết lập cổng bảo mật SSL...',
                      action: () async {
                        await Future.delayed(const Duration(seconds: 2));
                        // Thi thoảng giả lập lỗi để test tính năng Retry cho trực quan
                        return {'domain': 'app.coupon.internal', 'ssl': 'Let\'s Encrypt Wildcard'};
                      },
                      subtitleBuilder: (result) => 'Đã cấu hình ${result['domain']} qua ${result['ssl']}',
                    ),
                    AppProcessStepConfig(
                      title: 'Đồng bộ cơ sở dữ liệu phân tán',
                      processingSubtitle: 'Đang đồng bộ dữ liệu...',
                      action: () async {
                        await Future.delayed(const Duration(seconds: 2));
                        return {'records': 12540, 'duration': '1.2s'};
                      },
                      subtitleBuilder: (result) => 'Đã đồng bộ ${result['records']} bản ghi trong ${result['duration']}',
                    ),
                  ],
                  summaryTitleBuilder: (results) {
                    return '🚀 Dịch vụ của bạn đã được deploy hoàn tất!';
                  },
                  summaryNotesBuilder: (results) {
                    final k8s = results[0];
                    final cdn = results[1];
                    final db = results[2];
                    return [
                      if (k8s != null) 'Cụm Kubernetes: ${k8s['clusterId']}',
                      if (cdn != null) 'Domain liên kết: ${cdn['domain']}',
                      if (db != null) 'Đồng bộ dữ liệu: ${db['records']} bản ghi',
                    ];
                  },
                );
              },
            ),
            _ListTile(
              label: '📥 Multi-file Download – Tải xuống đồng thời nhiều tệp (Giả lập Lỗi & Retry)',
              color: const Color(0xFF3B82F6),
              onTap: () {
                int dbTryCount = 0;
                AppDialogEngine.showMultiDownload(
                  context,
                  title: 'Tải xuống gói tài nguyên cập nhật',
                  files: [
                    AppTransferFileConfig(
                      name: 'Hình ảnh assets & icons hệ thống.zip',
                      sizeInMB: 12.4,
                      transferAction: (onProgress) async {
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 100));
                          current += 0.1;
                          onProgress(current);
                        }
                      },
                    ),
                    AppTransferFileConfig(
                      name: 'Cơ sở dữ liệu SQLite offline_v2.db',
                      sizeInMB: 4.8,
                      transferAction: (onProgress) async {
                        dbTryCount++;
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 80));
                          current += 0.15;
                          onProgress(current.clamp(0.0, 1.0));
                          
                          // Lần đầu tiên: Đang tải đến 60% thì đứt mạng (ném lỗi)
                          if (dbTryCount == 1 && current >= 0.6) {
                            throw Exception("Mất kết nối server giữa chừng!");
                          }
                        }
                      },
                    ),
                    AppTransferFileConfig(
                      name: 'Tài liệu hướng dẫn sử dụng PDF.pdf',
                      sizeInMB: 28.1,
                      transferAction: (onProgress) async {
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 150));
                          current += 0.08;
                          onProgress(current);
                        }
                      },
                    ),
                  ],
                  onCompleted: () => debugPrint('📥 Tải xuống tất cả tệp thành công!'),
                  onCanceled: () => debugPrint('❌ Người dùng đã hủy tải xuống!'),
                );
              },
            ),
            _ListTile(
              label: '📤 Multi-file Upload – Tải lên đồng thời nhiều tệp',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                AppDialogEngine.showMultiUpload(
                  context,
                  title: 'Tải lên tài liệu phê duyệt',
                  files: [
                    AppTransferFileConfig(
                      name: 'Báo cáo tài chính quý 1_2026.xlsx',
                      sizeInMB: 3.5,
                      transferAction: (onProgress) async {
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 120));
                          current += 0.12;
                          onProgress(current);
                        }
                      },
                    ),
                    AppTransferFileConfig(
                      name: 'Hợp đồng lao động mẫu.docx',
                      sizeInMB: 1.2,
                      transferAction: (onProgress) async {
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 60));
                          current += 0.2;
                          onProgress(current);
                        }
                      },
                    ),
                    AppTransferFileConfig(
                      name: 'Video nghiệm thu công trình.mp4',
                      sizeInMB: 84.6,
                      transferAction: (onProgress) async {
                        double current = 0.0;
                        while (current < 1.0) {
                          await Future.delayed(const Duration(milliseconds: 200));
                          current += 0.05;
                          onProgress(current);
                        }
                      },
                    ),
                  ],
                  onCompleted: () => debugPrint('📤 Tải lên tất cả tệp thành công!'),
                  onCanceled: () => debugPrint('❌ Người dùng đã hủy tải lên!'),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── UPDATE PATCH DIALOG ──────────────────────
            _SectionTitle(
              title: '🚀 Update Patch Dialog',
              subtitle: 'AppDialogEngine.showUpdatePatch — Hot patch / Code push',
            ),
            const SizedBox(height: 12),

            _DemoRow(children: [
              _DemoCard(
                label: 'Default',
                icon: Icons.system_update_rounded,
                color: const Color(0xFF2575FC),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '1.2.3',
                  changelog: const [
                    'Sửa lỗi crash khi mở camera trên Android 14.',
                    'Cải thiện tốc độ tải danh sách phiếu thi công.',
                    'Tinh chỉnh nhỏ về typography & spacing.',
                  ],
                  onUpdate: () => debugPrint('▶️ User bấm Cập nhật (chưa simulate)'),
                ),
              ),
              _DemoCard(
                label: 'Auto sim',
                icon: Icons.play_circle_fill_rounded,
                color: const Color(0xFF16A34A),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '2.0.0',
                  changelog: const [
                    'Đại tu giao diện theo design system mới.',
                    'Hỗ trợ Dark mode toàn bộ ứng dụng.',
                    'Tích hợp Shorebird code push hoàn chỉnh.',
                  ],
                  isDownloading: true,
                  autoSimulate: true,
                  onUpdate: () {},
                ),
              ),
              _DemoCard(
                label: 'Manual sim',
                icon: Icons.touch_app_rounded,
                color: const Color(0xFFEA580C),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '1.5.0-beta',
                  changelog: const [
                    'Thêm tab "Quà tặng" trong menu chính.',
                    'Tối ưu memory khi xem ảnh dung lượng lớn.',
                  ],
                  showSimulator: true,
                  onUpdate: () => debugPrint('▶️ Bắt đầu mô phỏng tải...'),
                ),
              ),
              _DemoCard(
                label: 'Long log',
                icon: Icons.description_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '3.0.0',
                  changelog: List.generate(
                    15,
                    (i) =>
                        'Thay đổi #${i + 1}: tối ưu hiệu năng module ${String.fromCharCode(65 + i)}.',
                  ),
                  onUpdate: () {},
                ),
              ),
            ]),

            const SizedBox(height: 16),

            _DemoRow(children: [
              _DemoCard(
                label: 'Progress 30%',
                icon: Icons.donut_small_rounded,
                color: const Color(0xFF0EA5E9),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '1.4.0',
                  changelog: const [
                    'Đang tiếp tục bản tải dở trước đó.',
                    'Khôi phục checkpoint từ phiên trước.',
                  ],
                  progress: 0.3,
                  isDownloading: true,
                  autoSimulate: true,
                  onUpdate: () {},
                ),
              ),
              _DemoCard(
                label: 'Patch tối thiểu',
                icon: Icons.bug_report_rounded,
                color: const Color(0xFFDC2626),
                onTap: () => AppDialogEngine.showUpdatePatch(
                  version: '1.2.4-hotfix',
                  changelog: const [
                    'Hotfix lỗi đăng nhập trên iOS 18.',
                  ],
                  onUpdate: () {},
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            ]),

            const SizedBox(height: 28),

            // ── SNACKBARS ────────────────────────────────
            _SectionTitle(title: '🍞 Snackbars – Bottom', subtitle: 'AppSnackbarEngine'),
            const SizedBox(height: 12),

            _DemoRow(children: [
              _DemoCard(
                label: 'Info',
                icon: Icons.info_rounded,
                color: const Color(0xFF1E40AF),
                onTap: () => AppSnackbarEngine.showInfo(
                  context,
                  message: 'Email xác nhận đã được gửi tới hộp thư của bạn.',
                ),
              ),
              _DemoCard(
                label: 'Error',
                icon: Icons.error_rounded,
                color: const Color(0xFFB91C1C),
                onTap: () => AppSnackbarEngine.showError(
                  context,
                  message: 'Tải dữ liệu thất bại. Vui lòng thử lại.',
                ),
              ),
              _DemoCard(
                label: 'Success',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF15803D),
                onTap: () => AppSnackbarEngine.showSuccess(
                  context,
                  message: 'Cài đặt đã được lưu thành công!',
                ),
              ),
              _DemoCard(
                label: 'Warning',
                icon: Icons.warning_rounded,
                color: const Color(0xFFB45309),
                onTap: () => AppSnackbarEngine.showWarning(
                  context,
                  message: 'Kết nối không ổn định. Một số tính năng có thể bị hạn chế.',
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _SectionTitle(
              title: '🍞 Snackbars – Top',
              subtitle: 'TopOverlayBanner · Overlay · Queue · Slide-from-top',
            ),
            const SizedBox(height: 8),

            // Info chip – giải thích cơ chế
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
                        children: [
                          TextSpan(text: 'Dùng lại ', style: TextStyle(fontWeight: FontWeight.w400)),
                          TextSpan(text: 'TopOverlayBanner', style: TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' – Overlay engine với cơ chế ', style: TextStyle(fontWeight: FontWeight.w400)),
                          TextSpan(text: 'Queue', style: TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(
                            text: ': nhiều banner gọi liên tiếp sẽ xếp hàng, không đè nhau.',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _DemoRow(children: [
              _DemoCard(
                label: 'Info ↑',
                icon: Icons.info_rounded,
                color: const Color(0xFF1E40AF),
                onTap: () => AppSnackbarEngine.showInfo(
                  context,
                  message: 'Bạn có tin nhắn mới từ hỗ trợ khách hàng.',
                  position: AppSnackbarPosition.top,
                ),
              ),
              _DemoCard(
                label: 'Error ↑',
                icon: Icons.error_rounded,
                color: const Color(0xFFB91C1C),
                onTap: () => AppSnackbarEngine.showError(
                  context,
                  message: 'Phiên đăng nhập hết hạn!',
                  position: AppSnackbarPosition.top,
                ),
              ),
              _DemoCard(
                label: 'Success ↑',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF15803D),
                onTap: () => AppSnackbarEngine.showSuccess(
                  context,
                  message: 'Hình ảnh đã được tải lên!',
                  position: AppSnackbarPosition.top,
                ),
              ),
              _DemoCard(
                label: 'Warning ↑',
                icon: Icons.warning_rounded,
                color: const Color(0xFFB45309),
                onTap: () => AppSnackbarEngine.showWarning(
                  context,
                  message: 'Bộ nhớ gần đầy (90%).',
                  position: AppSnackbarPosition.top,
                ),
              ),
            ]),

            const SizedBox(height: 12),

            // Queue demo
            _ListTile(
              label: '🧪 Test Queue – Spam 3 banners liên tiếp',
              color: const Color(0xFF7C3AED),
              onTap: () {
                AppSnackbarEngine.showInfo(
                  context,
                  message: '[1/3] Thao tác thứ nhất hoàn thành.',
                  position: AppSnackbarPosition.top,
                  duration: const Duration(seconds: 2),
                );
                AppSnackbarEngine.showSuccess(
                  context,
                  message: '[2/3] Dữ liệu đã được đồng bộ lên server.',
                  position: AppSnackbarPosition.top,
                  duration: const Duration(seconds: 2),
                );
                AppSnackbarEngine.showWarning(
                  context,
                  message: '[3/3] Một số mục chưa được đồng bộ.',
                  position: AppSnackbarPosition.top,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            _ListTile(
              label: '🗑 Clear Queue (xoá toàn bộ hàng đợi)',
              color: const Color(0xFFEF4444),
              onTap: () => AppSnackbarEngine.clearTopQueue(),
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: '⚡ Snackbar – Action Button', subtitle: 'actionLabel + onAction'),
            const SizedBox(height: 12),

            _ListTile(
              label: 'Success + Hoàn tác',
              color: const Color(0xFF15803D),
              onTap: () => AppSnackbarEngine.showSuccess(
                context,
                message: 'Tin nhắn đã được xoá.',
                actionLabel: 'Hoàn tác',
                onAction: () => debugPrint('↩️ Đã hoàn tác xoá'),
              ),
            ),
            _ListTile(
              label: 'Error + Thử lại',
              color: const Color(0xFFB91C1C),
              onTap: () => AppSnackbarEngine.showError(
                context,
                message: 'Gửi ảnh thất bại. Kiểm tra kết nối.',
                actionLabel: 'Thử lại',
                duration: const Duration(seconds: 6),
                onAction: () => debugPrint('🔄 Đang thử lại...'),
              ),
            ),
            _ListTile(
              label: 'Info + Xem chi tiết',
              color: const Color(0xFF1E40AF),
              onTap: () => AppSnackbarEngine.showInfo(
                context,
                message: 'Đã có cập nhật mới cho ứng dụng.',
                actionLabel: 'Xem',
                onAction: () => debugPrint('🔗 Mở cửa hàng'),
              ),
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: '⭐ Snackbars – Advanced Actions', subtitle: 'Interactive & Custom Actions'),
            const SizedBox(height: 12),

            _ListTile(
              label: '👥 Multi-Action: Kết bạn (Đồng ý / Bỏ qua)',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                AppSnackbarEngine.showInfo(
                  context,
                  message: 'Nguyễn Văn A gửi yêu cầu kết bạn.',
                  position: AppSnackbarPosition.bottom,
                  duration: const Duration(seconds: 8),
                  actionLabel: 'Đồng ý',
                  onAction: () => debugPrint('Accept Friend Request'),
                  additionalActions: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        debugPrint('Ignore Request');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          'Bỏ qua',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            _ListTile(
              label: '⏳ Background Task: Tiến trình upload (Custom Widget & Leading)',
              color: const Color(0xFF0D9488),
              onTap: () {
                AppSnackbarEngine.showSuccess(
                  context,
                  message: '',
                  position: AppSnackbarPosition.bottom,
                  duration: const Duration(seconds: 5),
                  leading: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Đang tải lên báo cáo doanh thu...',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            _ListTile(
              label: '🔥 Top Banner (Hold to Pause & Swipe to Close)',
              color: const Color(0xFFEF4444),
              onTap: () {
                AppSnackbarEngine.showWarning(
                  context,
                  message: 'Chú ý: Vuốt LÊN để tắt nhanh banner. Nhấn GIỮ để dừng đếm ngược.',
                  position: AppSnackbarPosition.top,
                  duration: const Duration(seconds: 4),
                );
              },
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: '💬 Bottom Sheets – Trượt đáy màn hình', subtitle: 'AppBottomSheetEngine'),
            const SizedBox(height: 12),

            _ListTile(
              label: '🚪 Confirmation: Xác nhận Đăng xuất (Warning)',
              color: const Color(0xFFEA580C),
              onTap: () {
                AppBottomSheetEngine.showWarning(
                  context,
                  title: 'Xác nhận Đăng xuất',
                  subtitle: 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống? Mọi phiên làm việc trên các thiết bị khác sẽ vẫn được duy trì.',
                  confirmText: 'Đăng xuất ngay',
                  cancelText: 'Huỷ bỏ',
                  onConfirm: () => debugPrint('🚪 User logged out'),
                );
              },
            ),

            _ListTile(
              label: '🎉 Confirmation: Thanh toán thành công (Success)',
              color: const Color(0xFF16A34A),
              onTap: () {
                AppBottomSheetEngine.showSuccess(
                  context,
                  title: 'Nạp tiền thành công!',
                  subtitle: 'Tài khoản của bạn đã được cộng 200,000đ. Hệ thống sẽ cập nhật số dư khả dụng ngay lập tức.',
                  confirmText: 'Xem số dư',
                  cancelText: 'Đóng lại',
                  onConfirm: () => debugPrint('💰 View balance'),
                );
              },
            ),

            _ListTile(
              label: '📂 Action Menu Sheet: Quản lý tài liệu (4 Options)',
              color: const Color(0xFF2563EB),
              onTap: () {
                AppBottomSheetEngine.showActionSheet(
                  context,
                  title: 'Quản lý tài liệu',
                  subtitle: 'Chọn tác vụ muốn áp dụng cho file "Báo cáo tài chính Q4.pdf":',
                  actions: [
                    AppBottomSheetActionItem(
                      label: 'Chia sẻ qua Email / Telegram',
                      icon: Icons.share_rounded,
                      onTap: () => debugPrint('🔗 Shared document'),
                    ),
                    AppBottomSheetActionItem(
                      label: 'Đổi tên tài liệu',
                      icon: Icons.edit_rounded,
                      onTap: () => debugPrint('📝 Renamed document'),
                    ),
                    AppBottomSheetActionItem(
                      label: 'Tải về thiết bị offline',
                      icon: Icons.download_rounded,
                      onTap: () => debugPrint('📥 Downloaded document'),
                    ),
                    AppBottomSheetActionItem(
                      label: 'Xoá vĩnh viễn tệp tin',
                      icon: Icons.delete_forever_rounded,
                      isDestructive: true,
                      onTap: () => debugPrint('🚨 Deleted permanently'),
                    ),
                  ],
                );
              },
            ),

            _ListTile(
              label: '⏳ Custom Sheet: Nhập mã xác thực OTP',
              color: const Color(0xFF7C3AED),
              onTap: () {
                final otpController = TextEditingController();
                AppBottomSheetEngine.showCustom(
                  context,
                  title: 'Xác thực OTP giao dịch',
                  confirmText: 'Xác nhận OTP',
                  cancelText: 'Gửi lại mã',
                  onConfirm: () => debugPrint('🔑 Verified OTP: ${otpController.text}'),
                  onCancel: () => debugPrint('🔄 Resend OTP requested'),
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Vui lòng nhập mã bảo mật 6 số đã được gửi qua SMS đến số điện thoại đăng ký của bạn.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            _SectionTitle(title: '🔘 Selector Widget', subtitle: 'ShowSelector & LoadMoreSelector'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ShowSelector<OptionModel>(
                title: 'Chọn phòng ban',
                hint: 'Tìm kiếm phòng ban...',
                selectedItems: const [],
                selectedLength: 1, // Single select
                showSelectedConfirm: true,
                onChanged: (values) {
                  debugPrint('Selected: $values');
                },
                getListFunction: (pageSize, pageNumber, keyword) async {
                  await Future.delayed(const Duration(seconds: 1)); // Mock network delay
                  
                  final mockData = List.generate(
                    pageSize,
                    (i) {
                      final id = (pageNumber - 1) * pageSize + i + 1;
                      return OptionModel(id: id, name: 'Phòng ban số $id ${keyword.isNotEmpty ? '($keyword)' : ''}');
                    },
                  );
                  
                  final model = LoadMoreModel<OptionModel>.init(mockData);
                  model.total = 50; // Mock total records
                  return model;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Helper Widgets
// ════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _DemoRow extends StatelessWidget {
  const _DemoRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .toList(),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF16A34A),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
