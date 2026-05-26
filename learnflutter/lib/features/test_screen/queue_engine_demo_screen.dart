import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learnflutter/core/engines/engine_queue/engine_queue.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';

class QueueEngineDemoScreen extends StatefulWidget {
  const QueueEngineDemoScreen({super.key});

  @override
  State<QueueEngineDemoScreen> createState() => _QueueEngineDemoScreenState();
}

class _QueueEngineDemoScreenState extends State<QueueEngineDemoScreen> {
  late final InMemoryQueueEngine _queueEngine;
  int _concurrency = 1;
  bool _exponentialBackoff = true;
  int _taskCounter = 0;

  // Bản đồ theo dõi số lần chạy thử của các Flaky Tasks (mô phỏng)
  final Map<String, int> _flakyAttempts = {};

  @override
  void initState() {
    super.initState();
    _queueEngine = InMemoryQueueEngine(
      config: QueueConfig(
        concurrency: _concurrency,
        exponentialBackoff: _exponentialBackoff,
        defaultRetryDelay: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _queueEngine.dispose();
    super.dispose();
  }

  /// Thêm một task thông thường: chạy thành công sau 2.5s
  void _addStandardTask() {
    _taskCounter++;
    final id = 'task_std_$_taskCounter';
    final name = 'Tác vụ #${_taskCounter.toString().padLeft(3, '0')} (Tải dữ liệu)';

    _queueEngine.enqueue(
      CallbackQueueTask(
        id: id,
        name: name,
        maxRetries: 1,
        retryDelay: const Duration(seconds: 2),
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 2500));
        },
      ),
    );
  }

  /// Thêm một flaky task: lỗi 2 lần đầu (retry), đến lần thứ 3 mới thành công
  void _addFlakyTask() {
    _taskCounter++;
    final id = 'task_flaky_$_taskCounter';
    final name = 'Tác vụ #${_taskCounter.toString().padLeft(3, '0')} (Flaky API)';
    _flakyAttempts[id] = 0;

    _queueEngine.enqueue(
      CallbackQueueTask(
        id: id,
        name: name,
        maxRetries: 3,
        retryDelay: const Duration(seconds: 2),
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 1500));
          final attempts = (_flakyAttempts[id] ?? 0) + 1;
          _flakyAttempts[id] = attempts;

          if (attempts < 3) {
            throw Exception('Lỗi kết nối máy chủ (Thử lần $attempts/3)');
          }
        },
      ),
    );
  }

  /// Thêm một task lỗi hoàn toàn: thử lại 3 lần và thất bại
  void _addFailingTask() {
    _taskCounter++;
    final id = 'task_fail_$_taskCounter';
    final name = 'Tác vụ #${_taskCounter.toString().padLeft(3, '0')} (Lỗi hệ thống)';

    _queueEngine.enqueue(
      CallbackQueueTask(
        id: id,
        name: name,
        maxRetries: 2,
        retryDelay: const Duration(seconds: 1),
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 1500));
          throw Exception('Lỗi phân tích cú pháp tệp tin (Fatal Error)');
        },
      ),
    );
  }

  /// Cập nhật cấu hình động của hàng đợi
  void _updateEngineConfig() {
    _queueEngine.updateConfig(
      QueueConfig(
        concurrency: _concurrency,
        exponentialBackoff: _exponentialBackoff,
        defaultRetryDelay: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Space
      appBar: AppBar(
        title: const Text(
          'Queue Engine Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<QueueTask>>(
        stream: _queueEngine.tasksStream,
        initialData: const [],
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];

          // Tính toán các chỉ số thống kê
          final pendingCount = tasks.where((t) => t.status == QueueTaskStatus.pending).length;
          final executingCount = tasks.where((t) => t.status == QueueTaskStatus.executing).length;
          final completedCount = tasks.where((t) => t.status == QueueTaskStatus.completed).length;
          final failedCount = tasks.where((t) => t.status == QueueTaskStatus.failed).length;
          final cancelledCount = tasks.where((t) => t.status == QueueTaskStatus.cancelled).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Panel Cấu hình & Trạng thái Hàng đợi
              _buildConfigPanel(theme, executingCount),

              // 2. Panel Thống kê
              _buildStatPanel(
                pending: pendingCount,
                executing: executingCount,
                completed: completedCount,
                failed: failedCount,
                cancelled: cancelledCount,
              ),

              // Tiêu đề danh sách
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DANH SÁCH TÁC VỤ (${tasks.length})',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (tasks.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _queueEngine.clear();
                          _flakyAttempts.clear();
                          setState(() {
                            _taskCounter = 0;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF43F5E),
                        ),
                        child: const Text('Xoá sạch lịch sử'),
                      )
                  ],
                ),
              ),

              // 3. Danh sách các Task động
              Expanded(
                child: tasks.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          // Đảo thứ tự hiển thị để task mới nhất lên đầu
                          final task = tasks[tasks.length - 1 - index];
                          return _buildTaskCard(task, theme);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigPanel(ThemeData theme, int executingCount) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số tác vụ chạy song song tối đa (Concurrency)',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 2, 3, 5].map((val) {
                          final isSelected = _concurrency == val;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text('$val Task'),
                              selected: isSelected,
                              selectedColor: const Color(0xFF3B82F6),
                              backgroundColor: const Color(0xFF334155),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _concurrency = val;
                                  });
                                  _updateEngineConfig();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text(
                    'Exp Backoff',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Switch(
                    value: _exponentialBackoff,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        _exponentialBackoff = val;
                      });
                      _updateEngineConfig();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addStandardTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Standard Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addFlakyTask,
                  icon: const Icon(Icons.cloud_sync),
                  label: const Text('Flaky Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addFailingTask,
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Failing Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Trạng thái: ',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _queueEngine.isPaused ? const Color(0xFFEF4444).withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _queueEngine.isPaused ? 'ĐANG TẠM DỪNG' : 'ĐANG HOẠT ĐỘNG',
                      style: TextStyle(
                        color: _queueEngine.isPaused ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        if (_queueEngine.isPaused) {
                          _queueEngine.resume();
                        } else {
                          _queueEngine.pause();
                        }
                      });
                    },
                    icon: Icon(_queueEngine.isPaused ? Icons.play_arrow : Icons.pause),
                    style: IconButton.styleFrom(
                      backgroundColor: _queueEngine.isPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPanel({
    required int pending,
    required int executing,
    required int completed,
    required int failed,
    required int cancelled,
  }) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Pending', pending, const Color(0xFF94A3B8)),
          _buildStatItem('Running', executing, const Color(0xFF3B82F6), hasLoading: executing > 0),
          _buildStatItem('Success', completed, const Color(0xFF10B981)),
          _buildStatItem('Failed', failed, const Color(0xFFEF4444)),
          _buildStatItem('Cancelled', cancelled, const Color(0xFFF97316)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, {bool hasLoading = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLoading)
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              ),
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add,
            size: 64,
            color: const Color(0xFF334155),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hàng đợi trống',
            style: TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy bấm một nút phía trên để thêm tác vụ mẫu',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTaskCard(QueueTask task, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    Widget trailingWidget = const SizedBox.shrink();

    switch (task.status) {
      case QueueTaskStatus.pending:
        statusColor = const Color(0xFF94A3B8);
        statusIcon = Icons.hourglass_empty;
        trailingWidget = IconButton(
          icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444)),
          onPressed: () => _queueEngine.cancel(task.id),
          tooltip: 'Huỷ tác vụ',
        );
        break;
      case QueueTaskStatus.executing:
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.sync;
        trailingWidget = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3B82F6)),
        );
        break;
      case QueueTaskStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_outline;
        break;
      case QueueTaskStatus.failed:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_outline;
        break;
      case QueueTaskStatus.paused:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pause_circle_outline;
        break;
      case QueueTaskStatus.cancelled:
        statusColor = const Color(0xFFF97316);
        statusIcon = Icons.block_outlined;
        break;
    }

    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: task.status == QueueTaskStatus.executing ? const Color(0xFF3B82F6).withOpacity(0.5) : const Color(0xFF334155),
          width: task.status == QueueTaskStatus.executing ? 1.5 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                trailingWidget,
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${task.id}',
                  style: const TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'monospace'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            if (task.maxRetries > 0 && (task.status == QueueTaskStatus.pending || task.status == QueueTaskStatus.executing || task.status == QueueTaskStatus.failed)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Số lần thử lại: ',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Text(
                    '${task.retries}/${task.maxRetries}',
                    style: TextStyle(
                      color: task.retries > 0 ? const Color(0xFFF59E0B) : Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Thời gian chờ: ${task.retryDelay.inSeconds}s',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
            if (task.error != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                ),
                child: Text(
                  task.error!,
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 200.ms).fadeIn(duration: 200.ms);
  }
}
