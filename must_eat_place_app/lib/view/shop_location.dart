import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class ShopLocation extends StatefulWidget {
  const ShopLocation({super.key});

  @override
  State<ShopLocation> createState() => _ShopLocationState();
}

class _ShopLocationState extends State<ShopLocation> {
  late String latData; 
  late String longData; 
  late MapController mapController;

  var mustEatData = Get.arguments ?? '__';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latData = mustEatData[0];
    longData = mustEatData[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 위치'),
      ),
      body: flutterMap()
    );
  }

  // --- Function ---
  Widget flutterMap() {
  return FlutterMap(
    mapController: mapController,
    options: MapOptions(
        initialCenter: latlng.LatLng(double.parse(latData), double.parse(longData)), initialZoom: 17.0),
    children: [
      TileLayer(
        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      ),
      MarkerLayer(
        markers: [
          Marker(
            width: 80,
            height: 80,
            point: latlng.LatLng(double.parse(latData), double.parse(longData)),
            child: const Column(
              children: [
                Icon(
                  Icons.pin_drop,
                  size: 50,
                  color: Colors.red,
                )
              ],
            ),
          )
        ],
      )
    ],
  );
}
}