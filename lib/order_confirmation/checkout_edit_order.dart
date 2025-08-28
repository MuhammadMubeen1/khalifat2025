// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:khilafat_cola/ASD/asd_dashboard.dart';
// import 'package:khilafat_cola/Home/home.dart';
// import 'package:khilafat_cola/main.dart';
// import 'package:khilafat_cola/tracking/tracking.dart';
// import 'package:khilafat_cola/utils/widgets.dart';
// import 'package:khilafat_cola/widgets/Splash.dart';
//
// import '../Shop/Shop_Edit_Order_Screen.dart';
// import '../Shop/Shop_Hisotry_Screen.dart';
//
// class CheckoutScreen1 extends StatefulWidget {
//   final List<Products> products;
//   final shopid;
//   final orderId;
//
//   CheckoutScreen1({
//     required this.products,
//     this.orderId,
//     this.shopid,
//   });
//
//   @override
//   State<CheckoutScreen1> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen1> {
//   // Method to confirm the order
//
//   Future<void> confirmOrder(BuildContext context) async {
//     // Show confirmation dialog
//     bool confirm = await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Confirm Order'),
//               content: Text('Are you sure you want to confirm this order?'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(false); // User pressed No
//                   },
//                   child: Text('No'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(true); // User pressed Yes
//                   },
//                   child: Text('Yes'),
//                 ),
//               ],
//             );
//           },
//         ) ??
//         false; // Handle null case
//
//     if (confirm) {
//       // Create the body for the POST request
//       final orderItems = widget.products.map((product) {
//         return {
//           "productId": product.id,
//           "TradePrice": product.tradePrice,
//           "orderQuantity": product.manualQuantity,
//         };
//       }).toList();
//
//       final body = {
//         "orderId": widget.orderId,
//         "dsfId": userid,
//         "userId": userid,
//         "appDateTime": getCurrentDateTime(), // Current date and time
//         "OrderItemCommandList": orderItems,
//       };
//
//       // Send the POST request
//       final response = await http.post(
//         Uri.parse(
//             '${Constants.BASE_URL}/api/App/UpdateShopOrderByOrderId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': '6XesrAM2Nu',
//         },
//         body: jsonEncode(body),
//       );
//
//       print('Order Body: $body');
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         print('Response Data :  $responseData');
//         // int status = responseData['Status'];
//         String message = responseData['Message'];
//         // int data = responseData['Data'];
//         if (message == 'Order update Successfully') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Order confirmed successfully!')),
//           );
//           Navigator.push(
//               context, MaterialPageRoute(builder: (context) => ASDDashboard()));
//         }
//       } else {
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to confirm order: ${response.body}')),
//         );
//       }
//     } else {
//       // User cancelled the confirmation
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order confirmation cancelled.')),
//       );
//     }
//   }
//
//   // Calculate total price and total quantity
//   double getTotalPrice() {
//     return widget.products.fold(0.0, (total, product) {
//       return total + (product.manualQuantity * product.tradePrice);
//     });
//   }
//
//   int getTotalQuantity() {
//     return widget.products.fold(0, (total, product) {
//       return total + product.manualQuantity;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red[50],
//       appBar: AppBar(
//         backgroundColor: Colors.redAccent,
//         title: Text('Checkout'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check),
//             onPressed: () =>
//                 confirmOrder(context), // Call the confirm order method
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: widget.products.length,
//               itemBuilder: (context, index) {
//                 final product = widget.products[index];
//                 return Card(
//                   margin: const EdgeInsets.all(8.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Product image on the left
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8.0),
//                           child: Image.network(
//                             'http://kcapiqa.fscscampus.com/${product.image}',
//                             height: 70,
//                             width: 70,
//                           ),
//                         ),
//                         SizedBox(
//                             width:
//                                 16.0), // Add some spacing between image and text
//
//                         // Product details on the right
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${product.name} (${product.volumeInMl} ml ${product.type})',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize:
//                                       18, // Increased font size for product name
//                                   color: Colors
//                                       .black87, // Softer color for better visibility
//                                 ),
//                               ),
//                               SizedBox(
//                                   height:
//                                       4.0), // Space between product name and price
//                               Text(
//                                 'Trade Price: \Rs ${product.tradePrice.toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   fontSize: 16, // Font size for price
//                                   color: Colors
//                                       .green, // Highlight price with color
//                                 ),
//                               ),
//                               SizedBox(
//                                   height:
//                                       4.0), // Space between price and quantity
//                               Text(
//                                 'Quantity in Pack: ${product.quantityInPack}',
//                                 style: TextStyle(
//                                   fontSize: 16, // Font size for quantity
//                                   color: Colors
//                                       .black54, // Softer color for quantity
//                                 ),
//                               ),
//                               SizedBox(
//                                   height: 8.0), // Space below the product info
//                             ],
//                           ),
//                         ),
//                         // Add a column for the quantity display
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment
//                               .end, // Align QTY text to the right
//                           children: [
//                             Text(
//                               'QTY',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize:
//                                     18, // Increased font size for QTY label
//                                 color: Colors.black87, // Color for QTY label
//                               ),
//                             ),
//                             SizedBox(
//                                 height:
//                                     4.0), // Small space between QTY and quantity number
//                             Text(
//                               product.manualQuantity.toString(),
//                               style: TextStyle(
//                                 fontSize:
//                                     36, // Increased font size for the quantity
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors
//                                     .blueAccent, // Color for quantity number
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Display total quantity and price
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Container(
//               padding: EdgeInsets.all(16.0), // Padding inside the container
//               decoration: BoxDecoration(
//                 color: Colors.white, // White background color
//                 borderRadius: BorderRadius.circular(12.0), // Rounded corners
//                 border: Border.all(
//                     color: Colors.grey.shade300,
//                     width: 1.0), // Light grey border
//                 boxShadow: [
//                   BoxShadow(
//                     color:
//                         Colors.grey.withOpacity(0.3), // Soft shadow for depth
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3), // Offset for shadow
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Total Quantity: ${getTotalQuantity()}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black, // Black text color for contrast
//                     ),
//                   ),
//                   Text(
//                     'Total Price: \Rs ${getTotalPrice().toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black, // Black text color for contrast
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
