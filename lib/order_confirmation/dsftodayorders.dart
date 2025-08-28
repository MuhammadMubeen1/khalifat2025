import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../widgets/const.dart';

class DSFOrderHistoryScreen1 extends StatefulWidget {
  final orderId;
  const DSFOrderHistoryScreen1({super.key, this.orderId});
  @override
  _DSFOrderHistoryScreenState createState() => _DSFOrderHistoryScreenState();
}

class _DSFOrderHistoryScreenState extends State<DSFOrderHistoryScreen1> {
  String selectedDateTime = ''; // Variable to store selected date and time
  Future<List<dynamic>> fetchOrderDetails() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.BASE_URL}/api/App/GetShopOrderDetailsByOrderId?OrderId=${widget.orderId}&appDateTime=${getCurrentDateTime()}',
      ),
      headers: {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  String getCurrentDateTime() {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  }

  String convertTo12HourFormat(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Today DSF Orders"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchOrderDetails(),
              builder: (context, snapshot) {
                return _buildOrderList(snapshot);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(AsyncSnapshot<List<dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (snapshot.hasData) {
      var data = snapshot.data!;
      if (data.isEmpty) {
        return const Center(child: Text('No Data Available'));
      }

      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var dealership = data[index];
          var shopName = dealership['ShopName'];
          var shopAddress = dealership['ShopAddress'];
          var shopPhoneNumber = dealership['ShopPhoneNo'];
          var orderDate = dealership['OrderCreatedDate'];
          var orderStatus = dealership['OrderStatus'];
          var products = dealership['Products'];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              collapsedIconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              title: Text(
                'Shop Name: $shopName',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Address: $shopAddress \nOrder Date: ${convertTo12HourFormat(orderDate)} \nOrder Status: $orderStatus'),
              children: [
                ListTile(
                  title: const Text('Phone Number:'),
                  subtitle: Text(shopPhoneNumber),
                ),
                ListTile(
                  title: const Text('Order Date:'),
                  subtitle: Text(convertTo12HourFormat(orderDate)),
                ),
                const Divider(),
                const Text(
                  'Products:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, prodIndex) {
                    var product = products[prodIndex];
                    return Card(
                      child: ListTile(
                       leading: product['ImageName'] != null &&
                                product['ImageName'].isNotEmpty
                            ? (product['ImageName'].startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(
                                        product['ImageName'].split(',').last),
                                    width: 50,
                                    height: 50,
                                    // fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    '${product['ImageName']}',
                                    width: 50,
                                    height: 50,
                                    // fit: BoxFit.cover,
                                  ))
                            : Image.asset(
                                'assets/default_image.png',
                                width: 50,
                                height: 50,
                                // fit: BoxFit.cover,
                              ),

                        subtitle: Text(
                          '${product['ProductName']} (${product['VolumeInMl']} ml ${product['ProductType']})\nTrade Price: ${product['TradePrice']}\nQuantity in Pack: ${product['QuantityInPack']}\nItem Quantity: ${product['ItemQuantity']}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No Data Available'));
    }
  }
}
