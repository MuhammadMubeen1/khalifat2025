import 'dart:async';
import 'dart:convert';
import 'package:KhilafatCola/Supervisor/sup_shoptaggingscreen.dart';
import 'package:KhilafatCola/Supervisor/sup_teamscreen.dart';
import 'package:KhilafatCola/drawer/drawer.dart';
import 'package:KhilafatCola/mymaps/mymaps.dart';
import 'package:KhilafatCola/tracking/tracking.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:restart_app/restart_app.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Attendance/attendance_details_screen.dart';
import '../Attendance/shopvisitdetails.dart';
import '../Route/sup_routelist.dart';
import '../Shop/Shop_Orders_Screen.dart';
import '../main.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

String shopname = '';
String shopAddress = '';

class SuperviserDashboard extends StatefulWidget {
  const SuperviserDashboard({super.key});

  @override
  State<SuperviserDashboard> createState() => _ZSMDashboardState();
}

class _ZSMDashboardState extends State<SuperviserDashboard>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  String? locationString;
  var _totalDistance;
  String? _totalTime;
  var firstDealershipId;
  var distance;
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  final TextEditingController _commentController = TextEditingController();
  int todayRouteShopVisited = 0;
  int totalRouteShopVisit = 0;
  int totalTeamMember = 0;
  int offlineTeamMember = 0;
  int presentTeamMember = 0;
  int absentTeamMember = 0;
  int todayOrders = 0;
  late DateTime updatedHourTime;
  bool isLoading = false;
  int totalPendingShopTaggingRequest = 0;
  String? newTime;
  DateTime? startShiftTime;
  late DateTime newTimeValue;
  late Duration totalDuration;
  Duration remainingTime = Duration.zero;

  // late Duration liveTime;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
