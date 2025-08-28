import 'package:KhilafatCola/Hive/offline_order_model.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_model.dart';
import 'package:KhilafatCola/model/user_model.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'model/ProductsAdapter.dart';

// Global variables
String salesmenName = '';
String salesmId = '';
String starttime = "";
String endtime = "";
String deviceid = '';
String territoryName = '';
String shopName = '';
String shopAddress = '';
String phoneNumber = '';
String territoryCords = '';
String pinLocation = '';
String VerifiedDate = '';
int? shoptagrequests;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive with a valid path
    await Hive.initFlutter(); // Use initFlutter for Flutter apps

    // Register adapters

      Hive.registerAdapter(ShopTaggingModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(OfflineOrderAdapter());
    Hive.registerAdapter(OfflineOrderSelectedProductAdapter());
    await Hive.openBox<OfflineOrder>('offlineOrdersBox');
    await Hive.openBox('products_cache');
    await Hive.openBox('ordersBox');  
    await Hive.openBox<ShopTaggingModel>('shopTaggingBox');
    // Open boxes with proper error handling
    await Hive.openBox<UserModel>('userBox');

    print("Hive initialization successful");
  } catch (e) {
    print("Error initializing Hive: $e");
    // Handle initialization error (maybe show error screen)
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    } catch (e) {
      print("Connection check error: $e");
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    // Don't close Hive here as it will persist across app restarts
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Khilafat Drinks',
      home: Scaffold(
        body: WillPopScope(
          onWillPop: () async => false,
          child: UpgradeAlert(
               upgrader: Upgrader(
                  debugLogging: true,
                  debugDisplayAlways: false,
                  
                  languageCode: 'en',
                  messages: MyCustomUpgraderMessages(),
                  countryCode: 'EG',
                  minAppVersion: "1.0.8+25",
              ),
              child: SplashScreen()),
        ),
      ),
    );
  }
}

class MyCustomUpgraderMessages extends UpgraderMessages {

 
  String get buttonTitleUpdate => 'Update Now';
  @override
  String get prompt =>
      'A new version of the app is available. You must update to continue using the app.';
  @override
  String get title => 'Update Required';
}
