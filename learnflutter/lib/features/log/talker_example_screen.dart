// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:learnflutter/core/service/log/daily_log_scheduler.dart';
import 'package:learnflutter/core/service/log/log_file_service.dart';
import 'package:learnflutter/core/service/log/log_google_chat.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// [TalkerExampleScreen] là màn hình demo tích hợp package Talker 5.1.14 vào Flutter.
/// Nó minh hoạ toàn bộ API quan trọng của talker_flutter bao gồm:
///   - Ghi log nhiều mức độ: debug, info, warning, error, critical, good
///   - Xử lý ngoại lệ bằng talker.handle(e, st, message)
///   - Raw log với TalkerLog tuỳ chỉnh
///   - Xem log history trực tiếp trên thiết bị bằng TalkerScreen (không cần console)
/// Màn hình này hoạt động như một bộ test bench cho logging infrastructure của ứng dụng,
/// giúp team QA và dev xác nhận log đang được ghi đúng trước khi tích hợp vào luồng thực.
class TalkerExampleScreen extends StatefulWidget {
  /// [talker] là instance Talker được truyền vào từ ngoài (dependency injection).
  /// Bằng cách truyền từ ngoài, toàn bộ màn hình trong app có thể chia sẻ cùng một
  /// log history, giúp TalkerScreen hiển thị log xuyên suốt từ nhiều nguồn khác nhau.
  final Talker talker;

  const TalkerExampleScreen({super.key, required this.talker});

  @override
  State<TalkerExampleScreen> createState() => _TalkerExampleScreenState();
}

class _TalkerExampleScreenState extends State<TalkerExampleScreen> {
  /// [_logCount] đếm số lần người dùng đã gửi log — phục vụ cho mục đích demo.
  int _logCount = 0;

  /// Trạng thái của scheduler gửi log hằng ngày.
  bool _isSchedulerEnabled = false;

  /// Tên file log mới nhất đã được lưu.
  String _latestLogFileName = 'Chưa có file';

  /// Biến trạng thái khi đang gửi log thủ công.
  bool _isSendingLog = false;

  /// Getter tiện lợi để truy cập talker instance mà không cần gõ widget.talker nhiều lần.
  Talker get _talker => widget.talker;

  @override
  void initState() {
    super.initState();
    _checkSchedulerStatus();
    _updateLatestLogFileInfo();

    /// Ghi log khi màn hình này được khởi tạo lần đầu tiên.
    /// Cách dùng phổ biến trong initState để theo dõi vòng đời màn hình.
    _talker.info('🚀 TalkerExampleScreen đã được khởi tạo');
  }

  Future<void> _checkSchedulerStatus() async {
    final enabled = await DailyLogScheduler.isEnabled();
    if (mounted) {
      setState(() => _isSchedulerEnabled = enabled);
    }
  }

  Future<void> _updateLatestLogFileInfo() async {
    final file = await LogFileService.getLatestLogFile();
    if (mounted) {
      setState(() {
        _latestLogFileName =
            file != null ? file.path.split('/').last : 'Chưa có file';
      });
    }
  }

  @override
  void dispose() {
    /// Ghi log khi màn hình bị huỷ — hữu ích cho việc debug memory leak.
    _talker.debug('♻️ TalkerExampleScreen đã bị dispose');
    super.dispose();
  }

  /// [_logDebug] ghi một log cấp DEBUG — dùng cho thông tin phát triển nội bộ,
  /// thường bị ẩn trên môi trường production để tránh lộ dữ liệu nhạy cảm.
  void _logDebug() {
    _logCount++;
    _talker.debug(
        '🔍 [DEBUG #$_logCount] Trạng thái widget hiện tại: mounted=$mounted');
  }

  /// [_logInfo] ghi log cấp INFO — thông tin vận hành bình thường,
  /// phù hợp để theo dõi các sự kiện quan trọng như user action hay API response.
  void _logInfo() {
    _logCount++;
    _talker.info(
        'ℹ️ [INFO #$_logCount] Người dùng đã nhấn nút lần thứ $_logCount');
  }

  /// [_logWarning] cảnh báo ở cấp WARNING — không phải lỗi nhưng cần chú ý,
  /// ví dụ: kết nối chậm, dữ liệu không mong đợi, hoặc fallback logic được kích hoạt.
  void _logWarning() {
    _logCount++;
    _talker.warning('⚠️ [WARNING #$_logCount] Kết nối mạng không ổn định!');
  }

  /// [_logError] ghi log lỗi nghiêm trọng nhưng ứng dụng vẫn có thể tiếp tục.
  /// Sử dụng khi một tính năng thất bại nhưng không crash app.
  void _logError() {
    _logCount++;
    _talker.error('❌ [ERROR #$_logCount] Không thể tải dữ liệu từ server!');
  }

