import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/run_tracking_service.dart';
import '../../../shared/widgets/run_stat_chip.dart';
import '../../../shared/utils/run_formatters.dart';
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
  String _avatarUrl = '';
  BitmapDescriptor? _avatarMarker;

  static const _initialPosition = LatLng(16.4419, 102.8360); // KKU, Khon Kaen

  static const _anon =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

  @override
  void initState() {
    super.initState();
    _moveToUserLocation();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final url = (doc.data()?['avatarUrl'] as String?) ?? '';
    if (mounted) setState(() => _avatarUrl = url);
    final marker = await _buildAvatarMarker(url.isNotEmpty ? url : _anon);
    if (mounted) setState(() => _avatarMarker = marker);
  }

  Future<BitmapDescriptor> _buildAvatarMarker(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: 56,
        targetHeight: 56,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final size = 56.0;
      final border = 3.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      // Green border circle
      paint.color = Colors.green;
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Clip to inner circle and draw avatar
      final path = Path()
        ..addOval(Rect.fromCircle(
            center: Offset(size / 2, size / 2), radius: size / 2 - border));
      canvas.clipPath(path);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(border, border, size - border * 2, size - border * 2),
        image: image,
        fit: BoxFit.cover,
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<void> _moveToUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      final controller = await _mapCompleter.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
      );
    } catch (_) {}
  }

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

    // Fit camera to full route (start → end) then snapshot
    final snapshotFuture = _mapCompleter.future.then((controller) async {
      final points = _service.routePoints;
      if (points.length >= 2) {
        double minLat = points.first.latitude;
        double maxLat = points.first.latitude;
        double minLng = points.first.longitude;
        double maxLng = points.first.longitude;
        for (final p in points) {
          if (p.latitude < minLat) minLat = p.latitude;
          if (p.latitude > maxLat) maxLat = p.latitude;
          if (p.longitude < minLng) minLng = p.longitude;
          if (p.longitude > maxLng) maxLng = p.longitude;
        }
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            80,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
      }
      return controller.takeSnapshot();
    }).catchError((_) => null);

    final imageUrlFuture = snapshotFuture.then((snapshot) async {
      if (snapshot == null || snapshot.isEmpty) return '';
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
        duration: formatDuration(_service.elapsed),
        pace: '${formatPace(_service.paceMinPerKm)} /km',
        snapshotFuture: snapshotFuture,
        imageUrlFuture: imageUrlFuture,
      ),
    );
  }

  Set<Polyline> get _polylines {
    if (_service.routePoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _service.routePoints.toList(),
        color: Theme.of(context).colorScheme.primary,
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
        icon: _avatarMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Track Run',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
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
            color: Theme.of(context).colorScheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                if (_permissionDenied)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Location permission denied. Please enable it in settings.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RunStatChip(
                      label: 'Distance',
                      value: '${_service.distanceKm.toStringAsFixed(2)} km',
                    ),
                    RunStatChip(
                      label: 'Time',
                      value: formatDuration(_service.elapsed),
                    ),
                    RunStatChip(
                      label: 'Pace',
                      value: '${formatPace(_service.paceMinPerKm)} /km',
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _startSimulation,
                      child: const Text(
                        'START RUN',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  // STOP RUN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
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
