// import 'dart:convert';
// import 'package:KhilafatCola/Home/home.dart';
// import 'package:KhilafatCola/ZSM/zsm_dashboard.dart';
// import 'package:KhilafatCola/main.dart';
// import 'package:KhilafatCola/model/user_model.dart';
// import 'package:KhilafatCola/utils/NoInternetScreen.dart';
// import 'package:KhilafatCola/widgets/Splash.dart';
// import 'package:KhilafatCola/widgets/const.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:panara_dialogs/panara_dialogs.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'ASD/asd_dashboard.dart';
// import 'Supervisor/sup_dashboard.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _cnicController = TextEditingController();
//   final TextEditingController _pinController = TextEditingController();
//   bool _isLoading = false;
//   bool? IsMobileDeviceRegister;
//   bool? IsAvailableForMobile;
//   bool _isDisposed = false;

//   // Hive box for storing user data
//   late Box<UserModel> userBox;
//   late SharedPreferences _prefs;

//   //Internet Check
//   final Connectivity _connectivity = Connectivity();
//   bool _isConnected = true;

//   // Store ScaffoldMessengerState reference safely
//   ScaffoldMessengerState? _scaffoldMessenger;

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     await _initHive();
//     await _initSharedPreferences();
//     await _checkInitialConnection();
//     _listenToConnectionChanges();
//     await _checkPersistedLogin();
//   }

//   Future<void> _initHive() async {
//     if (!Hive.isAdapterRegistered(0)) {
//       Hive.registerAdapter(UserModelAdapter());
//     }
//     userBox = await Hive.openBox<UserModel>('userBox');
//   }

//   Future<void> _initSharedPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   Future<void> _checkPersistedLogin() async {
//     final isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
//     if (isLoggedIn) {
//       final email = _prefs.getString('email');
//       final password = _prefs.getString('password');
      
//       if (email != null && password != null) {
//         bool isLocalUser = await _checkLocalUser(email, password);
//         if (isLocalUser) {
//           if (mounted) {
//             _navigateBasedOnRole();
//           }
//         }
//       }
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scaffoldMessenger = ScaffoldMessenger.of(context);
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _cnicController.dispose();
//     _pinController.dispose();
//     super.dispose();
//   }

//   Future<void> _checkInitialConnection() async {
//     final result = await _connectivity.checkConnectivity();
//     if (_isDisposed) return;
//     if (mounted) {
//       setState(() {
//         _isConnected = result != ConnectivityResult.none;
//       });
//     }
//   }

//   void _listenToConnectionChanges() {
//     _connectivity.onConnectivityChanged.listen((result) {
//       if (_isDisposed || !mounted) return;
//       setState(() {
//         _isConnected = result != ConnectivityResult.none;
//       });
//     });
//   }

//   String getCurrentDateTime() {
//     final now = DateTime.now();
//     final formatter = DateFormat('yyyy-MM-dd');
//     return formatter.format(now);
//   }

//   Future<void> markLoginLogoutState() async {
//     final url = Uri.parse("${Constants.BASE_URL}/api/App/MarkLoginLogoutState");
//     final body = {
//       "deviceId": deviceid,
//       "appDateTime": getCurrentDateTime(),
//       "isLogin": true
//     };
//     final headers = {
//       "Content-Type": "application/json",
//       "Authorization": "6XesrAM2Nu",
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: json.encode(body),
//       );
//       if (response.statusCode == 200) {
//         print("Success: ${response.body}");
//       } else {
//         print("Failed: ${response.statusCode}, ${response.body}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   Future<void> _saveUserDataLocally(Map<String, dynamic> data) async {
//     try {
//       final user = UserModel(
//         userId: data['Data']['UserId'].toString(),
//         name: data['Data']["Name"].toString(),
//         role: data['Data']["RoleName"].toString(),
//         userImage: data['Data']['Image'].toString(),
//         userEmail: data['Data']['Email'].toString(),
//         userPhone: data['Data']['PhoneNumber'].toString(),
//         startShift: data["Data"]["ShiftTimeStart"].toString(),
//         endShift: data["Data"]["ShiftTimeEnd"].toString(),
//         isPresent: data['Data']['IsPresent'].toString(),
//         isMobileDeviceRegister: data["Data"]["IsMobileDeviceRegister"] ?? false,
//         isAvailableForMobile: data['Data']["IsAvailableForMobile"] ?? false,
//         email: _cnicController.text.trim(),
//         password: _pinController.text.trim(),
//       );

