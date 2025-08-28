import 'dart:convert';
import 'dart:io';

import 'package:KhilafatCola/Shop_Tagging/shop_tagging.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_Map.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../widgets/Splash.dart';
import '../widgets/const.dart';

class Tagging_History extends StatefulWidget {
  const Tagging_History({super.key});

  @override
  State<Tagging_History> createState() => _Tagging_HistoryState();
}

class _Tagging_HistoryState extends State<Tagging_History> {
  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  String lng = '';
  String lat = '';
  String Phone = '';
  String ShopName = '';
  String Address = '';
  String Territory = '';
  List<dynamic> tasks = [];
  bool isLoading = true;

  // Helper method to safely extract string values with null handling
  String safeString(dynamic value, [String defaultValue = 'N/A']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  Widget infoText(String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: text,
              style: GoogleFonts.lato(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchShopTagHistory() async {
    final url = Uri.parse(
        '${Constants.BASE_URL}/api/App/GetUserShopTagHistoryByUserId');

    // API request body
    final body = {"userId": userid, "appDateTime": getCurrentDateTime()};

    // Debug: Print request details
    print('=== API REQUEST DEBUG ===');
    print('URL: $url');
    print(
        'Headers: {\'Content-Type\': \'application/json\', \'Authorization\': \'6XesrAM2Nu\'}');
    print('Request Body: ${json.encode(body)}');
    print('User ID: $userid');
    print('Current DateTime: ${getCurrentDateTime()}');
    print('=========================');

    try {
      // Sending POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: json.encode(body),
      );

      // Debug: Print response details
      print('=== API RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('==========================');

      if (response.statusCode == 200) {
        // If the request was successful
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Debug: Print parsed JSON structure
        print('=== PARSED JSON DEBUG ===');
        print('JSON Keys: ${jsonResponse.keys.toList()}');
        print('Has Data key: ${jsonResponse.containsKey('Data')}');

        if (jsonResponse.containsKey('Data')) {
          print('Data type: ${jsonResponse['Data'].runtimeType}');
          print('Data content: ${jsonResponse['Data']}');

          // Check if Data is a list
          if (jsonResponse['Data'] is List) {
            print('Data list length: ${(jsonResponse['Data'] as List).length}');
            return jsonResponse['Data'];
          } else {
            print('Data is not a list, returning empty list');
            return [];
          }
        } else {
          print('Data key not found in response');
          print('Available keys: ${jsonResponse.keys.toList()}');
          return [];
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return [];
      }
    } catch (e) {
      // Handle any exceptions and return an empty list
      print('=== ERROR DEBUG ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      // Print stack trace for more details
      if (e is SocketException) {
        print('SocketException: ${e.message}');
      } else if (e is http.ClientException) {
        print('ClientException: ${e.message}');
      } else if (e is FormatException) {
        print('FormatException: ${e.message}');
      }

      print('===================');
      return [];
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

  @override
  void initState() {
    _checkInitialConnection();
    _listenToConnectionChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB71234),
                      Color(0xFFF02A2A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Center(
                              child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ))),
                      Center(
                          child: Text(
                        'Shop Tagging History',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: FutureBuilder<List<dynamic>>(
              future: fetchShopTagHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'No history data available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index] as Map<String, dynamic>;

                        // Safely extract lat/lng with null handling
                        Map<String, dynamic>? locationMap;
                        try {
                          if (item['PinLocation'] != null) {
                            locationMap = json
                                .decode(safeString(item['PinLocation'], '{}'));
                          }
                        } catch (e) {
                          print('Error parsing PinLocation: $e');
                          locationMap = {};
                        }

                        final lat = safeString(locationMap?['lat'], '0.0');
                        final lng = safeString(locationMap?['lng'], '0.0');
                        final imageUrl = safeString(item['ImageName']);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            infoText(
                                                "Created By",
                                                safeString(
                                                    item['CreatedByName'])),
                                            infoText("Owner Name",
                                                safeString(item['OwnerName'])),
                                            infoText("Shop Name",
                                                safeString(item['ShopName'])),
                                            infoText("Address",
                                                safeString(item['Address'])),
                                            infoText("Phone No",
                                                safeString(item['PhoneNo'])),
                                            infoText(
                                                "Opening Time",
                                                safeString(
                                                    item['OpeningTime'])),
                                            infoText(
                                                "Closing Time",
                                                safeString(
                                                    item['ClosingTime'])),
                                            infoText(
                                                "id", safeString(item['Id'])),
                                            if (safeString(item['Status'])
                                                    .toLowerCase() ==
                                                'reject')
                                              infoText("Remarks",
                                                  safeString(item['Remarks'])),
                                            Row(
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Status: ',
                                                        style: GoogleFonts.lato(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: safeString(
                                                            item['Status']),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: safeString(item[
                                                                          'Status'])
                                                                      .toLowerCase() ==
                                                                  'reject'
                                                              ? Colors.red
                                                              : safeString(item[
                                                                              'Status'])
                                                                          .toLowerCase() ==
                                                                      'processes'
                                                                  ? Colors
                                                                      .yellow
                                                                  : safeString(item['Status'])
                                                                              .toLowerCase() ==
                                                                          'approved'
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                if (safeString(item['Status'])
                                                        .toLowerCase() ==
                                                    'reject')
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        size: 25),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShopTagging(
                                                            shopId: int.tryParse(
                                                                    safeString(
                                                                        item[
                                                                            'Id'],
                                                                        '0')) ??
                                                                0,
                                                            shopData: item,
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
                                      const SizedBox(width: 10),
                                      // Image container with error handling
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[200],
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade400,
                                              blurRadius: 10,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: imageUrl.isNotEmpty &&
                                                imageUrl != 'N/A'
                                            ? _buildImageWidget(imageUrl)
                                            : const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShopLocationMap(
                                              latitude:
                                                  double.tryParse(lat) ?? 0.0,
                                              longitude:
                                                  double.tryParse(lng) ?? 0.0,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
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
                                              color: Colors.red.shade200,
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View Shop Location',
                                              style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.pin_drop,
                                                color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return const Center(child: Text('No Data Found'));
                }
              },
            ),
          ),
        ],
      )),
    );
  }
  Widget _buildImageWidget(String imageData) {
    try {
      // Check if it's a base64 data URI
      if (imageData.startsWith('data:image/')) {
        // Extract the base64 part from the data URI
        final base64String = imageData.split(',').last;
        // Decode the base64 string to bytes
        final bytes = base64.decode(base64String);
        // Create a memory image from bytes
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      } else {
        // If it's a regular URL, use NetworkImage
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      }
    } catch (e) {
      print('Error loading image: $e');
      return const Icon(Icons.error, color: Colors.red);
    }
  }
}
