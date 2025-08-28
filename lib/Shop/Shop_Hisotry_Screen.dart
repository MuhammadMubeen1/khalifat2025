import 'dart:convert';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


import '../widgets/const.dart';

class OrderProcessScreen extends StatefulWidget {
  final String orderId;

  const OrderProcessScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderProcessScreenState createState() => _OrderProcessScreenState();
}

class _OrderProcessScreenState extends State<OrderProcessScreen> {
  late Future<List<dynamic>> orderProcess;
  List<dynamic> shopList = []; // List to store fetched data
  bool isLoading = false;

  Future<void> getTodayDSFShopByUserLocation(String orderId) async {
    // Set loading state to true
    setState(() {
      isLoading = true;
    });

    // API URL with query parameters
    String url =
        '${Constants.BASE_URL}/api/App/GetOrderProcessByOrderId?appDateTime=${getCurrentDateTime()}&orderId=${widget.orderId}';

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

  String getCurrentDateTime() {
    return DateTime.now().toIso8601String();
  }

  @override
  void initState() {
    super.initState();
    // Call API to fetch order process
    getTodayDSFShopByUserLocation(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Order History Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '\u2022  History  \u2022',
                      style: GoogleFonts.cinzel(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...shopList.map((shop) {
                    return Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              spreadRadius: 4,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              shop['FromStatus'] == ''
                                  ? ''
                                  : 'From Status: ${shop['FromStatus'] ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'To Status: ${shop['ToStatus'] ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Comments: ${shop['Comments'] ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Update By: ${shop['UpdateBy'] ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Created Date: ${convertTo12HourFormat(shop['CreatedDate']) ?? 'N/A'}',
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
