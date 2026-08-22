import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/core/engines/engine_queue/engine_queue.dart';

void main() {
  group('QueueEngine Unit Tests', () {
    late InMemoryQueueEngine queue;

    tearDown(() {
      queue.dispose();
    });

    test('TC-01: Sequential Task Execution (concurrency = 1)', () async {
      queue = InMemoryQueueEngine(config: const QueueConfig(concurrency: 1));
      final List<String> executionOrder = [];

      final task1 = CallbackQueueTask(
        id: '1',
        name: 'Task 1',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          executionOrder.add('1');
        },
      );

      final task2 = CallbackQueueTask(
        id: '2',
        name: 'Task 2',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          executionOrder.add('2');
        },
      );

      final task3 = CallbackQueueTask(
        id: '3',
        name: 'Task 3',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          executionOrder.add('3');
        },
      );

      queue.enqueueAll([task1, task2, task3]);

      // Chờ cho các tác vụ chạy xong
      await Future.delayed(const Duration(milliseconds: 200));

      expect(executionOrder, equals(['1', '2', '3']));
      expect(queue.tasks.length, equals(3));
      expect(queue.tasks[0].status, equals(QueueTaskStatus.completed));
      expect(queue.tasks[1].status, equals(QueueTaskStatus.completed));
      expect(queue.tasks[2].status, equals(QueueTaskStatus.completed));
    });

    test('TC-02: Concurrent Task Execution (concurrency = 2)', () async {
      queue = InMemoryQueueEngine(config: const QueueConfig(concurrency: 2));
      final List<String> executingAtStart = [];

      final task1 = CallbackQueueTask(
        id: '1',
        name: 'Task 1',
        maxRetries: 0,
        callback: () async {
          executingAtStart.add('1');
          await Future.delayed(const Duration(milliseconds: 80));
        },
      );

      final task2 = CallbackQueueTask(
        id: '2',
        name: 'Task 2',
        maxRetries: 0,
        callback: () async {
          executingAtStart.add('2');
          await Future.delayed(const Duration(milliseconds: 80));
        },
      );

      final task3 = CallbackQueueTask(
        id: '3',
        name: 'Task 3',
        maxRetries: 0,
        callback: () async {
          executingAtStart.add('3');
          await Future.delayed(const Duration(milliseconds: 80));
        },
      );

      queue.enqueueAll([task1, task2, task3]);

      // Sau 20ms, task 1 và task 2 phải đang chạy, task 3 phải pending
      await Future.delayed(const Duration(milliseconds: 20));
      expect(executingAtStart.contains('1'), isTrue);
      expect(executingAtStart.contains('2'), isTrue);
      expect(executingAtStart.contains('3'), isFalse);

      // Chờ hoàn tất tất cả
      await Future.delayed(const Duration(milliseconds: 200));
      expect(executingAtStart.contains('3'), isTrue);
      expect(queue.tasks.every((t) => t.status == QueueTaskStatus.completed), isTrue);
    });

    test('TC-03: Auto Retry Policy on Failure (maxRetries = 2)', () async {
      queue = InMemoryQueueEngine(
        config: const QueueConfig(
          concurrency: 1,
          exponentialBackoff: false,
        ),
      );

      int attempts = 0;
      final task = CallbackQueueTask(
        id: 'retry_task',
        name: 'Retry Task',
        maxRetries: 2,
        retryDelay: const Duration(milliseconds: 20),
        callback: () async {
          attempts++;
          throw Exception('Lỗi giả lập');
        },
      );

      queue.enqueue(task);

      // Chờ hoàn tất mọi lần thử lại (1 lần đầu + 2 lần retry = 3 lần thử)
      // Tổng delay: 20ms * 2 = 40ms. Chờ hẳn 120ms để chạy xong.
      await Future.delayed(const Duration(milliseconds: 120));

      expect(attempts, equals(3));
      expect(queue.tasks[0].retries, equals(2));
      expect(queue.tasks[0].status, equals(QueueTaskStatus.failed));
      expect(queue.tasks[0].error, contains('Lỗi giả lập'));
    });

    test('TC-04: Exponential Backoff Timing', () async {
      queue = InMemoryQueueEngine(
        config: const QueueConfig(
          concurrency: 1,
          exponentialBackoff: true, // Bật exponential backoff
        ),
      );

      final List<DateTime> retryTimestamps = [];
      final task = CallbackQueueTask(
        id: 'backoff_task',
        name: 'Backoff Task',
        maxRetries: 2,
        retryDelay: const Duration(milliseconds: 30),
        callback: () async {
          retryTimestamps.add(DateTime.now());
          throw Exception('Lỗi Backoff');
        },
      );

      queue.enqueue(task);

      // Lần đầu chạy ngay lập tức.
      // Lần retry 1: delay = 30ms.
      // Lần retry 2: delay = 30 * 2^1 = 60ms.
      // Tổng delay = ~90ms. Chờ hẳn 200ms để chạy hết.
      await Future.delayed(const Duration(milliseconds: 200));

      expect(retryTimestamps.length, equals(3));
      
      final delay1 = retryTimestamps[1].difference(retryTimestamps[0]).inMilliseconds;
      final delay2 = retryTimestamps[2].difference(retryTimestamps[1]).inMilliseconds;

      // Cho phép sai số delta nhỏ (do event loop scheduling)
      expect(delay1, greaterThanOrEqualTo(25));
      expect(delay2, greaterThanOrEqualTo(55));
      expect(delay2, greaterThan(delay1)); // Lần 2 phải chờ lâu hơn lần 1
    });

    test('TC-05: Queue Control (Pause & Resume)', () async {
      queue = InMemoryQueueEngine(config: const QueueConfig(concurrency: 1));
      final List<String> completedTasks = [];

      final task1 = CallbackQueueTask(
        id: '1',
        name: 'Task 1',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          completedTasks.add('1');
        },
      );

      final task2 = CallbackQueueTask(
        id: '2',
        name: 'Task 2',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          completedTasks.add('2');
        },
      );

      queue.enqueue(task1);
      queue.enqueue(task2);

      // Khi Task 1 đang chạy, gọi tạm dừng hàng đợi
      await Future.delayed(const Duration(milliseconds: 10));
      queue.pause();
      expect(queue.isPaused, isTrue);

      // Chờ Task 1 chạy xong. Task 2 không được khởi động vì hàng đợi bị tạm dừng.
      await Future.delayed(const Duration(milliseconds: 80));
      expect(completedTasks, equals(['1']));
      expect(queue.tasks[1].status, equals(QueueTaskStatus.pending));

      // Resume hàng đợi, Task 2 phải được thực thi tiếp
      queue.resume();
      expect(queue.isPaused, isFalse);

      await Future.delayed(const Duration(milliseconds: 40));
      expect(completedTasks, equals(['1', '2']));
      expect(queue.tasks[1].status, equals(QueueTaskStatus.completed));
    });

    test('TC-06: Task Cancellation (Pending task)', () async {
      queue = InMemoryQueueEngine(config: const QueueConfig(concurrency: 1));
      final List<String> executed = [];

      final task1 = CallbackQueueTask(
        id: '1',
        name: 'Task 1',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          executed.add('1');
        },
      );

      final task2 = CallbackQueueTask(
        id: '2',
        name: 'Task 2',
        maxRetries: 0,
        callback: () async {
          executed.add('2');
        },
      );

      queue.enqueue(task1);
      queue.enqueue(task2);

      // Gọi huỷ Task 2 khi Task 1 đang chạy
      queue.cancel('2');
      expect(queue.tasks[1].status, equals(QueueTaskStatus.cancelled));

      // Đợi Task 1 hoàn tất
      await Future.delayed(const Duration(milliseconds: 80));
      
      expect(executed, equals(['1'])); // Task 2 không bao giờ được chạy
      expect(queue.tasks[1].status, equals(QueueTaskStatus.cancelled));
    });
  group('QueueEngine Stream Tests', () {
    test('Stream emits updates', () async {
      queue = InMemoryQueueEngine(config: const QueueConfig(concurrency: 1));
      final List<List<QueueTask>> streamEvents = [];

      final subscription = queue.tasksStream.listen((event) {
        streamEvents.add(event);
      });

      final task = CallbackQueueTask(
        id: 'stream_test',
        name: 'Stream Test',
        maxRetries: 0,
        callback: () async {
          await Future.delayed(const Duration(milliseconds: 10));
        },
      );

      queue.enqueue(task);

      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      // Stream ít nhất phải phát đi 3 sự kiện:
      // 1. Khi add (status = pending)
      // 2. Khi chạy (status = executing)
      // 3. Khi xong (status = completed)
      expect(streamEvents.length, greaterThanOrEqualTo(3));
      expect(streamEvents.first.first.status, equals(QueueTaskStatus.pending));
      expect(streamEvents.last.first.status, equals(QueueTaskStatus.completed));
    });
  });
  });
}
