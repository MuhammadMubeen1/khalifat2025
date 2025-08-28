  import 'dart:convert';
  import 'package:KhilafatCola/Supervisor/distributor_selection_screen.dart';
  import 'package:KhilafatCola/utils/NoInternetScreen.dart';
  import 'package:KhilafatCola/widgets/Splash.dart';
  import 'package:connectivity_plus/connectivity_plus.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:hive/hive.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
  import '../Supervisor/primary_sale_edit_screen.dart';
  import '../utils/widgets.dart';
  import '../widgets/const.dart';
  import '../widgets/primarysaleconstentid.dart';
  import 'blinking.dart';

  class SupervisorOrderHistoryScreen extends StatefulWidget {
    const SupervisorOrderHistoryScreen({super.key});

    @override
    _SupervisorOrderHistoryScreenState createState() =>
        _SupervisorOrderHistoryScreenState();
  }

  class _SupervisorOrderHistoryScreenState
      extends State<SupervisorOrderHistoryScreen>
      with SingleTickerProviderStateMixin {
    final List<String> statusIds = [
      Constant.CreateId.toString(),
      Constant.InProcessId.toString(),
      Constant.AccountReviewedId.toString(),
      Constant.OrderConfirmId.toString(),
      Constant.OrderDispatchedId.toString(),
      Constant.OrderReceivedId.toString(),
      Constant.OrderCanceledId.toString()
    ]; // Added '20' for Audit Reviewed
    String selectedStatusId =
        Constant.CreateId.toString(); // Default status ID for the first tab
    final Connectivity _connectivity = Connectivity();
    bool _isConnected = true;
    late TabController _tabController;
    bool isLoading = true;

    @override
    void initState() {
      _tabController = TabController(length: statusIds.length, vsync: this);
      syncAllStatuses();
      // Listen for tab changes and update the selectedStatusId
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            selectedStatusId = statusIds[_tabController.index];
            print('Swiped to Tab: $selectedStatusId');
            refreshData();
          });
        }
      });

      // _checkInitialConnection();
      _listenToConnectionChanges();
      super.initState();
    }

    Future<void> syncAllStatuses() async {
      for (String statusId in statusIds) {
        await fetchDealershipData(statusId);
      }
      setState(() {}); // Refresh UI
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

    Future<List<dynamic>> fetchDealershipData(String statusId) async {
      final url = Uri.parse(
        '${Constants.BASE_URL}/api/App/GetDealerOrderStatusWiseBySupId?userId=$userid&statusId=$statusId&appDateTime=${getCurrentDateTime()}',
      );

      final ordersBox = Hive.box('ordersBox');
      String cacheKey = 'orders_$statusId';

      try {
        final response = await http.get(
          url,
          headers: {
            'Authorization': '6XesrAM2Nu',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final data = decoded['Data'] as List<dynamic>;

          await ordersBox.put(cacheKey, data);
          return data;
        } else {
          return List<Map<String, dynamic>>.from(
              ordersBox.get(cacheKey, defaultValue: []));
        }
      } catch (e) {
        return List<Map<String, dynamic>>.from(
            ordersBox.get(cacheKey, defaultValue: []));
      }
    }

    Future<void> refreshData() async {
      await fetchDealershipData(selectedStatusId);
      setState(() {});
    }

    void _showImagePopup(String imageUrl) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              width: 300,
              height: 400,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return !_isConnected
          ? NoInternetScreen(
              onRetry: _checkInitialConnection,
            )
          : DefaultTabController(
              length: statusIds.length, // Number of tabs
              child: Scaffold(
                backgroundColor: Colors.red[50],
                appBar: AppBar(
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.white),
                  backgroundColor: Colors.redAccent,
                  title: const Text("Primary Sale",
                      style: TextStyle(
                        color: Colors.white,  
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                      )),
                  bottom: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(color: Colors.grey.shade200),
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: "Created"),
                      Tab(text: "In Process"), // New tab for In Process
                      Tab(text: "Account Reviewed"),
                      Tab(text: "Confirm"),
                      Tab(text: "Dispatched"),
                      Tab(text: "Received"),
                      Tab(text: "Canceled"),
                    ],
                    onTap: (index) {
                      setState(() {
                        selectedStatusId = statusIds[index];
                        print('StatusID: $selectedStatusId');
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DistributorSelectionScreen(),
                          ),
                        ).then((_) {
                          refreshData();
                        });
                      },
                      child: const Text(
                        "New Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                body: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 0; i < statusIds.length; i++)
                      FutureBuilder<List<dynamic>>(
                        future: fetchDealershipData(statusIds[i]),
                        builder: (context, snapshot) {
                          return RefreshIndicator(
                            onRefresh: refreshData,
                            child: _buildOrderList(snapshot),
                          );
                        },
                      ),
                  ],
                ),
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

        // Check if the selected tab is the "Dispatched" or "Received" tab
        if (selectedStatusId == Constant.OrderDispatchedId.toString() ||
            selectedStatusId == Constant.OrderReceivedId.toString()) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return DispatchedOrderListItem(
                dealership: data[index],
                selectedStatusId: selectedStatusId,
                onReceivedOrder: (comments, deliveryChallan, orderId) {
                  ReceivedOrder(comments, deliveryChallan, orderId);
                },
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return OrderListItem(
                dealership: data[index],
                selectedStatusId: selectedStatusId,
                onReceivedOrder: (comments, deliveryChallan, orderId) {
                  ReceivedOrder(comments, deliveryChallan, orderId);
                },
              );
            },
          );
        }
      } else {
        return const Center(child: Text('No Data Available'));
      }
    }

    Future<void> ReceivedOrder(
      String comments,
      String deliveryChallan,
      String orderId,
    ) async {
      // API URL
      String url = '${Constants.BASE_URL}/api/App/ReceiveOrderByDOId';
      print('API URL: $url');

      // Request headers
      Map<String, String> headers = {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json'
      };
      print('Headers: $headers');

      // Print individual values
      print('Order ID: $orderId');
      print('Delivery Challan Code: $deliveryChallan');
      print('Comments: $comments');

      // Request body
      final body = {
        // "orderId": orderId,
        // "userId": userid,
        // "appDateTime": getCurrentDateTime(),
        // "deliveryChallanCode": deliveryChallan,
        // "comments": comments

        "dOId": orderId,
        "userId": userid,
        "appDateTime": getCurrentDateTime(),
        "deliveryChallanCode": deliveryChallan,
        "comments": comments,
      };
      print('Request Body: $body');

      try {
        setState(() {
          isLoading = true;
        });
        print('Loading set to true');

        // Send POST request
        http.Response response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: json.encode(body),
        );
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Check if the request was successful
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Decoded Response Data: $data');

          // After getting a response from the API
          // You can add more logic here based on the response data
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (error) {
        print('Error during API call: $error');
      } finally {
        // Once API call is done, hide the loader and show the button again
        setState(() {
          isLoading = false;
        });
        print('Loading set to false');
      }
    }

    String getCurrentDateTime() {
      return DateTime.now().toIso8601String();
    }

    String convertTo12HourFormat(String isoDateString) {
      DateTime dateTime = DateTime.parse(isoDateString);
      return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
    }
  }

  class OrderListItem extends StatefulWidget {
    final Map<String, dynamic> dealership;
    final String selectedStatusId;
    final Function(String, String, String) onReceivedOrder;

    const OrderListItem({
      Key? key,
      required this.dealership,
      required this.selectedStatusId,
      required this.onReceivedOrder,
    }) : super(key: key);

    @override
    _OrderListItemState createState() => _OrderListItemState();
  }

  class _OrderListItemState extends State<OrderListItem> {
    String? deliveryChallanCode;
    final TextEditingController _deliveryChallan = TextEditingController();
    final TextEditingController _comments = TextEditingController();
    bool isLoading = true;
    bool isDeleting = false;

    @override
    void initState() {
      super.initState();
      deliveryChallanCode = widget.dealership['DeliveryChallanCode'];
    }

    Future<void> shoporder(String fromstatus, String tostatus, String orderId,
        String confirmedComment) async {
      String url = '${Constants.BASE_URL}/api/App/UpdateShopOrderStatus';

      Map<String, String> headers = {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json'
      };

      final body = {
        "userId": userid,
        "appDateTime": getCurrentDateTime(),
        "orderId": orderId,
        "fromStatusId": fromstatus,
        "toStatusId": tostatus,
        "comments": confirmedComment
      };

      try {
        setState(() {
          isLoading = true;
        });

        http.Response response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
        }
      } catch (error) {
        print('Error during API call: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      var dealership = widget.dealership;
      var territoryName = dealership['TerritoryName'];
      var dealerShipName = dealership['DealerShipName'];
      var address = dealership['Address'];
      var orderDate = dealership['OrderDate'];
      var orderStatus = dealership['OrderStatus'];
      var orderID = dealership['OrderID'];
      List<dynamic>? products = dealership['Products'] as List<dynamic>?;

      int? totalQuantity;
      double? totalPrice;

      if (products != null && products.isNotEmpty) {
        int qtySum = 0;
        double priceSum = 0.0;

        for (var product in products) {
          // Parse quantity
          var quantityRaw = product['Quantity'];
          int quantity = 0;
          if (quantityRaw is String) {
            quantity = int.tryParse(quantityRaw) ?? 0;
          } else if (quantityRaw is int) {
            quantity = quantityRaw;
          }

          // Parse price
          var priceRaw = product['DistributorPrice'];
          double price = 0.0;
          if (priceRaw is String) {
            price = double.tryParse(priceRaw) ?? 0.0;
          } else if (priceRaw is double || priceRaw is int) {
            price = priceRaw.toDouble();
          }

          qtySum += quantity;
          priceSum += price * quantity;
        }

        totalQuantity = qtySum;
        totalPrice = priceSum;
      } else {
        totalQuantity = null;
        totalPrice = null;
      }

      return Card(
        margin: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: Text(
            'Distributor: $dealerShipName',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              'Order Date:${formatDate(orderDate)} \nOrder Status: $orderStatus'),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  const Text('Address:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Flexible(
                      child: Text(address, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  if (deliveryChallanCode != null &&
                      deliveryChallanCode!.isNotEmpty)
                    const Text('Delivery Challan Code:',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  if (deliveryChallanCode != null &&
                      deliveryChallanCode!.isNotEmpty)
                    const SizedBox(width: 5),
                  if (deliveryChallanCode != null &&
                      deliveryChallanCode!.isNotEmpty)
                    Text(deliveryChallanCode!,
                        style: const TextStyle(fontSize: 15)),
                  if (deliveryChallanCode != null &&
                      deliveryChallanCode!.isNotEmpty &&
                      widget.selectedStatusId != '4')
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: deliveryChallanCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Copied to clipboard"),
                              duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (dealership['OrderImage'] != null &&
                    dealership['OrderImage'].isNotEmpty) {
                  _showImagePopup(dealership['OrderImage']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image not available')),
                  );
                }
              },
              child: dealership['OrderImage'] != null &&
                      dealership['OrderImage'].isNotEmpty
                  ? (dealership['OrderImage'].startsWith('data:image')
                      ? Image.memory(
                          base64Decode(dealership['OrderImage'].split(',').last),
                          width: 100,
                          height: 100,
                          // fit: BoxFit.cover,
                        )
                      : Image.network(
                          '${dealership['OrderImage']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Image not available',
                                style: TextStyle(color: Colors.black54),
                              ),
                            );
                          },
                        ))
                  : const Center(
                      child: Text(
                        'Image not available',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
            ),
            const Divider(),
            if (products != null && products.isNotEmpty)
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
                                  product['ImageName'],
                                  width: 50,
                                  height: 50,
                                  // fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported,
                                          size: 40),
                                ))
                          : const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                      subtitle: Text(
                        '${product['ProductName']} (${product['VolumeInMl']} ml ${product['ProductType']})\nDistributor Price: ${product['DistributorPrice']}\nQuantity: ${product['Quantity']}',
                      ),
                      trailing: Column(
                        children: [
                          const Text('QTY',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${product['Quantity']}',
                              style: const TextStyle(fontSize: 25.0)),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('No products found.'),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Quantity: ${totalQuantity ?? 0}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Price: ${totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (widget.selectedStatusId == Constant.CreateId.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopScreen4(orderId: orderID),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: const Center(
                                    child: Text("Order Delete Request")),
                                content: const Text(
                                    'Are you sure you want to delete the order?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      setState(() => isDeleting = true);

                                      await shoporder(
                                        widget.selectedStatusId,
                                        Constant.OrderDeletedId.toString(),
                                        orderID.toString(),
                                        '',
                                      );

                                      setState(() => isDeleting = false);
                                      Navigator.pop(context);
                                    },
                                    child: isDeleting
                                        ? const CircularProgressIndicator()
                                        : const Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            if (widget.selectedStatusId == Constant.OrderDispatchedId.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _showReceiveSheet(context, orderID.toString());
                    },
                    icon: const Icon(Icons.receipt_sharp),
                    label: const Text('Receive'),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    void _showReceiveSheet(BuildContext context, String orderIDD) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
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

                                  if (delivery.isNotEmpty &&
                                      delivery == deliveryChallanCode) {
                                    widget.onReceivedOrder(
                                      _comments.text,
                                      _deliveryChallan.text,
                                      orderIDD,
                                    );

                                    _comments.clear();
                                    _deliveryChallan.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Order Received!')),
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text("Invalid Challan Code!"),
                                          content: const Text(
                                              "Make sure to enter valid challan code."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("OK"),
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

    String formatDate(String dateString) {
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
      } catch (e) {
        return dateString; // Return the original string if parsing fails
      }
    }

    String convertTo12HourFormat(String isoDateString) {
      DateTime dateTime = DateTime.parse(isoDateString);
      return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
    }

    void _showImagePopup(String imageString) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              width: 300,
              height: 400,
              child: imageString.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(imageString.split(',').last),
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      '$imageString',
                      fit: BoxFit.contain,
                    ),
            ),
          );
        },
      );
    }
  }

  class DispatchedOrderListItem extends StatelessWidget {
    final Map<String, dynamic> dealership;
    final String selectedStatusId;
    final Function(String, String, String) onReceivedOrder;

    const DispatchedOrderListItem({
      Key? key,
      required this.dealership,
      required this.selectedStatusId,
      required this.onReceivedOrder,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      var dispatches = dealership['Dispatches'];
      var dealerShipName = dealership['DealerShipName'];
      var orderDate = dealership['OrderDate'];
      var orderStatus = dealership['OrderStatus'];
      var orderNO = dealership['OrderID'];
      var orderProductsGroup = dealership['OrderProductsGroup'];
      var address = dealership['Address'];
      var orderImage = dealership['OrderImage'];

      // Calculate totals for OrderProductsGroup
      int totalOrderQuantity = orderProductsGroup.fold(
          0, (sum, product) => sum + (product['TotalQuantity'] as int));
      double totalOrderPrice = orderProductsGroup.fold(
          0.0,
          (sum, product) =>
              sum +
              (product['DistributorPrice'] as double) *
                  (product['TotalQuantity'] as int));
      int dispatchedCount = dispatches
          .where((dispatch) => dispatch['StatusId'].toString() == '40')
          .length;

      return Card(
        margin: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          title: Text(
            'Distributor: $dealerShipName',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Order No: $orderNO',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10), // Space between text
                  if (dispatchedCount >
                      0) // Only show if there are dispatched orders
                    Text(
                      'Total Dispatched: $dispatchedCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 14, // Highlight in red
                      ),
                    ),
                  const SizedBox(width: 5), // Space between text and dot
                  if (dispatchedCount >
                      0) // Only show blinking dot if StatusId == 40 exists
                    const BlinkingRedDot(),
                ],
              ),
              Text(
                'Order Date: ${formatDate(orderDate)} \nOrder Status: $orderStatus',
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Address:',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text(address, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (orderImage != null && orderImage.isNotEmpty)
                    GestureDetector(
                      onTap: () {},
                      child: orderImage != null && orderImage.isNotEmpty
                          ? (orderImage.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(orderImage.split(',').last),
                                  width: 100,
                                  height: 100,
                                  // fit: BoxFit.cover,
                                )
                              : Image.network(
                                  '$orderImage',  
                                  width: 100,
                                  height: 100,
                                  // fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'No Image Available',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    );
                                  },
                                ))
                          : const Center(
                              child: Text(
                                'No Image Available',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                    )
                  else
                    const Center(
                      child: Text(
                        'No Image Available',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Order Products:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderProductsGroup.length,
                    itemBuilder: (context, index) {
                      var product = orderProductsGroup[index];
                      print('sjjsjsjsjsjs..${product.toString()}');
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
                              : const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                          subtitle: Text(
                            '${product['ProductName']} (${product['ProductType']})\n'
                            'Distributor Price: ${product['DistributorPrice']}\n'
                            'Quantity: ${product['TotalQuantity']}',
                          ),
                          trailing: Column(
                            children: [
                              const Text('QTY',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${product['TotalQuantity']}',
                                  style: const TextStyle(fontSize: 25.0)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity: $totalOrderQuantity',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   'Total Price: $totalOrderPrice',
                        //   style: const TextStyle(
                        //       fontSize: 16, fontWeight: FontWeight.bold),
                        // ),

                        Text(
                          'Total Price: ${NumberFormat("#,##0.##", "en_US").format(totalOrderPrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dispatches.length,
              itemBuilder: (context, index) {
                var dispatch = dispatches[index];

                // Make sure StatusId is compared as a string with '40'
                // It's possible the StatusId is stored as an int in your data
                String statusId = dispatch['StatusId'].toString();
                bool showReceiveButton = statusId == '40';

                // String statusId = dispatch['StatusId'].toString();

                // Set display text based on status
                String statusDisplayText;
                if (statusId == '50') {
                  statusDisplayText = 'Received';
                } else if (statusId == '40') {
                  statusDisplayText = 'Dispatched';
                } else {
                  statusDisplayText =
                      statusId; // Keep original for other statuses
                }

                // Debug print to check the status - remove in production
                print(
                    'Dispatch ${index}: StatusId = ${statusId}, Show button = ${showReceiveButton}');

                int totalDispatchQuantity = dispatch['Items']
                    .fold(0, (sum, item) => sum + (item['Quantity'] as int));
                double totalDispatchPrice = 0.0;

                for (var item in dispatch['Items']) {
                  double price =
                      double.tryParse(item['DistributorPrice'].toString()) ?? 0.0;
                  int quantity = int.tryParse(item['Quantity'].toString()) ?? 0;
                  totalDispatchPrice += price * quantity;
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispatch Date: ${formatDate(dispatch['DispatchDate'])}',
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Bilty No: ${dispatch['BiltyNo']}',
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Text(
                              'Status: $statusDisplayText', // Updated status text
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            if (statusId == '40') const BlinkingRedDot(),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text('DC Code: ${dispatch['DCCode']}'),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: dispatch['DCCode']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('DC Code copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 95),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Freight Charges: ${dispatch['FreightCharges']}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Driver Name: ${dispatch['DriverName']}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Driver PhoneNo: ${dispatch['DriverPhoneNo']}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Vehicle Name: ${dispatch['VehicleName']}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Registration Number: ${dispatch['RegistrationNumber']}',
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dispatch['Items'].length,
                        itemBuilder: (context, itemIndex) {
                          var item = dispatch['Items'][itemIndex];
                          return Card(
                            child: ListTile(
                              leading: item['ImageName'] != null &&
                                      item['ImageName'].isNotEmpty
                                  ? (item['ImageName'].startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(
                                              item['ImageName'].split(',').last),
                                          width: 50,
                                          height: 50,
                                          // fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          '${item['ImageName']}',
                                          width: 50,
                                          height: 50,
                                        ))
                                  : const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                              subtitle: Text(
                                '${item['ProductName']} (${item['ProductType']})\n'
                                'Distributor Price: ${item['DistributorPrice']}\n'
                                'Quantity: ${item['Quantity']}',
                              ),
                              trailing: Column(
                                children: [
                                  const Text('QTY',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${item['Quantity']}',
                                      style: const TextStyle(fontSize: 25.0)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Quantity: $totalDispatchQuantity',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            // Text(
                            //   'Total Price: ${NumberFormat("#,##0.00", "en_US").format(totalDispatchPrice)}',
                            //   style: const TextStyle(
                            //       fontSize: 16, fontWeight: FontWeight.bold),
                            // ),

                            Text(
                              'Total Price: ${NumberFormat("#,##0.##", "en_US").format(totalDispatchPrice)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Debug check for status 40
                      // Text(
                      //     'Debug: Status is $statusId, Show button: $showReceiveButton',
                      //     style: const TextStyle(color: Colors.grey)),

                      // Only show the Receive button if StatusId is 40
                      if (showReceiveButton) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Open receive modal and pass Order ID + DC Code
                            _showReceiveSheet(
                                context,
                                dispatch['DispatchOrderId'].toString(),
                                dispatch['DCCode'].toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            fixedSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Receive',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    String convertTo12HourFormat(String isoDateString) {
      DateTime dateTime = DateTime.parse(isoDateString);
      return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
    }

    void _showReceiveSheet(BuildContext context, String orderID, String dcCode) {
      TextEditingController _deliveryChallan = TextEditingController();
      TextEditingController _comments = TextEditingController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
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
                                'Fill below fields to receive order:',
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              // DC Code Display with Copy Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DC Code: $dcCode',
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: dcCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('DC Code copied!')),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Delivery Challan Code (User must enter manually)
                              TextField(
                                controller: _deliveryChallan,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  labelText: 'Enter Delivery Challan Code',
                                  hintText: 'Paste or type DC Code here',
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Comments Field
                              TextFormField(
                                controller: _comments,
                                decoration: InputDecoration(
                                  hintText: 'Enter Comments (Optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Receive Button
                              InkWell(
                                onTap: () {
                                  String enteredDcCode = _deliveryChallan.text;

                                  if (enteredDcCode.isNotEmpty &&
                                      enteredDcCode == dcCode) {
                                    // Call function to mark order as received
                                    onReceivedOrder(
                                        _comments.text, enteredDcCode, orderID);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Order Received!')),
                                    );

                                    Navigator.of(context).pop();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Invalid DC Code!"),
                                          content: const Text(
                                              "Ensure you enter the correct DC Code."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    height: 40,
                                    width: 120,
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
                                        'Receive',
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

    String formatDate(String dateString) {
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('hh:mm a, MMMM d, y').format(dateTime);
      } catch (e) {
        return dateString; // Return the original string if parsing fails
      }
    }
  }
