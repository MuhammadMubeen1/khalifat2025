import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:KhilafatCola/ASD/asd_dashboard.dart';
import 'package:KhilafatCola/Home/home.dart';
import 'package:KhilafatCola/MarkAttendence/attendence.dart';
import 'package:KhilafatCola/Supervisor/sup_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:upgrader/upgrader.dart';
import '../ZSM/zsm_dashboard.dart';
import '../login.dart';
import '../main.dart';
import '../utils/widgets.dart';
import 'const.dart';

// Global variables (same as before)
String userid = '';
String name = '';
String role = '';
String employeeDesination = '';
String userImage = '';
String userEmail = '';
String userPhone = '';
String StartShift = "";
String EndShift = "";
String IsMarkAttendance = '';
String isPresent = '';
String PresentTime = '';
String coords = '';
bool? IsMobileDeviceRegister;
bool? IsAvailableForMobile;
bool? IsDistCompForAtten;
List<dynamic> dealershipInformation = [];
String pinLocationss = '';
int? shopid;
bool isLoginSucess = false;
String dealershipName = '';
String dealershipLocation = '';
double? dealerlat;
double? dealerlng;
var DeliveryChallanCode;
var orderId;
double distanceInMeters = 0;
bool? IsLogedIn;
bool? isCheckOut;
String ImageServer = '';
String? dealershipID;

// Hive box names
const String userBoxName = 'userData';
const String dealershipBoxName = 'dealershipData';

class SplashScreen extends StatefulWidget {
  final bool? isConnected;
  const SplashScreen({super.key, this.isConnected});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();
  String? locationString;
  String? lat;
  String? lng;
  late Timer _timer;
  final newVersionPlus = NewVersionPlus(
      androidId: 'com.khilafat.cola', iOSId: 'com.khilafat.cola');
  late Box userBox;
  late Box dealershipBox;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _usingCachedData = false;
  bool _hasInternetConnection = true;
  bool _initialized = false;
  bool _forceOnlineCheck = false;
  bool _locationServiceEnabled = false;
  bool _locationPermissionGranted = false;
  bool _locationObtained = false;
  bool _showingLocationDialog = false;
  bool _apiCallInProgress = false;
  bool _locationSettingsOpened = false;

  // Upgrader variables
  bool _upgraderInitialized = false;
  bool _upgradeCheckCompleted = false;
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize upgrader with configuration
    _upgrader = Upgrader(
      debugLogging: true,
      durationUntilAlertAgain: const Duration(seconds: 0),
      debugDisplayAlways: false,
      languageCode: 'en',
      countryCode: 'EG',
      minAppVersion: "1.0.8+25",
    );

