import 'dart:convert';

import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
// Import the new screen

class DealershipDetailsScreen extends StatefulWidget {
  final dealershipInformation;

  DealershipDetailsScreen({this.dealershipInformation});

  @override
  State<DealershipDetailsScreen> createState() =>
      _DealershipDetailsScreenState();
}

class _DealershipDetailsScreenState extends State<DealershipDetailsScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void initState() {
    _checkInitialConnection();
    _listenToConnectionChanges();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.red,
              title: Text(
                'My Distributors',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
            body: widget.dealershipInformation.isNotEmpty
                ? ListView.builder(
                    itemCount: widget.dealershipInformation.length,
                    itemBuilder: (context, index) {
                      var dealership = widget.dealershipInformation[index];
                      return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.8),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.business, size: 20.0),
                                  // Icon for Dealership Name
                                  SizedBox(width: 8.0),
                                  Container(
                                    width: 250,
                                    child: Text(
                                      'Name: ${dealership['DealershipName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 20.0), // Icon for Phone
                                  SizedBox(width: 8.0),
                                  Text('Phone: ${dealership['PhoneNo']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 20.0), // Icon for Address
                                  SizedBox(width: 8.0),

                                  Expanded(
                                      child: Text(
                                          'Address: ${dealership['Address']}')),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.pin_drop,
                                      size: 20.0), // Icon for Distance
                                  SizedBox(width: 8.0),
                                  Text(
                                      'Distance: ${dealership['FormattedDistance']} ${dealership['FormattedDistanceUnit']}'),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Icon(Icons.location_searching, size: 20.0), // Icon for Location
                              //     SizedBox(width: 8.0),
                              //     Text('Location: ${dealership['DealershipLocation']}'),
                              //   ],
                              // ),

                              SizedBox(height: 16.0),

                              ElevatedButton(
                                onPressed: () {
                                  Map<String, dynamic> pinLocationMap =
                                      jsonDecode(
                                          dealership['DealershipLocation']);
                                  LatLng pinLatLng = LatLng(
                                      pinLocationMap['lat'],
                                      pinLocationMap['lng']);
                                  double dealerlat = pinLocationMap['lat'];
                                  double dealerlng = pinLocationMap['lng'];
                                  print('Lat:  $dealerlat');
                                  print('Lng: $dealerlng');
                                  // Navigate to the DealershipLocationScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DealershipLocationScreen(
                                        dealershipName:
                                            dealership['DealershipLocation'],
                                        latitude: dealerlat,
                                        longitude: dealerlng,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'View Location on Map',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ));
                    },
                  )
                : Center(
                    child: Text(
                      'No dealership information available.',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
          );
  }
}

class DealershipLocationScreen extends StatelessWidget {
  final dealershipName;
  final latitude;
  final longitude;

  DealershipLocationScreen({
    this.dealershipName,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Location'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId(dealershipName),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: dealershipName),
          ),
        },
      ),
    );
  }
}
