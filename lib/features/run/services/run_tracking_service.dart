import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Fake route around Chatuchak area, Bangkok (~3.5 km loop)
const _fakeRoute = [
  LatLng(13.7563, 100.5018),
  LatLng(13.7570, 100.5025),
  LatLng(13.7578, 100.5033),
  LatLng(13.7585, 100.5042),
  LatLng(13.7591, 100.5053),
  LatLng(13.7596, 100.5065),
  LatLng(13.7599, 100.5078),
  LatLng(13.7600, 100.5091),
  LatLng(13.7598, 100.5104),
  LatLng(13.7594, 100.5116),
  LatLng(13.7588, 100.5127),
  LatLng(13.7580, 100.5136),
  LatLng(13.7571, 100.5142),
  LatLng(13.7561, 100.5145),
  LatLng(13.7550, 100.5144),
  LatLng(13.7540, 100.5140),
  LatLng(13.7531, 100.5133),
  LatLng(13.7524, 100.5123),
  LatLng(13.7519, 100.5112),
  LatLng(13.7517, 100.5100),
  LatLng(13.7518, 100.5087),
  LatLng(13.7521, 100.5075),
  LatLng(13.7527, 100.5064),
  LatLng(13.7534, 100.5054),
  LatLng(13.7542, 100.5046),
  LatLng(13.7550, 100.5039),
  LatLng(13.7556, 100.5030),
  LatLng(13.7560, 100.5022),
  LatLng(13.7563, 100.5018),
];

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
        if (index >= _fakeRoute.length) {
          timer.cancel();
          _isSimulating = false;
          onUpdate();
          return;
        }

        final point = _fakeRoute[index];

        if (index > 0) {
          final prev = _fakeRoute[index - 1];
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
