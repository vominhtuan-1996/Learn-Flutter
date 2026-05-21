import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/engine_queue/models/queue_task.dart';
import 'package:learnflutter/core/network/queue/network_queue_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learnflutter/core/services/talker/app_talker.dart';

class NetworkQueueDemoScreen extends StatefulWidget {
  const NetworkQueueDemoScreen({super.key});

  @override
  State<NetworkQueueDemoScreen> createState() => _NetworkQueueDemoScreenState();
}

class _NetworkQueueDemoScreenState extends State<NetworkQueueDemoScreen> {
  final NetworkQueueService _queueService = NetworkQueueService.instance;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // Ensure initialized
    if (!_queueService.isInitialized) {
      _queueService.init();
    }
  }

  void _sendFastSuccess() async {
    try {
      await _queueService.get('https://httpbin.org/get');
      AppTalker.instance.info('Fast request success from caller perspective.');
    } catch (e) {
      AppTalker.instance.error('Fast request failed: $e');
    }
  }

  void _sendSlowSuccess() async {
    try {
      await _queueService.get('https://httpbin.org/delay/2');
      AppTalker.instance.info('Slow request success from caller perspective.');
    } catch (e) {
      AppTalker.instance.error('Slow request failed: $e');
    }
  }

  void _sendFailingRequest() async {
    try {
      await _queueService.get('https://httpbin.org/status/500', maxRetries: 2, retryDelay: const Duration(seconds: 1));
      AppTalker.instance.info('Failing request success from caller perspective.');
    } catch (e) {
      AppTalker.instance.error('Failing request failed permanently from caller perspective: $e');
    }
  }

  void _toggleNetwork(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
    if (_isOnline) {
      _queueService.resume();
    } else {
      _queueService.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '🌐 Network Queue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              _queueService.clear();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QueueTask>>(
        stream: _queueService.tasksStream,
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? _queueService.tasks;
          final pending = tasks.where((t) => t.status == QueueTaskStatus.pending).length;
          final executing = tasks.where((t) => t.status == QueueTaskStatus.executing).length;
          final completed = tasks.where((t) => t.status == QueueTaskStatus.completed).length;
          final failed = tasks.where((t) => t.status == QueueTaskStatus.failed).length;

          return Column(
            children: [
              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildStatCard('Pending', pending, const Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    _buildStatCard('Running', executing, const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _buildStatCard('Done', completed, const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _buildStatCard('Failed', failed, const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Network Connection Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isOnline ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _isOnline ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFEF4444).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_isOnline ? Icons.wifi : Icons.wifi_off, color: _isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                          const SizedBox(width: 12),
                          Text(
                            _isOnline ? 'Online (Queue Running)' : 'Offline (Queue Paused)',
                            style: TextStyle(
                              color: _isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOnline,
                        onChanged: _toggleNetwork,
                        activeColor: const Color(0xFF10B981),
                        inactiveThumbColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionBtn(
                            'Fast Success API',
                            Icons.bolt,
                            const Color(0xFF8B5CF6),
                            _sendFastSuccess,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionBtn(
                            'Slow Success API',
                            Icons.hourglass_bottom,
                            const Color(0xFF3B82F6),
                            _sendSlowSuccess,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildActionBtn(
                      'Failing API (Test Retry)',
                      Icons.error_outline,
                      const Color(0xFFF59E0B),
                      _sendFailingRequest,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white12),

              // Task List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No network requests.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          // Display in reverse order (newest first)
                          final task = tasks[tasks.length - 1 - index];
                          return _buildTaskItem(task);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(QueueTask task) {
    Color statusColor;
    IconData statusIcon;
    bool isSpinning = false;

    switch (task.status) {
      case QueueTaskStatus.pending:
        statusColor = const Color(0xFF94A3B8);
        statusIcon = Icons.schedule;
        break;
      case QueueTaskStatus.executing:
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.sync;
        isSpinning = true;
        break;
      case QueueTaskStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case QueueTaskStatus.failed:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error;
        break;
      case QueueTaskStatus.paused:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pause_circle;
        break;
      case QueueTaskStatus.cancelled:
        statusColor = const Color(0xFFF97316);
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: isSpinning
                ? Icon(statusIcon, color: statusColor, size: 24).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds)
                : Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (task.retries > 0)
                  Text(
                    'Retries: ${task.retries}/${task.maxRetries}',
                    style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                  ),
                if (task.error != null)
                  Text(
                    task.error!,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task.status.name.toUpperCase(),
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
