import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;

  final LatLng _initialPosition = const LatLng(13.7563, 100.5018);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();

    _markers.addAll([
      _runnerMarker(13.7566, 100.5010),
      _runnerMarker(13.7558, 100.5020),
      _runnerMarker(13.7562, 100.5030),
    ]);

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route1'),
        points: [
          const LatLng(13.7566, 100.5010),
          const LatLng(13.7558, 100.5020),
          const LatLng(13.7562, 100.5030),
        ],
        color: Colors.blue,
        width: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 16),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => mapController = controller,
    );
  }

  Marker _runnerMarker(double lat, double lng) {
    return Marker(
      markerId: MarkerId('$lat$lng'),
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(title: 'Runner', snippet: 'Running here'),
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

  void addPolyline(List<LatLng> points, String id) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(id),
          points: points,
          color: Colors.red,
          width: 4,
        ),
      );
    });
  }
}
