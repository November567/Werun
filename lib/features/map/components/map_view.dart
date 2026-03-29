import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const _initialPosition = LatLng(13.7563, 100.5018);

  final Set<Marker> _markers = {
    _runnerMarker('r1', 13.7566, 100.5010),
    _runnerMarker('r2', 13.7558, 100.5020),
    _runnerMarker('r3', 13.7562, 100.5030),
  };

  static Marker _runnerMarker(String id, double lat, double lng) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _initialPosition,
        zoom: 16,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
    );
  }
}
