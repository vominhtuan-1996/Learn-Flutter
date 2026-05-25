import 'package:flutter/material.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/shared/components/base_loading_draggable/base_draggable_loading.dart';

/// Demo trực quan `BaseDraggableLoading`:
/// - Scaffold body có nội dung mô tả.
/// - FAB draggable (kéo thả tự do, có vùng xoá ở mép dưới).
/// - 3 nút trigger overlay loading với message khác nhau.
/// - Toggle `autoAlign` / `hasDeletedWidget` để xem khác biệt khi rebuild.
class DraggableExampleScreen extends StatefulWidget {
  const DraggableExampleScreen({super.key});

  @override
  State<DraggableExampleScreen> createState() => _DraggableExampleScreenState();
}

class _DraggableExampleScreenState extends State<DraggableExampleScreen> {
  bool _autoAlign = false;
  bool _hasDelete = true;
  bool _isDragging = false;
  Offset _lastPos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return BaseDraggableLoading(
      floatSize: const Size(64, 64),
      autoAlign: _autoAlign,
      hasDeletedWidget: _hasDelete,
      backgroundColor: Colors.grey.shade100,
      onDragging: (v) => setState(() => _isDragging = v),
      onDragEvent: (dx, dy) => setState(() => _lastPos = Offset(dx, dy)),
      onDeleteWidget: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã xoá FAB'))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isDragging ? Colors.orange : Colors.indigo,
        onPressed: () => showLoading(
          context: context,
          message: 'Đang tải dữ liệu...',
        ),
        child: Icon(_isDragging ? Icons.open_with : Icons.cloud_download),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'BaseDraggableLoading Demo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Kéo nút floating đi khắp màn hình.\n'
              '• Kéo xuống vùng xoá ở mép dưới để gọi onDeleteWidget.\n'
              '• Tap FAB hoặc các nút bên dưới để show overlay loading.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dragging: $_isDragging'),
                    Text('Last position: '
                        '(${_lastPos.dx.toStringAsFixed(1)}, ${_lastPos.dy.toStringAsFixed(1)})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto align về mép'),
              value: _autoAlign,
              onChanged: (v) => setState(() => _autoAlign = v),
            ),
            SwitchListTile(
              title: const Text('Hiện delete widget (vùng xoá)'),
              value: _hasDelete,
              onChanged: (v) => setState(() => _hasDelete = v),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      showLoading(context: context, message: 'Đang đồng bộ...'),
                  child: const Text('Loading: ngắn'),
                ),
                FilledButton.tonal(
                  onPressed: () => showLoading(
                    context: context,
                    message:
                        'Đang tải dữ liệu cấu hình từ máy chủ, vui lòng chờ trong giây lát...',
                  ),
                  child: const Text('Loading: dài'),
                ),
                OutlinedButton(
                  onPressed: () => showLoading(context: context, message: ''),
                  child: const Text('Loading: no text'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Sample content area',
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
