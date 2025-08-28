import 'package:flutter/material.dart';

class OrderPendingScreen extends StatefulWidget {
  OrderPendingScreen({super.key});

  @override
  State<OrderPendingScreen> createState() => _OrderPendingState();
}

class _OrderPendingState extends State<OrderPendingScreen> {
  List<Map<String, dynamic>> myOrders = [];

  @override
  void initState() {
    super.initState();
    initializeOrders();
  }

  void initializeOrders() {
    setState(() {
      myOrders = [
        {
          "shopName": "Shop A",
          "Detail": "Shop A details, lat/long",
          "Location": "Latitude: 31.5497, Longitude: 74.3436",
          "SalemanName": "Sulieman",
          "Status": "Confirmed",
          "Order Date/Time": "2024/18/19 : 05:45",
        },
        {
          "shopName": "Shop B",
          "Detail": "Shop B details, lat/long",
          "Location": "Latitude: 32.5467, Longitude: 75.7653",
          "SalemanName": "Sunny",
          "Status": "Dispatched",
          "Order Date/Time": "2024/18/19 : 05:45",
        },
        {
          "shopName": "Shop C",
          "Detail": "Shop C details, lat/long",
          "Location": "Latitude: 33.1234, Longitude: 76.8765",
          "SalemanName": "Amir",
          "Status": "Dispatched",
          "Order Date/Time": "2024/18/19 : 05:45",
        },
        {
          "shopName": "Shop B",
          "Detail": "Shop B details, lat/long",
          "Location": "Latitude: 32.5467, Longitude: 75.7653",
          "SalemanName": "Sunny",
          "Status": "Confirmed",
          "Order Date/Time": "2024/18/19 : 05:45",
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Pending Deliveries'),
      ),
      body: Column(
        children: [
          // Total number of pending orders
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Pending Orders: ${myOrders.length}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // List of pending orders
          Expanded(
            child: myOrders.isNotEmpty
                ? ListView.builder(
                    itemCount: myOrders.length,
                    itemBuilder: (context, index) {
                      final order = myOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['shopName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          order['Detail'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          order['Location'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Salesman: ${order['SalemanName']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Order Date/Time: ${order['Order Date/Time']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Status: ${order['Status']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        child: Image.network(
                                            'https://picsum.photos/250?image=9',
                                            fit: BoxFit.cover),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle 'View' action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 12),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        icon: Icon(Icons.visibility,
                                            color: Colors.white),
                                        label: FittedBox(
                                          child: Text('View'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Add some space between buttons
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle 'Location' action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 12),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        icon: Icon(Icons.location_on,
                                            color: Colors.white),
                                        label: FittedBox(
                                          child: Text('Location'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle 'Dispatch'/'Delivered' action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 12),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        icon: Icon(Icons.location_on,
                                            color: Colors.white),
                                        label: FittedBox(
                                          child: Text(
                                            (order['Status'] != null &&
                                                    order['Status']
                                                        .toLowerCase()
                                                        .contains("confirmed"))
                                                ? 'Dispatch'
                                                : (order['Status'] != null &&
                                                        order['Status']
                                                            .toLowerCase()
                                                            .contains(
                                                                "dispatched"))
                                                    ? 'Delivered'
                                                    : 'Unknown',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
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
                    child: Text(
                      'No pending orders found',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