    _initializeApp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _locationSettingsOpened) {
      _locationSettingsOpened = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getLocationWithRetry();
      });
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Hive
      await _initializeHive();

      // Check internet connection
      await _checkInternetConnectionWithRetry();

      // Initialize the upgrader first
      await _upgrader.initialize();
      setState(() {
        _upgraderInitialized = true;
      });

      // Check if an update is required
      bool needsUpgrade = _upgrader.shouldDisplayUpgrade();
      print("Needs upgrade: $needsUpgrade");

      // Only proceed with app initialization if no upgrade is required
      if (!needsUpgrade) {
        // Get device ID
        await initDeviceId();

        // Get location - this will block until location is obtained
        await _getLocationWithRetry();

        // Load user data - force online check if we have connection
        await _loadUserData(forceOnline: _hasInternetConnection);
      }

      setState(() {
        _initialized = true;
        _upgradeCheckCompleted = true;
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      _handleInitializationError();
    }
  }

  Future<void> _getLocationWithRetry() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (!_locationObtained && retryCount < maxRetries) {
      try {
        await _checkAndRequestLocationServices();

        if (_locationServiceEnabled && _locationPermissionGranted) {
          await _getCurrentLocation();

          if (_currentPosition != null) {
            setState(() {
              _locationObtained = true;
            });

            // If we were showing the dialog, close it
            if (_showingLocationDialog && mounted) {
              Navigator.of(context).pop();
              _showingLocationDialog = false;
            }

            // Proceed with app initialization
            if (!_initialized) {
              await _loadUserData(forceOnline: _hasInternetConnection);
            }
            return;
          }
        }

        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        debugPrint('Location retry error: $e');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    if (!_locationObtained && mounted && !_showingLocationDialog) {
      _showPersistentLocationDialog();
    }
  }

  void _showPersistentLocationDialog() {
    if (_showingLocationDialog) return;

    _showingLocationDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("Location Required"),
          content: const Text(
              "This app requires your location to function properly. Please enable location services and grant location permissions."),
          actions: [
            TextButton(
              onPressed: () async {
                _locationSettingsOpened = true;
                await Geolocator.openLocationSettings();

                // Don't pop the dialog here - keep it visible
                // After returning from settings, wait a moment then check again
                if (mounted) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  _locationSettingsOpened = false;

                  // Check if location is now available
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  LocationPermission permission =
                      await Geolocator.checkPermission();

                  if (serviceEnabled &&
                      (permission == LocationPermission.always ||
                          permission == LocationPermission.whileInUse)) {
                    // If we got permission, dismiss dialog and proceed
                    Navigator.of(context).pop();
                    _showingLocationDialog = false;
                    await _getLocationWithRetry();
                  }
                  // Otherwise, dialog stays visible until user clicks Retry
                }
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showingLocationDialog = false;
                // Reset the location state and restart the initialization
                setState(() {
                  _locationObtained = false;
                  _locationServiceEnabled = false;
                  _locationPermissionGranted = false;
                });
                await _initializeApp(); // Restart the initialization process
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    ).then((_) {
      _showingLocationDialog = false;
    });
  }

  Future<void> _checkAndRequestLocationServices() async {
    try {
      // Check if location service is enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location service enabled: $_locationServiceEnabled');

      if (!_locationServiceEnabled) {
        // If we're returning from settings and it's still disabled
        if (_locationSettingsOpened) {
          throw Exception('Location services still disabled');
        }
        return;
      }

      // Request location permission
      await _requestLocationPermission();

      // If we just came back from settings and got permission
      if (_locationSettingsOpened && _locationPermissionGranted) {
        _locationSettingsOpened = false;
        await _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Location services check error: $e');
      rethrow;
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Current location permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Requested permission result: $permission');

        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      setState(() {
        _locationPermissionGranted = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } catch (e) {
      debugPrint('Location permission error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation when update is required or location not obtained
        if (_upgraderInitialized && _upgrader.shouldDisplayUpgrade()) {
          return false;
        }
        if (!_locationObtained) {
          return false;
        }
        return true;
      },
      child: UpgradeAlert(
        upgrader: _upgrader,
        dialogStyle: UpgradeDialogStyle.cupertino,
        showIgnore: false,
        showLater: false,
        shouldPopScope: () => false,
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB71234),
                  Color(0xFFF02A2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/gif.gif',
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    userBox = await Hive.openBox(userBoxName);
    dealershipBox = await Hive.openBox(dealershipBoxName);
  }

  Future<bool> _checkInternetConnectionWithRetry() async {
    int retries = 0;
    const maxRetries = 3;

    while (retries < maxRetries) {
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));

        final isConnected =
            result.isNotEmpty && result[0].rawAddress.isNotEmpty;

        setState(() {
          _hasInternetConnection = isConnected;
        });

        return isConnected;
      } catch (e) {
        retries++;
        if (retries < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    setState(() {
      _hasInternetConnection = false;
    });
    return false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!_locationServiceEnabled || !_locationPermissionGranted) {
        debugPrint('Location services not enabled or permission not granted');
        throw Exception('Location services not enabled');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      debugPrint('Got location: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentPosition = position;
        currentlat = position.latitude;
        currentlng = position.longitude;
        locationString = 'Latitude: $currentlat, Longitude: $currentlng';
        lat = '$currentlat';
        lng = '$currentlng';
        _locationObtained = true;
      });

      if (_showingLocationDialog && mounted) {
        Navigator.of(context).pop();
        _showingLocationDialog = false;
      }
    } on TimeoutException {
      debugPrint('Location timeout');
      throw Exception('Location request timed out');
    } catch (e) {
      debugPrint('Location error: $e');
      currentlat = 0.0;
      currentlng = 0.0;
      throw Exception('Failed to get location');
    }
  }

  Future<void> initDeviceId() async {
    try {
      deviceid = await _mobileDeviceIdentifierPlugin.getDeviceId() ??
          'Unknown platform version';
      String base64String = base64Encode(utf8.encode(deviceid));
      deviceid = base64String;
    } on PlatformException {
      deviceid = 'Failed to get platform version.';
    }
  }

  Future<void> _loadUserData({bool forceOnline = false}) async {
    try {
      // Don't proceed without location
      if (!_locationObtained) {
        debugPrint('Cannot load user data without location');
        return;
      }

      bool useOnlineData = _hasInternetConnection || forceOnline;

      if (useOnlineData) {
        setState(() {
          _apiCallInProgress = true;
        });

        final result = await _fetchUserDataWithRetry();

        setState(() {
          _apiCallInProgress = false;
        });

        if (result['status'] == 'success') {
          setState(() {
            _usingCachedData = false;
          });
          return;
        }

        // Only fall back to cached data if we have no internet connection
        if (!_hasInternetConnection && userBox.isNotEmpty) {
          _loadCachedData();
          return;
        }
      }

      // If we're here, either:
      // 1. We have no internet and no cached data
      // 2. The API call failed and we have no cached data
      // 3. We're forcing online check and it failed
      if (userBox.isNotEmpty) {
        _loadCachedData();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
      setState(() {
        _apiCallInProgress = false;
      });

      if (userBox.isNotEmpty) {
        _loadCachedData();
      } else {
        _navigateToLogin();
      }
    }
  }

  Future<Map<String, dynamic>> _fetchUserDataWithRetry() async {
    int retries = 0;
    const maxRetries = 3;

    while (retries < maxRetries) {
      try {
        final result =
            await getUserDetailsByDeviceId(currentlat ?? 0.0, currentlng ?? 0.0)
                .timeout(const Duration(seconds: 15));

        if (result['status'] == 'success') {
          return result;
        }

        if (_hasInternetConnection && retries < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 1));
          retries++;
          continue;
        }

        return result;
      } on TimeoutException catch (_) {
        retries++;
        if (retries < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        return {'status': 'error', 'message': 'Request timed out'};
      } catch (e) {
        retries++;
        if (retries < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        return {'status': 'error', 'error': e.toString()};
      }
    }

    return {'status': 'error', 'message': 'Max retries reached'};
  }

  Future<Map<String, dynamic>> getUserDetailsByDeviceId(
      double latitude, double longitude) async {
    String apiUrl = '${Constants.BASE_URL}/api/App/GetUserDetailsByDeviceId';

    // Validate coordinates
    if (latitude == 0.0 || longitude == 0.0) {
      debugPrint('Invalid coordinates provided');
      return {
        'status': 'error',
        'message': 'Invalid device location coordinates'
      };
    }

    Map<String, dynamic> requestBody = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      "lat": latitude,
      "lng": longitude
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '6XesrAM2Nu',
    };

    try {
      debugPrint('API Request: $apiUrl');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Validate response structure
        if (responseData is! Map<String, dynamic>) {
          throw FormatException('Invalid API response format');
        }

        final message = responseData["Message"]?.toString() ?? '';
        final statusCode = responseData['Status']?.toString() ?? '';
        final resp = responseData["Data"] is Map ? responseData["Data"] : null;

        // Handle different response scenarios
        if (resp != null) {
          // Validate required fields
          if (resp["UserId"] == null || resp["RoleName"] == null) {
            return {
              'status': 'error',
              'message': 'Required user data missing from response'
            };
          }

          await _saveDataToHive(resp, resp['lstDealershipDetails'] ?? []);
          _updateGlobalVariables(resp);
          _navigateBasedOnRole();

          return {'status': 'success', 'data': resp, 'message': message};
        }

        // Handle specific error messages
        if (message == 'User not exist!' || message == 'Date not matched') {
          if (message == 'Date not matched') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          Navigator.pop(context);
                          _navigateToLogin();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            });
          }
          return {'status': 'error', 'message': message};
        }

        return {
          'status': 'error',
          'message': message.isNotEmpty ? message : 'Unknown error occurred'
        };
      } else {
        debugPrint('API request failed with status: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'API request failed with status ${response.statusCode}'
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('API timeout: $e');
      return {
        'status': 'error',
        'message': 'Request timed out. Please check your connection.'
      };
    } on http.ClientException catch (e) {
      debugPrint('HTTP client error: $e');
      return {
        'status': 'error',
        'message': 'Network error. Please check your internet connection.'
      };
    } on FormatException catch (e) {
      debugPrint('JSON parsing error: $e');
      return {
        'status': 'error',
        'message': 'Data format error. Please try again later.'
      };
    } catch (e) {
      debugPrint('Unexpected error in getUserDetailsByDeviceId: $e');
      return {
        'status': 'error',
        'message': 'An unexpected error occurred. Please try again.'
      };
    }
  }

  void _updateGlobalVariables(Map<String, dynamic> resp) {
    name = resp["Name"]?.toString() ?? '';
    role = resp["RoleName"]?.toString() ?? '';
    userPhone = resp["PhoneNumber"]?.toString() ?? '';
    employeeDesination = resp["EmployeeDesignation"].toString();
    userEmail = resp["Email"]?.toString() ?? '';
    userid = resp["UserId"]?.toString() ?? '';
    userImage = resp["Image"]?.toString() ?? '';
    StartShift = resp["ShiftTimeStart"]?.toString() ?? '';
    EndShift = resp["ShiftTimeEnd"]?.toString() ?? '';
    IsMarkAttendance = resp["IsMarkAttendance"]?.toString() ?? '';
    isPresent = resp['IsPresent']?.toString() ?? '';
    PresentTime = resp['PresentTime']?.toString() ?? '';

    // For boolean values
    IsMobileDeviceRegister = resp['IsMobileDeviceRegister'] == true;
    IsDistCompForAtten = resp['IsDistCompForAtten'] == true;
    IsLogedIn = resp['IsLogedIn'] == true;
    IsAvailableForMobile = resp['IsAvailableForMobile'] == true;

    // For dealership information
    dealershipInformation = resp['lstDealershipDetails'] is List
        ? List<dynamic>.from(resp['lstDealershipDetails'])
        : [];

    if (dealershipInformation.isNotEmpty) {
      var firstDealership = dealershipInformation[0];
      distanceInMeters =
          (firstDealership['DistanceInMeters'] as num?)?.toDouble() ?? 0.0;
      for (var dealership in dealershipInformation) {
        dealershipID = dealership['DealershipId']?.toString();
      }
    }
  }

  Future<void> _saveDataToHive(
      Map<String, dynamic> userData, List<dynamic> dealershipData) async {
    try {
      await userBox.putAll({
        'name': userData["Name"].toString(),
        'role': userData["RoleName"].toString(),
        'userPhone': userData["PhoneNumber"].toString(),
        'userEmail': userData["Email"].toString(),
        'userid': userData["UserId"].toString(),
        'userImage': userData["Image"].toString(),
        'StartShift': userData["ShiftTimeStart"].toString(),
        'EndShift': userData["ShiftTimeEnd"].toString(),
        'IsMarkAttendance': userData["IsMarkAttendance"].toString(),
        'isPresent': userData['IsPresent']?.toString() ?? 'null',
        'PresentTime': userData['PresentTime'] ?? 'null',
        'IsMobileDeviceRegister': userData['IsMobileDeviceRegister'],
        'IsDistCompForAtten': userData['IsDistCompForAtten'],
        'IsLogedIn': userData['IsLogedIn'],
        'IsAvailableForMobile': userData['IsAvailableForMobile'],
      });

      await dealershipBox.put('dealershipInformation', dealershipData);
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }

  void _loadCachedData() {
    try {
      setState(() {
        _usingCachedData = true;
      });

      name = userBox.get('name', defaultValue: '');
      role = userBox.get('role', defaultValue: '');
      userPhone = userBox.get('userPhone', defaultValue: '');
      userEmail = userBox.get('userEmail', defaultValue: '');
      userid = userBox.get('userid', defaultValue: '');
      userImage = userBox.get('userImage', defaultValue: '');
      StartShift = userBox.get('StartShift', defaultValue: '');
      EndShift = userBox.get('EndShift', defaultValue: '');
      IsMarkAttendance = userBox.get('IsMarkAttendance', defaultValue: '');
      isPresent = userBox.get('isPresent', defaultValue: '');
      PresentTime = userBox.get('PresentTime', defaultValue: '');
      IsMobileDeviceRegister =
          userBox.get('IsMobileDeviceRegister', defaultValue: false);
      IsDistCompForAtten =
          userBox.get('IsDistCompForAtten', defaultValue: false);
      IsLogedIn = userBox.get('IsLogedIn', defaultValue: false);
      IsAvailableForMobile =
          userBox.get('IsAvailableForMobile', defaultValue: false);

      dealershipInformation =
          dealershipBox.get('dealershipInformation', defaultValue: []);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasInternetConnection) {
          // Fluttertoast.showToast(
          //   msg: "Online data fetch failed. Using cached data",
          //   toastLength: Toast.LENGTH_LONG,
          //   gravity: ToastGravity.TOP,
          //   timeInSecForIosWeb: 3,
          //   backgroundColor: Colors.orange,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
        } else {
          // Fluttertoast.showToast(
          //   msg: "No internet connection. Using offline data",
          //   toastLength: Toast.LENGTH_LONG,
          //   gravity: ToastGravity.TOP,
          //   timeInSecForIosWeb: 3,
          //   backgroundColor: Colors.orange,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
        }
      });

      _navigateBasedOnRole();
    } catch (e) {
      debugPrint('Error loading cached data: $e');
      _navigateToLogin();
    }
  }

  void _navigateBasedOnRole() {
    setState(() {
      _isLoading = false;
    });

    if (IsLogedIn == true) {
      if (IsAvailableForMobile == true) {
        if (IsMobileDeviceRegister == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (role == 'DSF') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (role == 'ASE') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const SuperviserDashboard()),
              );
            } else if (role == 'ASD') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ASDDashboard()),
              );
            } else if (role == 'ASM' || role == 'RSM' || role == 'ZSM') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ZSMDashboard()),
              );
            } else if (role == 'audit') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MarkAttedence()),
              );
            } else if (role == 'Distributor') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MarkAttedence()),
              );
            }
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Alert"),
                  content: const Text(
                      "Your Device is not registered to our servers."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToLogin();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: const Text(
                    "This account is not available for mobile access."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToLogin();
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        });
      }
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  void _handleInitializationError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userBox.isNotEmpty) {
        _loadCachedData();
      } else {
        _navigateToLogin();
        Fluttertoast.showToast(
          msg: "Initialization failed. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    userBox.close();
    dealershipBox.close();
    super.dispose();
  }
}
