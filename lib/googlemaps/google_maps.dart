// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:map_launcher/map_launcher.dart';
//
// class MapSample extends StatefulWidget {
//   final double destinationLatitude;
//   final double destinationLongitude;
//
//   const MapSample({
//     Key? key,
//     required this.destinationLatitude,
//     required this.destinationLongitude,
//   }) : super(key: key);
//
//   @override
//   State<MapSample> createState() => MapSampleState();
// }
//
// class MapSampleState extends State<MapSample> {
//   Position? _currentPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocationAndNavigate(); // Start navigation on load
//   }
//
//   Future<void> _initializeLocationAndNavigate() async {
//     await _getCurrentPosition(); // First, get the current position
//     if (_currentPosition != null) {
//       await _startNavigation(); // Start navigation if current position is available
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Since we are directly navigating, we don't need to build any map UI.
//     return Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(), // Show a loading spinner until navigation starts
//       ),
//     );
//   }
//
//   Future<void> _getCurrentPosition() async {
//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) return;
//
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       _currentPosition = position;
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }
//
//   Future<void> _startNavigation() async {
//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Current location not found.')),
//       );
//       return;
//     }
//
//     final availableMaps = await MapLauncher.installedMaps;
//     if (availableMaps.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No map apps installed.')),
//       );
//       return;
//     }
//
//     final coords = Coords(widget.destinationLatitude, widget.destinationLongitude);
//     final title = "Destination";
//
//     await availableMaps.first.showDirections(
//       destination: coords,
//       destinationTitle: title,
//       origin: Coords(_currentPosition!.latitude, _currentPosition!.longitude),
//       originTitle: "Current Location",
//     );
//   }
//
//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location services are disabled. Please enable the services.')));
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Location permissions are denied')));
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location permissions are permanently denied, we cannot request permissions.')));
//       return false;
//     }
//     return true;
//   }
// }