import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  List<LatLng>? coordinates; // List of LatLng for polyline
  final LatLng pinLocation; // Single LatLng for the pin marker

  LocationScreen({ this.coordinates, required this.pinLocation});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController _mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _createPolylineAndMarker();
  }

  // Function to create polyline and add marker for pin location
  void _createPolylineAndMarker() {
    // Add polyline
    polylines.add(Polyline(
      polylineId: PolylineId('territory_polyline'),
      points: widget.coordinates!,
      color: Colors.blue,
      width: 4,
    ));

    // for (int i = 0; i < widget.pinLocation.length; i++) {
    //   markers.add(Marker(
    //     markerId: MarkerId('pin_$i'),
    //     position: widget.pinLocation[i],
    //     infoWindow: InfoWindow(title: 'Pin Location $i'),
    //   ));
    // }
    // Add marker for pin location
    markers.add(Marker(
      markerId: MarkerId('pin_location'),
      position: widget.pinLocation,
      infoWindow: InfoWindow(title: 'Shop Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    setState(() {});
  }

  // Function to calculate the LatLngBounds and animate the camera
  void _setCameraBounds() {
    if (widget.coordinates!.isNotEmpty) {
      LatLngBounds bounds = _getLatLngBounds(widget.coordinates!);

      // Animate the camera to fit the bounds with padding
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100), // 100 is the padding
      );
    }
  }

  // Helper function to get LatLngBounds for the polyline and pin location
  LatLngBounds _getLatLngBounds(List<LatLng> coordinates) {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (LatLng latLng in coordinates) {
      if (latLng.latitude < minLat) minLat = latLng.latitude;
      if (latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (latLng.longitude < minLng) minLng = latLng.longitude;
      if (latLng.longitude > maxLng) maxLng = latLng.longitude;
    }

    // Include the pin location in the bounds calculation
    // if (widget.pinLocation.latitude < minLat)
    //   minLat = widget.pinLocation.latitude;
    // if (widget.pinLocation.latitude > maxLat)
    //   maxLat = widget.pinLocation.latitude;
    // if (widget.pinLocation.longitude < minLng)
    //   minLng = widget.pinLocation.longitude;
    // if (widget.pinLocation.longitude > maxLng)
    //   maxLng = widget.pinLocation.longitude;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Shop Location'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;

          // Once the map is created, set the camera bounds
          _setCameraBounds();
        },
        initialCameraPosition: CameraPosition(
          target: widget.coordinates!.isNotEmpty
              ? widget.coordinates![0]
              : LatLng(0, 0),
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
      ),
    );
  }
}