//       await userBox.put('currentUser', user);
      
//       // Persist login state
//       await _prefs.setBool('isLoggedIn', true);
//       await _prefs.setString('email', _cnicController.text.trim());
//       await _prefs.setString('password', _pinController.text.trim());
      
//       print("User data saved locally successfully");
//     } catch (e) {
//       print("Error saving user data locally: $e");
//     }
//   }

//   Future<bool> _checkLocalUser(String email, String password) async {
//     try {
//       if (!userBox.isOpen) {
//         await _initHive();
//       }
      
//       final user = userBox.get('currentUser');
//       if (user != null && user.email == email && user.password == password) {
//         // Set global variables from local data
//         name = user.name;
//         role = user.role;
//         userid = user.userId;
//         userImage = user.userImage;
//         userEmail = user.userEmail;
//         userPhone = user.userPhone;
//         StartShift = user.startShift;
//         EndShift = user.endShift;
//         isPresent = user.isPresent;
//         IsMobileDeviceRegister = user.isMobileDeviceRegister;
//         IsAvailableForMobile = user.isAvailableForMobile;

//         print("Local user found and validated");
//         return true;
//       }
//       print("No matching local user found");
//       return false;
//     } catch (e) {
//       print("Error checking local user: $e");
//       return false;
//     }
//   }

 
// Future<void> loginUser() async {
//     String email = _cnicController.text.trim();
//     String password = _pinController.text.trim();

//     // Basic validations
//     if (email.isEmpty) {
//       _showErrorMessage('Email is required');
//       return;
//     }
//     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
//       _showErrorMessage('Please enter a valid email address');
//       return;
//     }
//     if (password.isEmpty) {
//       _showErrorMessage('Password is required');
//       return;
//     }
//     if (password.length < 6) {
//       _showErrorMessage('Password must be at least 6 characters');
//       return;
//     }
//     if (deviceid.isEmpty) {
//       _showErrorMessage('Device ID is missing');
//       return;
//     }

//     // Offline login fallback
//     if (!_isConnected) {
//       bool isLocalUser = await _checkLocalUser(email, password);
//       if (isLocalUser) {
//         _navigateBasedOnRole();
//         return;
//       } else {
//            _showErrorMessage('No internet connection and no local user found.');
//         return;
//       }
//     }

//     // Online login
//     String url = '${Constants.BASE_URL}/api/App/Login';
//     Map<String, String> headers = {
//       'Authorization': '6XesrAM2Nu',
//       'Content-Type': 'application/json',
//     };

//     Map<String, dynamic> body = {
//       'email': email,
//       'password': password,
//       'appDateTime': getCurrentDateTime(),
//       'deviceId': deviceid,
//     };

//     try {
//       if (mounted) {
//         setState(() => _isLoading = true);
//       }

//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: json.encode(body),
//       );

//       if (_isDisposed || !mounted) return;

//       // 🌐 Log raw response for debugging
//       print('Login API response: ${response.statusCode}');
//       print('Login API body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final int statusCode = data['Status'] ?? 0;
//         final String message = data['Message'] ?? 'Unknown response';

//         if (statusCode == 200) {
//           final loginData = data['Data'] ?? {};
//           final bool isLoginSuccess = loginData['IsLoginSuccess'] ?? false;

//           if (isLoginSuccess) {
//             // Save user locally
//             await _saveUserDataLocally(data);

