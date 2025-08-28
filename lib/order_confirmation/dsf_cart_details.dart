import 'dart:convert';

import 'package:KhilafatCola/order_confirmation/checkout.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../main.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

class Products {
  final int id;
  final String name;
  final String type;
  final int volumeInMl;
  final double retailPrice;
  final double tradePrice;
  final int quantityInPack;
  final String image;
  int manualQuantity;

  Products(
      {required this.id,
      required this.name,
      required this.type,
      required this.volumeInMl,
      required this.retailPrice,
      required this.tradePrice,
      required this.quantityInPack,
      this.manualQuantity = 0,
      required this.image});

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['Id'],
      // Ensure this maps correctly from JSON
      name: json['Name'],
      type: json['Type'],
      volumeInMl: json['VolumeInMl'],
      retailPrice: json['RetailPrice'],
      tradePrice: json['TradePrice'],
      quantityInPack: json['QuantityInPack'],
      image: json['ImageName'],
      manualQuantity: 0, // Initialize to zero, not from API
    );
  }
}

class ShopScreen2 extends StatefulWidget {
  final shopid;
  final orderId;

  const ShopScreen2({Key? key, this.orderId, this.shopid}) : super(key: key);

  @override
  _ShopScreen2State createState() => _ShopScreen2State();
}

class _ShopScreen2State extends State<ShopScreen2> {
  List<Products> products = [];
  bool isLoading = false;

  // Fetching dealership data from API
  Future<void> fetchProducts() async {
    setState(() {
      print('Order Id: ${widget.orderId}');
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          '${Constants.BASE_URL}/api/App/GetActiveShopOrderProductByDsfId?userId=$userid&appDateTime=${getCurrentDateTime()}'),
      headers: {'Authorization': '6XesrAM2Nu'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['Data'];
      products =
          data.map<Products>((product) => Products.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load product data');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _increaseQuantity(Products product) {
    setState(() {
      product.manualQuantity += 1;
    });
  }

  // Decrease the product quantity
  void _decreaseQuantity(Products product) {
    setState(() {
      if (product.manualQuantity > 0) {
        product.manualQuantity -= 1;
      }
    });
  }

  void _showQuantityDialog(Products product) {
    TextEditingController quantityController =
        TextEditingController(text: product.manualQuantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Quantity"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter quantity"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                setState(() {
                  // Parse the input quantity and update the manualQuantity
                  int enteredQuantity =
                      int.tryParse(quantityController.text) ?? 0;
                  product.manualQuantity = enteredQuantity;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToCheckout() {
    // Filter products with manual quantities greater than 0
    final selectedProducts =
        products.where((product) => product.manualQuantity > 0).toList();

    if (selectedProducts.isNotEmpty) {
      // Navigate to checkout screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            products: selectedProducts,
            orderId: widget.orderId,
            shopid: widget.shopid,
          ),
        ),
      );
    } else {
      // Show a message if no products were selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter quantity for products to checkout')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    print('Shop Name$shopName');
    print('Shop Add$shopAddress');
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.check_outlined),
              onPressed: navigateToCheckout,
            ),
          ],
          backgroundColor: Colors.redAccent,
          title: const Text('Shop Products'),
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            //   child: Container(
            //     padding: const EdgeInsets.all(15),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: Colors.redAccent, width: 2),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.3),
            //           spreadRadius: 5,
            //           blurRadius: 10,
            //           offset: Offset(0, 3),
            //         ),
            //       ],
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           shopName,
            //           style: TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black87,
            //           ),
            //         ),
            //         // const SizedBox(height: 5),
            //         // Text(
            //         //   shopAddress,
            //         //   style: TextStyle(
            //         //     fontSize: 25,
            //         //     color: Colors.black87,
            //         //   ),
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
  borderRadius: BorderRadius.circular(8.0),
  child: product.image != null && product.image.isNotEmpty
      ? (product.image.startsWith('data:image')
          ? Image.memory(
              base64Decode(product.image.split(',').last),
              width: 60,
              height: 60,
              // fit: BoxFit.cover,
            )
          : Image.network(
              '${product.image}',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ))
      : Image.asset(
          'assets/default_image.png', // fallback local image
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${product.name} ${product.volumeInMl} ml  (${product.type})',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Trade Price: ${product.tradePrice}\nQuantity in Pack: ${product.quantityInPack}',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () {
                                                  _decreaseQuantity(product);
                                                }),
                                            // Display the current quantity
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _showQuantityDialog(product),
                                              child: Text(
                                                  '${product.manualQuantity}',
                                                  style: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () {
                                                  _increaseQuantity(product);
                                                }),
                                          ],
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
          ],
        ));
  }
}