  /// [_logCritical] ghi log mức độ CRITICAL — lỗi nghiêm trọng nhất,
  /// dùng cho các tình huống như crash, mất dữ liệu hoặc vi phạm bảo mật.
  void _logCritical() {
    _logCount++;
    _talker.critical('🔴 [CRITICAL #$_logCount] Houston, we have a problem!');
  }

  /// [_logGood] ghi nhận thành công — màu xanh lá, dùng sau khi hoàn thành tác vụ quan trọng.
  void _logGood() {
    _logCount++;
    // _talker.good('✅ [GOOD #$_logCount] Thanh toán hoàn tất thành công!');
  }

  /// [_handleException] mô phỏng việc bắt một Exception và ghi log đầy đủ
  /// bao gồm message, stack trace — cực kỳ quan trọng cho việc debug production crash.
  void _handleException() {
    _logCount++;
    try {
      /// Mô phỏng một ngoại lệ xảy ra trong quá trình xử lý nghiệp vụ.
      throw Exception('Lỗi API: Timeout sau 30 giây chờ đợi');
    } catch (e, st) {
      /// talker.handle() tự động phân tích Exception và Error, ghi log đẹp.
      /// Tham số thứ 3 là message bổ sung để giải thích context của lỗi.
      _talker.handle(
          e, st, '📡 [EXCEPTION #$_logCount] Exception trong NetworkService');
    }
  }

  /// [_logCustom] sử dụng TalkerLog tuỳ chỉnh để ghi log với màu sắc và title riêng.
  /// Thích hợp khi team muốn phân loại log theo domain (API, UI, Business logic).
  void _logCustom() {
    _logCount++;
    final customLog = TalkerLog(
      '🎨 [CUSTOM #$_logCount] Log tuỳ chỉnh với title và màu riêng',
      title: 'BUSINESS',
      logLevel: LogLevel.verbose,
    );
    _talker.logTyped(customLog);
  }

