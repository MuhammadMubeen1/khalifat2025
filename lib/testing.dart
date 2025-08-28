import 'dart:convert';

import 'package:KhilafatCola/Home/home.dart';
import 'package:KhilafatCola/ZSM/zsm_dashboard.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:panara_dialogs/panara_dialogs.dart';
import 'ASD/asd_dashboard.dart';
import 'Supervisor/sup_dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool? IsMobileDeviceRegister;
  bool? IsAvailableForMobile;
  //Internet Check
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

  //Internet Check
  // Function to get the current date and time
  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  Future<void> markLoginLogoutState() async {
    final url = Uri.parse("${Constants.BASE_URL}/api/App/MarkLoginLogoutState");

    // API Request Body
    final body = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      "isLogin": true
    };

    // API Request Headers
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "6XesrAM2Nu",
    };

    try {
      // Making POST request
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      print('Responseeseseseseses:${response.body}');
      // Checking response status
      if (response.statusCode == 200) {
        print("Success: ${response.body}");
      } else {
        print("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> loginUser() async {
  //   // API URL
  //   String url = '${Constants.BASE_URL}/api/App/Login';
  //
  //   // Request headers
  //   Map<String, String> headers = {
  //     'Authorization': '6XesrAM2Nu',
  //     'Content-Type': 'application/json',
  //   };
  //
  //   // Basic validation checks
  //   String email = _cnicController.text.trim();
  //   String password = _pinController.text.trim();
  //
  //   if (email.isEmpty) {
  //     _showErrorMessage('Email is required');
  //     return;
  //   }
  //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
  //     _showErrorMessage('Please enter a valid email address');
  //     return;
  //   }
  //   if (password.isEmpty) {
  //     _showErrorMessage('Password is required');
  //     return;
  //   }
  //   if (password.length < 6) {
  //     _showErrorMessage('Password must be at least 6 characters');
  //     return;
  //   }
  //   if (deviceid == null || deviceid.isEmpty) {
  //     _showErrorMessage('Device ID is missing');
  //     return;
  //   }
  //
  //   // Request body
  //   Map<String, dynamic> body = {
  //     'email': email,
  //     'password': password,
  //     'appDateTime': getCurrentDateTime(),
  //     'deviceId': deviceid,
  //   };
  //
  //   print('Request body: $body');
  //   print('Login screen Device ID: $deviceid');
  //
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     // Send POST request
  //     http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: json.encode(body),
  //     );
  //
  //     // Log the response
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       // Check if login is successful
  //       final String message = data['Message'];
  //       final bool isLoginSuccess = data['Data']['IsLoginSuccess'];
  //
  //       if (isLoginSuccess) {
  //         // Fetch user data
  //         name = data['Data']["Name"];
  //         role = data['Data']["RoleName"];
  //         userid = data['Data']['UserId'];
  //         userImage = data['Data']['Image'];
  //         userEmail = data['Data']['Email'];
  //         userPhone = data['Data']['PhoneNumber'];
  //         StartShift = data["Data"]["ShiftTimeStart"].toString();
  //         EndShift = data["Data"]["ShiftTimeEnd"].toString();
  //         isPresent = data['Data']['IsPresent'].toString();
  //         IsMarkAttendance = data["Data"]["IsMarkAttendance"].toString();
  //
  //         print('User Role: $role');
  //         await Future.delayed(Duration(seconds: 2));
  //
  //         // Navigate based on user role
  //         if (role == 'DSF') {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => HomeScreen()),
  //           );
  //         } else {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => SuperviserDashboard()),
  //           );
  //         }
  //       } else {
  //         _showErrorMessage(message ?? 'Login failed');
  //       }
  //     } else {
  //       _showErrorMessage('Server error: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error during login: $error');
  //     _showErrorMessage('An unexpected error occurred. Please try again.');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  //
  Future<void> loginUser() async {
    // API URL
    String url = '${Constants.BASE_URL}/api/App/Login';

    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json',
    };

    String email = _cnicController.text.trim();
    String password = _pinController.text.trim();

    if (email.isEmpty) {
      _showErrorMessage('Email is required');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorMessage('Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      _showErrorMessage('Password is required');
      return;
    }
    if (password.length < 6) {
      _showErrorMessage('Password must be at least 6 characters');
      return;
    }
    if (deviceid.isEmpty) {
      _showErrorMessage('Device ID is missing');
      return;
    }

    // Request body
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'appDateTime': getCurrentDateTime(),
      'deviceId': deviceid,
    };

    print('Request body: $body');
    print('Login screen Device ID: $deviceid');

    try {
      setState(() {
        _isLoading = true;
      });
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if login is successful
        final String message = data['Message'];
        final int statusCode = data['Status'];

        print('Statussss$statusCode');
        if (statusCode == 200) {
          final bool? isLoginSuccess = data['Data']['IsLoginSuccess'];
          if (isLoginSuccess!) {
            // Fetch user data
            name = data['Data']["Name"].toString();
            role = data['Data']["RoleName"].toString();
            userid = data['Data']['UserId'].toString();
            userImage = data['Data']['Image'].toString();
            userEmail = data['Data']['Email'].toString();
            userPhone = data['Data']['PhoneNumber'].toString();
            StartShift = data["Data"]["ShiftTimeStart"].toString();
            EndShift = data["Data"]["ShiftTimeEnd"].toString();
            isPresent = data['Data']['IsPresent'].toString();
            // IsMarkAttendance = data["Data"]["IsMarkAttendance"].toString();
            IsMobileDeviceRegister = data["Data"]["IsMobileDeviceRegister"];
            IsAvailableForMobile = data['Data']["IsAvailableForMobile"];
            print('Registered$IsMobileDeviceRegister');
            print('Mobile$IsAvailableForMobile');

            print('User Role: $role');
            await Future.delayed(const Duration(seconds: 2));

            if (IsAvailableForMobile == true) {
              // Special email that bypasses device registration check
              if (email == "ASE@KC.COM" || IsMobileDeviceRegister == true) {
                if (role == 'DSF') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } else if (role == 'ASE') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const SuperviserDashboard()),
                  );
                } else if (role == 'ASD') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ASDDashboard()),
                  );
                } else if (role == 'ASM') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ZSMDashboard()),
                  );
                } else if (role == 'RSM') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ZSMDashboard()),
                  );
                } else if (role == 'ZSM') {
                  await markLoginLogoutState();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ZSMDashboard()),
                  );
                }
              } else {
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
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              }
            } else {
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
              //     "This account is not available for mobile access.",
              //     "Close",
              //         () {},
              //     PanaraDialogType.warning);
              // _showErrorMessage('You are not eligible for the Mobile ');
              //Check for Available for Mobile
            }
          }
        } else if (statusCode == 100) {
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
                      Navigator.of(context).pop(); // Close the dialog
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
                    "Wrong Password/Email. Please verify your credentials"),
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
      } else {
        print('No Role Found');
      }
    } catch (error) {
      print('Error during login: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: const Text("Wrong email or password, please try again!"),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showModernDialog(BuildContext context, String title, String message,
      String buttonText, Function() onTapDismiss, PanaraDialogType type) {
    PanaraInfoDialog.show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onTapDismiss: () {
        Navigator.pop(context);
      },
      panaraDialogType: type,
    );
  }
  // void _showErrorMessage(String message) {
  //   // You can replace this with Fluttertoast or any other error message display logic
  //   print(message);
  //   // Fluttertoast.showToast(
  //   //   msg: message,
  //   //   toastLength: Toast.LENGTH_SHORT,
  //   //   gravity: ToastGravity.BOTTOM,
  //   //   backgroundColor: Colors.red,
  //   //   textColor: Colors.white,
  //   // );
  // }

  void _showErrorMessage(String message) {
    // You can replace this with Fluttertoast or any other error message display logic
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isObscured = true;

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
      body: !_isConnected
          ? NoInternetScreen(onRetry: _checkInitialConnection)
          : SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10, top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FadeInUp(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 15,
                                              bottom: 5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/logo.png',
                                                height: 70,
                                                width: 300,
                                                color: Colors.red,
                                              ),
                                              const Text(
                                                  'The Taste of Pakistan'),
                                              const SizedBox(
                                                height: 50,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFB71234), // A richer Coca-Cola Red
                                    Color(0xFFF02A2A), // A slightly darker red
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                // image: DecorationImage(image: AssetImage('assets/backgrounds.jpg'),fit: BoxFit.cover),

                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(60))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Please Login For Continue',
                                      style: GoogleFonts.actor(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    FadeInUp(
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      child: TextFormField(
                                        controller: _cnicController,
                                        decoration: InputDecoration(
                                          hintText: 'Please Enter Your Email',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.person,
                                            color: Colors.red,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15.0),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    FadeInUp(
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      child: TextField(
                                        obscureText: _isObscured,
                                        // keyboardType: TextInputType.number,
                                        controller: _pinController,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Please Enter Your Password',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.password,
                                            color: Colors.red,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscured
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscured =
                                                    !_isObscured; // Toggle the state to show or hide password
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15.0),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          ) // Show loader while loading
                                        : FadeInUp(
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            child: InkWell(
                                              onTap: () {
                                                // login();
                                                final cnic =
                                                    _cnicController.text;
                                                final pin = _pinController.text;
                                                if (cnic.isNotEmpty &&
                                                    pin.isNotEmpty) {
                                                  loginUser();
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Validation Error"),
                                                        content: const Text(
                                                            "Email/Password must not be empty"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: const Text(
                                                                "Close"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(
                                                  //   const SnackBar(
                                                  //       content: Text(
                                                  //           'Please enter email and password')),
                                                  // );
                                                  // Fluttertoast.showToast(
                                                  //     msg: 'Please Enter % Password',
                                                  //     toastLength: Toast.LENGTH_SHORT,
                                                  //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
                                                  //     backgroundColor: Colors.white,
                                                  //     textColor: Colors.black
                                                  // );
                                                }
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.white),
                                                child: Center(
                                                    child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      'Login',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      color: Colors.red,
                                                    )
                                                  ],
                                                )),
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
