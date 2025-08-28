import 'dart:convert';

import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


import '../widgets/const.dart';

class OrderDetails {
  final int orderId;
  final String orderStatus;
  final String shopName;
  final String shopAddress;
  final String shopPhoneNo;
  final String shopLocation;
  final String orderCreatedDate; // New field
  final String orderCreatedById; // New field
  final String orderCreatedBy; // New field
  final String dsfId; // New field
  final String dsf; // New field
  final List<Product> products;

  OrderDetails({
    required this.orderId,
    required this.orderStatus,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhoneNo,
    required this.shopLocation,
    required this.orderCreatedDate, // New field
    required this.orderCreatedById, // New field
    required this.orderCreatedBy, // New field
    required this.dsfId, // New field
    required this.dsf, // New field
    required this.products,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    var productsList = json['Products'] as List;
    List<Product> products =
        productsList.map((i) => Product.fromJson(i)).toList();

    return OrderDetails(
      orderId: json['OrderId'],
      orderStatus: json['OrderStatus'],
      shopName: json['ShopName'],
      shopAddress: json['ShopAddress'],
      shopPhoneNo: json['ShopPhoneNo'],
      shopLocation: json['ShopLocation'],
      orderCreatedDate: json['OrderCreatedDate'], // New field
      orderCreatedById: json['OrderCreatedById'], // New field
      orderCreatedBy: json['OrderCreatedBy'], // New field
      dsfId: json['DSFId'], // New field
      dsf: json['DSF'], // New field
      products: products,
    );
  }
}

class Product {
  final int productId;
  final String productName;
  final String productType;
  final int volumeInMl;
  final int quantityInPack;
  final int itemQuantity;
  final double tradePrice;
  final String imageName;

  Product({
    required this.productId,
    required this.productName,
    required this.productType,
    required this.volumeInMl,
    required this.quantityInPack,
    required this.itemQuantity,
    required this.tradePrice,
    required this.imageName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['ProductId'],
      productName: json['ProductName'],
      productType: json['ProductType'],
      volumeInMl: json['VolumeInMl'],
      quantityInPack: json['QuantityInPack'],
      itemQuantity: json['ItemQuantity'],
      tradePrice: json['TradePrice'].toDouble(),
      imageName: json['ImageName'],
    );
  }
}

// Fetch Order Details function
Future<OrderDetails?> fetchOrderDetails(String orderId) async {
  final url =
      '${Constants.BASE_URL}/api/App/GetShopOrderDetailsByOrderId?OrderId=$orderId&appDateTime=${getCurrentDateTime()}';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data != null && data['Data'] != null && data['Data'].isNotEmpty) {
      // Parse the first item in the 'Data' array
      return OrderDetails.fromJson(data['Data'][0]);
    }
    print('Dta:$data');
  } else {
    throw Exception('Failed to load order details');
  }
  return null;
}

// Call the fetchOrderDetails function and use the OrderDetails and Product classes here
class OrderDetailsScreen1 extends StatefulWidget {
  final OrderId;

  const OrderDetailsScreen1({super.key, this.OrderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen1> {
  late Future<OrderDetails?> orderDetailsFuture;
  int getTotalQuantity(List<Product> products) {
    return products.fold(0, (sum, product) => sum + product.itemQuantity);
  }

  double getTotalAmount(List<Product> products) {
    return products.fold(0.0,
        (sum, product) => sum + (product.tradePrice * product.itemQuantity));
  }

  @override
  void initState() {
    super.initState();
    orderDetailsFuture = fetchOrderDetails(widget.OrderId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<OrderDetails?>(
        future: orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No order details found'));
          }

          final orderDetails = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        spreadRadius: 4,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '\u2022  ${orderDetails.orderStatus}  \u2022',
                                  style: GoogleFonts.cinzel(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Shop Name : ',
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: orderDetails.shopName,
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Shop Address : ',
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: orderDetails.shopAddress,
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Phone No : ',
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: orderDetails.shopPhoneNo,
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Order Date: ',
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: convertTo12HourFormat(
                                    orderDetails.orderCreatedDate),
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Order Created By: ',
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: orderDetails.orderCreatedBy,
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product List
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Products:',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderDetails.products
                      .where((product) => product.itemQuantity > 0)
                      .length,
                  itemBuilder: (context, prodIndex) {
                    final product = orderDetails.products
                        .where((product) => product.itemQuantity > 0)
                        .toList()[prodIndex];
                    return Card(
                      child: ListTile(
                     leading: product.imageName != null &&
                                product.imageName.isNotEmpty
                            ? (product.imageName.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(
                                        product.imageName.split(',').last),
                                    width: 50,
                                    height: 50,
                                    // fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    '${product.imageName}',
                                    width: 50,
                                    height: 50,
                                    // fit: BoxFit.cover,
                                  ))
                            : const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),

                        title: Text(
                          '${product.productName} (${product.volumeInMl} ml ${product.productType})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Trade Price: ${product.tradePrice}\n'
                          'Quantity in Pack: ${product.quantityInPack}\n',
                        ),
                        trailing: Column(
                          children: [
                            const Text(
                              'Qty:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '${product.itemQuantity}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity: ${getTotalQuantity(orderDetails.products)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total Amount: ${getTotalAmount(orderDetails.products).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: orderDetails.products.length,
                //   itemBuilder: (context, index) {
                //     final product = orderDetails.products[index];
                //     return Card(
                //       margin: EdgeInsets.symmetric(vertical: 8),
                //       child: Padding(
                //         padding: EdgeInsets.all(16),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               product.productName,
                //               style: TextStyle(
                //                   fontSize: 16, fontWeight: FontWeight.bold),
                //             ),
                //             SizedBox(height: 4),
                //             Text('Type: ${product.productType}'),
                //             Text('Volume: ${product.volumeInMl} ml'),
                //             Text('Quantity in Pack: ${product.quantityInPack}'),
                //             Text(
                //                 'Price: \$${product.tradePrice.toStringAsFixed(2)}'),
                //             Text('Quantity: ${product.itemQuantity}'),
                //             SizedBox(height: 8),
                //             Image.network(
                //               'http://kcapiqa.fscscampus.com/${product.imageName}',
                //               height: 100,
                //               fit: BoxFit.cover,
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
