import 'dart:convert';

import 'package:KhilafatCola/ASD/asd_dashboard.dart';
import 'package:KhilafatCola/Home/home.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../widgets/const.dart';
import 'dsf_cart_details.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Products> products;
  final shopid;
  final orderId;

  const CheckoutScreen({
    super.key,
    required this.products,
    this.orderId,
    this.shopid,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoading = false;
  // Method to confirm the order

  Future<void> confirmOrder(BuildContext context) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Order'),
              content:
                  const Text('Are you sure you want to confirm this order?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User pressed No
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User pressed Yes
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false; // Handle null case

    if (confirm) {
      setState(() {
        isLoading = true; // Show loader
      });

      Future<void> getUserDetailsByDeviceId() async {
        // Define the API URL
        String apiUrl =
            '${Constants.BASE_URL}/api/App/GetUserDetailsByDeviceId';

        // Prepare the request body
        Map<String, dynamic> requestBody = {
          "deviceId": deviceid,
          "appDateTime": getCurrentDateTime(),
          "lat": 31.485686333868593,
          "lng": 74.28243076184944
        };

        // Define the headers
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        };

        try {
          // Make the POST request
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: headers,
            body: jsonEncode(requestBody),
          );

          // Check if the response is successful
          if (response.statusCode == 200) {
            print('Splash resp ${response.body}');
            // Parse and handle the response data
            final responseData = jsonDecode(response.body);
            final message = responseData["Message"];
            final resp = responseData["Data"];
            if (resp != null) {
              name = resp["Name"].toString();
              role = resp["RoleName"].toString();
              userPhone = resp["PhoneNumber"].toString();
              userEmail = resp["Email"].toString();
              userid = resp["UserId"].toString();
              userImage = resp["Image"].toString();
              StartShift = resp["ShiftTimeStart"].toString();
              EndShift = resp["ShiftTimeEnd"].toString();
              IsMarkAttendance = resp["IsMarkAttendance"].toString();
              isPresent = resp['IsPresent'].toString() ?? "";
              dealershipName = resp['DealershipName'] ?? "";
              dealershipLocation = resp['DealershipLocation'] ?? "";

              Map<String, dynamic> pinLocationMap =
                  jsonDecode(dealershipLocation);
              dealerlat = pinLocationMap['lat'];
              dealerlng = pinLocationMap['lng'];
              print('Lat:  $dealerlat');
              print('Lng: $dealerlng');
            } else {
              print('Could not Load Data');
            }
          } else {
            print(
                'Failed to fetch user details. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error occurred: $e');
        }
      }

      await getUserDetailsByDeviceId(); // Ensure we wait for user details to load

      // Create the body for the POST request
      final orderItems = widget.products.map((product) {
        return {
          "productId": product.id,
          "TradePrice": product.tradePrice,
          "orderQuantity": product.manualQuantity,
        };
      }).toList();

      final body = {
        "shopId": widget.shopid,
        "dsfId": userid,
        "userId": userid,
        "appDateTime":
            DateTime.now().toIso8601String(), // Current date and time
        "OrderItemCommandList": orderItems,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse('${Constants.BASE_URL}/api/App/SaveShopOrder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      print('Order Body: $body');

      // Reset loading state after the API call
      setState(() {
        isLoading = false; // Hide loader
      });

      if (response.statusCode == 200 && role == "ASD") {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order confirmed successfully!')),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ASDDashboard()));
      } else if (response.statusCode == 200 && role == "DSF") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm order: ${response.body}')),
        );
      }
    } else {
      // User cancelled the confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order confirmation cancelled.')),
      );
    }
  }

  // Calculate total price and total quantity
  double getTotalPrice() {
    return widget.products.fold(0.0, (total, product) {
      return total + (product.manualQuantity * product.tradePrice);
    });
  }

  int getTotalQuantity() {
    return widget.products.fold(0, (total, product) {
      return total + product.manualQuantity;
    });
  }

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Checkout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () =>
                confirmOrder(context), // Call the confirm order method
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image on the left
                       ClipRRect(
  borderRadius: BorderRadius.circular(50), // circle shape
  child: userImage != null && userImage.isNotEmpty
      ? (userImage.startsWith('data:image')
          ? Image.memory(
              base64Decode(userImage.split(',').last),
              height: 80,
              width: 80,
             
            )
          : Image.network(
              '$userImage',
              height: 80,
              width: 80,
         
            ))
      : Image.asset(
          'assets/default_avatar.png',
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
),
                        const SizedBox(
                            width:
                                16.0), // Add some spacing between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.name} (${product.volumeInMl} ml ${product.type})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      18, // Increased font size for product name
                                  color:
                                      Colors.black87, // Slightly softer color
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Space between product name and price
                              Text(
                                'Trade Price: Rs ${product.tradePrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16, // Increased font size for price
                                  color: Colors
                                      .green, // Color to highlight the price
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Space between price and quantity
                              Text(
                                'Quantity in Pack: ${product.quantityInPack}',
                                style: const TextStyle(
                                  fontSize:
                                      16, // Increased font size for quantity
                                  color: Colors
                                      .black54, // Softer color for quantity
                                ),
                              ),
                              const SizedBox(
                                  height: 8.0), // Space below the product info
                            ],
                          ),
                        ),
                        // Adjust the layout for QTY
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .end, // Align QTY text to the right
                          children: [
                            const Text(
                              'QTY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    18, // Increased font size for QTY label
                                color: Colors.black87, // Color for QTY label
                              ),
                            ),
                            const SizedBox(
                                height:
                                    4.0), // Small space between QTY and quantity number
                            Text(
                              product.manualQuantity.toString(),
                              style: const TextStyle(
                                fontSize:
                                    36, // Increased font size for the quantity
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .blueAccent, // Color for quantity number
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Display total quantity and price
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding:
                  const EdgeInsets.all(16.0), // Padding inside the container
              decoration: BoxDecoration(
                color: Colors.white, // White background color
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
                border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0), // Light grey border
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.grey.withOpacity(0.3), // Soft shadow for depth
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Offset for shadow
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Quantity: ${getTotalQuantity()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black, // Black text color for contrast
                    ),
                  ),
                  Text(
                    'Total Price: Rs ${getTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black, // Black text color for contrast
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
