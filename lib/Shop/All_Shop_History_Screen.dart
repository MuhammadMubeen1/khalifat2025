import 'dart:convert';
import 'package:KhilafatCola/order_confirmation/today_order_screen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../widgets/const.dart';

class OrderProcessScreen extends StatefulWidget {
  final String shopID;

  const OrderProcessScreen({Key? key, required this.shopID}) : super(key: key);

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
        '${Constants.BASE_URL}/api/App/GetShopOrderHistoryByShopId?shopId=${widget.shopID}&appDateTime=${getCurrentDateTime()}';

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
    getTodayDSFShopByUserLocation(widget.shopID);
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // Align text to the right
                              children: [
                                Text(
                                  'Order Status: ${shop['OrderStatus']}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Order Created: ${convertTo12HourFormat(shop['OrderCreatedDate'])}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Created By: ${shop['OrderCreatedBy']}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Shop Name: ${shop['ShopName'] ?? 'N/A'}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Shop Address: ${shop['ShopAddress'] ?? 'N/A'}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Phone: ${shop['ShopPhoneNo'] ?? 'N/A'}',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                shop['OrderStatusId'] == 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         ShopScreen3(
                                              //       orderId: shop['OrderId'],
                                              //       shopid: widget.shopID,
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors
                                                  .redAccent, // Text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    30), // Adjust the radius as needed
                                              ),
                                            ),
                                            child: const Text('Edit'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailsScreen1(
                                                    OrderId: shop['OrderId'],
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors
                                                  .redAccent, // Text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    30), // Adjust the radius as needed
                                              ),
                                            ),
                                            child: const Text('View Details'),
                                          ),
                                        ],
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailsScreen1(
                                                OrderId: shop['OrderId'],
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Colors.redAccent, // Text color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Adjust the radius as needed
                                          ),
                                        ),
                                        child: const Text('View Details'),
                                      ),
                              ],
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
