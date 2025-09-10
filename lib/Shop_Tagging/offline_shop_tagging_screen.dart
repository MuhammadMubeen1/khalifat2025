import 'dart:convert';
import 'dart:io';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineShopTaggingScreen extends StatefulWidget {
  const OfflineShopTaggingScreen({super.key});

  @override
  State<OfflineShopTaggingScreen> createState() =>
      _OfflineShopTaggingScreenState();
}

class _OfflineShopTaggingScreenState extends State<OfflineShopTaggingScreen> {
  late Box<ShopTaggingModel> _shopTaggingBox;
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _isSyncing = false;
  bool _isMounted = false;
  final Dio _dio = Dio();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _phoneController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initHive();
    _checkInitialConnection();
    _listenToConnectionChanges();
  }

  @override
  void dispose() {
    _isMounted = false;
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initHive() async {
    _shopTaggingBox = Hive.box<ShopTaggingModel>('shopTaggingBox');
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    if (_isMounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

  void _listenToConnectionChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (_isMounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  void _showTopToast(String message, Color backgroundColor) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
      ),
    );
  }

  Future<void> _syncAllOfflineData() async {
    if (!_isConnected) {
      _showTopToast('No internet connection available', Colors.red);
      return;
    }

    if (_isMounted) {
      setState(() {
        _isSyncing = true;
      });
    }

    final unsyncedData =
        _shopTaggingBox.values.where((item) => !item.isSynced).toList();
    int successCount = 0;
    int failedCount = 0;
    int duplicateCount = 0;

    for (final data in unsyncedData) {
      try {
        // Skip duplicate items in bulk sync
        if (data.isDuplicate) {
          duplicateCount++;
          continue;
        }

        final payload = data.toJson();
        payload['createdAt'] = DateTime.now().toIso8601String();
        payload['appDateTime'] = DateTime.now().toIso8601String();

        final response = await _dio.post(
          '${Constants.BASE_URL}/api/App/SaveShopTaggingByTerritoryId',
          data: payload,
          options: Options(
            headers: {
              'Authorization': '6XesrAM2Nu',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) => status! < 500,
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData is Map &&
              responseData.containsKey('Status') &&
              responseData['Status'] == 412 &&
              responseData.containsKey('Message') &&
              responseData['Message']
                  .toString()
                  .toLowerCase()
                  .contains('duplicate')) {
            data.isDuplicate = true;
            duplicateCount++;
          } else {
            data.isSynced = true;
            successCount++;
          }

          final key = _shopTaggingBox
              .keyAt(_shopTaggingBox.values.toList().indexOf(data));
          await _shopTaggingBox.put(key, data);
        } else if (response.statusCode == 400 || response.statusCode == 412) {
          final responseData = response.data;
          if (responseData is Map &&
              ((responseData.containsKey('Status') &&
                      responseData['Status'] == 412) ||
                  (responseData.containsKey('message') &&
                      responseData['message']
                          .toString()
                          .toLowerCase()
                          .contains('duplicate')))) {
            data.isDuplicate = true;
            duplicateCount++;

            final key = _shopTaggingBox
                .keyAt(_shopTaggingBox.values.toList().indexOf(data));
            await _shopTaggingBox.put(key, data);
          } else {
            failedCount++;
          }
        } else {
          failedCount++;
        }
      } catch (e) {
        failedCount++;
      }
    }

    if (_isMounted) {
      setState(() {
        _isSyncing = false;
      });

      if (successCount > 0 || failedCount > 0 || duplicateCount > 0) {
        String message;
        Color backgroundColor;

        if (successCount > 0 && duplicateCount == 0 && failedCount == 0) {
          message = 'All $successCount items synced successfully!';
          backgroundColor = Colors.green;
        } else if (successCount > 0 && duplicateCount > 0 && failedCount == 0) {
          message =
              '$successCount items synced, $duplicateCount duplicates found';
          backgroundColor = Colors.orange;
        } else if (successCount > 0 && failedCount > 0 && duplicateCount == 0) {
          message = '$successCount items synced, $failedCount failed';
          backgroundColor = Colors.orange;
        } else if (successCount == 0 &&
            duplicateCount > 0 &&
            failedCount == 0) {
          message = '$duplicateCount duplicate items found';
          backgroundColor = Colors.orange;
        } else if (successCount == 0 &&
            failedCount > 0 &&
            duplicateCount == 0) {
          message = 'All $failedCount items failed to sync';
          backgroundColor = Colors.red;
        } else {
          message =
              'Synced: $successCount, Duplicates: $duplicateCount, Failed: $failedCount';
          backgroundColor = Colors.orange;
        }

        _showTopToast(message, backgroundColor);
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _shopTaggingBox.getAt(index);
    if (item == null) return;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shop Tagging'),
        content: const Text(
            'Are you sure you want to delete this shop tagging data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _shopTaggingBox.deleteAt(index);
      if (_isMounted) {
        setState(() {});
      }
      _showTopToast('Shop tagging data deleted', Colors.red);
    }
  }

  Future<void> _syncSingleItem(int index) async {
    if (!_isConnected) {
      _showTopToast('No internet connection available', Colors.red);
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    final unsyncedItems =
        _shopTaggingBox.values.where((item) => !item.isSynced).toList();

    if (index >= unsyncedItems.length) {
      setState(() {
        _isSyncing = false;
      });
      return;
    }

    final item = unsyncedItems[index];
    final actualIndex = _shopTaggingBox.values.toList().indexOf(item);

    if (actualIndex == -1 || item.isSynced) {
      setState(() {
        _isSyncing = false;
      });
      return;
    }

    try {
      final payload = item.toJson();
      payload['createdAt'] = DateTime.now().toIso8601String();
      payload['appDateTime'] = DateTime.now().toIso8601String();

      final response = await _dio.post(
        '${Constants.BASE_URL}/api/App/SaveShopTaggingByTerritoryId',
        data: payload,
        options: Options(
          headers: {
            'Authorization': '6XesrAM2Nu',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map &&
            responseData.containsKey('Status') &&
            responseData['Status'] == 412 &&
            responseData.containsKey('Message') &&
            responseData['Message']
                .toString()
                .toLowerCase()
                .contains('duplicate')) {
          item.isDuplicate = true;
          _showTopToast('Duplicate phone number detected!', Colors.orange);
        } else {
          item.isSynced = true;
          item.isDuplicate = false;
          _showTopToast('Shop data synced successfully!', Colors.green);
        }

        await _shopTaggingBox.putAt(actualIndex, item);
      } else if (response.statusCode == 400 || response.statusCode == 412) {
        final responseData = response.data;
        if (responseData is Map &&
            ((responseData.containsKey('Status') &&
                    responseData['Status'] == 412) ||
                (responseData.containsKey('message') &&
                    responseData['message']
                        .toString()
                        .toLowerCase()
                        .contains('duplicate')))) {
          item.isDuplicate = true;
          await _shopTaggingBox.putAt(actualIndex, item);
          _showTopToast('Duplicate phone number detected!', Colors.orange);
        } else {
          _showTopToast('Failed to sync shop data', Colors.red);
        }
      } else {
        _showTopToast('Failed to sync shop data', Colors.red);
      }
    } catch (e) {
      _showTopToast('Error syncing shop: $e', Colors.red);
    } finally {
      if (_isMounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  
  

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB71234),
                      Color(0xFFF02A2A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Offline Shop Tagging',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_isConnected)
                        IconButton(
                          icon: _isSyncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.sync, color: Colors.white),
                          onPressed: _isSyncing ? null : _syncAllOfflineData,
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _shopTaggingBox.listenable(),
                  builder: (context, Box<ShopTaggingModel> box, _) {
                    final pendingItems = box.values
                        .where((item) => !item.isSynced)
                        .toList()
                        .cast<ShopTaggingModel>();

                    if (pendingItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 60,
                              color: Colors.green[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'All data synced!',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No pending sync operations',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingItems.length,
                      itemBuilder: (context, index) {
                        final item = pendingItems[index];
                        final isDuplicate = item.isDuplicate;
                        final actualIndex =
                            _shopTaggingBox.values.toList().indexOf(item);

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          color: isDuplicate ? Colors.orange[50] : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.shopName,
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDuplicate
                                              ? Colors.orange[800]
                                              : Colors.red[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDuplicate
                                            ? Colors.orange[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isDuplicate ? 'Duplicate' : 'Pending',
                                        style: GoogleFonts.lato(
                                          color: isDuplicate
                                              ? Colors.orange[800]
                                              : Colors.red[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    Icons.person, 'Owner', item.ownerName),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.phone,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.lato(
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Phone: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: item.phoneNo),
                                          ],
                                        ),
                                      ),
                                    ),
                                   
                                  ],
                                ),
                                if (isDuplicate)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning,
                                            size: 16,
                                            color: Colors.orange[800]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Duplicate phone number - already exists in system',
                                          style: GoogleFonts.lato(
                                            color: Colors.orange[800],
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                _buildDetailRow(
                                    Icons.location_on, 'Address', item.address),
                                if (item.landmark.isNotEmpty)
                                  _buildDetailRow(
                                      Icons.place, 'Landmark', item.landmark),
                                _buildDetailRow(Icons.schedule, 'Timing',
                                    '${item.openingTime} - ${item.closingTime}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Fridges:',
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (item.pepsiFridge != '0')
                                      _buildFridgeChip(
                                          'Pepsi', item.pepsiFridge),
                                    if (item.cokeFridge != '0')
                                      _buildFridgeChip('Coke', item.cokeFridge),
                                    if (item.nestleFridge != '0')
                                      _buildFridgeChip(
                                          'Nestle', item.nestleFridge),
                                    if (item.nesfrutaFridge != '0')
                                      _buildFridgeChip(
                                          'Nesfruta', item.nesfrutaFridge),
                                    if (item.othersFridge != '0')
                                      _buildFridgeChip(
                                          'Others', item.othersFridge),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a')
                                          .format(item.createdAt),
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (!isDuplicate)
                                          ElevatedButton.icon(
                                            onPressed: _isSyncing
                                                ? null
                                                : () => _syncSingleItem(index),
                                            icon: const Icon(Icons.sync,
                                                size: 16),
                                            label: Text(
                                              'Sync Now',
                                              style: GoogleFonts.lato(
                                                  fontSize: 12),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red[800],
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        if (isDuplicate)
                                          ElevatedButton.icon(
                                            onPressed: _isSyncing
                                                ? null
                                                : () => _syncSingleItem(index),
                                            icon: const Icon(Icons.sync,
                                                size: 16),
                                            label: Text(
                                              'Resend',
                                              style: GoogleFonts.lato(
                                                  fontSize: 12),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange[800],
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteItem(actualIndex),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFridgeChip(String brand, String count) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      label: Text(
        '$brand: $count',
        style: GoogleFonts.lato(
          fontSize: 12,
          color: Colors.grey[800],
        ),
      ),
      avatar: CircleAvatar(
        backgroundColor: Colors.red[100],
        radius: 12,
        child: Text(
          count,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
      ),
    );
  }
}
