import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ShopLocationMap({required this.latitude, required this.longitude});

  @override
  _ShopLocationMapState createState() => _ShopLocationMapState();
}

class _ShopLocationMapState extends State<ShopLocationMap> {
  late GoogleMapController mapController;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId('shopLocation'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: "Shop Location"),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop Location'), backgroundColor: Colors.red
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        markers: _markers,
      ),
    );
  }
}
