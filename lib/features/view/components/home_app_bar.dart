import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.menu, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Search Locations',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }
}