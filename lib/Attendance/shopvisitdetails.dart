import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../widgets/Splash.dart';
import '../widgets/const.dart';

class ShopVisitDetailsScreen extends StatefulWidget {
  final visitedId;
  final orderId;

  const ShopVisitDetailsScreen({super.key, this.visitedId, this.orderId});

  @override
  State<ShopVisitDetailsScreen> createState() => _ShopVisitDetailsScreenState();
}

class _ShopVisitDetailsScreenState extends State<ShopVisitDetailsScreen> {
  ////////////////////////////////////////////////////////////////////////////
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

  ////////////////////////////////////////////////////////////////////////////
  bool isLoading = false;
  List<Map<String, dynamic>> myteam = [];
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    fetchMyTeamData1();
    fetchOrderDetails();
    selectedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    //startAutoRefresh();
    print('Order ID ${widget.orderId}');
    super.initState();
  }

  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      fetchMyTeamData1(); // Call the API every 5 seconds
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data when this screen is shown
    refreshData();
  }

  void refreshData() {
    fetchMyTeamData1();
    fetchOrderDetails();
    setState(() {
      // This will call the FutureBuilders to re-fetch data
    });
  }

  Future<void> fetchMyTeamData1() async {
    final String url =
        '${Constants.BASE_URL}/api/App/GetMarkShopVisitsById?markShopVisitsId=${widget.visitedId}&appDateTime=${getCurrentDateTime()}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            myteam = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Shop Visit Details'),
        ),
        body: Column(
          // Adjust based on your needs
          children: [
            SizedBox(
              height: 200,
              child: myteam.isNotEmpty
                  ? ListView.builder(
                      itemCount: myteam.length,
                      itemBuilder: (context, index) {
                        final teamMember = myteam[index];
                        return Column(
                          children: [
                            Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: Colors.grey.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                     CircleAvatar(
                                        backgroundImage: userImage != null &&
                                                userImage.isNotEmpty
                                            ? (userImage
                                                    .startsWith('data:image')
                                                ? MemoryImage(
                                                    base64Decode(userImage
                                                        .split(',')
                                                        .last),
                                                  )
                                                : NetworkImage(
                                                        '$userImage')
                                                    as ImageProvider)
                                            : const AssetImage(
                                                'assets/default_avatar.png'),
                                      ),

                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              teamMember['IsOpen'] == true
                                                  ? 'The Shop was Open'
                                                  : 'The Shop was closed',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Comments: ${teamMember['Comments']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Visited On: \n${convertTo12HourFormat(teamMember['VisitOn'])}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Visited By : ${teamMember['VisitBy']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 5)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "No Data Available",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                      },
                    ),
            ),
            const SizedBox(height: 10), // Add some spacing
            widget.orderId != null
                ? Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchOrderDetails(),
                      builder: (context, snapshot) {
                        return _buildOrderList(snapshot);
                      },
                    ),
                  )
                : FutureBuilder(
                    future: Future.delayed(const Duration(seconds: 5)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "The Shop was closed or Order was not taken",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                    },
                  ),
          ],
        ));
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

          // Calculate total price and quantity for items where ItemQuantity > 0
          double totalPrice = products.fold(
            0,
            (sum, item) => item['ItemQuantity'] > 0
                ? sum + (item['TradePrice'] * item['ItemQuantity'])
                : sum,
          );
          int totalQuantity = products.fold(
            0,
            (sum, item) =>
                item['ItemQuantity'] > 0 ? sum + item['ItemQuantity'] : sum,
          );

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              initiallyExpanded: true,
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
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      const Text(
                        'Phone Number:',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        shopPhoneNumber,
                        style: const TextStyle(fontSize: 15),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      const Text(
                        'Address',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        shopAddress,
                        style: const TextStyle(fontSize: 15),
                      )
                    ],
                  ),
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
                    // Only display items with ItemQuantity > 0
                    if (product['ItemQuantity'] > 0) {
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
                                    
                                    )
                                  : Image.network(
                                      '${product['ImageName']}',
                                      width: 50,
                                      height: 50,
                                    
                                    ))
                              : Image.asset(
                                  'assets/default_image.png', // Fallback local image
                                  width: 50,
                                  height: 50,
                              
                                ),

                          subtitle: Text(
                            '${product['ProductName']} (${product['VolumeInMl']} ml ${product['ProductType']})\nTrade Price: ${product['TradePrice']}\nQuantity in Pack: ${product['QuantityInPack']}',
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'QTY',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                product['ItemQuantity'].toString(),
                                style: const TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox
                          .shrink(); // Return an empty widget if quantity <= 0
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Quantity: $totalQuantity',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Total Price: $totalPrice',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    ],
                  ),
                )
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
    print('Order Id ${widget.orderId}');
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
                                 
                                  )
                                : Image.network(
                                    '${product['ImageName']}',
                                    width: 50,
                                    height: 50,
                                
                                  ))
                            : Image.asset(
                                'assets/default_image.png', // Fallback local image
                                width: 50,
                                height: 50,
                             
                              ),

                        subtitle: Text(
                          '${product['ProductName']} (${product['VolumeInMl']} ml ${product['ProductType']})\nWholesale Price: ${product['WholeSalePrice']}\nQuantity in Pack: ${product['QuantityInPack']}\nItem Quantity: ${product['ItemQuantity']}',
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