//             // Set globals
//             name = loginData["Name"]?.toString() ?? '';
//             role = loginData["RoleName"]?.toString() ?? '';
//             userid = loginData['UserId']?.toString() ?? '';
//             userImage = loginData['Image']?.toString() ?? '';
//             userEmail = loginData['Email']?.toString() ?? '';
//             userPhone = loginData['PhoneNumber']?.toString() ?? '';
//             StartShift = loginData["ShiftTimeStart"]?.toString() ?? '';
//             EndShift = loginData["ShiftTimeEnd"]?.toString() ?? '';
//             isPresent = loginData['IsPresent']?.toString() ?? '';
//             IsMobileDeviceRegister =
//                 loginData["IsMobileDeviceRegister"] ?? false;
//             IsAvailableForMobile = loginData["IsAvailableForMobile"] ?? false;

//             print("Login successful. Navigating to dashboard...");
//             await Future.delayed(const Duration(seconds: 2));

//             if (!_isDisposed && mounted) {
//               _navigateBasedOnRole();
//             }
//           } else {
//                _showErrorMessage('Login failed. Please verify your credentials.');
//           }
//         } else if (statusCode == 100) {
//             _showErrorMessage('Your device date is not synced with the server.');
//         } else {
//              _showErrorMessage(message);
//         }
//       } else {
//           _showErrorMessage(
//             'Login failed. Server returned status ${response.statusCode}.');
//       }
//     } catch (error, stack) {
//       print('❌ Login exception: $error');
//       print('🪵 Stacktrace: $stack');
//       if (!_isDisposed && mounted) {
//           _showErrorMessage('An error occurred. Please try again.');
//       }
//     } finally {
//       if (!_isDisposed && mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _navigateBasedOnRole() {
//     if (IsAvailableForMobile == true) {
//       if (IsMobileDeviceRegister == true) {
//         Widget destination;
//         switch (role) {
//           case 'DSF':
//             destination = const HomeScreen();
//             break;
//           case 'ASE':
//             destination = const SuperviserDashboard();
//             break;
//           case 'ASD':
//             destination = const ASDDashboard();
//             break;
//           case 'ASM':
//           case 'RSM':
//           case 'ZSM':
//             destination = const ZSMDashboard();
//             break;
//           default:
//             _showErrorMessage('Unknown role: $role');
//             return;
//         }

//         markLoginLogoutState().then((_) {
//           if (!_isDisposed && mounted) {
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (context) => destination),
//               (Route<dynamic> route) => false,
//             );
//           }
//         });
//       } else {
   
//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (BuildContext context) {
//               return Align(
//                 alignment: Alignment.topCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 50), // Top position
//                   child: Material(
//                     color: Colors.transparent,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Text(
//                             "Alert",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             "Your Device is not registered to our servers.",
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context).pop();
                             
//                             },
//                             child: const Text("Close"),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
        

//       }
//     } else {
//       _showErrorMessage('This account is not available for mobile access.');
//     }
//   }

//   void _showErrorMessage(String message) {
//     if (!_isDisposed && mounted && _scaffoldMessenger != null) {
//       try {
//         _scaffoldMessenger!.showSnackBar(
//           SnackBar(
//             content: Text(message),
//             duration: const Duration(seconds: 3),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } catch (e) {
//         print('Error showing snackbar: $e');
//       }
//     }
//   }

