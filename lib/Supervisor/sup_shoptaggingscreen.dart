import 'dart:async';
import 'dart:convert';

import 'package:KhilafatCola/Supervisor/sup_LocationScreen.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../main.dart';
import 'sup_shopslocation.dart';

class ShopTaggingRequestScreen extends StatefulWidget {
  const ShopTaggingRequestScreen({super.key});

  @override
  _ShopTaggingRequestScreenState createState() =>
      _ShopTaggingRequestScreenState();
}

class _ShopTaggingRequestScreenState extends State<ShopTaggingRequestScreen> {
  List<Map<String, dynamic>> newRequests = [];
  List<Map<String, dynamic>> confirmedRequests = [];
  List<Map<String, dynamic>> RejectedRequests = [];
  List<Map<String, dynamic>> ProductiveRequests = [];
  List<Map<String, dynamic>> NonProductiveRequests = [];
  bool isLoading = false;
  final bool _loading = false;
  final bool _isLoading = false;
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  late String shopPin;
  List<LatLng> pinLocations = [];
  List<String> TerritoryNames = [];
  List<String> ShopNames = [];
  List<String> Addresss = [];
  List<String> PhoneNos = [];
  bool isVerified = true;
  Timer? _timer;

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

  @override
  void initState() {
    _checkInitialConnection();
    _listenToConnectionChanges();

    isLoading = false;
    saveShopDetails(shopName, shopAddress, territoryName, phoneNumber);
    fetchShopTaggingData();
    confirmShopTaggingData();
    rejectedShopTaggingData();
    productiveShopTaggingData();
    nonproductiveShopTaggingData();
    refreshData();
    super.initState();
    // startAutoRefresh();
  }

  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      fetchShopTaggingData();
      confirmShopTaggingData();
      rejectedShopTaggingData();
      productiveShopTaggingData();
      nonproductiveShopTaggingData(); // Call the API every 5 seconds
    });
  }

  void saveShopDetails(
      String shopName, String address, String territoryName, String phoneNo) {
    // Create a string to store the details

    // Add the details to the list
    ShopNames.add(shopName);
    Addresss.add(address);
    TerritoryNames.add(territoryName);
    PhoneNos.add(phoneNo);

    print('Shop Names : $ShopNames');
    print('Address : $Addresss');
    print('Territory Names : $Addresss');
    print('Phone Number : $PhoneNos');
  }

  void savePinLocations(String pinLocation) {
    // Decode the JSON string
    Map<String, dynamic> pinLocationMap = jsonDecode(pinLocation);

    LatLng pinLatLng = LatLng(pinLocationMap['lat'], pinLocationMap['lng']);

    pinLocations.add(pinLatLng);

    print('Saved Shop Location: $pinLocations');
  }

  void refreshData() {
    fetchShopTaggingData();
    confirmShopTaggingData();
    rejectedShopTaggingData();
    productiveShopTaggingData();
    nonproductiveShopTaggingData();
    setState(() {
      // This will call the FutureBuilders to re-fetch data
    });
  }

 Future<void> fetchShopTaggingData() async {
  setState(() {
    isLoading = true;
  });

  String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/GetShopTaggingForVerificatiionBySupID';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '6XesrAM2Nu',
      },
      body: jsonEncode({
        'userId': userid,
        'appDateTime': getCurrentDateTime(),
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['Data'] != null) {
        List<dynamic> requests = jsonResponse['Data'];
        setState(() {
          newRequests = List<Map<String, dynamic>>.from(requests);
        });
      } else {
        print('No new requests found in the API response.');
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data when this screen is shown
    refreshData();
  }

Future<void> confirmShopTaggingData() async {
  setState(() {
    isLoading = true;
  });

  String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/GetConfirmTerritoryShopByUserID';

  // Define the request body
  final Map<String, dynamic> body = {
    "userId": userid,
    "appDateTime": getCurrentDateTime(),
  };

  // Debug: Print request details
  print('API URL: $apiUrl');
  print('Headers: ${{
    'Content-Type': 'application/json',
    'Authorization': '6XesrAM2Nu',
  }}');
  print('Body: ${jsonEncode(body)}');

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '6XesrAM2Nu',
      },
      body: jsonEncode(body),
    );

    // Debug: Print response details
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Responasse body: ${response.body}');

    if (response.statusCode == 200) {
      await Future.delayed(const Duration(seconds: 3));

      // Assuming the API returns a map with a key 'data' containing a list of requests
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['Data'] != null) {
        List<dynamic> requests = jsonResponse['Data'];
        setState(() {
          confirmedRequests = List<Map<String, dynamic>>.from(requests);
        });
      } else {
        print('No new requests found in the API response.');
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
      // Optionally handle HTML error response
      if (response.body.contains('<html>')) {
        print('Received an HTML error page. Check the API URL and authorization.');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> rejectedShopTaggingData() async {
    setState(() {
      isLoading = true;
    });
    String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/GetRejectedVerifyStatusByUserID';
    final Map<String, dynamic> body = {
      "userId": userid,
      "appDateTime": getCurrentDateTime()
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a map with a key 'data' containing a list of requests
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            RejectedRequests = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> productiveShopTaggingData() async {
    setState(() {
      isLoading = true;
    });
    String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/GetProductiveTerritoryShopByUserID';
    final Map<String, dynamic> body = {
      "userId": userid,
      "appDateTime": getCurrentDateTime()
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a map with a key 'data' containing a list of requests
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            ProductiveRequests = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> nonproductiveShopTaggingData() async {
    setState(() {
      isLoading = true;
    });
    String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/GetNonProductiveTerritoryShopByUserID';
    final Map<String, dynamic> body = {
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a map with a key 'data' containing a list of requests
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            NonProductiveRequests = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateConfirmShopTaggingData(int id) async {
    setState(() {
      isLoading = true;
    });
    String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/UpdateUVShopVerificationStatus';
    final Map<String, dynamic> body = {
      "userId": userid,
      "ShopId": id,
      "IsVerified": true,
      "appDateTime": getCurrentDateTime(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a map with a key 'data' containing a list of requests
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];

          setState(() {
            confirmedRequests = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failewwwd to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRejectedShopTaggingData(int id) async {
    setState(() {
      isLoading = true;
    });
    String apiUrl = 'http://kcapiqa.fscscampus.com/api/App/UpdateUVShopVerificationStatus';
    final Map<String, dynamic> body = {
      "userId": userid,
      "ShopId": id,
      "IsVerified": false,
      "appDateTime": getCurrentDateTime(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a map with a key 'data' containing a list of requests
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            confirmedRequests = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? getLat(String? pinLocation) {
    if (pinLocation != null && pinLocation.isNotEmpty) {
      var decoded = jsonDecode(pinLocation);
      return decoded['lat'].toString(); // Access 'lat'
    }
    return 'N/A';
  }

  String? getLng(String? pinLocation) {
    if (pinLocation != null && pinLocation.isNotEmpty) {
      var decoded = jsonDecode(pinLocation);
      return decoded['lng'].toString(); // Access 'lng'
    }
    return 'N/A';
  }

  String convertIsoToNormalFormat(String isoDateString) {
    // Parse the ISO 8601 date string into a DateTime object
    DateTime dateTime = DateTime.parse(isoDateString);

    // Format the DateTime object into a user-friendly format
    String formattedDate = DateFormat('MMMM d, y hh:mm a').format(dateTime);

    return formattedDate;
  }

  String convertTo12HourFormat(String time) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time); // Parse 24-hour time
      return DateFormat('hh:mm a').format(parsedTime); // Format to 12-hour
    } catch (e) {
      return 'N/A'; // Return 'N/A' in case of any parsing error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.redAccent,
          title: const Text('Shop Tagging Request',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 22,
            ),
          ),
          bottom: TabBar(
          labelStyle:  TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(color: Colors.grey.shade200),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'New Requests'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Rejected'),
              Tab(text: 'Productive'),
              Tab(text: 'Non Productive'),
            ],
          ),
        ),
        body: 
        // !_isConnected
        //     ? NoInternetScreen(onRetry: _checkInitialConnection)
        //     : isLoading
        //         ?
                
                //  const Center(child: CircularProgressIndicator())
                // : 
                TabBarView(
                    children: [
                      _buildRequestList(newRequests,
                          'No pending requests found', false, false),
                      _buildRequestList(confirmedRequests,
                          'No confirmed requests found', true, true),
                      _buildRequestList(RejectedRequests,
                          'No rejected requests found', true, false),
                      _buildRequestList(ProductiveRequests,
                          'No productive requests found', true, false),
                      _buildRequestList(NonProductiveRequests,
                          'No non-productive requests found', true, false),
                    ],
                  ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed,
      required bool isLoading}) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white),),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests,
      String emptyMessage, bool isConfirmedTab, bool isVerified) {
    return requests.isNotEmpty
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (requests.isNotEmpty) {
                        savePinLocations(pinLocationss);
                        //String pinLocation = requests.first['PinLocation'];
                        showAllShops(context, coords, pinLocationss);
                      }
                    },
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: const Text('Shops Location',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              // Display total number of items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Total Record: ${requests.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Expanded ListView for the shop requests
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    pinLocationss = request['PinLocation'];
                    coords = request['TerritoryCoordinates'];
                    savePinLocations(pinLocationss);
                    String territoryName = request['TerritoryName'];
                    shopName = request['ShopName'];
                    shopAddress = request['Address'];
                    String phoneNumber = request['PhoneNo'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                onTap: () {
                                  print(
                                      'ID ${request['Id'] ?? 'Unknown Shop'}');
                                },
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                Container(
  height: 80,
  width: 80,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: request['ImageName'] != null &&
                                                request['ImageName'].isNotEmpty
                                            ? (request['ImageName']
                                                    .startsWith('data:image')
                                                ? Image.memory(
                                                    base64Decode(
                                                        request['ImageName']
                                                            .split(',')
                                                            .last),
                                                    // fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        '${request['ImageName']}',
                                                    // fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                         const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              color: Colors
                                                                  .redAccent),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ))
                                            : const Icon(Icons
                                                .error), // fallback if image is null or empty
                                      ),

),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request['ShopName'] ??
                                                'Unknown Shop',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Owner: ${request['OwnerName'] ?? 'Unknown'}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Phone: ${request['PhoneNo'] ?? 'N/A'}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Tooltip(
                                            message:
                                                request['Address'] ?? 'N/A',
                                            child: Text(
                                              'Address: ${request['Address'] ?? 'N/A'}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green[700]),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Hours: ${convertTo12HourFormat(request['OpeningTime'] ?? 'N/A')}-${convertTo12HourFormat(request['ClosingTime'] ?? 'N/A')}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Created By: ${request['CreatedByName'] ?? 'N/A'}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[300], thickness: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!isConfirmedTab) ...[
                                      _buildActionButton(
                                        context,
                                        icon: Icons.check,
                                        label: isLoading
                                            ? 'Loading...'
                                            : 'Confirm',
                                        color: Colors.green,
                                        onPressed: () async {
                                          bool isConfirmed = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Action'),
                                                content: const Text(
                                                    'Are you sure you want to confirm?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (isConfirmed) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            await updateConfirmShopTaggingData(
                                                request['Id']);
                                            refreshData();
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        isLoading: isLoading,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildActionButton(
                                        context,
                                        icon: Icons.cancel,
                                        label:
                                            isLoading ? 'Loading...' : 'Reject',
                                        color: Colors.redAccent,
                                        onPressed: () async {
                                          bool isConfirmed = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Action'),
                                                content: const Text(
                                                    'Are you sure you want to reject?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: const Text('Reject'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (isConfirmed) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            await updateRejectedShopTaggingData(
                                                request['Id']);
                                            refreshData();
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        isLoading: isLoading,
                                      ),
                                    ],
                                    const SizedBox(width: 3),
                                    IconButton(
                                      onPressed: () {
                                        navigateToLocationScreen(
                                            context,
                                            request['TerritoryCoordinates'],
                                            request['PinLocation']);
                                        print('Location button pressed');
                                      },
                                      icon: const Icon(Icons.pin_drop,
                                          color: Colors.redAccent),
                                      tooltip: 'Location',
                                      color: Colors.blueAccent,
                                      iconSize: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text(
                    "No Data Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
            },
          );
  }

  // Placeholder lists for other tabs
  Widget _buildPlaceholderList(String message) {
    return Center(
      child: Text(message),
    );
  }

  // Function to parse the JSON string and return a list of LatLng objects
  List<LatLng> getLatLngCoordinates(String territoryCoordinates) {
    List<dynamic> coordinatesList = jsonDecode(territoryCoordinates);

    // Convert the list of coordinates into a list of LatLng objects
    List<LatLng> latLngList = coordinatesList.map((coord) {
      return LatLng(coord['lat'], coord['lng']);
    }).toList();
    latLngList.add(latLngList[0]);

    print('Lattitude Long : $latLngList');

    return latLngList;
  }

  void navigateToLocationScreen(
      BuildContext context, String territoryCoordinates, String pinLocation) {
    // Parse the territory coordinates
    List<LatLng> coordinates = getLatLngCoordinates(territoryCoordinates);

    // Parse the pin location
    Map<String, dynamic> pinLocationMap = jsonDecode(pinLocation);
    LatLng pinLatLng = LatLng(pinLocationMap['lat'], pinLocationMap['lng']);

    // Navigate to the LocationScreen and pass the coordinates and pin location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationScreen(coordinates: coordinates, pinLocation: pinLatLng),
      ),
    );
  }

  void showAllShops(
      BuildContext context, String territoryCoordinates, String pinLocation) {
    // Parse the territory coordinates
    List<LatLng> coordinates = getLatLngCoordinates(territoryCoordinates);

    // Parse the pin location
    Map<String, dynamic> pinLocationMap = jsonDecode(pinLocation);
    LatLng pinLatLng = LatLng(pinLocationMap['lat'], pinLocationMap['lng']);

    // Navigate to the LocationScreen and pass the coordinates and pin location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen1(
          coordinates: coordinates,
          pinLocation: pinLocations,
          shopLocation: pinLatLng,
          Address: shopAddress,
          PhoneNo: phoneNumber,
          ShopName: shopName,
          TerritoryName: territoryName,
          ShopNames: ShopNames,
          PhoneNos: PhoneNos,
          TerritoryNames: TerritoryNames,
          Addresss: Addresss,
        ),
      ),
    );
  }
}
