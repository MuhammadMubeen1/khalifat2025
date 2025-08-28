import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> deliveredOrders = [
    {
      "shopName": "Shop A",
      "image": "assets/shop_a.png",
      "DSF": "Ali",
      "quantity": 3,
      "price": 500,
      "status": "delivered",
      "Order Time/Date": "2024/18/09 : 04:00"
    },
    {
      "shopName": "Shop B",
      "image": "assets/shop_b.png",
      "quantity": 2,
      "price": 800,
      "status": "late",
      "DSF": "Ali",
      "Order Time/Date": "2024/18/09 : 04:00"
    },
    {
      "shopName": "Shop C",
      "image": "assets/shop_c.png",
      "quantity": 1,
      "price": 1000,
      "status": "canceled",
      "DSF": "Ali",
      "Order Time/Date": "2024/18/09 : 04:00"
    }
  ];
  List<Map<String, dynamic>> lateOrders = [
    {
      "shopName": "Shop B",
      "image": "assets/shop_b.png",
      "quantity": 2,
      "price": 800,
      "status": "late",
      "DSF": "Ali",
      "Order Time/Date": "2024/18/09 : 04:00"
    }
  ];
  List<Map<String, dynamic>> canceledOrders = [
    {
      "shopName": "Shop C",
      "image": "assets/images/shopclose.png",
      "quantity": 1,
      "price": 1000,
      "status": "canceled",
      "DSF": "Ali",
      "Order Time/Date": "2024/18/09 : 04:00"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? orderedItemsJson = prefs.getString('ordered_items');

    if (orderedItemsJson != null) {
      List<dynamic> jsonList = jsonDecode(orderedItemsJson);

      setState(() {
        for (var order in jsonList.cast<Map<String, dynamic>>()) {
          switch (order['status']) {
            case 'delivered':
              deliveredOrders.add(order);
              break;
            case 'late':
              lateOrders.add(order);
              break;
            case 'canceled':
              canceledOrders.add(order);
              break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('Today Orders'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(deliveredOrders, 'No orders found', false, false),
            _buildOrderList(
                lateOrders, 'No delivered orders found', true, false),
            _buildOrderList(canceledOrders, 'No orders found', true, true),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select an Option"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("View selected");
              },
              child: Text("View"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Edit selected");
              },
              child: Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Confirm selected");
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Cancel selected");
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, String emptyMessage,
      bool isConfirmedTab, bool isCancelledTab) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Orders: ${orders.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: orders.isNotEmpty
              ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['shopName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Quantity: ${order['quantity']}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              'Price: Rs. ${order['price']}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              'Total: Rs. ${order['price'] * order['quantity']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'DSF: ${order['DSF']}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              'Order Time: ${order['Order Time/Date']}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Conditional rendering of buttons based on the tab
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: isCancelledTab
                                    ? [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                          child: Icon(Icons.visibility,
                                              color: Colors.white),
                                        ),
                                      ]
                                    : isConfirmedTab
                                        ? [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                              ),
                                              child: Icon(Icons.visibility,
                                                  color: Colors.white),
                                            ),
                                          ]
                                        : [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                              ),
                                              child: Icon(Icons.visibility,
                                                  color: Colors.white),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                              ),
                                              child: Icon(Icons.edit,
                                                  color: Colors.white),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                              ),
                                              child: Icon(Icons.check,
                                                  color: Colors.white),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                              ),
                                              child: Icon(Icons.cancel,
                                                  color: Colors.white),
                                            ),
                                          ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(emptyMessage, style: TextStyle(fontSize: 18)),
                ),
        ),
      ],
    );
  }
}
