
import 'dart:convert';

import 'package:KhilafatCola/Shop/Shop_Hisotry_Screen.dart';
import 'package:KhilafatCola/Shop/Shop_Order_Detail_Screen.dart';
import 'package:KhilafatCola/order_confirmation/dsf_cart_details.dart';
import 'package:KhilafatCola/utils/NoInternetScreen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../widgets/const.dart';

class ShopOrderScreen extends StatefulWidget {
  const ShopOrderScreen({super.key});

  @override
  _ShopOrderScreenState createState() => _ShopOrderScreenState();
}

class _ShopOrderScreenState extends State<ShopOrderScreen> {
  String selectedDateTime = ''; // Variable to store selected date and time
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleNo = TextEditingController();
  final TextEditingController _confirmComment = TextEditingController();
  final TextEditingController _cancelComment = TextEditingController();

  final TextEditingController _driverName = TextEditingController();
  final TextEditingController _driverPhoneNo = TextEditingController();
  final TextEditingController _deliveryChallan = TextEditingController();
  final TextEditingController _deliveryTime = TextEditingController();
  final TextEditingController _comments = TextEditingController();
  String inputText = '';
  var orderId;
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  void clearAllFields() {
    _vehicleNo.clear();
    _confirmComment.clear();
    _cancelComment.clear();
    _driverName.clear();
    _driverPhoneNo.clear();
    _deliveryChallan.clear();
    _deliveryTime.clear();
    _comments.clear();
  }