DateTime _convertToDateTime(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);

    // Get the current date
    final currentDate = DateTime.now();

    // Return the DateTime with the current date and specified time
    return DateTime(currentDate.year, currentDate.month, currentDate.day, hours,
        minutes, seconds);
  }



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

  bool screenload = false;
  bool showStartButton = false;
  bool makeattendance = false;

  bool? mark;
  bool? checkout;

  void attenanceabsent() {
    if (isPresent == "false") {
      mark = false;
      checkout = false;
    }
    {}
  }

  String formatRemainingTime(Duration time) {
    int hours = time.inHours;
    int minutes = time.inMinutes % 60;
    int seconds = time.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Function to calculate the progress percentage
  void _calculateProgress() {
    double progress = (totalDuration.inSeconds - remainingTime.inSeconds) /
        totalDuration.inSeconds *
        100;
    _valueNotifier.value = progress;
  }


  Future<void> getNearestDealership() async {
    final String apiUrl =
        '${Constants.BASE_URL}/api/App/GetUserDetailsByDeviceId';

    Map<String, dynamic> requestBody = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      "lat": currentlat,
      "lng": currentlng,
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '6XesrAM2Nu', // replace with your actual token
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['Data'];

        if (data != null &&
            data['lstDealershipDetails'] != null &&
            data['lstDealershipDetails'].isNotEmpty) {
          final firstDealership = data['lstDealershipDetails'][0];
          firstDealershipId = firstDealership['DealershipId'];
          print('🔹 First Dealership ID: $firstDealershipId');
        } else {
          print('❌ No dealerships found.');
        }
      } else {
        print('❌ Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error occurred: $e');
    }
  }

  Future<void> MarkAttendance(
    bool? marks,
    String? reason,
  ) async {
    setState(() {
      isLoading = true;
    });

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
      'dealershipId': firstDealershipId,
    };
    try {
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);
      // Check if the request was successful
      if (response.statusCode == 200) {
        await _getCurrentLocations();
        final data = jsonDecode(response.body);
        final status = data['Status'];
        final message = data['Message'];

        // After getting a response from the API

        print('user role ${response.body}');
        if (message == 'Attendance Mark Successfully') {
          setState(() {
            isLoading = false;
          });
          // Attendance Already Mark
          startNewMark();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Center(child: Text("Attendane Marked ")),
                content: const Text(
                    'You are requested to restart the application to sync the server date time with attendance'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Restart.restartApp();
                      // Phoenix.rebirth(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
         
        } else if (message == 'Attendance Already Mark') {
          setState(() {
            isLoading = false;
          });
          startShift();

      
        } else if (message == "Today is your weekly Off!") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
     
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        isLoading = false;
        makeattendance = false;
      });
    }
  }

  Future<void> MarkAttendancewithDealershipID(
    bool? marks,
    String? reason,
  ) async {
    setState(() {
      isLoading = true;
    });

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
      'dealershipId': firstDealershipId
    };

    try {
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print('ResponseAttendance${response.request}');
      // Check if the request was successful
      if (response.statusCode == 200) {
        await _getCurrentLocations();
        final data = jsonDecode(response.body);
        final status = data['Status'];
        final message = data['Message'];
        print('StatusAttendance$status');
        setState(() {
          isLoading = false;
        });

        // After getting a response from the API

        print('user role ${response.body}');
        if (message == 'Attendance Mark Successfully') {
          // Attendance Already Mark
          startNewMark();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Center(child: Text("Attendane Marked ")),
                content: const Text(
                    'You are requested to restart the application to sync the server date time with attendance'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Restart.restartApp();
                      // Close the application
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
          
        } else if (message == 'Attendance Already Mark') {
          startShift();

        
        } else if (message == "Today is your weekly Off!") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
      
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        isLoading = false;
        makeattendance = false;
      });
    }
  }

  Future<void> fetchDashboardData() async {
    final String apiUrl =
        '${Constants.BASE_URL}/api/App/GetSupervisorDashboardByUserId?userId=$userid&appDateTime=${getCurrentDateTime()}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '6XesrAM2Nu',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON data
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Access the "Data" object inside the response
        var dashboardData = responseData['Data'];

        setState(() {
          todayRouteShopVisited = dashboardData['TodayRouteShopVisited'];
          totalRouteShopVisit = dashboardData['TotalRouteShopVisit'];
          totalTeamMember = dashboardData['TotalTeamMember'];
          offlineTeamMember = dashboardData['OfflineTeamMember'];
          presentTeamMember = dashboardData['PresentTeamMember'];
          absentTeamMember = dashboardData['AbsentTeamMember'];
          totalPendingShopTaggingRequest =
              dashboardData['TotalPendingShopTaggingRequest'];
          todayOrders = dashboardData['TodayTerritoryOrder'];
        });
        // Extract individual fields from "Data"

        // Print or use the data as needed
        print('Today Route Shop Visited: $todayRouteShopVisited');
        print('Total Route Shop Visit: $totalRouteShopVisit');
        print('Total Team Member: $totalTeamMember');
        print('Offline Team Member: $offlineTeamMember');
        print('Present Team Member: $presentTeamMember');
        print('Absent Team Member: $absentTeamMember');
        print(
            'Total Pending Shop Tagging Request: $totalPendingShopTaggingRequest');
        print('Total Todays Order: $todayOrders');
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getTodayDSFShopByUserLocation() async {
    // API URL
    setState(() {
      isLoading = true;
    });
    String url = '${Constants.BASE_URL}/api/App/GetTodayDSFShopByUserLocation';

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
      print('Respo${response.body}');
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

  bool shiftStarted = false; // To track if the shift has started
  String? formattedPresentTime;

  @override
  void initState() {
    
    getNearestDealership();
    print('PresentTime$PresentTime');
    WidgetsBinding.instance.addObserver(this);
    print("Start Shift $StartShift");

    // _startLocationTracking();

    print("IsPResent : $isPresent");
    if (isPresent != 'null' && PresentTime != 'null') {
      formattedPresentTime = convertToHHMMSS(PresentTime);
      print('correctPresentTime$formattedPresentTime');
      setShiftTimes();
      checkShiftTime();
      startShift();
    } else {
      print('No Present Time');
      setState(() {
        showStartButton = true;
      });
      startShift();
    }

    attenanceabsent();
    // For app lifecycle state

    super.initState();

    // fetchSalesmanTasks(); // Call the function when the widget is initialized
  }

  DateTime addHoursToTime(String startTime, int hoursToAdd) {
    // Parse the start time string into a DateTime object
    final now = DateTime.now();
    final timeParts = startTime.split(':');

    // Create a DateTime object from the provided startTime string (using today's date)
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]), // Hours
      int.parse(timeParts[1]), // Minutes
      int.parse(timeParts[2]), // Seconds
    );

    // Add the specified hours to the DateTime object
    final newDateTime = startDateTime.add(Duration(hours: hoursToAdd));

    // Return the new DateTime object with the updated time
    return newDateTime;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  @override
  void dispose() {
    shiftTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//////////////////////////////////
//   DateTime? startShiftTime;
  DateTime? endShiftTime;
  Timer? shiftTimer;

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

 
  void setShiftTimes() {
  final now = DateTime.now();
  print('formattedPresentTime: $formattedPresentTime');

  // Check if formattedPresentTime is valid (HH:mm:ss format)
  if (formattedPresentTime != null && 
      formattedPresentTime != "Invalid timestamp format" &&
      RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(formattedPresentTime!)) {
    
    final startTimeParts = formattedPresentTime!.split(':');
    print('StartShiftNow: $formattedPresentTime');

    try {
      // Create DateTime object for startShiftTime using today's date and the formattedPresentTime
      startShiftTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startTimeParts[0]), // Hours
        int.parse(startTimeParts[1]), // Minutes
        int.parse(startTimeParts[2]), // Seconds
      );

      // Calculate endShiftTime by adding 8 hours to startShiftTime
      endShiftTime = startShiftTime!.add(const Duration(hours: 8));

      print('StartShiftTime: $startShiftTime');
      print('EndShiftTime: $endShiftTime');
    } catch (e) {
      print('Error parsing time: $e');
      // Fallback: Use current time as startShiftTime
      startShiftTime = now;
      endShiftTime = now.add(const Duration(hours: 8));
    }
  } else {
    print('Invalid formattedPresentTime. Using fallback.');
    // Fallback: Use current time as startShiftTime
    startShiftTime = now;
    endShiftTime = now.add(const Duration(hours: 8));
  }
}

  void checkShiftTime() {
    DateTime now = DateTime.now();

    if (startShiftTime != null &&
        startShiftTime != '' &&
        endShiftTime != null) {
      if (now.isAfter(startShiftTime!) && now.isBefore(endShiftTime!)) {
        setState(() {
          showStartButton = true; // Show the button if within shift time
          remainingTime = endShiftTime != null && startShiftTime != null
              ? endShiftTime!.difference(startShiftTime!)
              : Duration.zero; // Default to zero duration if null
        });
      } else {
        setState(() {
          showStartButton = false; // Hide the button if outside shift time
          remainingTime = Duration.zero; // Ensure remainingTime is not null
        });
      }
    } else {
      setState(() {
        showStartButton = false;
        remainingTime =
            Duration.zero; // Ensure remainingTime has a valid default value
      });
    }
  }

  Future<void> _confirmOrder() async {
    // Show the loader
    setState(() {
      isLoading = true;
    });
    try {
      Navigator.of(context).pop();
      // API call

      await MarkAttendance(false, _commentController.text);
      mark = true;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully!')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to confirm order. Please try again.')),
      );
    } finally {
      // Dismiss the loader
    }
  }

  Position? position;

  Future<void> _getCurrentLocations() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }
    Position? currentPosition;
    // Get current position
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });

    // Call API with the coordinates
    if (position != null) {
      getUserDetailsByDeviceId(position!.latitude, position!.longitude);
    }
  }

  Future<void> getUserDetailsByDeviceId(double latitude, longitude) async {
    setState(() {
      isLoading = true;
    });
    // Define the API URL
    String apiUrl = '${Constants.BASE_URL}/api/App/GetUserDetailsByDeviceId';

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      // "appDateTime": '2024-11-11T08:49:02.056Z',
      "lat": latitude,
      "lng": longitude
    };
    print('ReqBody$requestBody');

    // Define the headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '6XesrAM2Nu',
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => LoginScreen()
      //     // HomeScreen()
      //   ),
      // )
      // Check if the response is successful
      print('UserDetails${response.body}');
      if (response.statusCode == 200) {
        isLoading = false;
        print('Splash resp ${response.body}');
        // Parse and handle the response data
        final responseData = jsonDecode(response.body);
        final message = responseData["Message"];
        final resp = responseData["Data"];
        final statusCode = responseData['Status'];

        if (resp != null) {
          name = resp["Name"].toString();
          role = resp["RoleName"].toString();
          userPhone = resp["PhoneNumber"].toString();
          userEmail = resp["Email"].toString();
          userid = resp["UserId"].toString();
          userImage = resp["Image"].toString();
          StartShift = resp["ShiftTimeStart"].toString();

          EndShift = resp["ShiftTimeEnd"].toString();
          IsMarkAttendance = resp["IsMarkAttendance"].toString();
          isPresent = resp['IsPresent']?.toString() ?? 'null';
          PresentTime = resp['PresentTime'] ?? 'null';
          print('IsPresent$isPresent');
          print('IsPresentTime$PresentTime');

          // PresentTime = resp['PresentTime'];
          // print('PresentTime$PresentTime');
          IsMobileDeviceRegister = resp['IsMobileDeviceRegister'];
          IsDistCompForAtten = resp['IsDistCompForAtten'];
          IsLogedIn = resp['IsLogedIn'];
          print('ISLOGIN$IsLogedIn');
          setState(() {
            isCheckOut = resp['IsCheckOut'];
            print('IsCheckOut$isCheckOut');
          });
          print('AttendanceMandatory$IsDistCompForAtten');
          IsAvailableForMobile = resp['IsAvailableForMobile'];
          dealershipInformation = resp['lstDealershipDetails'] ?? [];
          print('DistributorDetails$dealershipInformation');
          if (dealershipInformation.isNotEmpty) {
            var firstDealership =
                dealershipInformation[0]; // Access the first item
            distanceInMeters =
                firstDealership['DistanceInMeters']; // Get the DistanceInMeters

            print('Distance of first dealership: $distanceInMeters meters');
            for (var dealership in dealershipInformation) {
              int dealershipId = dealership['DealershipId'];
              String dealershipName = dealership['DealershipName'];
              String phoneNo = dealership['PhoneNo'];
              String address = dealership['Address'];
              String location = dealership['DealershipLocation'];
              double distanceInMeters = dealership['DistanceInMeters'];
              String formattedDistance = dealership['FormattedDistance'];
              String formattedDistanceUnit =
                  dealership['FormattedDistanceUnit'];
              dealershipID = dealership['DealershipId'].toString();
              print('DealerShipID$dealershipID');

              print('Dealership Name: $dealershipName, Phone: $phoneNo');
            }
          } else {
            isLoading = false;
            print('No dealership information available.');
          }

          print('Response data: $responseData');
          print('Response data: $message');
          print('Response attance: $IsMarkAttendance');
          print('Response role: $role');
          print('Userid : $userid');
          print('IsLogedIn$IsLogedIn');
          // print('Dealership Lat: $latitude');
          // print('Dealership Long: $longitude');
        } else {}
      } else {
        isLoading = false;
        print(
            'Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      print('Error occurred: $e');
    }
  }

  String convertToHHMMSS(String timestamp) {
    try {
      // Check if the timestamp is already in hh:mm:ss format
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timestamp)) {
        return timestamp; // It's already in the correct format
      }

      // Parse the input timestamp as a DateTime object
      DateTime dateTime = DateTime.parse(timestamp);
      // Format to hh:mm:ss
      String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}:"
          "${dateTime.second.toString().padLeft(2, '0')}";
      return formattedTime;
    } catch (e) {
      return "Invalid timestamp format";
    }
  }

  Future<void> MarkCheckOut() async {
    if (position == null) {
      setState(() {
        isLoading = false;
      });
      print('Error: Position is null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine location.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Define the API URL
    String apiUrl = '${Constants.BASE_URL}/api/App/MarkAttendanceCheckOut';

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "lat": position!.latitude,
      "lng": position!.longitude,
    };
    print('ReqBody$requestBody');

    // Define the headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '6XesrAM2Nu',
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print('CheckOut Resposne${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['Status'];
        final message = responseData['Message'];
        if (status == 409) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
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
                title: const Text("Success"),
                content: Text(message ?? "Check-out successful!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          await getUserDetailsByDeviceId(
              position!.latitude, position!.longitude);
        }

        setState(() {
          isLoading = false;
        });
        print('Attendance Response${response.body}');
        // Show success dialog
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to mark check-out. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark check-out.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while checking out.')),
      );
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

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify'),
          content: const Text('Are you sure you want to mark your absent'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the confirmation dialog
                await _confirmOrder(); // Proceed to confirm the order with a loader
              },
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (endShiftTime == 'null') {
        } else {
          remainingTime = endShiftTime!.difference(DateTime.now());
        }
      });

      // Stop the timer if the remaining time is zero or negative
      if (remainingTime.isNegative || remainingTime == Duration.zero) {
        shiftTimer?.cancel();
        remainingTime = Duration.zero;
      }
    });
  }

  void showCheckoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify'),
          content: const Text('Are you sure you want to mark check out'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.pop(context);

              
                await MarkCheckOut();
                // Close the confirmation dialog
                // Proceed to confirm the order with a loader
              },
            ),
          ],
        );
      },
    );
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

  markCheckoutAttendance() async {
    if (IsLogedIn == true) {
      setState(() async {
        await MarkCheckOut();
        // checkout = false;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: const Text("Please Mark your Attendance first"),
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
    }
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
        child: !_isConnected
            ? NoInternetScreen(onRetry: _checkInitialConnection)
            : Scaffold(
                backgroundColor: Colors.red.shade50,
                extendBodyBehindAppBar: true,
                key: _scaffoldKey,
                drawer: const CustomDrawer(),
                body: Stack(
                  children: [
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 10),
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
                                                  size: 30,
                                                  color: Colors.white),
                                              onPressed: _openDrawer,
                                            ),
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage: userImage !=
                                                          null &&
                                                      userImage.isNotEmpty
                                                  ? (userImage.startsWith(
                                                              'data:image')
                                                          ? MemoryImage(
                                                              base64Decode(
                                                                  userImage
                                                                      .split(',')
                                                                      .last))
                                                          : NetworkImage(
                                                              '$userImage'))
                                                      as ImageProvider
                                                  :const  AssetImage(
                                                      'assets/default_avatar.png'),
                                            )

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
                                              left: 5,
                                              right: 5,
                                              bottom: 10,
                                              top: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FadeInUp(
                                                      duration: const Duration(
                                                          milliseconds: 1000),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Text(
                                                                  'Welcome Back',
                                                                  style: GoogleFonts.lato(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
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
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Name: ',
                                                                      style: GoogleFonts.arvo(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .w100,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Text(
                                                                      name,
                                                                      style: GoogleFonts.lato(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                )),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Role: ',
                                                                      style: GoogleFonts.arvo(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .w100,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Text(
                                                                      role,
                                                                      style: GoogleFonts.lato(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                )),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Phone No: ',
                                                                      style: GoogleFonts.arvo(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .w100,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Text(
                                                                      userPhone,
                                                                      style: GoogleFonts.lato(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                )),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Email: ',
                                                                      style: GoogleFonts.arvo(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .w100,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    Text(
                                                                      userEmail,
                                                                      style: GoogleFonts.lato(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      )),
                                                  showStartButton &&
                                                          !shiftStarted
                                                      ? InkWell(
                                                          onTap: () {
                                                            mark != true &&
                                                                    isPresent !=
                                                                        "false"
                                                                ? _showAttendanceShee(
                                                                    context)
                                                                : '';
                                                            // _showAttendanceSheet(context);
                                                          },
                                                          child: Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            90),
                                                                gradient: mark !=
                                                                            true &&
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
                                                                              fontSize: 13,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      : const SizedBox(),
                                                                  mark != true &&
                                                                          isPresent !=
                                                                              "false"
                                                                      ? Text(
                                                                          'Attendance',
                                                                          style: GoogleFonts.lato(
                                                                              fontSize: 13,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      : Text(
                                                                          'Leave',
                                                                          style: GoogleFonts.lato(
                                                                              fontSize: 13,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                ],
                                                              )),
                                                        )
                                                      : SizedBox(
                                                          height: 120,
                                                          width: 100,
                                                          child: Column(
                                                            children: [
                                                              isCheckOut == true
                                                                  ? const SizedBox
                                                                      .shrink()
                                                                  : DashedCircularProgressBar
                                                                      .aspectRatio(
                                                                      aspectRatio:
                                                                          1,
                                                                      // width ÷ height
                                                                      valueNotifier:
                                                                          _valueNotifier,

                                                                      progress:
                                                                          // (remainingTime!
                                                                          //         .inSeconds)
                                                                          32400 /
                                                                              32400 *
                                                                              100,
                                                                      startAngle:
                                                                          225,
                                                                      sweepAngle:
                                                                          270,
                                                                      foregroundColor:
                                                                          Colors
                                                                              .green,
                                                                      backgroundColor:
                                                                          const Color(
                                                                              0xffeeeeee),
                                                                      foregroundStrokeWidth:
                                                                          10,
                                                                      backgroundStrokeWidth:
                                                                          10,
                                                                      animation:
                                                                          true,
                                                                      seekSize:
                                                                          6,
                                                                      seekColor:
                                                                          const Color(
                                                                              0xffeeeeee),
                                                                      child:
                                                                          Center(
                                                                        child: ValueListenableBuilder(
                                                                            valueListenable: _valueNotifier,
                                                                            builder: (_, double value, __) => Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                      formatRemainingTime(remainingTime),
                                                                                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                                                    ),
                                                                                    Text(
                                                                                      'Remaining Time',
                                                                                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                                                                                    ),
                                                                                  ],
                                                                                )),
                                                                      ),
                                                                    ),
                                                              // isCheckOut == false ?
                                                              isCheckOut == true
                                                                  ? Container(
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(.3),
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            Text(
                                                                          'Checked Out',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            // Adjust font size as needed
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white, // Adjust text color if needed
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : SizedBox(
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          FilledButton(
                                                                        style: FilledButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.white),
                                                                        onPressed:
                                                                            () async {
                                                                          if (IsDistCompForAtten ==
                                                                              true) {
                                                                            if (dealershipInformation.isNotEmpty) {
                                                                              if (distanceInMeters <= 50) {
                                                                                showCheckoutConfirmationDialog();

                                                                                // showModernDialog(
                                                                                //     context,
                                                                                //     "Success",
                                                                                //     "Your Attendance has been marked.",
                                                                                //     "Proceed",
                                                                                //         () {},
                                                                                //     PanaraDialogType.success);

                                                                                // Close the dialog
                                                                                // mark = false;
                                                                              } else {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      title: const Text("Location Alert"),
                                                                                      content: const Text("You Must be within 50 meters in the distributor area."),
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
                                                                                    content: const Text("No Distributor has been assigned."),
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
                                                                              //     "Success",
                                                                              //     "Your Attendance has been marked.",
                                                                              //     "Proceed",
                                                                              //         () {},
                                                                              //     PanaraDialogType.success);
                                                                            }
                                                                          } else {
                                                                            showCheckoutConfirmationDialog();
                                                                          }
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Check Out',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                              // : SizedBox.shrink()
                                                            ],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // First Button (Attendance History)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen1(
                                          name: name,
                                          userId: userid,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    // Coca-Cola red
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      // Rounded corners
                                      side: const BorderSide(
                                        color: Colors.white, // Border color
                                        width: 2, // Border width
                                      ),
                                    ),
                                    minimumSize: const Size(100, 40),
                                    // Width: 100, Height: 40
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            16), // Control horizontal padding
                                  ),
                                  child: const Text(
                                    'Attendance History',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),

                                // Second Button (Refresh)
                                ElevatedButton(
                                  onPressed: () {
                                    // fetchDashboardData();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    // Coca-Cola red
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      // Rounded corners
                                      side: const BorderSide(
                                        color: Colors.white, // Border color
                                        width: 2, // Border width
                                      ),
                                    ),
                                    minimumSize: const Size(100, 40),
                                    // Width: 100, Height: 40
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            16), // Control horizontal padding
                                  ),
                                  child: const Text(
                                    'Refresh',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                                child: GridView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 18.0,
                                childAspectRatio: 1.3,
                              ),
                              children: [
                                _buildCard(
                                  context,
                                  "Today Orders",
                                  '$todayOrders',
                                  const ShopOrderScreen(),
                                  Icons.history,
                                ),
                                // _buildCard(
                                //   context,
                                //   "Pending Delivery",
                                //   "10",
                                //   OrderPendingScreen(),
                                //   Icons.pending,
                                // ),
                                _buildCard(
                                  context,
                                  "Today Route Visit",
                                  "$todayRouteShopVisited/$totalRouteShopVisit",
                                  const RouteListScreen(),
                                  Icons.route,
                                ),
                                _buildCard(
                                  context,
                                  "Shop Tagging Request",
                                  "$totalPendingShopTaggingRequest",
                                 const ShopTaggingRequestScreen(),
                                  Icons.tag,
                                ),
                                _buildWideCard(
                                  context,
                                  "My Team",
                                  "Present : $presentTeamMember \nAbsent : $absentTeamMember\nOffline : $offlineTeamMember",
                                  const MyTeamScreen(),
                                  Icons.group,
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {},
                          // Disable touch events by providing an empty onTap
                          child: Container(
                            color: Colors.red[50], // Semi-transparent overlay
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                  ],
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

  Widget _buildCard(
    BuildContext context,
    String title,
    String value,
    Widget destination,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    value,
                    style: GoogleFonts.lato(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                icon,
                size: 24.0,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideCard(
    BuildContext context,
    String title,
    String value,
    Widget destination,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.lato(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  icon,
                  size: 24.0,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
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
                              fontSize: 10,
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
                                  print('DistanceMetere s$distanceInMeters');
                                  if (IsDistCompForAtten == true) {
                                    if (dealershipInformation.isNotEmpty) {
                                      if (distanceInMeters <= 50) {
                                        Navigator.of(context).pop();
                                        await MarkAttendancewithDealershipID(
                                            true, '');
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Alert"),
                                            content: const Text(
                                                "No Distributor has been assigneds."),
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
                                    mark = false;
                                    // showModernDialog(
                                    //     context,
                                    //     "Alert",
                                    //     "No Distributor has been assigned",
                                    //     "Proceed",
                                    //         () {},
                                    //     PanaraDialogType.warning);
                                  }

                                  // if(distanceInMeters == null && IsDistCompForAtten == true)
                                  //   {
                                  //     showModernDialog(
                                  //         context,
                                  //         "Alert",
                                  //         "No distributor has been assigned to you.",
                                  //         "Proceed",
                                  //             () {},
                                  //         PanaraDialogType.warning);
                                  //     Navigator.of(context)
                                  //         .pop();
                                  //   }
                                  // else  {
                                  //
                                  // } else {
                                  //   // Navigator.of(context)
                                  //   //     .pop();
                                  //   // await MarkAttendance(true, '');
                                  //   // Close the dialog
                                  //   // mark = false;
                                  //   showModernDialog(
                                  //       context,
                                  //       "Location Error",
                                  //       "Your Attendance has been marked.",
                                  //       "Proceed",
                                  //       () {},
                                  //       PanaraDialogType.warning);
                                  // }
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
                                        'Leave',
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
                                'Reason for Leave:',
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _commentController,
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
                                  final comment = _commentController.text;
                                  if (comment.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Validation Error"),
                                          content: const Text(
                                              "Comment must not be empty."),
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
                                  } else {
                                    showConfirmationDialog();
                                  }
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

  void _showCheckOutSheet(BuildContext context) {
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
                              fontSize: 10,
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
                                  print('DistanceMetere s$distanceInMeters');
                                  if (IsDistCompForAtten == true) {
                                    if (dealershipInformation.isNotEmpty) {
                                      if (distanceInMeters <= 50) {
                                        Navigator.of(context).pop();
                                        await MarkCheckOut();
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Alert"),
                                            content: const Text(
                                                "No Distributor has been assigneds."),
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
                                    await MarkCheckOut();
                                    mark = false;
                                    // showModernDialog(
                                    //     context,
                                    //     "Alert",
                                    //     "No Distributor has been assigned",
                                    //     "Proceed",
                                    //         () {},
                                    //     PanaraDialogType.warning);
                                  }

                                  // if(distanceInMeters == null && IsDistCompForAtten == true)
                                  //   {
                                  //     showModernDialog(
                                  //         context,
                                  //         "Alert",
                                  //         "No distributor has been assigned to you.",
                                  //         "Proceed",
                                  //             () {},
                                  //         PanaraDialogType.warning);
                                  //     Navigator.of(context)
                                  //         .pop();
                                  //   }
                                  // else  {
                                  //
                                  // } else {
                                  //   // Navigator.of(context)
                                  //   //     .pop();
                                  //   // await MarkAttendance(true, '');
                                  //   // Close the dialog
                                  //   // mark = false;
                                  //   showModernDialog(
                                  //       context,
                                  //       "Location Error",
                                  //       "Your Attendance has been marked.",
                                  //       "Proceed",
                                  //       () {},
                                  //       PanaraDialogType.warning);
                                  // }
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
                                        'Check Out',
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
                                controller: _commentController,
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
                                  final comment = _commentController.text;
                                  if (comment.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Validation Error"),
                                          content: const Text(
                                              "Comment must not be empty."),
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
                                  } else {
                                    showConfirmationDialog();
                                  }
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
