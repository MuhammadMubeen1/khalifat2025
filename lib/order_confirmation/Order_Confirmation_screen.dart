import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp1());
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyCartScreen(),
    );
  }
}

class MyCartScreen extends StatefulWidget {
  final String? dealershipName;
  final String? phoneNo;
  final String? address;
  MyCartScreen({super.key, this.phoneNo, this.address, this.dealershipName});
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  List<String> _imageAssets = [
    'assets/images/Colacan.png',
    'assets/images/limcan.png',
    'assets/images/Orange.png',
    'assets/images/Colacan.png',
    'assets/images/limcan.png',
    'assets/images/Orange.png',
    'assets/images/Colacan.png',
    'assets/images/limcan.png',
    'assets/images/Orange.png',
  ];

  List<String> _productNames = [
    'Cola Flavoured Drink',
    'Lime Flavoured Drink',
    'Orange Flavoured Drink',
    'Cola Flavoured Drink (1.5L)',
    'Lime Flavoured Drink (1.5L)',
    'Orange Flavoured Drink (1.5L)',
    'Cola Flavoured Drink (1L)',
    'Lime Flavoured Drink (1L)',
    'Orange Flavoured Drink (1L)',
  ];

  List<int> _quantities = [0, 0, 0, 0, 0, 0, 0, 0, 0];

  List<int> _ids = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  List<int> _prices = [150, 150, 150, 300, 300, 300, 250, 250, 250];

  int get totalQuantity {
    return _quantities.reduce((sum, element) => sum + element);
  }

  double get totalPrice {
    double price = 0.0;
    for (int i = 0; i < _quantities.length; i++) {
      price += _quantities[i] * _prices[i];
    }
    return price;
  }

  void _incrementQuantity(int index) {
    setState(() {
      _quantities[index]++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_quantities[index] > 1) {
        _quantities[index]--;
      }
    });
  }

  void _confirmOrder() {
    List<Map<String, dynamic>> orderedItems = [];

    for (int i = 0; i < _imageAssets.length; i++) {
      if (_quantities[i] > 0) {
        orderedItems.add({
          'productId': _ids[i],
          'image': _imageAssets[i],
          'name': _productNames[i],
          'quantity': _quantities[i],
          'price': _prices[i],
        });
      }
    }

    // Navigate to the confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderConfirmationScreen(orderedItems: orderedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: Colors.redAccent,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: _confirmOrder,
            child: Text('Confirm Order'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: List.generate(_imageAssets.length, (index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 8.0),
                        Image.asset(
                          _imageAssets[index],
                          height: 100.0,
                          width: 100.0,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _productNames[index],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '300ml can',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Text(
                                    'Rs. ${_prices[index]}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () => _decrementQuantity(index),
                                  ),
                                  Text('${_quantities[index]}'),
                                  IconButton(
                                    icon: Icon(Icons.add_circle),
                                    onPressed: () => _incrementQuantity(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          // Bottom Floating Container
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 70,
          //     padding: EdgeInsets.symmetric(horizontal: 16.0),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.grey.withOpacity(0.5),
          //           spreadRadius: 5,
          //           blurRadius: 7,
          //           offset: Offset(0, 3), // changes position of shadow
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Total Quantity: $totalQuantity',
          //               style: TextStyle(
          //                   fontSize: 16, fontWeight: FontWeight.bold),
          //             ),
          //             Text(
          //               'Total Price: Rs. ${totalPrice.toStringAsFixed(2)}',
          //               style: TextStyle(
          //                   fontSize: 16, fontWeight: FontWeight.bold),
          //             ),
          //           ],
          //         ),
          //         ElevatedButton(
          //           onPressed: _confirmOrder,
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.redAccent,
          //           ),
          //           child: Text('Checkout'),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orderedItems;

  OrderConfirmationScreen({required this.orderedItems});

  // Method to save ordered items to SharedPreferences
  Future<void> saveOrderedItemsToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert orderedItems list to JSON string
    String orderedItemsJson = jsonEncode(orderedItems);

    // Save the JSON string in SharedPreferences
    await prefs.setString('ordered_items', orderedItemsJson);
  }

  // Method to calculate the total price of the ordered items
  double calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var item in orderedItems) {
      totalPrice += item['price'] * item['quantity'];
      print('ID :  ${item['productId']}');
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Order Confirmation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...orderedItems.map((item) {
              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 8.0),
                      Image.asset(
                        item['image'],
                        height: 100.0,
                        width: 100.0,
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product ID: ${item['productId']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Quantity: ${item['quantity']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'Total: Rs. ${item['price'] * item['quantity']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      thickness: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Price: Rs. $totalPrice',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
