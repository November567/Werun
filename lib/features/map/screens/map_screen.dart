import 'package:flutter/material.dart';
import '../components/map_view.dart';
import '../components/map_search_bar.dart';
import '../components/run_place_card.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [MapView(), MapSearchBar(), RunPlaceCard()]);
  }
}
