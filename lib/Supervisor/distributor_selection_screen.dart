import 'package:KhilafatCola/Hive/offline_order_model.dart';
import 'package:KhilafatCola/order_confirmation/demo.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/const.dart';

class DistributorSelectionScreen extends StatefulWidget {
  const DistributorSelectionScreen({super.key});

  @override
  State<DistributorSelectionScreen> createState() =>
      _DistributorSelectionScreenState();
}

class _DistributorSelectionScreenState
    extends State<DistributorSelectionScreen> {
  bool isLoading = false;
  bool isOnline = true;
  final Dio _dio = Dio();
  int? _selectedCategory;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _loadDistributors();
  }

  Future<void> _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOnline = result != ConnectivityResult.none;
      });
      // Try to sync pending orders when connection is restored
      if (isOnline) {
        _syncPendingOrders();
      }
    });
  }

 Future<void> _syncPendingOrders() async {
    final offlineOrdersBox = Hive.box<OfflineOrder>('offlineOrdersBox');
    final pendingOrders =
        offlineOrdersBox.values.toList().where((o) => !o.isSynced).toList();

    if (pendingOrders.isEmpty) return;

    try {
      for (var i = 0; i < pendingOrders.length; i++) {
        final order = pendingOrders[i];
        await _submitOrderToServer(order);

        // Get the actual key from the box
        final key = offlineOrdersBox.keyAt(i) as int;

        // Mark as synced by updating the entry
        await offlineOrdersBox.put(key, order.copyWith(isSynced: true));
      }
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pendingOrders.length} orders synced successfully'),
        ),
      );
    } catch (e) {
      print('Error syncing orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error syncing orders: $e'),
        ),
      );
    }
  }

  Future<void> _submitOrderToServer(OfflineOrder order) async {
    // Convert to server format and submit
    final response = await _dio.post(
      "${Constants.BASE_URL}/api/App/SaveDealershipOrder",
      data: {
        "dealershipId": order.dealershipId,
        "address": order.address,
        "userId": order.userId,
        "appDateTime": order.appDateTime,
        "ImageFileSource": order.imageBase64,
        "OrderItemCommandList": order.products
            .map((p) => {
                  "productId": p.productId,
                  "DistributorPrice": p.distributorPrice,
                  "orderQuantity": p.orderQuantity,
                })
            .toList(),
      },
      options: Options(
        headers: {
          'Authorization': '6XesrAM2Nu',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit order');
    }
  }

  Future<void> _loadDistributors() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isOnline) {
        await _fetchCategories();
      } else {
        await _loadCachedDistributors();
      }
    } catch (e) {
      print('Error loading distributors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading distributors: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get(
        '${Constants.BASE_URL}/api/App/GetDistributorByUserId?userId=$userid&appDateTime=${getCurrentDateTime()}',
        options: Options(
          headers: {
            'Authorization': '6XesrAM2Nu',
            'Content-Type': 'application/json',
          },
        ),
      );

      setState(() {
        _categories = response.data['Data'];
      });

      await _cacheDistributors(response.data['Data']);
    } catch (e) {
      print('Failed to fetch categories: $e');
      await _loadCachedDistributors();
    }
  }

  Future<void> _cacheDistributors(List<dynamic> distributors) async {
    final box = await Hive.openBox('distributors_cache');
    await box.put('distributors', distributors);
  }

  Future<void> _loadCachedDistributors() async {
    final box = await Hive.openBox('distributors_cache');
    final cachedData = box.get('distributors');

    if (cachedData != null) {
      setState(() {
        _categories = cachedData;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No cached distributors available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.redAccent,
        title: const Center(
            child: Text(
          'Select Distributor',
          style: TextStyle(
            color: Colors.white,
          ),
        )),
      ),
      body: Column(
        children: [
          if (!isOnline)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.amber,
              child: const Text(
                'OFFLINE MODE - Working with cached data',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DropdownButtonFormField<int>(
                          iconEnabledColor: Colors.red,
                          decoration: const InputDecoration(
                            hintText: 'Select Distributor',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          items: _categories.isEmpty
                              ? [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('No distributor available'),
                                  ),
                                ]
                              : _categories
                                  .map((category) => DropdownMenuItem<int>(
                                        value: category['DealershipId'] as int,
                                        child: Text(category['DealershipName']
                                            as String),
                                      ))
                                  .toList(),
                          onChanged: (value) async {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          value: _selectedCategory,
                          validator: (value) => value == null
                              ? 'Please select a distributor'
                              : null,
                          dropdownColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              if (_selectedCategory == null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Center(
                                          child: Text("Validation Alert")),
                                      content: const Text(
                                          'Please Select distributor first.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                final selectedDistributor =
                                    _categories.firstWhere((d) =>
                                        d['DealershipId'] == _selectedCategory);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DealershipScreen2(
                                      distributorID: _selectedCategory!,
                                      distributorName:
                                          selectedDistributor['DealershipName'],
                                      distributorAddress:
                                          selectedDistributor['Address'],
                                      isOnline: isOnline,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Order'))
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
