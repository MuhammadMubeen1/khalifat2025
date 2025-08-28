import 'dart:convert';

import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../widgets/Splash.dart';
import '../widgets/const.dart';

class AttendanceScreen1 extends StatefulWidget {
  final String name;
  final String userId;

  const AttendanceScreen1(
      {super.key, required this.name, required this.userId});

  @override
  State<AttendanceScreen1> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen1> {
  List<Map<String, dynamic>> attendanceData = [];
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool isLoading = true; // Loading state

  // Method to fetch user attendance
  Future<void> fetchAndSaveAttendance(String userId) async {
    try {
      setState(() {
        isLoading = true; // Show loader
      });

      final response = await http.get(
        Uri.parse(
            '${Constants.BASE_URL}/api/App/GetUserAttendanceByUserId?userId=$userId&appDateTime=${getCurrentDateTime()}'),
        headers: {
          'Authorization': '6XesrAM2Nu',
          'Content-Type': 'application/json',
        },
      );

      print('Response: ${response.body}');
      print('Response Request: ${response.request}');
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['Status'] == 100) {
          // Handle Status 100
          setState(() {
            isLoading = false; // Hide loader
            attendanceData = []; // Clear attendance data
          });
         showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content:
                    const Text("Please adjust your device date and try again."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
          // showModernDialog(
          //     context,
          //     "Alert",
          //     "Please adjust your device date and try again",
          //     "Proceed",
          //         () {
          //       Navigator.pop(context);
          //
          //         },
          //     PanaraDialogType.warning);
        } else if (responseBody['Status'] == 200) {
          // Handle successful response
          setState(() {
            attendanceData =
                List<Map<String, dynamic>>.from(responseBody['Data']);
            isLoading = false; // Hide loader
          });
        } else {
          throw Exception('Unknown Status: ');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ');
      }
    } catch (e) {
      print('Error fetching attendance:');
      setState(() {
        isLoading = false; // Hide loader on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
       const  SnackBar(
          content: Text('Check your netwotk'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getCurrentDateTime() {
    return DateTime.now().toIso8601String();
  }

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

  String convertTo12HourFormat(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    String time =
        "${parsedDate.hour % 12 == 0 ? 12 : parsedDate.hour % 12}:${parsedDate.minute.toString().padLeft(2, '0')} ${parsedDate.hour >= 12 ? 'PM' : 'AM'}";
    String date =
        "${parsedDate.day.toString().padLeft(2, '0')}-${(parsedDate.month).toString().padLeft(2, '0')}-${parsedDate.year}";
    return "$date $time";
  }

  @override
  void initState() {
    _checkInitialConnection();
    _listenToConnectionChanges();
    fetchAndSaveAttendance(widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        iconTheme: const  IconThemeData(color: Colors.white),
        title: const Text('Attendance History Details', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      ),
      body: 
           isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: attendanceData.isNotEmpty
                      ? ListView.builder(
                          itemCount: attendanceData.length,
                          itemBuilder: (context, index) {
                            final item = attendanceData[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.8),
                                    blurRadius: 10.0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item['Name']} (${item['Email']})",
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    "${item['IsPresent'] == true ? 'Present' : 'Absent Reason: ${item['Reason']}'} ",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: item['IsPresent']
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    "Attendance Date: ${convertTo12HourFormat(item['AttendanceDate'])}",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (item['Reason'] != null)
                                    const SizedBox(height: 8.0),
                                  const SizedBox(height: 8.0),
                                  item['CheckOut'] != null
                                      ? Text(
                                          "Check Out Date: ${convertTo12HourFormat(item['CheckOut'])}",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54,
                                          ),
                                        )
                                      : const Text(
                                          'No Checkout details available',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                  const SizedBox(height: 8.0),
                                  SizedBox(
                                    height: 43,
                                    child: Center(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          Map<String, dynamic> pinLocationMap =
                                              jsonDecode(item['PinLocation']);
                                          double latitude =
                                              pinLocationMap['lat'];
                                          double longitude =
                                              pinLocationMap['lng'];
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LocationScreen(
                                                latitude: latitude,
                                                longitude: longitude,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.pin_drop,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Attendance Location',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  item['CheckOutLocation'] != null
                                      ? SizedBox(
                                          height: 43,
                                          child: Center(
                                            child: FilledButton.icon(
                                              onPressed: () {
                                                Map<String, dynamic>
                                                    pinLocationMap =
                                                    jsonDecode(item[
                                                        'CheckOutLocation']);
                                                double latitude =
                                                    pinLocationMap['lat'];
                                                double longitude =
                                                    pinLocationMap['lng'];
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LocationScreen(
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.pin_drop,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Checkout Location',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink()
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('No Attendance Data Found')),
                ),
    );
  }
}

class LocationScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationScreen(
      {Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Location'), backgroundColor: Colors.red),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('pinLocation'),
            position: LatLng(latitude, longitude),
          ),
        },
      ),
    );
  }
}
