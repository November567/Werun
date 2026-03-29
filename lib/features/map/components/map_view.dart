import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'runner_profile_sheet.dart';
import 'map_marker_helper.dart';
import '../../../core/constants/fake_route.dart';

// Fake runners: name, starting offset, and ticksPerStep (higher = slower)
// ticksPerStep=1 → moves every tick; ticksPerStep=3 → moves every 3rd tick
const _fakeRunners = [
  {'id': 'runner_1', 'name': 'Alex', 'offset': 0,  'ticksPerStep': 1},
  {'id': 'runner_2', 'name': 'Sam',  'offset': 7,  'ticksPerStep': 3},
  {'id': 'runner_3', 'name': 'Mia',  'offset': 14, 'ticksPerStep': 2},
  {'id': 'runner_4', 'name': 'Tom',  'offset': 21, 'ticksPerStep': 4},
];

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;

  static const _fallbackPosition = LatLng(16.4419, 102.8360); // KKU, Khon Kaen
  LatLng _initialPosition = _fallbackPosition;
  final Set<Marker> _markers = {};

  // Current route index for each runner
  final Map<String, int> _runnerIndex = {};
  final Map<String, BitmapDescriptor> _avatarIcons = {};
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();

    // Init runner positions
    for (final r in _fakeRunners) {
      _runnerIndex[r['id'] as String] = r['offset'] as int;
    }

    _updateMarkers();
    _loadAvatarIcons();
    _moveToUserLocation();

    // Move runners every 1.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _stepRunners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _moveToUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _initialPosition = userLatLng);
      mapController.animateCamera(CameraUpdate.newLatLng(userLatLng));
    } catch (_) {
      // Keep fallback position if location unavailable
    }
  }

  Future<void> _loadAvatarIcons() async {
    for (final r in _fakeRunners) {
      final id = r['id'] as String;
      final profile = runnerProfiles[id];
      if (profile == null) continue;
      final icon = await buildAvatarMarker(
        imageUrl: profile.avatarUrl,
        label: profile.name,
        borderColor: _markerColor(id),
      );
      _avatarIcons[id] = icon;
    }
    // Refresh markers with avatar icons
    if (mounted) _updateMarkers();
  }

  Color _markerColor(String id) {
    switch (id) {
      case 'runner_1': return Colors.greenAccent;
      case 'runner_2': return Colors.cyan;
      case 'runner_3': return Colors.orange;
      case 'runner_4': return Colors.purple;
      default:         return Colors.greenAccent;
    }
  }

  void _stepRunners() {
    _tick++;
    for (final r in _fakeRunners) {
      final ticksPerStep = r['ticksPerStep'] as int;
      if (_tick % ticksPerStep != 0) continue;
      final id = r['id'] as String;
      _runnerIndex[id] = (_runnerIndex[id]! + 1) % kFakeRoute.length;
    }
    _updateMarkers();
  }

  void _updateMarkers() {
    final updated = <Marker>{};
    for (final r in _fakeRunners) {
      final id = r['id'] as String;
      final name = r['name'] as String;
      final pos = kFakeRoute[_runnerIndex[id]!];
      updated.add(
        Marker(
          markerId: MarkerId(id),
          position: pos,
          infoWindow: InfoWindow(title: name, snippet: 'Tap to view profile'),
          icon: _avatarIcons[id] ?? BitmapDescriptor.defaultMarkerWithHue(_markerHue(id)),
          onTap: () => RunnerProfileSheet.show(context, id),
        ),
      );
    }
    setState(() {
      _markers
        ..clear()
        ..addAll(updated);
    });
  }

  double _markerHue(String id) {
    switch (id) {
      case 'runner_1': return BitmapDescriptor.hueGreen;
      case 'runner_2': return BitmapDescriptor.hueCyan;
      case 'runner_3': return BitmapDescriptor.hueOrange;
      case 'runner_4': return BitmapDescriptor.hueViolet;
      default:         return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => mapController = controller,
    );
  }

  void addMarker(LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

}
