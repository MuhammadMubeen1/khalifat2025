import 'dart:async';
import 'dart:convert';

import 'package:KhilafatCola/Shop/All_Shop_History_Screen.dart';
import 'package:KhilafatCola/drawer/drawer.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/mymaps/mymaps.dart';
import 'package:KhilafatCola/order_confirmation/dsf_cart_details.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Search/data/data_model.dart';
import '../Search/domain/repository.dart';
import '../Search/presentation/components/loading_widget.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

String shopname = '';
String shopAddress = '';

class ASDDashboard extends StatefulWidget {
  const ASDDashboard({super.key});

  @override
  State<ASDDashboard> createState() => _ASDDashboardState();
}

class _ASDDashboardState extends State<ASDDashboard>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  String? locationString;
  // String userImage = "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...";
  var _totalDistance;
  var firstDealershipId;
  String? _totalTime;
  var distance;
  final TextEditingController _searchShop = TextEditingController();

  /////////////////////////////////////////////////
  final List<User> _users = <User>[];
  List<User> _usersDisplay = <User>[];

  /////////////////////////////////////////////////
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

  List<dynamic> shopList = [];
  List<dynamic> originalShopList = []; // List to store fetched data
  // Flag to indicate loading state
  bool isLoading = true;
  bool screenload = false;
  bool showStartButton = false;
  bool makeattendance = false;
  bool isShopNotFound = false;
  bool _isLoading = true;

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
    // String url = '${Constants.BASE_URL}/api/App/MarkAttendance';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance Mark Successfully')),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance Already Mark')),
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

  // Future<void> getTodayDSFShopByUserLocation() async {
  //   // API URL
  //   setState(() {
  //     isLoading = true;
  //   });
  //   String url =
  //       '${Constants.BASE_URL}/api/App/GetTodayDSFShopByUserLocation';
  //
  //   // Request body
  //   Map<String, dynamic> requestBody = {
  //     'userId': userid,
  //     'lat': currentlat,
  //     'lng': currentlng,
  //     'appDateTime': getCurrentDateTime()
  //   };
  //   print('current lat$requestBody');
  //   print('current lat$currentlat');
  //
  //   // Request headers
  //   Map<String, String> headers = {
  //     'Authorization': '6XesrAM2Nu',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   try {
  //     // Sending the POST request
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(requestBody),
  //     );
  //
  //     // Check for successful response
  //     if (response.statusCode == 200) {
  //       // Parse the response
  //       Map<String, dynamic> responseData = jsonDecode(response.body);
  //       setState(() {
  //         shopList = responseData['Data'] ?? []; // Update the shop list
  //         isLoading = false; // Set loading to false
  //       });
  //       // Access the 'Data' field and convert it to string
  //       String data = responseData['Data'].toString();
  //       print('Data: $data');
  //     } else {
  //       print('Failed to load data. Status Code: ${response.statusCode}');
  //       setState(() {
  //         isLoading = false; // In case of error, stop loading
  //       });
  //       print('Failed to load data. Status Code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     setState(() {
  //       isLoading = false; // In case of error, stop loading
  //     });
  //   }
  // }
  //
  void searchShop(String query) {
    final input = query.toLowerCase(); // Convert query to lower case

    // If the input is empty, show all shops
    if (input.isEmpty) {
      setState(() {
        shopList = List.from(originalShopList);
        isShopNotFound = false; // Reset flag if search is cleared
      });
      return;
    }

    // Filter shops based on the search query
    final filteredShops = originalShopList.where((shop) {
      final shopName = shop['ShopName']?.toLowerCase() ?? '';
      return shopName.contains(input);
    }).toList();

    // Check if any shops are found
    if (filteredShops.isEmpty) {
      setState(() {
        shopList = []; // Clear the list if no matches
        isShopNotFound = true; // Set flag to show message
      });
      return;
    }
    setState(() {
      shopList = filteredShops;
      isShopNotFound = false; // Reset flag if shops are found
    });
  }

  //
  Future<void> getTodayDSFShopByUserLocation() async {
    // Set loading state to true
    setState(() {
      isLoading = true;
      isShopNotFound = false;
    });

    // API URL with query parameters
    String url =
        // '${Constants.BASE_URL}/api/App/GetAllTerritoryShopByUserId?userId=$userid&lat=$currentlat&lng=$currentlng&appDateTime=${getCurrentDateTime()}';
        '${Constants.BASE_URL}/api/App/GetAllTerritoryShopByUserId?userId=$userid&lat=$currentlat&lng=$currentlng&appDateTime=${getCurrentDateTime()}';

    print('URL: $url'); // Print the full URL for debugging

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json',
    };

    try {
      // Sending the GET request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
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
    getNearestDealership();
    super.initState();
    getDistanceAndDuration();
    // fetchUsers().then((value) {
    //   setState(() {
    //     _isLoading = false;
    //     _users.addAll(value);
    //     _usersDisplay = _users;
    //     print(_usersDisplay.length);
    //   });
    // });
    print("IsPResent : $isPresent");
    _startLocationTracking();
    _buildUserDetailsInColumn();
    _buildUserDetailsInColumn1();
    getTodayDSFShopByUserLocation();
    attenanceabsent();
    print("Start Shift $StartShift");
    WidgetsBinding.instance.addObserver(this); // For app lifecycle state
    setShiftTimes();
    checkShiftTime(); // Check shift times on initialization
    startShift();
    //////////////////////////
    fetchUsers().then((value) {
      setState(() {
        _isLoading = false;
        _users.addAll(value);
        _usersDisplay = _users;
      });
    });
    /////////////////////////
    // fetchSalesmanTasks(); // Call the function when the widget is initialized
  }

  //

  //
  // Search Bar Widget
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        onChanged: (searchText) {
          searchText = searchText.toLowerCase();
          setState(() {
            _usersDisplay = _users.where((u) {
              var fName = u.shopName.toLowerCase(); // Accessing shopName
              return fName.contains(
                  searchText); // Check if shopName contains search text
            }).toList();
          });
        },
        decoration: InputDecoration(
          filled: true,
          // Add a background color
          fillColor: Colors.red.shade50,
          // Set a light background color
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          // Adjust padding inside the TextField
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.redAccent, // Border color when focused
              width: 2.0, // Border width when focused
            ),
            // Remove the default border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.redAccent, // Border color when focused
              width: 2.0, // Border width when focused
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color:
                  Colors.redAccent, // Border color when enabled but not focused
            ),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.redAccent, // Customize the color of the search icon
          ),
          hintText: 'Search Shops',
          hintStyle:
              TextStyle(color: Colors.grey[600]), // Change hint text style
        ),
      ),
    );
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

  String formatRemainingTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Do you want to close the app?'),
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
      child: DefaultTabController(
        length: 2,
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
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Column(
                                children: [
                                  Row(
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
                                            ? (userImage
                                                    .startsWith('data:image')
                                                ? MemoryImage(
                                                    base64Decode(
                                                      userImage.split(',').last,
                                                    ),
                                                  )
                                                : NetworkImage('$userImage')
                                                    as ImageProvider)
                                            : const AssetImage(
                                                'assets/default_avatar.png'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, bottom: 10, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FadeInUp(
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5, left: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Image.asset(
                                            'assets/images/gif.gif',
                                            height: 120,
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
                            height: 35,
                            width: 110,
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
                        Tab(text: 'Pending Shops'),
                        Tab(text: 'Completed Shops'),
                      ],
                    ),
                  ),
                  makeattendance == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.red,
                        ))
                      : Expanded(
                          child: TabBarView(
                            children: [
                              isLoading
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator()) // Show loading indicator while fetching data
                                  : shopList.isEmpty
                                      ? const Center(
                                          child: Text(
                                              'Please Refresh and Allow Location Permission'))
                                      : isShopNotFound
                                          ? const Center(
                                              child: Text(
                                                  'Shop not found in your territory.'))
                                          : Present(),
                              Absent()
                            ],
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

  Widget Present() {
    return Column(
      children: [
        _searchBar(),
        Expanded(child: _buildUserDetailsInColumn()),
      ],
    );
  }

  Widget Absent() {
    return Column(
      children: [
        _searchBar(),
        Expanded(child: _buildUserDetailsInColumn1()),
      ],
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
                                onTap: () {
                                  MarkAttendance(true, '');
                                  Navigator.of(context).pop();
                                  mark = false;
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
                                            fit: BoxFit.cover,
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

  Widget _buildUserDetailsInColumn() {
    if (_isLoading) {
      return Center(child: LoadingView());
    } else if (_usersDisplay.isEmpty) {
      return const Center(child: Text('No Shops found.'));
    } else {
      return ListView.builder(
        itemCount: _usersDisplay.length,
        itemBuilder: (context, index) {
          User user = _usersDisplay[index];

          return user.isOrder == 'No'
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display total orders if available
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: AutoSizeText(
                                maxLines: 3,
                                user.shopName,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: AutoSizeText(
                                user.shopAddress,
                                maxLines: 3,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Text(convertTo12HourFormatt(user.openingTime)),
                            const Text(' To '),
                            Text(convertTo12HourFormatt(user.closingTime)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Text(user.phoneNo),
                          ],
                        ),
                        const SizedBox(
                            height: 8.0), // Add space between text and buttons

                        // Column for buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Colors.red.shade50,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopScreen2(
                                      shopid: user.shopId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Order',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                                height: 4.0), // Space b etween buttons
                            user.totalOrder > 0
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                              color: Colors.red.shade50,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderProcessScreen(
                                                shopID: user.shopId.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('History'),
                                      ),
                                      Positioned(
                                        right: -4,
                                        top: -4,
                                        child: user.totalOrder > 0
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  user.totalOrder.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(
                                height: 4.0), // Space before the map button
                            IconButton(
                              icon: const Icon(Icons.pin_drop,
                                  color: Colors.redAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyMap(
                                      latshop: user.shopLat,
                                      lngshop: user.shopLng,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        },
      );
    }
  }

  Widget _buildUserDetailsInColumn1() {
    if (_isLoading) {
      return Center(child: LoadingView());
    } else if (_usersDisplay.isEmpty) {
      return const Center(child: Text('No Shops found.'));
    } else {
      // Check if all users have 'No' in their orders
      bool allPending = _usersDisplay.every((user) => user.isOrder == 'No');

      // If all users have 'No' in their orders, show the message once
      if (allPending) {
        return const Center(
            child: Text('Please Complete all pending shops to show the data'));
      }

      return ListView.builder(
        itemCount: _usersDisplay.length,
        itemBuilder: (context, index) {
          User user = _usersDisplay[index];
          return user.isOrder != 'No'
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
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
                            const Icon(
                              Icons.store,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: AutoSizeText(
                                maxLines: 3,
                                user.shopName,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: AutoSizeText(
                                user.shopAddress,
                                maxLines: 3,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Text(convertTo12HourFormatt(user.openingTime)),
                            const Text(' To '),
                            Text(convertTo12HourFormatt(user.closingTime)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4.0),
                            Text(user.phoneNo),
                          ],
                        ),
                        const SizedBox(
                            height: 8.0), // Add space between text and buttons

                        // Column for buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Colors.red.shade50,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopScreen2(
                                      shopid: user.shopId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Order'),
                            ),
                            const SizedBox(
                                height: 4.0), // Space between buttons
                            user.totalOrder > 0
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                              color: Colors.red.shade50,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderProcessScreen(
                                                shopID: user.shopId.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('History'),
                                      ),
                                      Positioned(
                                        right: -4,
                                        top: -4,
                                        child: user.totalOrder > 0
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  user.totalOrder.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(
                                height: 4.0), // Space before the map button
                            IconButton(
                              icon: const Icon(Icons.pin_drop,
                                  color: Colors.redAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyMap(
                                      latshop: user.shopLat,
                                      lngshop: user.shopLng,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(); // Show nothing for invalid users
        },
      );
    }
  }

  // Widget _buildUserDetailsInColumn1() {
  //   if (_isLoading) {
  //     return Center(child: LoadingView());
  //   } else if (_usersDisplay.isEmpty) {
  //     return Center(child: Text('No Shops found.'));
  //   } else {
  //     return ListView.builder(
  //       itemCount: _usersDisplay.length,
  //       itemBuilder: (context, index) {
  //         User user = _usersDisplay[index];
  //         return user.isOrder != 'No'
  //             ? Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Container(
  //                   width: 150,
  //                   padding: EdgeInsets.all(12.0),
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     color: Colors.white,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.grey.withOpacity(0.5),
  //                         spreadRadius: 2,
  //                         blurRadius: 5,
  //                         offset: Offset(0, 3),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Display total orders if available
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.store,
  //                             size: 20,
  //                             color: Colors.redAccent,
  //                           ),
  //                           SizedBox(width: 4.0),
  //                           Expanded(
  //                             child: AutoSizeText(
  //                               maxLines: 3,
  //                               '${user.shopName}',
  //                               minFontSize: 10,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.location_on,
  //                             size: 20,
  //                             color: Colors.redAccent,
  //                           ),
  //                           SizedBox(width: 4.0),
  //                           Expanded(
  //                             child: AutoSizeText(
  //                               '${user.shopAddress}',
  //                               maxLines: 3,
  //                               minFontSize: 10,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 4.0),
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.access_time,
  //                             size: 20,
  //                             color: Colors.redAccent,
  //                           ),
  //                           SizedBox(width: 4.0),
  //                           Text('${convertTo12HourFormatt(user.openingTime)}'),
  //                           Text(' To '),
  //                           Text('${convertTo12HourFormatt(user.closingTime)}'),
  //                         ],
  //                       ),
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.phone,
  //                             size: 20,
  //                             color: Colors.redAccent,
  //                           ),
  //                           SizedBox(width: 4.0),
  //                           Text('${user.phoneNo}'),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                           height: 8.0), // Add space between text and buttons
  //
  //                       // Column for buttons
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Colors.redAccent,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(8.0),
  //                                 side: BorderSide(
  //                                   color: Colors.red.shade50,
  //                                   width: 2.0,
  //                                 ),
  //                               ),
  //                             ),
  //                             onPressed: () {
  //                               Navigator.pushReplacement(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => ShopScreen2(
  //                                     shopid: user.shopId,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                             child: Text('Order'),
  //                           ),
  //                           SizedBox(height: 4.0), // Space between buttons
  //                           user.totalOrder > 0
  //                               ? Stack(
  //                                   clipBehavior: Clip.none,
  //                                   children: [
  //                                     ElevatedButton(
  //                                       style: ElevatedButton.styleFrom(
  //                                         backgroundColor: Colors.redAccent,
  //                                         shape: RoundedRectangleBorder(
  //                                           borderRadius:
  //                                               BorderRadius.circular(8.0),
  //                                           side: BorderSide(
  //                                             color: Colors.red.shade50,
  //                                             width: 2.0,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       onPressed: () {
  //                                         Navigator.push(
  //                                           context,
  //                                           MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 OrderProcessScreen(
  //                                               shopID: user.shopId.toString(),
  //                                             ),
  //                                           ),
  //                                         );
  //                                       },
  //                                       child: Text('History'),
  //                                     ),
  //                                     Positioned(
  //                                       right: -4,
  //                                       top: -4,
  //                                       child: user.totalOrder > 0
  //                                           ? Container(
  //                                               padding: EdgeInsets.all(4),
  //                                               decoration: BoxDecoration(
  //                                                 color: Colors.red,
  //                                                 shape: BoxShape.circle,
  //                                               ),
  //                                               child: Text(
  //                                                 user.totalOrder.toString(),
  //                                                 style: TextStyle(
  //                                                   color: Colors.white,
  //                                                   fontSize: 12,
  //                                                   fontWeight: FontWeight.bold,
  //                                                 ),
  //                                               ),
  //                                             )
  //                                           : SizedBox(),
  //                                     ),
  //                                   ],
  //                                 )
  //                               : SizedBox(),
  //                           SizedBox(
  //                               height: 4.0), // Space before the map button
  //                           IconButton(
  //                             icon:
  //                                 Icon(Icons.pin_drop, color: Colors.redAccent),
  //                             onPressed: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => MyMap(
  //                                     latshop: user.shopLat,
  //                                     lngshop: user.shopLng,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               )
  //             : Center(child: Text('Please Complete all pending shops to show the data'));
  //       },
  //     );
  //   }
  // }
}
