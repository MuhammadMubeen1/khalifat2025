import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';



class MyMap extends StatefulWidget {
  double? latshop;
  double? lngshop;
  MyMap({
    super.key,
    this.latshop,
    this.lngshop,
  });

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation; // Current Location
  // Example: San Francisco
  Set<Polyline> _polylines = {};
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  String? _totalDistance;
  String? _totalTime;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _rideStarted = false;
  final double _zoomLevel = 12.0; // Zoom level
  bool _isTracking = false; // Flag to track ride in progress
  late LatLng _endLocation; // Declare it without initializing
  @override
  void initState() {
    super.initState();
    _endLocation = LatLng(widget.latshop!, widget.lngshop!);
    _startTrackingLocation(); // Start location tracking
  }

  // Start tracking location in real-time
  void _startTrackingLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update location every 10 meters
      ),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newPosition;
      });

      // Automatically move and zoom camera to the current location if tracking
      if (_isTracking && _mapController != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              newPosition.latitude < _endLocation.latitude
                  ? newPosition.latitude
                  : _endLocation.latitude,
              newPosition.longitude < _endLocation.longitude
                  ? newPosition.longitude
                  : _endLocation.longitude,
            ),
            northeast: LatLng(
              newPosition.latitude > _endLocation.latitude
                  ? newPosition.latitude
                  : _endLocation.latitude,
              newPosition.longitude > _endLocation.longitude
                  ? newPosition.longitude
                  : _endLocation.longitude,
            ),
          ),
          100.0, // Padding between the bounds and edges of the screen
        ));
      }

      // Add markers, draw route, and calculate distance/time
      _addMarkers();
      _drawPolygon();
      _getPolyline();
      getDistanceAndDuration();
    });
  }

  // Add markers to the current location and destination
  void _addMarkers() {
    if (_currentLocation == null) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('start'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Start Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('end'),
          position: _endLocation,
          infoWindow: InfoWindow(title: 'End Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  // Function to draw a polygon between current location and destination
  void _drawPolygon() {
    if (_currentLocation == null) return;

    setState(() {
      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: PolygonId('polygon'),
          points: [_currentLocation!, _endLocation],
          strokeColor: Colors.blue,
          strokeWidth: 3,
          fillColor: Colors.blue.withOpacity(0.15),
        ),
      );
    });
  }

  // Function to get polyline between start and end locations
  void _getPolyline() async {
    if (_currentLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCUXuGguc6775bLD97Ao8y0DYlz0rJciyI", // Google API key
      PointLatLng(_currentLocation!.latitude, _currentLocation!.longitude),
      PointLatLng(_endLocation.latitude, _endLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('polyline'),
          visible: true,
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }

  // Function to calculate distance and time using Google Directions API
  Future<void> getDistanceAndDuration() async {
    if (_currentLocation == null) return;

    final String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${_endLocation.latitude},${_endLocation.longitude}&key=AIzaSyCxHGLsKCjMWc4q6oqVhYFvl5YRoqaiP1g";

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'] as List;
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'] as List;
        if (legs.isNotEmpty) {
          final duration = legs[0]['duration']['text'];
          final distance = legs[0]['distance']['text'];

          setState(() {
            _totalDistance = distance;
            _totalTime = duration;
          });
        }
      }
    }
  }

  // Start button action
  void _startRide() {
    setState(() {
      _rideStarted = true;
      _isTracking = true; // Enable tracking of rider's current location
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Cancel the location stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("tracking")),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB71234), // A richer Coca-Cola Red
                    Color(0xFFF02A2A), // A slightly darker red
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Center(
                            child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ))),
                    // TextButton(onPressed: (){}, child: Text('Shop Close',style: TextStyle(color: Colors.white),)),
                    SizedBox(
                      width: 80,
                    ),
                    Center(
                        child: Text(
                      'Find Shop Route',
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ))
                  ],
                ),
              ),
            ),
            Expanded(
              child: _currentLocation == null
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading until location is fetched
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation!,
                        zoom: _zoomLevel,
                      ),
                      markers: _markers, // Display markers
                      polylines: _polylines, // Display polyline
                      polygons: _polygons, // Display polygon
                      myLocationEnabled: true, // Show the user's location
                      myLocationButtonEnabled:
                          true, // Enable 'my location' button
                      onMapCreated: (controller) {
                        _mapController = controller;
                        // Move camera to current location when the map is created
                        _mapController
                            ?.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentLocation!,
                            zoom: _zoomLevel,
                          ),
                        ));
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Distance From Your Current Location",
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  Text(
                    "$_totalDistance",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Total Time $_totalTime",
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  SizedBox(height: 16.0),
                  // Text(widget.latshop)
                  // _rideStarted
                  //     ? Text(
                  //   "Ride Started! Tracking Destination...",
                  //   style: TextStyle(fontSize: 18, color: Colors.green),
                  // )
                  //     :   InkWell(
                  //   onTap: (){
                  //     _startRide();
                  //   },
                  //       child: Container(
                  //   height: 30,
                  //   width: 90,
                  //   decoration:
                  //   BoxDecoration(
                  //       borderRadius:
                  //       BorderRadius.circular(
                  //           10),
                  //       gradient:   LinearGradient(
                  //         colors: [
                  //           Color(
                  //               0xFFB71234), // A richer Coca-Cola Red
                  //           Color(
                  //               0xFFF02A2A), // A slightly darker red
                  //         ],
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //       ),
                  //   ),
                  //   child:
                  //   Center(
                  //       child:
                  //       Text(
                  //        'Start Ride',
                  //         style: TextStyle(
                  //             color:
                  //             Colors.white),
                  //       ),
                  //   ),
                  // ),
                  //     ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
