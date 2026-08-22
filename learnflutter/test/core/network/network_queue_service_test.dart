import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/core/engines/engine_queue/models/queue_config.dart';
import 'package:learnflutter/core/network/queue/network_queue_service.dart';

void main() {
  group('NetworkQueueService Tests', () {
    late NetworkQueueService queueService;

    setUp(() {
      queueService = NetworkQueueService.instance;
      // Khởi tạo queue với config test
      queueService.init(
        config: const QueueConfig(
          concurrency: 2,
          exponentialBackoff: true,
        ),
      );
    });

    tearDown(() {
      queueService.dispose();
    });

    test('Singleton is initialized correctly', () {
      expect(queueService.isInitialized, true);
      expect(queueService.tasks.length, 0);
      expect(queueService.isPaused, false);
    });

    test('Pause and Resume queue', () {
      queueService.pause();
      expect(queueService.isPaused, true);

      queueService.resume();
      expect(queueService.isPaused, false);
    });

    test('Clear queue', () {
      queueService.clear();
      expect(queueService.tasks.length, 0);
    });
  });
}