  Future<void> _selectDates(
      BuildContext context, TextEditingController controller) async {
    // Pick the date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the date as 'yyyy-MM-dd'
        final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

        // Set the formatted date to the controller
        controller.text = formattedDate;
      });
    }
  }

  Future<void> DispatchOrder(String vehical, String drivername, String orderId,
      String driverphone, String time, String comments) async {
    // API URL
    String url = '${Constants.BASE_URL}/api/App/DispatchShopOrder';

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Request body
    final body = {
      "orderId": orderId,
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "deliveryDateTime": getCurrentDateTime(),
      "vehicleNo": vehical,
      "driverName": drivername,
      "driverPhoneNo": driverphone,
      "comments": comments
    };
    print('Print Body $body');
    try {
      setState(() {
        _isLoading = true;
      });
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);
      // Check if the request was successful

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // After getting a response from the API
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //     msg: 'Invalid Email & Password',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black
      // );
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> ReceivedOrder(
    String comments,
    String deliverychallan,
    String orderId,
  ) async {
    // API URL
    String url = '${Constants.BASE_URL}/api/App/ReceiveShopOrder';

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Request body
    final body = {
      "orderId": orderId,
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "deliveryChallanCode": deliverychallan,
      "comments": comments
    };
    print('Print Body $body');
    try {
      setState(() {
        _isLoading = true;
      });
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);
      // Check if the request was successful

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // After getting a response from the API
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //     msg: 'Invalid Email & Password',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black
      // );
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> shoporder(String fromstatus, String tostatus, String orderId,
      String confirmedComment) async {
    // API URL
    String url = '${Constants.BASE_URL}/api/App/UpdateShopOrderStatus';

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Request body
    final body = {
      "userId": userid,
      "appDateTime": getCurrentDateTime(),
      "orderId": orderId,
      "fromStatusId": fromstatus,
      "toStatusId": tostatus,
      "comments": confirmedComment
    };
    print(body);
    try {
      setState(() {
        _isLoading = true;
      });
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);
      // Check if the request was successful

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // After getting a response from the API
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //     msg: 'Invalid Email & Password',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black
      // );
      print('Error during login: $error');
    } finally {
      // Once API call is done, hide the loader and show the button again
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchDealershipData(String statusId) async {
    String url =
        '${Constants.BASE_URL}/api/App/GetShopOrderStatusWiseByDateSupId?userId=$userid&statusId=$statusId&appDateTime=${getCurrentDateTime()}&orderDate=$selectedDateTime';
    final response = await http.get(
      Uri.parse(
        url,
      ),
      headers: {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json',
      },
    );
    print(url);
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

    selectedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
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
    return
    //  !_isConnected
    //     ? NoInternetScreen(onRetry: _checkInitialConnection)
    //     : 
        DefaultTabController(
            length: 5, // Number of tabs
            child: Scaffold(
              backgroundColor: Colors.red[50],
              appBar: AppBar(
                centerTitle: true,
                iconTheme:const   IconThemeData(color: Colors.white),
                backgroundColor: Colors.redAccent,
                title: const Text("Shop Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 22, ),),
                bottom:  TabBar(
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(color: Colors.grey.shade200),
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  isScrollable: true,
                  tabs:const  [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     // Ensures proper spacing
                    children: [
                      // Select Date Button
                   Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () => _selectDate(context), // Click action
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Padding for button-like feel
                            decoration: BoxDecoration(
                              color: Colors.redAccent, // Background color
                              borderRadius:
                                  BorderRadius.circular(5), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Subtle shadow
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center, // Centers the text
                            child: const Text(
                              "Select Date",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Selected Date Display (Flexible to prevent overflow)
                      if (selectedDateTime.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Text(
                            convertTo12HourFormat(selectedDateTime),
                            style: const TextStyle(fontSize: 15.0),
                            // overflow: TextOverflow
                            //     .ellipsis, // Prevents long text overflow
                            softWrap: false,
                          ),
                        ),

                      // Refresh Button
                     Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            for (int i = 1; i <= 5; i++) {
                              fetchDealershipData(i.toString());
                            }
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Adds vertical padding
                            decoration: BoxDecoration(
                              color: Colors.redAccent, // Button color
                              borderRadius:
                                  BorderRadius.circular(5), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Subtle shadow effect
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment:
                                Alignment.center, // Centers the text inside
                            child: const Text(
                              'Refresh',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
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
        return _buildOrderList(snapshot, statusId);
      },
    );
  }

  Widget _buildOrderList(AsyncSnapshot<List<dynamic>> snapshot, String id) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('No Data Available'));
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
                // orderId = dealership['OrderId'];
                var shopName = dealership['ShopName'];
                var shopAddress = dealership['ShopAddress'];
                var shopPhoneNumber = dealership['ShopPhoneNo'];
                var orderDate = dealership['OrderCreatedDate'];
                var orderStatus = dealership['OrderStatus'];
                var fromstatus = dealership['OrderStatusId'];
                var orderIde = dealership['OrderId'];
                var products = dealership['Products'];
                var vehicalname = dealership["VehicleNo"];
                var DriverName = dealership["DriverName"];
                var DriverPhoneNo = dealership["DriverPhoneNo"];
                var DeliveryChallanCode = dealership["DeliveryChallanCode"];

                return _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      ) // Show loader while loading
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        child: Container(
                          height: 170,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, right: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 270,
                                      height: 110,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Shop Name : ',
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                TextSpan(
                                                  text: shopName,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                TextSpan(
                                                  text: shopAddress,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Order Date : ',
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                TextSpan(
                                                  text: convertTo12HourFormat(
                                                      orderDate),
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Order Status : ',
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                TextSpan(
                                                  text: orderStatus,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShopOrderDetailScreen(
                                                      products: products,
                                                      shopName: shopName,
                                                      shopAddress: shopAddress,
                                                      date: orderDate,
                                                      Status: orderStatus,
                                                      Number: shopPhoneNumber,
                                                      vehicalname: vehicalname,
                                                      drivername: DriverName,
                                                      driverPhone:
                                                          DriverPhoneNo,
                                                      kcnumber:
                                                          DeliveryChallanCode,
                                                    )));
                                      },
                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      id == "1"
                                          ? InkWell(
                                              onTap: () {
                                                {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Cancel Order'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Text(
                                                                'Are you sure you want to cancel this order?'),
                                                            const SizedBox(
                                                                height: 16),
                                                            TextField(
                                                              controller:
                                                                  _confirmComment,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Enter Comments',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                'Cancel'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                'Yes'),
                                                            onPressed: () {
                                                              shoporder(
                                                                  fromstatus
                                                                      .toString(),
                                                                  '2',
                                                                  orderIde
                                                                      .toString(),
                                                                  _confirmComment
                                                                      .text);
                                                              clearAllFields(); // Pass inputText to the function
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Order Confirmed!')),
                                                              );

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              // Close the dialog
                                                              // Proceed to confirm the order
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: InkWell(
                                                child: Visibility(
                                                  visible: id ==
                                                      "1", // Show button only if id == 2

                                                  child: Container(
                                                    height: 30,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.green
                                                              .withOpacity(0.4),
                                                          spreadRadius: 4,
                                                          blurRadius: 3,
                                                          offset: const Offset(
                                                              0,
                                                              2), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Confirm Order'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min, // To make the dialog compact
                                                                    children: [
                                                                      const Text(
                                                                          'Are you sure you want to confirm this order?'),
                                                                      const SizedBox(
                                                                          height:
                                                                              16),
                                                                      TextField(
                                                                        controller:
                                                                            _confirmComment,
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          labelText:
                                                                              'Enter comments',
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(); // Close the dialog
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: const Text(
                                                                          'Yes'),
                                                                      onPressed:
                                                                          () {
                                                                        shoporder(
                                                                            fromstatus.toString(),
                                                                            '2',
                                                                            orderIde.toString(),
                                                                            _confirmComment.text);
                                                                        clearAllFields(); // Pass inputText to the function
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        // Proceed to confirm the order
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Text(
                                                            'Confirm',
                                                            style: GoogleFonts
                                                                .lato(
                                                                    color: Colors
                                                                        .black),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                _showdispatchsheet(context,
                                                    orderIde.toString());
                                              },
                                              child: Visibility(
                                                visible: id ==
                                                    "2", // Show button only if id == 2

                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange
                                                            .withOpacity(0.4),
                                                        spreadRadius: 4,
                                                        blurRadius: 3,
                                                        offset: const Offset(0,
                                                            2), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: InkWell(
                                                        onTap: () {
                                                          _showdispatchsheet(
                                                              context,
                                                              orderIde
                                                                  .toString());
                                                        },
                                                        child: Text(
                                                          'Dispatch',
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .black),
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      InkWell(
                                        onTap: () {
                                          _showrecivesheet(
                                              context, orderIde.toString());
                                        },
                                        child: Visibility(
                                          visible: id == '3',
                                          child: Container(
                                            height: 30,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.4),
                                                  spreadRadius: 4,
                                                  blurRadius: 3,
                                                  offset: const Offset(0,
                                                      2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: InkWell(
                                                  onTap: () {
                                                    _showrecivesheet(context,
                                                        orderIde.toString());
                                                  },
                                                  child: Text(
                                                    'Received',
                                                    style: GoogleFonts.lato(
                                                        color: Colors.black),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Cancel Order'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                        'Are you sure you want to cancel this order?'),
                                                    const SizedBox(height: 16),
                                                    TextField(
                                                      controller:
                                                          _cancelComment,
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'Enter Comments',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () {
                                                      shoporder(
                                                          fromstatus.toString(),
                                                          '5',
                                                          orderIde.toString(),
                                                          _cancelComment.text);
                                                      clearAllFields(); // Pass inputText to the function
                                                      Navigator.of(context)
                                                          .pop();

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Order Cancelled!')),
                                                      );
                                                      // Close the dialog
                                                      // Proceed to confirm the order
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Visibility(
                                          visible: id == '1',
                                          child: Container(
                                            height: 30,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red
                                                      .withOpacity(0.4),
                                                  spreadRadius: 4,
                                                  blurRadius: 3,
                                                  offset: const Offset(0,
                                                      2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Cancel Order'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                  'Are you sure you want to cancel this order?'),
                                                              const SizedBox(
                                                                  height: 16),
                                                              TextField(
                                                                controller:
                                                                    _cancelComment,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  labelText:
                                                                      'Enter Comments',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Yes'),
                                                              onPressed: () {
                                                                shoporder(
                                                                    fromstatus
                                                                        .toString(),
                                                                    '5',
                                                                    orderIde
                                                                        .toString(),
                                                                    _cancelComment
                                                                        .text);
                                                                clearAllFields(); // Pass inputText to the function
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Order Cancelled!')),
                                                                );
                                                                clearAllFields(); // Close the dialog
                                                                // Proceed to confirm the order
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    'Cancel',
                                                    style: GoogleFonts.lato(
                                                        color: Colors.black),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderProcessScreen(
                                                        orderId:
                                                            orderIde.toString(),
                                                      )));
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                                spreadRadius: 4,
                                                blurRadius: 3,
                                                offset: const Offset(0,
                                                    2), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              OrderProcessScreen(
                                                                orderId: orderIde
                                                                    .toString(),
                                                              )));
                                                },
                                                child: Text(
                                                  'History',
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
              },
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

  void _showrecivesheet(BuildContext context, String orderIDD) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the sheet to take up more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Ensure the bottom sheet resizes with the keyboard
            ),
            child: Container(
              // height: MediaQuery.of(context)
              //     .size
              //     .height/2, // Use the full height of the screen
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fill below fields for receiving :',
                              style: GoogleFonts.lato(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              keyboardType: TextInputType.text,
                              controller: _deliveryChallan,

                              // inputFormatters: [
                              //   TextInputFormatter.withFunction(
                              //         (oldValue, newValue) {
                              //       String newText = newValue.text;
                              //       if (newText.length > oldValue.text.length) {
                              //         if (newText.length == 4 || newText.length == 7) {
                              //           newText = newText.substring(0, newText.length - 1) +
                              //               '-' +
                              //               newText.substring(newText.length - 1);
                              //         }
                              //       }
                              //       return TextEditingValue(
                              //         text: newText,
                              //         selection: newValue.selection,
                              //       );
                              //     },
                              //   ),
                              // ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelText: 'Enter Delivery Challan Code',
                                hintText: 'KCS-78-41',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _comments,
                              decoration: InputDecoration(
                                hintText: 'Enter Comments',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                final delivery = _deliveryChallan.text;

                                // Ensure the delivery code is not empty and does not match the predefined DeliveryChallanCode
                                // if (delivery.isNotEmpty && delivery == DeliveryChallanCode) {
                                ReceivedOrder(
                                  _comments.text,
                                  _deliveryChallan.text,
                                  orderIDD,
                                );
                                clearAllFields();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Order Received!')),
                                );
                                print('deliveryCode:$delivery');
                                print('orderIDD$orderIDD');
                                Navigator.of(context).pop();
                                // } else {
                                //   print('deliveryCode:$delivery');
                                //   print('orderIDD$orderIDD');
                                //   // Show an alert dialog if the delivery code is empty or matches DeliveryChallanCode
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: Text("Invalid Challan Code!"),
                                //         content: Text(
                                //             "Make sure to enter valid challan code."),
                                //         actions: [
                                //           TextButton(
                                //             onPressed: () {
                                //               Navigator.of(context)
                                //                   .pop(); // Close the dialog
                                //             },
                                //             child: Text("OK"),
                                //           ),
                                //         ],
                                //       );
                                //     },
                                //   );
                                // }
                              },
                              child: Center(
                                child: Container(
                                  height: 30,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB71234),
                                        Color(0xFFF02A2A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(90),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Received',
                                      style:
                                          GoogleFonts.lato(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showdispatchsheet(BuildContext context, String OrderIdd) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the sheet to take up more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Ensure the bottom sheet resizes with the keyboard
            ),
            child: Container(
              // height: MediaQuery.of(context)
              //     .size
              //     .height/2, // Use the full height of the screen
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Define a GlobalKey for FormState

                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fill below fields for dispatch:',
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _driverName,
                                decoration: InputDecoration(
                                  hintText: 'Enter Driver Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Driver Name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _vehicleNo,
                                decoration: InputDecoration(
                                  hintText: 'Enter Vehicle No',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Vehicle No';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _driverPhoneNo,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                    mask: '####-#######',
                                    filter: {"#": RegExp(r'[0-9]')},
                                  ),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Enter Driver Phone No',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length != 12) {
                                    return 'Please enter a valid Phone No';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _deliveryTime,
                                readOnly: true,
                                onTap: () {
                                  _selectDates(context, _deliveryTime);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Delivery Time',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Delivery Time';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _comments,
                                decoration: InputDecoration(
                                  hintText: 'Enter Comments',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  // clearAllFields();
                                  // Validate all form fields
                                  if (_formKey.currentState!.validate()) {
                                    DispatchOrder(
                                        _vehicleNo.text,
                                        _driverName.text,
                                        OrderIdd,
                                        _driverPhoneNo.text,
                                        _deliveryTime.text,
                                        _comments.text);
                                    clearAllFields();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Order Dispatched!')),
                                    );

                                    Navigator.of(context).pop();
                                  } else {
                                    // Display an error message if validation fails
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Incomplete Fields'),
                                          content: const Text(
                                              'Please complete all fields.'),
                                          actions: [
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFB71234),
                                          Color(0xFFF02A2A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Dispatch',
                                        style: GoogleFonts.lato(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
