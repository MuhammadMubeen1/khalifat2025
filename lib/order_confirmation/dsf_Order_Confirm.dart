import 'dart:convert';

import 'package:KhilafatCola/order_confirmation/dsf_cart_details.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../utils/widgets.dart';
import '../widgets/const.dart';

class DSFOrderHistoryScreen extends StatefulWidget {
  final int initialTabIndex;
  const DSFOrderHistoryScreen({super.key, this.initialTabIndex = 0});
  @override
  _DSFOrderHistoryScreenState createState() => _DSFOrderHistoryScreenState();
}

class _DSFOrderHistoryScreenState extends State<DSFOrderHistoryScreen> {
  String selectedDateTime = '';
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true; // Variable to store selected date and time

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<List<dynamic>> fetchDealershipData(String statusId) async {
    final response = await http.get(
      Uri.parse(
        '${Constants.BASE_URL}/api/App/GetShopOrderStatusWiseByDateDfsId?userId=$userid&statusId=$statusId&appDateTime=${getCurrentDateTime()}&orderDate=$selectedDateTime',
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

  Future<List<dynamic>> getfetchDealershipData(String statusId) async {
    final response = await http.get(
      Uri.parse(
        '${Constants.BASE_URL}/api/App/GetShopOrderStatusWiseByDateDfsId?userId=$userid&statusId=$statusId&appDateTime=${getCurrentDateTime()}&orderDate=${getCurrentDateTime()}',
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

  String convertTo12HourFormat(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    String formattedDate = DateFormat('MMMM d, y').format(dateTime);
    return formattedDate;
  }

  String convertIsoToNormalFormat(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    String formattedDate = DateFormat('MMMM d, y hh:mm a').format(dateTime);
    return formattedDate;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Select Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Select Time after selecting Date
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date and Time into a single DateTime object
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the DateTime and store it in the variable
        setState(() {
          this.selectedDateTime = DateFormat('yyyy-MM-dd')
              .format(selectedDateTime); // Store selected date and time
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data when this screen is shown
    refreshData();
  }

  void refreshData() {
    fetchDealershipData("1");
    fetchDealershipData("2");
    fetchDealershipData("3");
    fetchDealershipData("4");
    fetchDealershipData("5");
    // Call fetchDealershipData for each statusId to refresh the data
    setState(() {
      // This will call the FutureBuilders to re-fetch data
    });
  }

  @override
  void initState() {
    _checkInitialConnection();
    _listenToConnectionChanges();

    selectedDateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());
    fetchDealershipData("1");
    fetchDealershipData("2");
    fetchDealershipData("3");
    fetchDealershipData("4");
    fetchDealershipData("5");
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Apply custom theme for the date picker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Format and set the selected date
      setState(() {
        selectedDateTime =
            DateFormat('yyyy-MM-dd').format(pickedDate); // Only show date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetScreen(onRetry: _checkInitialConnection)
        : DefaultTabController(
            length: 5,
            initialIndex: widget.initialTabIndex, // Number of tabs
            child: Scaffold(
              
              backgroundColor: Colors.red[50],
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                centerTitle: true,
                backgroundColor: Colors.redAccent,
                title: const Text("Shop Order", style: TextStyle(color: Colors.white),),
                bottom:  TabBar(
                    labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(color: Colors.grey.shade200),
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Created"),
                    Tab(text: "Confirm"),
                    Tab(text: "Dispatched"),
                    Tab(text: "Received"),
                    Tab(text: "Canceled"),
                    // Tab(text: "Return"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShopScreen2()));
                    },
                    child: const Visibility(
                      visible: false,
                      child: Text(
                        "New Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => _selectDate(context), // Click action
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // Button padding
                          decoration: BoxDecoration(
                            color: Colors.redAccent, // Background color
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Subtle shadow effect
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center, // Centers text inside
                          child: const Text(
                            "Select Date",
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontWeight: FontWeight.w600, // Font weight
                              fontSize:
                                  16, // Adjusted size for better visibility
                            ),
                          ),
                        ),
                      ),

                    ),
                  ),
                  if (selectedDateTime.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Selected Date: ${convertTo12HourFormat(selectedDateTime)}",
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOrderTab('1'),
                        _buildOrderTab('2'),
                        _buildOrderTab('3'),
                        _buildOrderTab('4'),
                        _buildOrderTab('5'),
                        // _buildOrderTab('6'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildOrderTab(String statusId) {
    return FutureBuilder<List<dynamic>>(
      future: fetchDealershipData(statusId),
      builder: (context, snapshot) {
        return _buildOrderList(snapshot);
      },
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

      return data.isNotEmpty
          ? ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var dealership = data[index];
                var shopName = dealership['ShopName'];
                var shopAddress = dealership['ShopAddress'];
                var shopPhoneNumber = dealership['ShopPhoneNo'];
                var orderDate = dealership['OrderCreatedDate'];
                var orderStatus = dealership['OrderStatus'];
                var products = dealership['Products'];
                double totalPrice = products.fold(
                    0,
                    (sum, item) =>
                        sum + (item['TradePrice'] * item['ItemQuantity']));
                int totalQuantity =
                    products.fold(0, (sum, item) => sum + item['ItemQuantity']);
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
                        'Address: $shopAddress \nOrder Date: ${convertTo12HourFormat(orderDate)}\nPhone Number: $shopPhoneNumber \nOrder Date: ${convertTo12HourFormat(orderDate)} \nOrder Status: $orderStatus'),
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 15.0),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Phone Number:',
                      //         style: TextStyle(
                      //             fontSize: 18, fontWeight: FontWeight.bold),
                      //       ),
                      //       SizedBox(
                      //         width: 5,
                      //       ),
                      //       Text(
                      //         shopPhoneNumber,
                      //         style: TextStyle(
                      //             fontSize: 18, fontWeight: FontWeight.bold),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 15.0),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Order Date:',
                      //         style: TextStyle(
                      //             fontSize: 18, fontWeight: FontWeight.bold),
                      //       ),
                      //       SizedBox(
                      //         width: 5,
                      //       ),
                      //       Text(
                      //         convertTo12HourFormat(orderDate),
                      //         style: TextStyle(
                      //             fontSize: 18, fontWeight: FontWeight.bold),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // ListTile(
                      //   title: Text('Order Date:'),
                      //   subtitle: Text(convertTo12HourFormat(orderDate)),
                      // ),
                      const Divider(),
                      const Text(
                        'Products:',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
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
                                      ? (product['ImageName']
                                              .startsWith('data:image')
                                          ? Image.memory(
                                              base64Decode(product['ImageName']
                                                  .split(',')
                                                  .last),
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
                                        
                                        ),

                                  title: Text(
                                    '${product['ProductName']} (${product['VolumeInMl']} ml ${product['ProductType']})',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Trade Price: ${product['TradePrice']}\n'
                                    'Quantity in Pack: ${product['QuantityInPack']}\n',
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
                                        '${product['ItemQuantity']}',
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
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Quantity: $totalQuantity',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  'Total Price: $totalPrice',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                          )
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(
                          //     'Total Quantity: $totalQuantity Total Price: ${totalPrice.toStringAsFixed(2)}',
                          //     style: TextStyle(
                          //         fontSize: 16, fontWeight: FontWeight.bold),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // )
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : FutureBuilder(
              future: Future.delayed(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Order Available",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }
              },
            );
    } else {
      return const Center(child: Text('No Data Available'));
    }
  }
}
