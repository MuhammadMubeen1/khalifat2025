import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class MapSample extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;

  const MapSample({
    Key? key,
    required this.destinationLatitude,
    required this.destinationLongitude,
  }) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  String? _currentAddress;
  Position? _currentPosition;
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.4855162, 74.2785524),
    zoom: 14.4746,
  );
  @override
  void initState() {
    _getCurrentPosition;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _mapController = controller;
        },
        markers: _createMarkers(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

        },
        label: const Text('Get Current Location'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng(_currentPosition!);
      _getPolyline();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getPolyline() async {
    if (_currentPosition == null) return;

    final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final destination = '${widget.destinationLatitude},${widget.destinationLongitude}';
    final apiKey = 'AIzaSyCUXuGguc6775bLD97Ao8y0DYlz0rJciyI'; // Replace with your Google API key

    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey&mode="driving"';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final polyline = data['routes'][0]['overview_polyline']['points'];
        _polylineCoordinates = _decodePolyline(polyline);

        _addPolyline();
      }
    } else {
      print('Failed to fetch route');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return polylineCoordinates;
  }

  void _addPolyline() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Colors.red,
      points: _polylineCoordinates,
      width: 5,
    );
    setState(() {
      _polylines.add(polyline);
    });
  }

  Set<Marker> _createMarkers() {
    return {
      if (_currentPosition != null)
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.destinationLatitude, widget.destinationLongitude),
        infoWindow: InfoWindow(title: 'Destination'),
      ),
    };
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable the services.')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }


}
