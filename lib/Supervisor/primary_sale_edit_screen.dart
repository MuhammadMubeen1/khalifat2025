import 'dart:convert';
import 'package:KhilafatCola/Supervisor/primary_sale_checkout_screen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../widgets/const.dart';

class OrderData {
  int orderId;
  int orderStatusId;
  String orderStatus;
  int distributorId;
  String distributorName;
  String distributorAddress;
  String distributorPhoneNo;
  DateTime orderCreatedDate;
  String orderCreatedById;
  String orderCreatedBy;

  OrderData({
    required this.orderId,
    required this.orderStatusId,
    required this.orderStatus,
    required this.distributorId,
    required this.distributorName,
    required this.distributorAddress,
    required this.distributorPhoneNo,
    required this.orderCreatedDate,
    required this.orderCreatedById,
    required this.orderCreatedBy,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['OrderId'],
      orderStatusId: json['OrderStatusId'],
      orderStatus: json['OrderStatus'],
      distributorId: json['DistributorId'],
      distributorName: json['DistributorName'],
      distributorAddress: json['DistributorAddress'],
      distributorPhoneNo: json['DistributorPhoneNo'],
      orderCreatedDate: DateTime.parse(json['OrderCreatedDate']),
      orderCreatedById: json['OrderCreatedById'],
      orderCreatedBy: json['OrderCreatedBy'],
    );
  }
}

class Products {
  final int id;
  final String name;
  final String type;
  final int volumeInMl; // This is an int
  final int quantityInPack; // This is an int
  final int itemQuantity;
  final double distributorPrice;
  final String image;
  int manualQuantity;

  Products({
    required this.id,
    required this.name,
    required this.type,
    required this.volumeInMl,
    required this.quantityInPack,
    required this.itemQuantity,
    required this.distributorPrice,
    required this.image,
    this.manualQuantity = 0,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['ProductId'],
      name: json['ProductName'],
      type: json['ProductType'],
      volumeInMl: json['VolumeInMl'].toInt(), // Convert double to int
      quantityInPack: json['QuantityInPack'].toInt(), // Convert double to int
      itemQuantity: json['ItemQuantity'],
      distributorPrice:
          json['DistributorPrice'].toDouble(), // Ensure this is a double
      image: json['ImageName'],
      manualQuantity: json['ItemQuantity'],
    );
  }
}

class ShopScreen4 extends StatefulWidget {
  final orderId;

  const ShopScreen4({
    Key? key,
    this.orderId,
  }) : super(key: key);

  @override
  _ShopScreen3State createState() => _ShopScreen3State();
}

class _ShopScreen3State extends State<ShopScreen4> {
  List<Products> products = [];
  OrderData? orderDetails;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
          '${Constants.BASE_URL}/api/App/GetDistOrderDetailsByOrderId?OrderId=${widget.orderId}&appDateTime=${getCurrentDateTime()}'),
      headers: {'Authorization': '6XesrAM2Nu'},
    );
    print('PrimarySaleEditRequest${response.request}');
    print('PrimarySaleEditResponse${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      errorMessage = jsonResponse['Message'];

      final orderData = jsonResponse['Data'][0];
      orderDetails = OrderData.fromJson(orderData);
      products = (orderData['Products'] as List)
          .map((product) => Products.fromJson(product))
          .toList();
    } else if (response.statusCode == 410) {
      // errorMessage = jsonResponse['Message'];
      print('ErrorMessage$errorMessage');
      throw Exception('Failed to load product data');
    } else {
      throw Exception('Failed to load product data');
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
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
    print('SelectedProducts$selectedProducts');
    if (selectedProducts.isNotEmpty) {
      // Navigate to checkout screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen2(
            products: selectedProducts, // Send edited products
            orderId: widget.orderId,
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
          title: const Text('Edit Distributor Order'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Show loader while loading
              )
            : Column(
                children: [
                  // Container(
                  //   height: 100,
                  //   child: ListView.builder(
                  //     itemCount: products.length,
                  //     itemBuilder: (context, index) {
                  //       final product = products[index];
                  //       return Padding(
                  //         padding:
                  //         const EdgeInsets.only(top: 20, left: 20, right: 20),
                  //         child: Container(
                  //           padding: const EdgeInsets.all(15),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(12),
                  //             border: Border.all(color: Colors.redAccent, width: 2),
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.grey.withOpacity(0.3),
                  //                 spreadRadius: 5,
                  //                 blurRadius: 10,
                  //                 offset: Offset(0, 3),
                  //               ),
                  //             ],
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text(
                  //                 product.name,
                  //                 style: TextStyle(
                  //                   fontSize: 15,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.black87,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 5),
                  //
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  Expanded(
                    child: isLoading
                        ? Center(child: Text(errorMessage!))
                        : products.isEmpty
                            ? const Center(child: Text('No products found'))
                            : ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: product.image != null &&
                                                    product.image.isNotEmpty
                                                ? (product.image.startsWith(
                                                        'data:image')
                                                    ? Image.memory(
                                                        base64Decode(product
                                                            .image
                                                            .split(',')
                                                            .last),
                                                        width: 50,
                                                        height: 50,
                                                        // fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        '${product.image}',
                                                        width: 50,
                                                        height: 50,
                                                        // fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            const Center(
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 30,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ))
                                                : const Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13)),
                                                const SizedBox(height: 4),
                                                Text(
                                                    'Distributor Price: ${product.distributorPrice}\nQuantity in Pack: ${product.quantityInPack}',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600)),
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
                                                      icon: const Icon(
                                                          Icons.remove),
                                                      onPressed: () {
                                                        _decreaseQuantity(
                                                            product);
                                                      }),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  // Display the current quantity
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _showQuantityDialog(
                                                            product), // To manually update quantity
                                                    child: Text(
                                                      product.manualQuantity
                                                          .toString(), // Show manual quantity, which reflects the editable state
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
                                                      onPressed: () {
                                                        _increaseQuantity(
                                                            product);
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.red[50],
  //     appBar: AppBar(
  //       backgroundColor: Colors.redAccent,
  //       title: Text(orderDetails?.distributorName ?? 'Shop Products'),
  //     ),
  //     body: isLoading
  //         ? Center(child: CircularProgressIndicator())
  //         : products.isEmpty
  //         ? Center(child: Text('No products found'))
  //         : ListView.builder(
  //       itemCount: products.length,
  //       itemBuilder: (context, index) {
  //         final product = products[index];
  //         return Card(
  //           margin: EdgeInsets.all(10),
  //           child: ListTile(
  //             leading: Image.network('http://kcapiqa.fscscampus.com/${product.image}', width: 50, height: 50),
  //             title: Text('${product.name} ${product.volumeInMl}ml'),
  //             subtitle: Text('Price: ${product.distributorPrice} | Pack: ${product.quantityInPack}'),
  //             trailing: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.remove),
  //                   onPressed: () {
  //                     setState(() {
  //                       if (product.manualQuantity > 0) product.manualQuantity--;
  //                     });
  //                   },
  //                 ),
  //                 Text('${product.manualQuantity}'),
  //                 IconButton(
  //                   icon: Icon(Icons.add),
  //                   onPressed: () {
  //                     setState(() {
  //                       product.manualQuantity++;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
