import 'dart:io';
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

  Future<void> _syncAllOfflineData() async {
    if (!_isConnected) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('No internet connection available')),
      );
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

    for (final data in unsyncedData) {
      try {
        // Create the payload with the original createdAt timestamp
        final payload = data.toJson();
        payload['createdAt'] = DateTime.now();

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
          data.isSynced = true;
          final key = _shopTaggingBox
              .keyAt(_shopTaggingBox.values.toList().indexOf(data));
          await _shopTaggingBox.put(key, data);
          successCount++;
        } else {
          print('Failed to sync: ${response.statusCode} - ${response.data}');
          failedCount++;
        }
      } catch (e) {
        print('Error syncing data: $e');
        failedCount++;
      }
    }

    if (_isMounted) {
      setState(() {
        _isSyncing = false;
      });

      if (successCount > 0 || failedCount > 0) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              successCount == unsyncedData.length
                  ? 'All data synced successfully!'
                  : 'Synced $successCount/${unsyncedData.length} items',
            ),
            backgroundColor: successCount == unsyncedData.length
                ? Colors.green
                : successCount > 0
                    ? Colors.orange
                    : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Shop tagging data deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _syncSingleItem(int index) async {
    if (!_isConnected) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('No internet connection available')),
      );
      debugPrint("❌ Sync failed: No internet connection.");
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // Get all unsynced items to find the correct index
    final unsyncedItems =
        _shopTaggingBox.values.where((item) => !item.isSynced).toList();

    if (index >= unsyncedItems.length) {
      // Item might have been synced already
      setState(() {
        _isSyncing = false;
      });
      return;
    }

    final item = unsyncedItems[index];
    final actualIndex = _shopTaggingBox.values.toList().indexOf(item);

    if (actualIndex == -1 || item.isSynced) {
      debugPrint("ℹ️ Item is null or already synced. Skipping...");
      setState(() {
        _isSyncing = false;
      });
      return;
    }

    try {
      debugPrint("➡️ Sending sync request for item at index $actualIndex...");

      // Create the payload with the original createdAt timestamp
      final payload = item.toJson();
      payload['createdAt'] = DateTime.now();

      debugPrint("📦 Payload: $payload");

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

      debugPrint("📡 Response Status: ${response.statusCode}");
      debugPrint("📡 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        item.isSynced = true;
        await _shopTaggingBox.putAt(actualIndex, item);
        debugPrint("✅ Data synced successfully for index $actualIndex.");
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint(
            "❌ Failed to sync item at index $actualIndex. Status: ${response.statusCode}, Data: ${response.data}");
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Failed to sync data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("🔥 Exception while syncing item at index $actualIndex: $e");
      debugPrint("🔥 Stacktrace: $stack");
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                    // Filter to show only unsynced items
                    final unsyncedItems = box.values
                        .where((item) => !item.isSynced)
                        .toList()
                        .cast<ShopTaggingModel>();

                    if (unsyncedItems.isEmpty) {
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
                      itemCount: unsyncedItems.length,
                      itemBuilder: (context, index) {
                        final item = unsyncedItems[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
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
                                          color: Colors.red[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Pending',
                                        style: GoogleFonts.lato(
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    Icons.person, 'Owner', item.ownerName),
                                _buildDetailRow(
                                    Icons.phone, 'Phone', item.phoneNo),
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
                                // if (item.imagePath.isNotEmpty)
                                //   Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       const SizedBox(height: 12),
                                //       Text(
                                //         'Image:',
                                //         style: GoogleFonts.lato(
                                //           fontWeight: FontWeight.bold,
                                //         ),
                                //       ),
                                //       const SizedBox(height: 4),
                                //       Image.file(
                                //         File(item.imagePath),
                                //         height: 100,
                                //         width: double.infinity,
                                //         fit: BoxFit.cover,
                                //       ),
                                //     ],
                                //   ),
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
                                        ElevatedButton.icon(
                                          onPressed: _isSyncing
                                              ? null
                                              : () => _syncSingleItem(index),
                                          icon:
                                              const Icon(Icons.sync, size: 16),
                                          label: Text(
                                            'Sync Now',
                                            style:
                                                GoogleFonts.lato(fontSize: 12),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[800],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
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
                                          onPressed: () {
                                            // Find the actual index in the box
                                            final actualIndex = _shopTaggingBox
                                                .values
                                                .toList()
                                                .indexOf(item);
                                            if (actualIndex != -1) {
                                              _deleteItem(actualIndex);
                                            }
                                          },
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
