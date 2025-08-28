import 'dart:convert';

import 'package:KhilafatCola/order_confirmation/sup_Order_Comfirm.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../Shop/Shop_Edit_Order_Screen.dart';
import '../Shop/Shop_Hisotry_Screen.dart';
import '../widgets/const.dart';

class CheckoutScreen2 extends StatefulWidget {
  final products;
  final shopid;
  final orderId;

  const CheckoutScreen2({
    super.key,
    this.products,
    this.orderId,
    this.shopid,
  });

  @override
  State<CheckoutScreen2> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen2> {
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
      // Create the body for the POST request
      final orderItems = widget.products.map((product) {
        return {
          "productId": product.id,
          "DistributorPrice": product.distributorPrice,
          "orderQuantity": product.manualQuantity,
        };
      }).toList();

      final body = {
        "orderId": widget.orderId,
        "userId": userid,
        "appDateTime": getCurrentDateTime(), // Current date and time
        "OrderItemCommandList": orderItems,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(
            '${Constants.BASE_URL}/api/App/UpdateDistOrderByOrderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(body),
      );

      print('Order Body: $body');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response Data :  $responseData');
        // int status = responseData['Status'];
        String message = responseData['Message'];
        // int data = responseData['Data'];
        if (message == 'Order update Successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order confirmed successfully!')),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SupervisorOrderHistoryScreen()));
        }
      } else {
        // Show error message
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
      return total + (product.manualQuantity * product.distributorPrice);
    });
  }

  int getTotalQuantity() {
    return widget.products.fold(0, (total, product) {
      return total + product.manualQuantity;
    });
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
                          borderRadius: BorderRadius.circular(8.0),
                          child: product.image != null &&
                                  product.image.isNotEmpty
                              ? (product.image.startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(
                                          product.image.split(',').last),
                                      height: 50,
                                      width: 50,
                                      // fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      '${product.image}',
                                      height: 50,
                                      width: 50,
                                      // fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 30),
                                      ),
                                    ))
                              : const Center(
                                  child:
                                      Icon(Icons.image_not_supported, size: 30),
                                ),
                        ),

                        const SizedBox(
                            width:
                                16.0), // Add some spacing between image and text

                        // Product details on the right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.name} (${product.volumeInMl} ml ${product.type})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      13, // Increased font size for product name
                                  color: Colors
                                      .black87, // Softer color for better visibility
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Space between product name and price
                              Text(
                                'Distributor Price: Rs ${product.distributorPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13, // Font size for price
                                  color: Colors
                                      .green, // Highlight price with color
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Space between price and quantity
                              Text(
                                'Quantity in Pack: ${product.quantityInPack}',
                                style: const TextStyle(
                                  fontSize: 13, // Font size for quantity
                                  color: Colors
                                      .black54, // Softer color for quantity
                                ),
                              ),
                              const SizedBox(
                                  height: 8.0), // Space below the product info
                            ],
                          ),
                        ),
                        // Add a column for the quantity display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .end, // Align QTY text to the right
                          children: [
                            const Text(
                              'QTY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    15, // Increased font size for QTY label
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
                                    25, // Increased font size for the quantity
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
                      fontSize: 14,
                      color: Colors.black, // Black text color for contrast
                    ),
                  ),
                  Text(
                    'Total Price: Rs ${getTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
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
