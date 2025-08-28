import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen1 extends StatefulWidget {
  final List<LatLng> coordinates; // List of LatLng for polyline
  final List<LatLng> pinLocation; // Single LatLng for the pin marker
  final LatLng shopLocation;
  final String? TerritoryName;
  final String ShopName;
  final String Address;
  final String PhoneNo;
  List<String>? TerritoryNames;
  final List<String> ShopNames;
  final List<String> Addresss;
  final List<String> PhoneNos;

  LocationScreen1(
      {required this.coordinates,
      required this.pinLocation,
      required this.shopLocation,
      this.TerritoryName,
      required this.ShopName,
      required this.Address,
      required this.PhoneNo,
      required this.Addresss,
      required this.PhoneNos,
      required this.ShopNames,
      this.TerritoryNames});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen1> {
  late GoogleMapController _mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  // Variables to store selected marker's information
  String? selectedTerritory;
  String? selectedShopName;
  String? selectedAddress;
  String? selectedPhoneNo;

  @override
  void initState() {
    super.initState();
    _createPolylineAndMarker();
  }

  // Function to create polyline and add markers for pin locations
  void _createPolylineAndMarker() {
    // Add polyline
    polylines.add(Polyline(
      polylineId: PolylineId('territory_polyline'),
      points: widget.coordinates,
      color: Colors.blue,
      width: 4,
    ));

    // Add markers for all pin locations in the list
    for (int i = 0; i < widget.pinLocation.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('pin_$i'),
        position: widget.pinLocation[i],
        onTap: () {
          // Update the state with relevant details when a pin marker is tapped
          setState(() {
            selectedTerritory = widget.TerritoryNames![i];
            selectedShopName = widget.ShopNames[i];
            selectedAddress = widget.Addresss[i];
            selectedPhoneNo = widget.PhoneNos[i];
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Add marker for the main shop location
    markers.add(Marker(
      markerId: MarkerId('shop_location'),
      position: widget.shopLocation,
      onTap: () {
        // Update the state with the main shop details when the shop marker is tapped
        setState(() {
          selectedTerritory = widget.TerritoryName;
          selectedShopName = widget.ShopName;
          selectedAddress = widget.Address;
          selectedPhoneNo = widget.PhoneNo;
        });
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    setState(() {});
  }

  // Function to calculate the LatLngBounds and animate the camera
  void _setCameraBounds() {
    if (widget.coordinates.isNotEmpty) {
      LatLngBounds bounds = _getLatLngBounds(widget.coordinates);

      // Animate the camera to fit the bounds with padding
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100), // 100 is the padding
      );
    }
  }

  // Helper function to get LatLngBounds for the polyline and pin locations
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
        title: const Text('Shop Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Set the camera bounds once the map is created
              _setCameraBounds();
            },
            initialCameraPosition: CameraPosition(
              target: widget.coordinates.isNotEmpty
                  ? widget.coordinates[0]
                  : LatLng(0, 0),
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
          ),
          // Container to display the shop details when a marker is tapped
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: selectedShopName != null // Check if a marker has been tapped
                ? Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shop Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Shop Name: $selectedShopName \n'
                          'Shop Address: $selectedAddress \n'
                          'Phone Number: $selectedPhoneNo \n'
                          'Territory Name: $selectedTerritory',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  )
                : SizedBox(height: 0), // No height if no marker is tapped
          ),
        ],
      ),
    );
  }
}
