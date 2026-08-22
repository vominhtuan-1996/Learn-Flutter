import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/core/services/keyboard/keyboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyboardService Queue Integration Tests', () {
    late KeyboardService service;

    setUp(() {
      service = KeyboardService.instance;
    });

    test('Should enqueue transition task and run queued actions sequentially', () async {
      bool actionExecuted = false;
      DateTime? actionTime;
      final transitionStartTime = DateTime.now();

      // Enqueue action that should only run after keyboard settles
      unawaited(service.runAfterKeyboardTransition(() async {
        actionExecuted = true;
        actionTime = DateTime.now();
      }, taskName: 'Test action after transition'));

      // Simulate metrics changing (keyboard sliding up)
      service.updateFromInsetsForTesting(100.0);
      service.updateFromInsetsForTesting(200.0);
      service.updateFromInsetsForTesting(300.0);

      // Verify that the action has NOT executed yet (keyboard still transitioning)
      expect(actionExecuted, isFalse);

      // Wait for the settle timer (120ms) to fire
      await Future.delayed(const Duration(milliseconds: 180));

      // Verify that the action has now executed
      expect(actionExecuted, isTrue);
      expect(actionTime, isNotNull);

      final elapsed = actionTime!.difference(transitionStartTime);
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(120));
    });

    test('Transition task should auto-complete on timeout (500ms)', () async {
      bool actionExecuted = false;

      unawaited(service.runAfterKeyboardTransition(() async {
        actionExecuted = true;
      }, taskName: 'Timeout Action'));

      // Trigger transition
      service.updateFromInsetsForTesting(150.0);

      // Repeatedly trigger inset updates to reset the settle timer (preventing normal completion)
      for (int i = 0; i < 9; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        service.updateFromInsetsForTesting(150.0 + i);
      }

      // Total delay is 450ms, and settle timer (120ms) is still reset.
      // Wait another 150ms to exceed the 500ms timeout of the first transition task.
      await Future.delayed(const Duration(milliseconds: 150));

      // The action should have executed via the timeout safeguard!
      expect(actionExecuted, isTrue);
    });

    test('keyboardVisible and keyboardHeight should settle correctly', () async {
      service.updateFromInsetsForTesting(0.0);
      await Future.delayed(const Duration(milliseconds: 150));
      expect(service.keyboardVisible.value, isFalse);
      expect(service.keyboardHeight.value, 0.0);

      service.updateFromInsetsForTesting(320.0);
      await Future.delayed(const Duration(milliseconds: 150));
      expect(service.keyboardVisible.value, isTrue);
      expect(service.keyboardHeight.value, 320.0);
    });
  });
}
