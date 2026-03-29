import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/run_tracking_service.dart';
import 'post_run_sheet.dart';

class RunTrackingScreen extends StatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  State<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends State<RunTrackingScreen> {
  final _service = RunTrackingService();
  final Completer<GoogleMapController> _mapCompleter = Completer();

  bool _isRunning = false;
  bool _permissionDenied = false;
  bool _isStopping = false;
  Timer? _uiTimer;

  static const _initialPosition = LatLng(13.7563, 100.5018);

  @override
  void dispose() {
    _service.stop();
    _uiTimer?.cancel();
    super.dispose();
  }

  void _startUiTimer() {
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _startRun() async {
    final granted = await RunTrackingService.requestPermission();
    if (!granted) {
      setState(() => _permissionDenied = true);
      return;
    }
    setState(() {
      _isRunning = true;
      _permissionDenied = false;
    });
    _startUiTimer();
    await _service.start(_onNewPoint);
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _permissionDenied = false;
    });
    _startUiTimer();
    _service.startSimulation(() {
      _onNewPoint();
      // Auto-stop when simulation finishes
      if (!_service.isSimulating && _isRunning) {
        _stopRun();
      }
    });
  }

  void _onNewPoint() async {
    if (!mounted) return;
    setState(() {});
    if (_service.routePoints.isNotEmpty) {
      final last = _service.routePoints.last;
      final controller = await _mapCompleter.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(last.latitude, last.longitude)),
      );
    }
  }

  Future<void> _stopRun() async {
    await _service.stop();
    _uiTimer?.cancel();

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isStopping = false;
    });

    // Snapshot + upload both run in background after sheet opens
    final snapshotFuture = _mapCompleter.future
        .then((controller) => controller.takeSnapshot())
        .catchError((_) => null);

    final imageUrlFuture = snapshotFuture.then((snapshot) async {
      if (snapshot == null) return '';
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('run_maps/${DateTime.now().millisecondsSinceEpoch}.png');
        await ref.putData(snapshot, SettableMetadata(contentType: 'image/png'));
        return await ref.getDownloadURL();
      } catch (_) {
        return '';
      }
    });

    // Open sheet immediately — no waiting
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostRunSheet(
        distance: '${_service.distanceKm.toStringAsFixed(2)} km',
        duration: _formatDuration(_service.elapsed),
        pace: '${_formatPace(_service.paceMinPerKm)} /km',
        snapshotFuture: snapshotFuture,
        imageUrlFuture: imageUrlFuture,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatPace(double? pace) {
    if (pace == null) return "--'--\"";
    final min = pace.floor();
    final sec = ((pace - min) * 60).round();
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  Set<Polyline> get _polylines {
    if (_service.routePoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _service.routePoints.toList(),
        color: Colors.lime,
        width: 5,
      ),
    };
  }

  Set<Marker> get _markers {
    if (_service.routePoints.isEmpty) return {};
    return {
      Marker(
        markerId: const MarkerId('start'),
        position: _service.routePoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('current'),
        position: _service.routePoints.last,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Track Run',
          style: TextStyle(color: Colors.lime, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.lime),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              onMapCreated: (c) => _mapCompleter.complete(c),
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
            ),
          ),

          // Stats + buttons
          Container(
            color: const Color(0xFF1A1A1A),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                if (_permissionDenied)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Location permission denied. Please enable it in settings.',
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: 'Distance',
                      value:
                          '${_service.distanceKm.toStringAsFixed(2)} km',
                    ),
                    _StatBox(
                      label: 'Time',
                      value: _formatDuration(_service.elapsed),
                    ),
                    _StatBox(
                      label: 'Pace',
                      value:
                          '${_formatPace(_service.paceMinPerKm)} /km',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (!_isRunning) ...[
                  // START RUN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _startRun,
                      child: const Text(
                        'START RUN',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // SIMULATE
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.lime,
                        side: const BorderSide(color: Colors.lime),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _startSimulation,
                      child: const Text('SIMULATE RUN (FAKE GPS)'),
                    ),
                  ),
                ] else ...[
                  // STOP RUN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isStopping ? null : _stopRun,
                      child: _isStopping
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'STOP RUN',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