  /// [_clearLogs] xoá toàn bộ log history khỏi bộ nhớ.
  /// Hữu ích khi muốn bắt đầu một session theo dõi mới.
  void _clearLogs() {
    _talker.cleanHistory();
    _logCount = 0;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ Đã xoá toàn bộ log history'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// [_openTalkerScreen] mở màn hình xem log ngay trên thiết bị — không cần cắm máy.
  /// Đây là killer feature của talker_flutter: QA và dev có thể xem log real-time
  /// trực tiếp trên iPhone/Android trong các buổi testing.
  void _openTalkerScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TalkerScreen(
          talker: _talker,

          /// [theme] tuỳ chỉnh giao diện của TalkerScreen cho phù hợp với app theme.
          theme: TalkerScreenTheme(
            backgroundColor: Color(0xFF1A1A2E),
            textColor: Colors.white,
            cardColor: Color(0xFF16213E),
          ),
          appBarTitle: 'Talker Log Viewer',
        ),
      ),
    );
  }

  /// [_onSendLogNow] thực hiện xuất log hiện tại ra file và gửi ngay lên Google Chat.
  Future<void> _onSendLogNow() async {
    setState(() => _isSendingLog = true);
    try {
      // 1. Lưu log từ RAM ra file
      final file = await LogFileService.exportTalkerHistory(_talker);

      // 2. Gửi file log qua Google Chat
      final success =
          await LogGoogleChat.sendLogFile(file, title: '📤 Manual Log Report');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? '✅ Đã gửi log thành công!' : '❌ Gửi log thất bại'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        _updateLatestLogFileInfo();
      }
    } catch (e) {
      _talker.error('Lỗi khi gửi log thủ công', e);
    } finally {
      if (mounted) setState(() => _isSendingLog = false);
    }
  }

  /// [_toggleScheduler] bật/tắt lịch gửi log hằng ngày.
  Future<void> _toggleScheduler() async {
    if (_isSchedulerEnabled) {
      await DailyLogScheduler.cancelAll();
    } else {
      await DailyLogScheduler.initialize();
    }
    await _checkSchedulerStatus();
  }

  /// [_onShareLogFile] mở share dialog để gửi file log qua ứng dụng khác.
  Future<void> _onShareLogFile() async {
    final file = await LogFileService.getLatestLogFile();
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)], text: 'Talker Logs');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Không tìm thấy file log nào để chia sẻ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: Text('Talker 5.1.14 Example'),
        actions: [
          /// Nút xem log trực tiếp ngay trên AppBar — tiện lợi nhất khi testing.
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: 'Xem Talker Logs',
            onPressed: _openTalkerScreen,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Phần header giải thích mục đích của màn hình demo.
            _buildSectionHeader(
              icon: Icons.info_outline,
              title: 'Talker Flutter Logger',
              subtitle:
                  'Log đã ghi: $_logCount lần. Nhấn "View Logs" để xem chi tiết.',
              color: Colors.blue,
            ),
            SizedBox(height: 16),

            /// Nhóm nút ghi log theo từng mức độ (log level).
            _buildSectionHeader(
              icon: Icons.layers,
              title: 'Các mức độ Log (Log Levels)',
              subtitle: 'Mỗi mức có màu và ký hiệu riêng trong TalkerScreen.',
              color: Colors.purple,
            ),
            SizedBox(height: 8),
            _buildLogButton(
              label: '🔍 Debug Log',
              description: 'Thông tin nội bộ dev. Ẩn trên production.',
              color: Colors.grey,
              onPressed: _logDebug,
            ),
            _buildLogButton(
              label: 'ℹ️ Info Log',
              description: 'Sự kiện bình thường: user action, API success.',
              color: Colors.blue,
              onPressed: _logInfo,
            ),
            _buildLogButton(
              label: '⚠️ Warning Log',
              description: 'Không phải lỗi nhưng cần chú ý theo dõi.',
              color: Colors.orange,
              onPressed: _logWarning,
            ),
            _buildLogButton(
              label: '❌ Error Log',
              description: 'Lỗi nhưng app vẫn tiếp tục chạy được.',
              color: Colors.red,
              onPressed: _logError,
            ),
            _buildLogButton(
              label: '🔴 Critical Log',
              description: 'Lỗi nghiêm trọng nhất: crash, mất data, bảo mật.',
              color: Colors.red.shade900,
              onPressed: _logCritical,
            ),
            _buildLogButton(
              label: '✅ Good Log',
              description: 'Thành công: thanh toán OK, upload xong, v.v.',
              color: Colors.green,
              onPressed: _logGood,
            ),
            SizedBox(height: 16),

            /// Nhóm tính năng nâng cao.
            _buildSectionHeader(
              icon: Icons.star,
              title: 'Tính năng nâng cao',
              subtitle: 'Exception handling, custom log, và quản lý history.',
              color: Colors.amber,
            ),
            SizedBox(height: 8),
            _buildLogButton(
              label: '💥 Handle Exception',
              description: 'Bắt Exception và ghi log với stack trace đầy đủ.',
              color: Colors.deepOrange,
              onPressed: _handleException,
            ),
            _buildLogButton(
              label: '🎨 Custom TalkerLog',
              description: 'Log tuỳ chỉnh với title, màu sắc theo domain.',
              color: Colors.teal,
              onPressed: _logCustom,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  /// Nút mở TalkerScreen — xem toàn bộ log history trực quan.
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.terminal),
                    label: Text('📋 View Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _openTalkerScreen,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  /// Nút xoá history — reset để bắt đầu session test mới.
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline),
                    label: Text('🗑️ Clear Logs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _clearLogs,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            /// Card hướng dẫn nhanh cách đọc TalkerScreen.
            _buildTipsCard(),
            SizedBox(height: 16),

            /// MỚI: Nhóm quản lý Log File và Scheduler.
            _buildSectionHeader(
              icon: Icons.mark_as_unread,
              title: '📬 Quản lý Log File & Daily Report',
              subtitle: 'Tự động gửi log lên Google Chat hằng ngày.',
              color: Colors.blueGrey,
            ),
            SizedBox(height: 12),
            _buildLogManagementCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị bảng điều khiển log file và scheduler.
  Widget _buildLogManagementCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _isSchedulerEnabled
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  child: Icon(
                    _isSchedulerEnabled
                        ? Icons.schedule
                        : Icons.schedule_send_outlined,
                    color: _isSchedulerEnabled ? Colors.green : Colors.grey,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gửi log hằng ngày',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _isSchedulerEnabled
                            ? 'Trạng thái: Đang hoạt động'
                            : 'Trạng thái: Đã tắt',
                        style: TextStyle(
                            fontSize: 12,
                            color: _isSchedulerEnabled
                                ? Colors.green
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isSchedulerEnabled,
                  onChanged: (_) => _toggleScheduler(),
                  activeColor: Colors.green,
                ),
              ],
            ),
            Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: _isSendingLog
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(Icons.send_rounded),
                    label: 'Gửi ngay',
                    color: Colors.blue,
                    onPressed: _isSendingLog ? null : _onSendLogNow,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icon(Icons.share_outlined),
                    label: 'Chia sẻ file',
                    color: Colors.indigo,
                    onPressed: _onShareLogFile,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_outlined,
                      size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File mới nhất: $_latestLogFileName',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  /// Widget helper tạo header cho mỗi nhóm chức năng.
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper tạo nút bấm ghi log với mô tả rõ ràng.
  Widget _buildLogButton({
    required String label,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10),
            color: color.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  /// Card hiển thị tips nhanh giúp người dùng mới hiểu cách dùng TalkerScreen.
  Widget _buildTipsCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  '💡 Cách dùng TalkerScreen',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildTip('🔍', 'Filter: lọc log theo level (debug, error, v.v.)'),
            _buildTip('🔎', 'Search: tìm kiếm log theo nội dung'),
            _buildTip('📤', 'Share: xuất file log để gửi cho team phân tích'),
            _buildTip('🗑️', 'Clear: xoá history để bắt đầu session mới'),
            _buildTip('📋', 'Tap vào từng log để xem stack trace đầy đủ'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
