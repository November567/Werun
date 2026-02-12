import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(13.7563, 100.5018),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.werun',
        ),

        /// Runner markers
        MarkerLayer(
          markers: [
            _runnerMarker(13.7566, 100.5010),
            _runnerMarker(13.7558, 100.5020),
            _runnerMarker(13.7562, 100.5030),
          ],
        ),
      ],
    );
  }

  Marker _runnerMarker(double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 48,
      height: 48,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 24,
        child: CircleAvatar(
          radius: 21,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?img=${lat.hashCode % 70}',
          ),
        ),
      ),
    );
  }
}
