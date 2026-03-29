import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/fake_route.dart';

class RunTrackingService {
  final _routePoints = <LatLng>[];
  StreamSubscription<Position>? _positionSub;
  Timer? _simulationTimer;

  double _distanceMeters = 0;
  DateTime? _startTime;
  Position? _lastPosition;
  bool _isSimulating = false;

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  double get distanceKm => _distanceMeters / 1000;
  bool get isSimulating => _isSimulating;
  Duration get elapsed =>
      _startTime == null ? Duration.zero : DateTime.now().difference(_startTime!);

  double? get paceMinPerKm {
    if (distanceKm < 0.01) return null;
    return elapsed.inSeconds / 60 / distanceKm;
  }

  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> start(VoidCallback onUpdate) async {
    _reset();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      if (_lastPosition != null) {
        _distanceMeters += Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }
      _lastPosition = pos;
      _routePoints.add(LatLng(pos.latitude, pos.longitude));
      onUpdate();
    });
  }

  /// Replay [_fakeRoute] points one by one, one point every [intervalMs] ms.
  void startSimulation(VoidCallback onUpdate, {int intervalMs = 600}) {
    _reset();
    _isSimulating = true;

    int index = 0;
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (timer) {
        if (index >= kFakeRoute.length) {
          timer.cancel();
          _isSimulating = false;
          onUpdate();
          return;
        }

        final point = kFakeRoute[index];

        if (index > 0) {
          final prev = kFakeRoute[index - 1];
          _distanceMeters += Geolocator.distanceBetween(
            prev.latitude,
            prev.longitude,
            point.latitude,
            point.longitude,
          );
        }

        _routePoints.add(point);
        index++;
        onUpdate();
      },
    );
  }

  Future<void> stop() async {
    // Set synchronously before any await so isSimulating is false immediately
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    await _positionSub?.cancel();
    _positionSub = null;
  }

  void _reset() {
    _routePoints.clear();
    _distanceMeters = 0;
    _lastPosition = null;
    _startTime = DateTime.now();
  }
}
