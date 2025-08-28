import 'dart:convert';

import 'package:KhilafatCola/order_confirmation/sup_dealership_map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../utils/widgets.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

class DealershipScreen extends StatefulWidget {
  const DealershipScreen({super.key});

  @override
  _DealershipScreenState createState() => _DealershipScreenState();
}

class _DealershipScreenState extends State<DealershipScreen> {
  final List<String> _imageAssets = [
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
  final List<String> _productNames = [
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

  final List<int> _prices = [150, 150, 150, 300, 300, 300, 250, 250, 250];
  final List<int> _ids = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  double? tradePrice;
  int? productID;
  var dealershipId;
  var DealershipName;
  var PhoneNo;
  var address;
  final List<int> _quantities = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  final List<TextEditingController> _controllers = [];
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

  @override
  void initState() {
    for (var quantity in _quantities) {
      _controllers.add(TextEditingController(text: quantity.toString()));
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    // TODO: implement dispose
    super.dispose();
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
        builder: (context) => OrderConfirmationScreen(
          orderedItems: orderedItems,
        ),
      ),
    );
  }

  ///
  Future<Map<String, dynamic>> fetchDealershipData() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.BASE_URL}/api/App/GetProductForDOBySupId?userId=$userid&appDateTime=${getCurrentDateTime()}',
      ),
      headers: {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData != null && decodedData['Data'] != null) {
        return decodedData['Data'];
      } else {
        throw Exception('No valid data returned from API');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> confirmOrder() async {
    String url = '${Constants.BASE_URL}/api/App/SaveDealershipOrder';
    const String authorizationToken = '6XesrAM2Nu';

    final body = {
      "dealershipId": dealershipId,
      "address": address,
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "OrderItemCommandList": [
        {"productId": 2, "tradePrice": 550.00, "orderQuantity": 10},
        {"productId": 3, "tradePrice": 550.00, "orderQuantity": 0},
        {"productId": 4, "tradePrice": 550.00, "orderQuantity": 5},
        {"productId": 5, "tradePrice": 500.00, "orderQuantity": 20}
      ]
    };
    print('API Body: $body');
    final headers = {
      'Authorization': authorizationToken,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Order successfully confirmed.');
        // Handle the response, if any
        final responseData = jsonDecode(response.body);
        print(responseData);
      } else {
        print('Failed to confirm order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while confirming order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              // Action when the New Order button is pressed
              print("New Order button pressed");
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => MyCartScreen()));
              _confirmOrder();
            },
            child: const Text(
              "Confirm Order",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.redAccent,
        title: const Text("Dealership Order"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDealershipData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            dealershipId = data['DealershipId'];
            DealershipName = data['DealershipName'];
            PhoneNo = data['PhoneNo'];
            address = data['Address'];
            var pinLocation = jsonDecode(data['PinLocation']);
            var products = data['Products'];
            if (products is List) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        DealershipName!,
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          'Phone: $PhoneNo\nAddress: $address',
                          style: const TextStyle(
                              fontSize: 18.0, color: Colors.black),
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                latitude: pinLocation['lat'],
                                longitude: pinLocation['lng'],
                              ),
                            ),
                          );
                        },
                        child: const Text("View Location"),
                      ),
                    ),
                    const Divider(),
                    Column(
                      children: List.generate(products.length, (index) {
                        var product = products[index];
                        tradePrice = product['TradePrice'];
                        productID = product['ProductId'];

                        return Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 8.0),
                             product['ImageName'] != null &&
                                        product['ImageName'].isNotEmpty
                                    ? (product['ImageName']
                                            .startsWith('data:image')
                                        ? Image.memory(
                                            base64Decode(product['ImageName']
                                                .split(',')
                                                .last),
                                            height: 100.0,
                                            width: 100.0,
                                            // fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            '${product['ImageName']}',
                                            height: 100.0,
                                            width: 100.0,
                                            // fit: BoxFit.cover,
                                          ))
                                    : Image.asset(
                                        'assets/default_image.png',
                                        height: 100.0,
                                        width: 100.0,
                                        fit: BoxFit.cover,
                                      ),

                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${product['Name']} ${product['VolumeInMl']} ml ${product['Type']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Quantity in Pack:${product['QuantityInPack'].toString()}',
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          Text(
                                            'Rs. ${product['TradePrice']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.remove_circle),
                                            onPressed: () =>
                                                _decrementQuantity(index),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Enter Quantity'),
                                                    content: TextField(
                                                      controller:
                                                          _controllers[index],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Quantity',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            // Update the quantity based on user input
                                                            int? newQuantity =
                                                                int.tryParse(
                                                                    _controllers[
                                                                            index]
                                                                        .text);
                                                            if (newQuantity !=
                                                                null) {
                                                              _prices[index] =
                                                                  newQuantity;
                                                            }
                                                          });
                                                          print(
                                                              'Order Quantity ${product['OrderQuantity']}');
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        child: const Text('OK'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              '${_quantities[index]}',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle),
                                            onPressed: () =>
                                                _incrementQuantity(index),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                thickness: 1.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                  child: Text('Products data is not a valid list'));
            }
          } else {
            return const Center(child: Text('No Data Available'));
          }
        },
      ),
    );
  }
}

class OrderConfirmationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderedItems;

  const OrderConfirmationScreen({super.key, required this.orderedItems});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  double totalPrice = 0.0;

  Future<void> confirmOrder() async {
    String url = '${Constants.BASE_URL}/api/App/SaveDealershipOrder';
    const String authorizationToken = '6XesrAM2Nu';

    // Prepare OrderItemCommandList based on orderedItems
    List<Map<String, dynamic>> orderItemCommandList =
        widget.orderedItems.map((item) {
      return {
        "productId": item['productId'],
        "tradePrice": item['price'],
        "orderQuantity": item['quantity'],
      };
    }).toList();

    final body = {
      "dealershipId": '',
      "address": '',
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "OrderItemCommandList": orderItemCommandList,
    };

    print('API Body: $body');

    final headers = {
      'Authorization': authorizationToken,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Order successfully confirmed.');
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order successfully confirmed.')),
        );
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => SupervisorOrderHistory()));
        print(responseData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm Order')),
        );
        print('Failed to confirm order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while confirming order: $e');
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var item in widget.orderedItems) {
      totalPrice += item['price'] * item['quantity'];
    }
    return totalPrice;
  }

  @override
  void initState() {
    super.initState();

    totalPrice = calculateTotalPrice(); // Calculate total price on init
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to confirm this order?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                confirmOrder(); // Proceed to confirm the order
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Order Confirmation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...widget.orderedItems.map((item) {
              return Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset(
                        item['image'],
                        height: 100.0,
                        width: 100.0,
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Quantity: ${item['quantity']}',
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'Total: Rs. ${item['price'] * item['quantity']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog(); // Show confirmation dialog
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text('Confirm Order'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement retake order functionality if needed
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text('Retake Order'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getCurrentDateTime() {
    // Returns the current date and time in ISO 8601 format
    return DateTime.now().toIso8601String();
  }
}
