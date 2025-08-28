import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

const baseurl = 'http://kcapiqa.fscscampus.com/';
String getCurrentDateTime() {
  final now = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(now);
}

double? currentlat;
double? currentlng;

String convertTo12HourFormatt(String time) {
  try {
    final parsedTime = DateFormat('HH:mm').parse(time); // Parse 24-hour time
    return DateFormat('hh:mm a').format(parsedTime); // Format to 12-hour
  } catch (e) {
    return 'N/A'; // Return 'N/A' in case of any parsing error
  }
}

final Connectivity _connectivity = Connectivity();
bool _isConnected = true;
Future<void> _checkInitialConnection() async {
  final result = await _connectivity.checkConnectivity();

  _isConnected = result != ConnectivityResult.none;
}

void _listenToConnectionChanges() {
  _connectivity.onConnectivityChanged.listen((result) {
    // setState(() {
    //
    // });
    _isConnected = result != ConnectivityResult.none;
  });
}

String convertTo12HourFormat(String isoDateString) {
  // Parse the ISO 8601 date string into a DateTime object
  DateTime dateTime = DateTime.parse(isoDateString);

  // Format the DateTime object into a 12-hour format
  String formattedDate = DateFormat('hh:mm a, MMMM d, y').format(dateTime);

  return formattedDate;
}

/////////////////////// DSF //////////////////////////

/////////////////////// DSF //////////////////////////

///////////////////////Superviser Gohar ///////////////////
int? shopId;

///////////////////////Superviser Gohar ///////////////////

