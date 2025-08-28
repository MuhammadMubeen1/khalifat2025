import 'dart:async';
import 'dart:convert';

import 'package:KhilafatCola/Attendance/shopvisitdetails.dart';
import 'package:KhilafatCola/drawer/drawer.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/mymaps/mymaps.dart';
import 'package:KhilafatCola/tracking/tracking.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';

import 'package:animate_do/animate_do.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


import '../widgets/const.dart';

String shopname = '';
String shopAddress = '';

class RSMDashboardd extends StatefulWidget {
  const RSMDashboardd({super.key});

  @override
  State<RSMDashboardd> createState() => _RSMDashboardState();
}

class _RSMDashboardState extends State<RSMDashboardd>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  String? locationString;
  var _totalDistance;
  String? _totalTime;
  var distance;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return early
      return Future.error('Location services are disabled.');
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, return early
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, return early
      return Future.error('Location permissions are permanently denied');
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert latitude and longitude to integers
    currentlat = position.latitude;
    currentlng = position.longitude;

    setState(() {
      locationString = 'Latitude: $currentlat, Longitude: $currentlng';
      print('news location $locationString');
    });
  }

  void _startLocationTracking() {
    _getCurrentLocation();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      _getCurrentLocation();
    });
  }

  List<dynamic> shopList = []; // List to store fetched data
  // Flag to indicate loading state
  bool isLoading = true;
  bool screenload = false;
  bool showStartButton = false;
  bool makeattendance = false;

  // String salesmenName = '';
  // String salesmId = '';
  // String starttime="";
  // String endtime="";
  // Function to fetch data from the API
  bool? mark;

  void attenanceabsent() {
    if (isPresent == "false") {
      mark = false;
    }
    {}
  }

  Future<void> MarkAttendance(
    bool? marks,
    String? reason,
  ) async {
    // API URL
    String url = '${Constants.BASE_URL}/api/App/MarkAttendance';

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Request body
    Map<String, dynamic> body = {
      "UserId": userid,
      "IsPresent": marks,
      "Reason": reason,
      "lat": currentlat,
      "lng": currentlng,
      'appDateTime': getCurrentDateTime(),
    };
    try {
      setState(() {
        makeattendance = true;
      });
      // Send POST request
      await Future.delayed(const Duration(seconds: 3));
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);
      // Check if the request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['Status'];
        final message = data['Message'];

        await Future.delayed(const Duration(seconds: 3));

        // After getting a response from the API

        print('user role ${response.body}');
        if (message == 'Attendance Mark Successfully') {
          // Attendance Already Mark
          startNewMark();
          // Fluttertoast.showToast(
          //     msg: message,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
          //     backgroundColor: Colors.white,
          //     textColor: Colors.black);

          // Navigate to the home screen
        } else if (message == 'Attendance Already Mark') {
          startShift();
          // Fluttertoast.showToast(
          //     msg: message,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
          //     backgroundColor: Colors.white,
          //     textColor: Colors.black);
          // Show error if login is not successful
        } else if (message == 'Date not matched') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: const Text(
                    "Your Device date is not synced with server date."),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the application
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: const Text(
                    "Your Device date is not synced with server date."),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the application
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //     msg: '',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black);
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        makeattendance = false;
      });
    }
  }

  Future<void> getTodayDSFShopByUserLocation() async {
    // API URL
    setState(() {
      isLoading = true;
    });
    String url =
        '${Constants.BASE_URL}/api/App/GetTodayDSFShopByUserLocation';

    // Request body
    Map<String, dynamic> requestBody = {
      'userId': userid,
      'lat': currentlat,
      'lng': currentlng,
      'appDateTime': getCurrentDateTime()
    };
    print('current lat$requestBody');
    print('current lat$currentlat');

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json',
    };

    try {
      // Sending the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Check for successful response
      if (response.statusCode == 200) {
        // Parse the response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          shopList = responseData['Data'] ?? []; // Update the shop list
          isLoading = false; // Set loading to false
        });
        // Access the 'Data' field and convert it to string
        String data = responseData['Data'].toString();
        print('Data: $data');
      } else {
        print('Failed to load data. Status Code: ${response.statusCode}');
        setState(() {
          isLoading = false; // In case of error, stop loading
        });
        print('Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // In case of error, stop loading
      });
    }
  }

  bool shiftStarted = false; // To track if the shift has started

  @override
  void initState() {
    super.initState();
    getDistanceAndDuration();
    print("IsPResent : $isPresent");
    _startLocationTracking();
    getTodayDSFShopByUserLocation();
    attenanceabsent();
    print("Start Shift $StartShift");
    WidgetsBinding.instance.addObserver(this); // For app lifecycle state
    setShiftTimes();
    checkShiftTime(); // Check shift times on initialization
    startShift();
    // fetchSalesmanTasks(); // Call the function when the widget is initialized
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  @override
  void dispose() {
    shiftTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//////////////////////////////////
  DateTime? startShiftTime;
  DateTime? endShiftTime;
  Timer? shiftTimer;
  Duration remainingTime = Duration.zero;

  // String startTimeString = "07:33:00"; // Example start time (HH:mm:ss)
  // String endTimeString = "19:00:00"; // Example end time (HH:mm:ss)
  bool isAbsentSelected = false;

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      shiftTimer?.cancel(); // Stop the timer when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      // Resume checking the time when app comes back to foreground
      if (showStartButton) {
        startTimer(); // Resume the timer if the shift is active
      }
    }
  }

  // Set the start and end times using the current date and provided time strings
  void setShiftTimes() {
    final now = DateTime.now();
    final startTimeParts = StartShift.split(':');
    final endTimeParts = EndShift.split(':');
    print('end time $startTimeParts');
    // Create DateTime objects using today's date and the provided times
    startShiftTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
      int.parse(startTimeParts[2]),
    );

    endShiftTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
      int.parse(endTimeParts[2]),
    );
  }

  // Check if the current time is between start and end shift times
  void checkShiftTime() {
    DateTime now = DateTime.now();

    if (now.isAfter(startShiftTime!) && now.isBefore(endShiftTime!)) {
      setState(() {
        showStartButton = true; // Show the button if within shift time
        remainingTime =
            endShiftTime!.difference(now); // Calculate initial remaining time
      });
    } else {
      setState(() {
        showStartButton = false; // Hide the button if outside shift time
      });
    }
  }

  Future<void> getDistanceAndDuration() async {
    _getCurrentLocation();
    if (currentlat == null && currentlng == null) return;

    final String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$currentlat,$currentlng&destination=$dealerlat,$dealerlng&key=AIzaSyCxHGLsKCjMWc4q6oqVhYFvl5YRoqaiP1g";

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'] as List;
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'] as List;
        if (legs.isNotEmpty) {
          final duration = legs[0]['duration']['text'];
          // distance = legs[0]['distance']['text'];
          distance = legs[0]['distance']['value'];
          setState(() {
            _totalDistance = distance;
            _totalTime = duration;
          });
          print('Total Distance: $distance');
          print('Total Time: $_totalTime');
        }
      }
    }
  }

  void startTimer() {
    shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = endShiftTime!.difference(DateTime.now());
      });

      // Stop the timer if the remaining time is zero or negative
      if (remainingTime.isNegative || remainingTime == Duration.zero) {
        shiftTimer?.cancel();
        remainingTime = Duration.zero;
      }
    });
  }

  void startNewMark() {
    if (mark == true) {
      shiftStarted = false;
      showStartButton = true;
    } else {
      shiftStarted = true;
      showStartButton = false;
      startTimer();
    }
  }

  // Start shift and begin the timer
  void startShift() {
    print("Shift Started");
    setState(() {
      if (IsMarkAttendance == "true" && isPresent == "true") {
        shiftStarted = true;
        showStartButton = false;
      } else {
        shiftStarted = false;
        showStartButton = true;
      }
      // shiftStarted = true;
      // showStartButton = false; // Hide the start shift button when shift starts
    });
    startTimer(); // Start the countdown timer
  }

  // Format remaining time as HH:mm:ss
  String formatRemainingTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          // Show a confirmation dialog
          return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit App'),
                  content:
                      const Text('Do you want to go back and close the app?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false), // Stay in the app
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(true), // Exit the app
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ) ??
              false; // Default to false if the dialog is dismissed
        },
        child: Scaffold(
          backgroundColor: Colors.red.shade50,
          extendBodyBehindAppBar: true,
          key: _scaffoldKey,
          drawer: const CustomDrawer(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/background.jpg',
                                ),
                                fit: BoxFit.cover),
                            // gradient: LinearGradient(
                            //   colors: [
                            //     Color(
                            //         0xFFB71234), // A richer Coca-Cola Red
                            //     Color(
                            //         0xFFF02A2A), // A slightly darker red
                            //   ],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.menu,
                                        size: 30, color: Colors.white),
                                    onPressed: _openDrawer,
                                  ),
                                  CircleAvatar(
                                    backgroundImage: userImage != null &&
                                            userImage.isNotEmpty
                                        ? (userImage.startsWith('data:image')
                                            ? MemoryImage(
                                                base64Decode(
                                                    userImage.split(',').last),
                                              )
                                            : NetworkImage(
                                                '$userImage',
                                              )) as ImageProvider
                                        : null,
                                    child:
                                        (userImage == null || userImage.isEmpty)
                                            ? const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            : null,
                                  ),

                                ],
                              ),
                            ),
                            Container(
                              // color: Colors.blue.shade400,
                              // decoration: BoxDecoration(
                              //   image: DecorationImage(image: AssetImage('assets/schoolbackground.jpg'),fit: BoxFit.cover),
                              //     gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                              //       Colors.white,
                              //       Colors.green.shade400
                              //     ])),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, bottom: 10, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FadeInUp(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        'Welcome Back',
                                                        style: GoogleFonts.lato(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                  // Align(
                                                  //     alignment: Alignment.topLeft,
                                                  //
                                                  //
                                                  //     child:greetings() ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Name: ',
                                                            style: GoogleFonts.arvo(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            name,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Role: ',
                                                            style: GoogleFonts.arvo(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            role,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Phone No: ',
                                                            style: GoogleFonts.arvo(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            userPhone,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Email: ',
                                                            style: GoogleFonts.arvo(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            userEmail,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            )),
                                        showStartButton && !shiftStarted
                                            ? InkWell(
                                                onTap: () {
                                                  mark != true &&
                                                          isPresent != "false"
                                                      ? _showAttendanceShee(
                                                          context)
                                                      : '';
                                                  // _showAttendanceSheet(context);
                                                },
                                                child: Container(
                                                    height: 140,
                                                    width: 140,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              90),
                                                      gradient: mark != true &&
                                                              isPresent !=
                                                                  "false"
                                                          ? const LinearGradient(
                                                              colors: [
                                                                Color.fromRGBO(
                                                                    0,
                                                                    66,
                                                                    37,
                                                                    1),
                                                                Color.fromRGBO(
                                                                    0,
                                                                    66,
                                                                    61,
                                                                    1)
                                                                // A richer Coca-Cola Red
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            )
                                                          : const LinearGradient(
                                                              colors: [
                                                                Color.fromRGBO(
                                                                    0,
                                                                    153,
                                                                    153,
                                                                    153),
                                                                Color.fromRGBO(
                                                                    0,
                                                                    244,
                                                                    244,
                                                                    244)
                                                                // A richer Coca-Cola Red
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        mark != true &&
                                                                isPresent !=
                                                                    "false"
                                                            ? Text(
                                                                'Mark',
                                                                style: GoogleFonts.lato(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : const SizedBox(),
                                                        mark != true &&
                                                                isPresent !=
                                                                    "false"
                                                            ? Text(
                                                                'Attendance',
                                                                style: GoogleFonts.lato(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : Text(
                                                                'Absent',
                                                                style: GoogleFonts.lato(
                                                                    fontSize:
                                                                        22,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                      ],
                                                    )),
                                              )
                                            : SizedBox(
                                                height: 140,
                                                width: 140,
                                                child: DashedCircularProgressBar
                                                    .aspectRatio(
                                                  aspectRatio: 1,
                                                  // width ÷ height
                                                  valueNotifier: _valueNotifier,

                                                  progress: (32400 -
                                                          remainingTime
                                                              .inSeconds) /
                                                      32400 *
                                                      100,
                                                  startAngle: 225,
                                                  sweepAngle: 270,
                                                  foregroundColor: Colors.green,
                                                  backgroundColor:
                                                      const Color(0xffeeeeee),
                                                  foregroundStrokeWidth: 10,
                                                  backgroundStrokeWidth: 10,
                                                  animation: true,
                                                  seekSize: 6,
                                                  seekColor:
                                                      const Color(0xffeeeeee),
                                                  child: Center(
                                                    child:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                _valueNotifier,
                                                            builder: (_,
                                                                    double
                                                                        value,
                                                                    __) =>
                                                                Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      formatRemainingTime(
                                                                          remainingTime),
                                                                      style: GoogleFonts.lato(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    Text(
                                                                      'Remaining Time',
                                                                      style: GoogleFonts.lato(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                )),
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        '________________',
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        'My Shops',
                        style: GoogleFonts.lato(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            getTodayDSFShopByUserLocation();
                          });
                        },
                        child: Container(
                            height: 30,
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB71234), // A richer Coca-Cola Red
                                  Color(0xFFF02A2A), // A slightly darker red
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Refresh',
                                  style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TabBar(
                      labelColor: Colors.white,
                      // Set the label color
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.red,
                      // Set the unselected label color
                      indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB71234), // A richer Coca-Cola Red
                              Color(0xFFF02A2A), // A slightly darker red
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),
                  makeattendance == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.red,
                        ))
                      : dealershipInformation.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                              itemCount: dealershipInformation.length,
                              itemBuilder: (context, index) {
                                var dealership = dealershipInformation[index];

                                return GestureDetector(
                                  onTap: () {
                                    // Add your onTap logic here
                                  },
                                  child: Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Distributor Name: ${dealership['DealershipName']}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Distributor Phone Number:${dealership['PhoneNo']}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Distributor Address:${dealership['Address']}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Row(
                                          children: [
                                            Text(
                                              'Distributor Distance:${dealership['FormattedDistance']}${dealership['FormattedDistanceUnit']} ',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ))
                          : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget Present() {
    return ListView.builder(
      itemCount: shopList.length,
      itemBuilder: (context, index) {
        var shop = shopList[index]; // Access each shop

        // Assuming each shop object has 'shopName' and 'ownerName'
        shopName = shop['ShopName'] ?? 'No Shop Name';
        String OpeningTime = shop['OpeningTime'] ?? 'No Owner Name';
        String ClosingTime = shop['ClosingTime'] ?? 'No Owner Name';
        double shoplat = shop['ShopLat'] ?? 'No Owner Name';
        double shoplag = shop['ShopLng'] ?? 'No Owner Name';
        shopAddress = shop['ShopAddress'] ?? 'No Owner Name';
        String Phone = shop['PhoneNo'] ?? 'No Phone No';
        String Distance = shop["FormattedDistance"] ?? "No Distance";
        String DistanceKm = shop["FormattedDistanceUnit"] ?? "No Distance";
        int distanceValue = int.tryParse(Distance) ?? 0;
        String isVisited = shop['IsVisited'];
        String isOrder = shop['IsOrder'];
        final shopIds = shop['ShopId'];
        final VisitId = shop['VisitId'];
        final orderId = shop['OrderId'];
        bool canClickButton = distanceValue < 50 && DistanceKm == 'm';
        return isVisited == "No"
            ? Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 5, left: 5),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        shiftStarted == true && canClickButton == true
                            ? BoxShadow(
                                color: Colors.green.shade600,
                                blurRadius: 10,
                                offset: const Offset(0, 3), // Shadow position
                              )
                            : BoxShadow(
                                color: Colors.red.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 3), // Shadow position
                              ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                      border: shiftStarted == true
                          ? Border.all(color: Colors.white, width: 5)
                          : Border.all(color: Colors.grey, width: 5),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 230,
                              child: ListTile(
                                // leading: Icon(
                                //   Icons
                                //       .arrow_circle_right_rounded,
                                //   color: Colors
                                //       .black,
                                // ),
                                title: Text(
                                  shopName,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: shopAddress,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: convertTo12HourFormatt(
                                                OpeningTime),
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          TextSpan(
                                            text: ' To ',
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          TextSpan(
                                            text: convertTo12HourFormatt(
                                                ClosingTime),
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: Phone,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: Distance,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          TextSpan(
                                            text: DistanceKm,
                                            style: GoogleFonts.lato(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (shiftStarted == true &&
                                    canClickButton == true) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StopDetailScreen(
                                          shopid: shopIds,
                                        ),
                                      ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'You must mark attendence or come nearly 50 meter to the shop to activate this operation ')),
                                  );
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: shiftStarted == true &&
                                          canClickButton == true
                                      ? const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFFB71234), // A richer Coca-Cola Red
                                            Color(
                                                0xFFF02A2A), // A slightly darker red
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey,
                                            Colors.grey
                                                .shade300 // A slightly darker red
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    isVisited == "Yes"
                                        ? 'View Details'
                                        : 'Pending',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (shiftStarted == true &&
                                    canClickButton == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyMap(
                                        latshop: shoplat,
                                        lngshop: shoplag,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'You are far away from the Shop')),
                                  );
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  gradient: shiftStarted == true
                                      ? const LinearGradient(
                                          colors: [
                                            Color(
                                                0xFFB71234), // A richer Coca-Cola Red
                                            Color(
                                                0xFFF02A2A), // A slightly darker red
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey,
                                            Colors.grey
                                                .shade300 // A slightly darker red
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                ),
                                child: const Icon(
                                  Icons.pin_drop,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Text(' No Shop Found');
      },
    );
  }

  Widget Absent() {
    bool hasVisitedShops = shopList.any((shop) => shop['IsVisited'] == "Yes");

    if (!hasVisitedShops) {
      // Show "You are marked absent" in the center if no shop is visited
      return const Center(
        child: Text(
          'No Data Found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Show the list if there are visited shops
    return ListView.builder(
      itemCount: shopList.length,
      itemBuilder: (context, index) {
        var shop = shopList[index];
        String shopName = shop['ShopName'] ?? 'No Shop Name';
        String OpeningTime = shop['OpeningTime'] ?? 'No Opening Time';
        String ClosingTime = shop['ClosingTime'] ?? 'No Closing Time';
        double shoplat = shop['ShopLat'] ?? 0.0;
        double shoplag = shop['ShopLng'] ?? 0.0;
        String shopAddress = shop['ShopAddress'] ?? 'No Address';
        String Phone = shop['PhoneNo'] ?? 'No Phone';
        String Distance = shop["FormattedDistance"] ?? "No Distance";
        String isVisited = shop['IsVisited'];
        String isOrder = shop['IsOrder'];
        final shopIds = shop['ShopId'];
        final VisitId = shop['VisitId'];
        final orderId = shop['OrderId'];

        if (isVisited == "Yes") {
          return Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: FadeInUp(
              duration: const Duration(milliseconds: 1500),
              child: Container(
                height: 130,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade600,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 5),
                  color: Colors.white,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              shopAddress,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${convertTo12HourFormatt(OpeningTime)} To ${convertTo12HourFormatt(ClosingTime)}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              Phone,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopVisitDetailsScreen(
                                  visitedId: VisitId,
                                  orderId: orderId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(24, 131, 0, 1),
                                  Color.fromRGBO(64, 186, 15, 1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'View Details',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyMap(
                                  latshop: shoplat,
                                  lngshop: shoplag,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(90),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(24, 131, 0, 1),
                                  Color.fromRGBO(64, 186, 15, 1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.pin_drop,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAttendanceShee(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the sheet to take up more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Ensure the bottom sheet resizes with the keyboard
            ),
            child: Container(
              // height: MediaQuery.of(context)
              //     .size
              //     .height/2, // Use the full height of the screen
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Mark Attendance',
                            style: GoogleFonts.lato(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the buttons
                            children: [
                              InkWell(
                                onTap: () async {
                                  print('DistanceMeteres$distanceInMeters');
                                  if (IsDistCompForAtten == true) {
                                    if (dealershipInformation.isNotEmpty) {
                                      if (distanceInMeters <= 50) {
                                        Navigator.of(context).pop();
                                        await MarkAttendance(true, '');
                                        // showModernDialog(
                                        //     context,
                                        //     "Success",
                                        //     "Your Attendance has been marked.",
                                        //     "Proceed",
                                        //         () {},
                                        //     PanaraDialogType.success);

                                        // Close the dialog
                                        mark = false;
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Location Alert"),
                                              content: const Text(
                                                  "You Must be within 50 meters in the distributor area."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text("Close"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        // showModernDialog(
                                        //     context,
                                        //     "Location Alert",
                                        //     "You Must be within 50 meters in the distributor area.",
                                        //     "Proceed",
                                        //         () {},
                                        //     PanaraDialogType.warning);
                                      }
                                    } else {
                                      print('sss');
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Alert"),
                                            content: const Text(
                                                "No Distributor has been assigned."),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: const Text("Close"),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      // showModernDialog(
                                      //     context,
                                      //     "Success",
                                      //     "Your Attendance has been marked.",
                                      //     "Proceed",
                                      //         () {},
                                      //     PanaraDialogType.success);
                                    }
                                  } else {
                                    Navigator.of(context).pop();
                                    await MarkAttendance(true, '');
                                    // showModernDialog(
                                    //     context,
                                    //     "Alert",
                                    //     "No Distributor has been assigned",
                                    //     "Proceed",
                                    //         () {},
                                    //     PanaraDialogType.warning);
                                  }
                                },
                                child: Container(
                                  height: 60,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromRGBO(0, 66, 37, 1),
                                        Color.fromRGBO(0, 66, 61, 1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/present.png'),
                                            // fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Present',
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isAbsentSelected = !isAbsentSelected;
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB71234),
                                        Color(0xFFF02A2A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Absent',
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isAbsentSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reason for Absence:',
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your comment here...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  void showConfirmationDialog() {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Order'),
                                          content: const Text(
                                              'Are you sure you want to confirm this order?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                // Proceed to confirm the order
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

                                  MarkAttendance(false, 'sss');
                                  mark = true;
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Center(
                                  child: Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFB71234),
                                          Color(0xFFF02A2A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Send',
                                        style: GoogleFonts.lato(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
