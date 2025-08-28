// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:khilafat_cola/Supervisor/primary_sale_checkout_screen.dart';
// import 'package:khilafat_cola/utils/widgets.dart';
//
//
//
// class OrderData {
//   int orderId;
//   int orderStatusId;
//   String orderStatus;
//   int shopId;
//   String shopName;
//   String shopAddress;
//   String shopPhoneNo;
//   // ShopLocation shopLocation;
//   DateTime orderCreatedDate;
//   String orderCreatedById;
//   String orderCreatedBy;
//   String dsfId;
//   String dsf;
//
//   OrderData({
//     required this.orderId,
//     required this.orderStatusId,
//     required this.orderStatus,
//     required this.shopId,
//     required this.shopName,
//     required this.shopAddress,
//     required this.shopPhoneNo,
//     // required this.shopLocation,
//     required this.orderCreatedDate,
//     required this.orderCreatedById,
//     required this.orderCreatedBy,
//     required this.dsfId,
//     required this.dsf,
//   });
//
//   factory OrderData.fromJson(Map<String, dynamic> json) {
//     return OrderData(
//       orderId: json['OrderId'],
//       orderStatusId: json['OrderStatusId'],
//       orderStatus: json['OrderStatus'],
//       shopId: json['ShopId'],
//       shopName: json['ShopName'],
//       shopAddress: json['ShopAddress'],
//       shopPhoneNo: json['ShopPhoneNo'],
//       // shopLocation: ShopLocation.fromJson(jsonDecode(json['ShopLocation'])),
//       orderCreatedDate: DateTime.parse(json['OrderCreatedDate']),
//       orderCreatedById: json['OrderCreatedById'],
//       orderCreatedBy: json['OrderCreatedBy'],
//       dsfId: json['DSFId'],
//       dsf: json['DSF'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'OrderId': orderId,
//       'OrderStatusId': orderStatusId,
//       'OrderStatus': orderStatus,
//       'ShopId': shopId,
//       'ShopName': shopName,
//       'ShopAddress': shopAddress,
//       'ShopPhoneNo': shopPhoneNo,
//       // 'ShopLocation': jsonEncode(shopLocation.toJson()),
//       'OrderCreatedDate': orderCreatedDate.toIso8601String(),
//       'OrderCreatedById': orderCreatedById,
//       'OrderCreatedBy': orderCreatedBy,
//       'DSFId': dsfId,
//       'DSF': dsf,
//     };
//   }
// }
//
// // class Products {
// //   final int id;
// //   final String name;
// //   final String type;
// //   final int volumeInMl;
// //   // final double retailPrice;
// //   final int itemQuantity;
// //   final double tradePrice;
// //   final int quantityInPack;
// //   final String image;
// //   int manualQuantity;
// //
// //   Products(
// //       {required this.id,
// //       required this.name,
// //       required this.type,
// //       required this.volumeInMl,
// //       required this.itemQuantity,
// //       // required this.retailPrice,
// //       required this.tradePrice,
// //       required this.quantityInPack,
// //       this.manualQuantity = 0,
// //       required this.image});
// //
// //   factory Products.fromJson(Map<String, dynamic> json) {
// //     return Products(
// //       id: json['ProductId'],
// //       // Ensure this maps correctly from JSON
// //       name: json['ProductName'],
// //       type: json['ProductType'],
// //       volumeInMl: json['VolumeInMl'],
// //       // retailPrice: json['RetailPrice'],
// //       itemQuantity: json['ItemQuantity'],
// //       tradePrice: json['TradePrice'],
// //       quantityInPack: json['QuantityInPack'],
// //       image: json['ImageName'],
// //       manualQuantity: 0, // Initialize to zero, not from API
// //     );
// //   }
// // }
//
// //
// class Products {
//   final int id;
//   final String name;
//   final String type;
//   final int volumeInMl;
//   final int itemQuantity; // This holds the original quantity from the order
//   final double tradePrice;
//   final int quantityInPack;
//   final String image;
//   int manualQuantity; // This will hold the edited quantity
//
//   Products({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.volumeInMl,
//     required this.itemQuantity, // Original order quantity
//     required this.tradePrice,
//     required this.quantityInPack,
//     this.manualQuantity =
//         0, // Default to 0 for new items, or equal to itemQuantity for existing items
//     required this.image,
//   });
//
//   factory Products.fromJson(Map<String, dynamic> json) {
//     return Products(
//       id: json['ProductId'],
//       name: json['ProductName'],
//       type: json['ProductType'],
//       volumeInMl: json['VolumeInMl'],
//       itemQuantity: json['ItemQuantity'],
//       tradePrice: json['TradePrice'],
//       quantityInPack: json['QuantityInPack'],
//       image: json['ImageName'],
//       manualQuantity: json[
//           'ItemQuantity'], // Set manual quantity to the original order quantity
//     );
//   }
// }
//
// //
//
// class ShopScreen3 extends StatefulWidget {
//   final shopid;
//   final orderId;
//
//   const ShopScreen3({Key? key, this.orderId, this.shopid}) : super(key: key);
//
//   @override
//   _ShopScreen2State createState() => _ShopScreen2State();
// }
//
// class _ShopScreen2State extends State<ShopScreen3> {
//   List<Products> products = [];
//   List<OrderData> orderDetails = [];
//   bool isLoading = false;
//   List<dynamic> myApi = [];
//
//   // Fetching dealership data from API
//   Future<void> fetchProducts() async {
//     setState(() {
//       print('Order Id: ${widget.orderId}');
//       isLoading = true;
//     });
//
//     final response = await http.get(
//       Uri.parse(
//           '${Constants.BASE_URL}/api/App/GetShopOrderDetailsByOrderId?OrderId=${widget.orderId}&appDateTime=${getCurrentDateTime()}'),
//       headers: {'Authorization': '6XesrAM2Nu'},
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body)['Data'][0]['Products'];
//       final data1 = jsonDecode(response.body)['Data'];
//
//       print('D:$data');
//       products =
//           data.map<Products>((product) => Products.fromJson(product)).toList();
//       orderDetails = data1
//           .map<OrderData>((product) => OrderData.fromJson(product))
//           .toList();
//
//       print('E:$data1');
//     } else {
//       throw Exception('Failed to load product data');
//     }
//
//     setState(() {
//       // orderDetails = OrderData.fromJson(data1);
//       isLoading = false;
//     });
//   }
//
//   void _increaseQuantity(Products product) {
//     setState(() {
//       product.manualQuantity += 1;
//     });
//   }
//
//   // Decrease the product quantity
//   void _decreaseQuantity(Products product) {
//     setState(() {
//       if (product.manualQuantity > 0) {
//         product.manualQuantity -= 1;
//       }
//     });
//   }
//
//   void _showQuantityDialog(Products product) {
//     TextEditingController quantityController =
//         TextEditingController(text: product.manualQuantity.toString());
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter Quantity"),
//           content: TextField(
//             controller: quantityController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(hintText: "Enter quantity"),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Confirm"),
//               onPressed: () {
//                 setState(() {
//                   // Parse the input quantity and update the manualQuantity
//                   int enteredQuantity =
//                       int.tryParse(quantityController.text) ?? 0;
//                   product.manualQuantity = enteredQuantity;
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // void navigateToCheckout() {
//   //   // Filter products with manual quantities greater than 0
//   //   final selectedProducts =
//   //       products.where((product) => product.manualQuantity > 0).toList();
//   //
//   //   if (selectedProducts.isNotEmpty) {
//   //     // Navigate to checkout screen
//   //     // Navigator.push(
//   //     //   context,
//   //     //   MaterialPageRoute(
//   //     //     builder: (context) => CheckoutScreen3(
//   //     //       products: selectedProducts, // Send edited products
//   //     //       orderId: widget.orderId,
//   //     //       shopid: widget.shopid,
//   //     //     ),
//   //     //   ),
//   //     // );
//   //   } else {
//   //     // Show a message if no products were selected
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //           content: Text('Please enter quantity for products to checkout')),
//   //     );
//   //   }
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.red[50],
//         appBar: AppBar(
//           actions: [
//             // IconButton(
//             //   icon: Icon(Icons.check_outlined),
//             //   onPressed: navigateToCheckout,
//             // ),
//           ],
//           backgroundColor: Colors.redAccent,
//           title: Text('Shop Products'),
//         ),
//         body: Column(
//           children: [
//             Container(
//               height: 100,
//               child: ListView.builder(
//                 itemCount: orderDetails.length,
//                 itemBuilder: (context, index) {
//                   final product = orderDetails[index];
//                   return Padding(
//                     padding:
//                         const EdgeInsets.only(top: 20, left: 20, right: 20),
//                     child: Container(
//                       padding: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.redAccent, width: 2),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3),
//                             spreadRadius: 5,
//                             blurRadius: 10,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             product.shopName,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           // const SizedBox(height: 5),
//                           // Text(
//                           //   ',${product.shopAddress}',
//                           //   style: TextStyle(
//                           //     fontSize: 25,
//                           //     color: Colors.black87,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : products.isEmpty
//                       ? Center(child: Text('No products found'))
//                       : ListView.builder(
//                           itemCount: products.length,
//                           itemBuilder: (context, index) {
//                             final product = products[index];
//                             return Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 side: BorderSide(color: Colors.grey.shade300),
//                               ),
//                               margin: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 16.0),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Row(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       child: Image.network(
//                                         'http://kcapiqa.fscscampus.com/${product.image}',
//                                         width: 60,
//                                         height: 60,
//                                       ),
//                                     ),
//                                     SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                               '${product.name} ${product.volumeInMl} ml  (${product.type})',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16)),
//                                           SizedBox(height: 4),
//                                           Text(
//                                               'Trade Price: ${product.tradePrice}\nQuantity in Pack: ${product.quantityInPack}',
//                                               style: TextStyle(
//                                                   color: Colors.grey.shade600)),
//                                         ],
//                                       ),
//                                     ),
//                                     Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             IconButton(
//                                                 icon: Icon(Icons.remove),
//                                                 onPressed: () {
//                                                   _decreaseQuantity(product);
//                                                 }),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             // Display the current quantity
//                                             GestureDetector(
//                                               onTap: () => _showQuantityDialog(
//                                                   product), // To manually update quantity
//                                               child: Text(
//                                                 product.manualQuantity
//                                                     .toString(), // Show manual quantity, which reflects the editable state
//                                                 style: TextStyle(
//                                                   fontSize: 25,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             IconButton(
//                                                 icon: Icon(Icons.add),
//                                                 onPressed: () {
//                                                   _increaseQuantity(product);
//                                                 }),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//             ),
//           ],
//         ));
//   }
// }