//   bool _isObscured = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Container(
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           left: 10, right: 10, bottom: 10, top: 5),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               FadeInUp(
//                                   duration: const Duration(milliseconds: 1000),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 10,
//                                         right: 10,
//                                         top: 15,
//                                         bottom: 5),
//                                     child: Column(
//                                       children: [
//                                         Image.asset(
//                                           'assets/images/logo.png',
//                                           height: 70,
//                                           width: 300,
//                                           color: Colors.red,
//                                         ),
//                                         const Text('The Taste of Pakistan'),
//                                         const SizedBox(height: 50),
//                                       ],
//                                     ),
//                                   )),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Color(0xFFB71234),
//                               Color(0xFFF02A2A),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(60),
//                               topRight: Radius.circular(60))),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: <Widget>[
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Please Login For Continue',
//                                 style: GoogleFonts.actor(
//                                     color: Colors.white, fontSize: 22),
//                               ),
//                               const SizedBox(height: 30),
//                               FadeInUp(
//                                 duration: const Duration(milliseconds: 1500),
//                                 child: TextFormField(
//                                   controller: _cnicController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Please Enter Your Email',
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey[500],
//                                       fontSize: 16,
//                                     ),
//                                     prefixIcon: const Icon(
//                                       Icons.person,
//                                       color: Colors.red,
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(30.0),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 15.0),
//                                   ),
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 30),
//                               FadeInUp(
//                                 duration: const Duration(milliseconds: 1500),
//                                 child: TextField(
//                                   obscureText: _isObscured,
//                                   controller: _pinController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Please Enter Your Password',
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey[500],
//                                       fontSize: 16,
//                                     ),
//                                     prefixIcon: const Icon(
//                                       Icons.password,
//                                       color: Colors.red,
//                                     ),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         _isObscured
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                         color: Colors.red,
//                                       ),
//                                       onPressed: () {
//                                         if (mounted) {
//                                           setState(() {
//                                             _isObscured = !_isObscured;
//                                           });
//                                         }
//                                       },
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(30.0),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 15.0),
//                                   ),
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 30),
//                               _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : FadeInUp(
//                                       duration:
//                                           const Duration(milliseconds: 1500),
//                                       child: InkWell(
//                                         onTap: () {
//                                           final cnic = _cnicController.text;
//                                           final pin = _pinController.text;
//                                           if (cnic.isNotEmpty &&
//                                               pin.isNotEmpty) {
//                                             loginUser();
//                                           } else {
//                                             _showErrorMessage(
//                                                 "Email/Password must not be empty");
//                                           }
//                                         },
//                                         child: Container(
//                                           height: 50,
//                                           width: 200,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(30),
//                                               color: Colors.white),
//                                           child: const Center(
//                                               child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               Text(
//                                                 'Login',
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 16),
//                                               ),
//                                               Icon(
//                                                 Icons.arrow_forward,
//                                                 color: Colors.red,
//                                               )
//                                             ],
//                                           )),
//                                         ),
//                                       ),
//                                     )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'package:KhilafatCola/Home/home.dart';
import 'package:KhilafatCola/MarkAttendence/attendence.dart';
import 'package:KhilafatCola/ZSM/zsm_dashboard.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/model/user_model.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ASD/asd_dashboard.dart';
import 'Supervisor/sup_dashboard.dart';

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
  bool _isDisposed = false;

  // Hive box for storing user data
  late Box<UserModel> userBox;
  late SharedPreferences _prefs;

  //Internet Check
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  // Store ScaffoldMessengerState reference safely
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initHive();
    await _initSharedPreferences();
    await _checkInitialConnection();
    _listenToConnectionChanges();
    await _checkPersistedLogin();
  }

  Future<void> _initHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    userBox = await Hive.openBox<UserModel>('userBox');
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _checkPersistedLogin() async {
    try {
      final isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        final email = _prefs.getString('email');
        final password = _prefs.getString('password');

        if (email != null && password != null) {
          bool isLocalUser = await _checkLocalUser(email, password);
          if (isLocalUser && mounted) {
            _navigateBasedOnRole();
          } else {
            await _clearPersistedLogin();
          }
        } else {
          await _clearPersistedLogin();
        }
      }
    } catch (e) {
      print("Error checking persisted login: $e");
      await _clearPersistedLogin();
    }
  }


  // In LoginScreen class
  Future<void> _clearPersistedLogin() async {
    try {
      await _prefs.remove('isLoggedIn');
      await _prefs.remove('email');
      await _prefs.remove('password');
      print("Persisted login data cleared");
    } catch (e) {
      print("Error clearing persisted login: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cnicController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    if (_isDisposed) return;
    if (mounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  Future<void> markLoginLogoutState() async {
    final url = Uri.parse("${Constants.BASE_URL}/api/App/MarkLoginLogoutState");
    final body = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      "isLogin": true
    };
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "6XesrAM2Nu",
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        print("Success: ${response.body}");
      } else {
        print("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _saveUserDataLocally(Map<String, dynamic> data) async {
    try {
      final user = UserModel(
        userId: data['Data']['UserId'].toString(),
        name: data['Data']["Name"].toString(),
        role: data['Data']["RoleName"].toString(),
        userImage: data['Data']['Image'].toString(),
        userEmail: data['Data']['Email'].toString(),
        userPhone: data['Data']['PhoneNumber'].toString(),
        startShift: data["Data"]["ShiftTimeStart"].toString(),
        endShift: data["Data"]["ShiftTimeEnd"].toString(),
        isPresent: data['Data']['IsPresent'].toString(),
        isMobileDeviceRegister: data["Data"]["IsMobileDeviceRegister"] ?? false,
        isAvailableForMobile: data['Data']["IsAvailableForMobile"] ?? false,
        email: _cnicController.text.trim(),
        password: _pinController.text.trim(),
      );

      await userBox.put('currentUser', user);

      // Persist login state
      await _prefs.setBool('isLoggedIn', true);
      await _prefs.setString('email', _cnicController.text.trim());
      await _prefs.setString('password', _pinController.text.trim());

      print("User data saved locally successfully");
    } catch (e) {
      print("Error saving user data locally: $e");
    }
  }

  Future<bool> _checkLocalUser(String email, String password) async {
    try {
      if (!userBox.isOpen) {
        await _initHive();
      }

      final user = userBox.get('currentUser');
      if (user != null && user.email == email && user.password == password) {
        // Set global variables from local data
        name = user.name;
        role = user.role;
        userid = user.userId;
        userImage = user.userImage;
        userEmail = user.userEmail;
        userPhone = user.userPhone;
        StartShift = user.startShift;
        EndShift = user.endShift;
        isPresent = user.isPresent;
        IsMobileDeviceRegister = user.isMobileDeviceRegister;
        IsAvailableForMobile = user.isAvailableForMobile;

        print("Local user found and validated");
        return true;
      }
      print("No matching local user found");
      return false;
    } catch (e) {
      print("Error checking local user: $e");
      return false;
    }
  }

  Future<void> loginUser() async {
    String email = _cnicController.text.trim();
    String password = _pinController.text.trim();

    // Basic validations
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

    // Convert email to uppercase for case-insensitive comparison
    String normalizedEmail = email.toUpperCase();

    // Offline login fallback
    if (!_isConnected) {
      bool isLocalUser = await _checkLocalUser(email, password);
      if (isLocalUser) {
        _navigateBasedOnRole();
        return;
      } else {
        _showErrorMessage('No internet connection and no local user found.');
        return;
      }
    }

    // Online login
    String url = '${Constants.BASE_URL}/api/App/Login';
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'appDateTime': getCurrentDateTime(),
      'deviceId': deviceid,
    };

    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (_isDisposed || !mounted) return;

      print('Login API response: ${response.statusCode}');
      print('Login API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int statusCode = data['Status'] ?? 0;
        final String message = data['Message'] ?? 'Unknown response';

        if (statusCode == 200) {
          final loginData = data['Data'] ?? {};
          final bool isLoginSuccess = loginData['IsLoginSuccess'] ?? false;

          if (isLoginSuccess) {
            // Save user locally
            await _saveUserDataLocally(data);

            // Set globals
            name = loginData["Name"]?.toString() ?? '';
            role = loginData["RoleName"]?.toString() ?? '';
            userid = loginData['UserId']?.toString() ?? '';
            userImage = loginData['Image']?.toString() ?? '';
            userEmail = loginData['Email']?.toString() ?? '';
            userPhone = loginData['PhoneNumber']?.toString() ?? '';
            StartShift = loginData["ShiftTimeStart"]?.toString() ?? '';
            EndShift = loginData["ShiftTimeEnd"]?.toString() ?? '';
            isPresent = loginData['IsPresent']?.toString() ?? '';
            IsMobileDeviceRegister =
                loginData["IsMobileDeviceRegister"] ?? false;
            IsAvailableForMobile = loginData["IsAvailableForMobile"] ?? false;

            print("Login successful. Navigating to dashboard...");
            await Future.delayed(const Duration(seconds: 2));

            if (!_isDisposed && mounted) {
              // Special case for ASE@KC.COM - bypass device registration check
              if (normalizedEmail == "ASE@KC.COM") {
                IsMobileDeviceRegister = true;
                IsAvailableForMobile = true;
              }
              _navigateBasedOnRole();
            }
          } else {
            _showErrorMessage('Login failed. Please verify your credentials.');
          }
        } else if (statusCode == 100) {
          _showErrorMessage('Your device date is not synced with the server.');
        } else {
          _showErrorMessage(message);
        }
      } else {
        _showErrorMessage(
            'Login failed. Server returned status ${response.statusCode}.');
      }
    } catch (error, stack) {
      print('❌ Login exception: $error');
      print('🪵 Stacktrace: $stack');
      if (!_isDisposed && mounted) {
        _showErrorMessage('An error occurred. Please try again.');
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateBasedOnRole() {
    if (IsAvailableForMobile == true) {
      // Special email that bypasses device registration check
      String normalizedEmail = _cnicController.text.trim().toUpperCase();
      if (normalizedEmail == "ASE@KC.COM" || IsMobileDeviceRegister == true) {
        Widget destination;
        switch (role) {
          case 'DSF':
            destination = const HomeScreen();
            break;
          case 'ASE':
            destination = const SuperviserDashboard();
            break;
          case 'ASD':
            destination = const ASDDashboard();
            break;
          case 'audit':
            destination = const MarkAttedence();
            break;
          case 'Distributor':
            destination = const MarkAttedence();
            break;

          case 'ASM':
          case 'RSM':
          case 'ZSM':
            destination = const ZSMDashboard();
            break;
          default:
            _showErrorMessage('Unknown role: $role');
            return;
        }

        markLoginLogoutState().then((_) {
          if (!_isDisposed && mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => destination),
              (Route<dynamic> route) => false,
            );
          }
        });
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const  [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Alert",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your Device is not registered to our servers.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    } else {
      _showErrorMessage('This account is not available for mobile access.');
    }
  }

  void _showErrorMessage(String message) {
    if (!_isDisposed && mounted && _scaffoldMessenger != null) {
      try {
        _scaffoldMessenger!.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print('Error showing snackbar: $e');
      }
    }
  }

  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
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
                                        const Text('The Taste of Pakistan'),
                                        const SizedBox(height: 50),
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
                              Color(0xFFB71234),
                              Color(0xFFF02A2A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60))),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              Text(
                                'Please Login For Continue',
                                style: GoogleFonts.actor(
                                    color: Colors.white, fontSize: 22),
                              ),
                              const SizedBox(height: 30),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1500),
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
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1500),
                                child: TextField(
                                  obscureText: _isObscured,
                                  controller: _pinController,
                                  decoration: InputDecoration(
                                    hintText: 'Please Enter Your Password',
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
                                        if (mounted) {
                                          setState(() {
                                            _isObscured = !_isObscured;
                                          });
                                        }
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : FadeInUp(
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      child: InkWell(
                                        onTap: () {
                                          final cnic = _cnicController.text;
                                          final pin = _pinController.text;
                                          if (cnic.isNotEmpty &&
                                              pin.isNotEmpty) {
                                            loginUser();
                                          } else {
                                            _showErrorMessage(
                                                "Email/Password must not be empty");
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 200,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white),
                                          child: const Center(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
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
