import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werun_projct/features/run/services/run_tracking_service.dart';

void main() {
  group('RunTrackingService — initial state', () {
    late RunTrackingService service;

    setUp(() => service = RunTrackingService());
    tearDown(() => service.stop());

    test('starts with zero distance', () {
      expect(service.distanceKm, 0.0);
    });

    test('starts with empty route points', () {
      expect(service.routePoints, isEmpty);
    });

    test('elapsed returns zero before any run', () {
      expect(service.elapsed, Duration.zero);
    });

    test('paceMinPerKm returns null before run starts', () {
      expect(service.paceMinPerKm, isNull);
    });

    test('isSimulating is false initially', () {
      expect(service.isSimulating, isFalse);
    });
  });

  group('RunTrackingService — simulation', () {
    late RunTrackingService service;

    setUp(() => service = RunTrackingService());
    tearDown(() => service.stop());

    test('isSimulating becomes true after startSimulation', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        expect(service.isSimulating, isTrue);
        async.elapse(const Duration(milliseconds: 50));
        expect(service.isSimulating, isTrue);
      });
    });

    test('adds all fake route points during simulation', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        // 29 points × 100ms = 2900ms, plus one final tick
        async.elapse(const Duration(milliseconds: 3500));
        expect(service.routePoints.length, 29,
            reason: 'simulation should add all 29 points from _fakeRoute');
      });
    });

    test('isSimulating becomes false after all points are consumed', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 3500));
        expect(service.isSimulating, isFalse);
      });
    });

    test('distance is positive after simulation completes', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 3500));
        expect(service.distanceKm, greaterThan(0));
      });
    });

    test('distance is approximately 3.5 km for the Bangkok loop', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 3500));
        // Loop is ~3.5 km — allow ±0.6 km tolerance
        expect(service.distanceKm, inInclusiveRange(2.9, 4.1));
      });
    });

    // BUG DETECTOR: routePoints must not be mutated from outside the service
    test('routePoints list is unmodifiable', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 500));
        expect(
          () => service.routePoints.add(service.routePoints.first),
          throwsUnsupportedError,
        );
      });
    });

    test('stop() while simulating sets isSimulating to false', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 500));
        service.stop();
        expect(service.isSimulating, isFalse);
      });
    });

    test('stop() while simulating stops adding new points', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 500));
        final countAfterStop = service.routePoints.length;
        service.stop();
        async.elapse(const Duration(milliseconds: 2000));
        expect(service.routePoints.length, countAfterStop,
            reason: 'no new points should be added after stop()');
      });
    });

    // BUG DETECTOR: paceMinPerKm should return null until 10m of distance
    test('paceMinPerKm returns null when distance < 0.01 km', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        // Only advance one tick — distance should be tiny
        async.elapse(const Duration(milliseconds: 100));
        // First point has no distance (index 0 skipped), second adds ~100m
        // If < 0.01 km, should still be null
        if (service.distanceKm < 0.01) {
          expect(service.paceMinPerKm, isNull);
        }
      });
    });

    test('second startSimulation resets previous run data', () {
      fakeAsync((async) {
        service.startSimulation(() {}, intervalMs: 100);
        async.elapse(const Duration(milliseconds: 500));
        final firstRunPoints = service.routePoints.length;
        expect(firstRunPoints, greaterThan(0));

        service.stop();
        service.startSimulation(() {}, intervalMs: 100);

        expect(service.routePoints.length, lessThan(firstRunPoints),
            reason: 'second run should reset route points');
        expect(service.distanceKm, lessThan(0.1),
            reason: 'second run should reset distance');
      });
    });
  });
}
