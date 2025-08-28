import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:KhilafatCola/Hive/offline_order_model.dart'
show OfflineOrder, OfflineOrderSelectedProduct;
import 'package:KhilafatCola/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class OfflineOrdersScreen extends StatefulWidget {
  const OfflineOrdersScreen({super.key});

  @override
  _OfflineOrdersScreenState createState() => _OfflineOrdersScreenState();
}

class _OfflineOrdersScreenState extends State<OfflineOrdersScreen> {
  late Box<OfflineOrder> offlineOrdersBox;
  bool isLoading = false;
  bool isSyncing = false;
  bool isSendingOrder = false; // New flag for sending order progress
  bool _isDisposed = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();

  @override 
  void initState() {
    super.initState();
    _initHive();
  }

  @override
  void dispose() {
    _isDisposed = true;
    Hive.close();
    super.dispose();
  }

  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen('offlineOrdersBox')) {
        offlineOrdersBox = await Hive.openBox<OfflineOrder>('offlineOrdersBox');
      } else {
        offlineOrdersBox = Hive.box<OfflineOrder>('offlineOrdersBox');
      }
      if (mounted) setState(() {});
    } catch (e) {
      _showSnackBar('Error initializing storage: $e');
    }
  }

  Future<void> _syncOrders() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      isSyncing = true;
    });

    try {
      final pendingOrders =
          offlineOrdersBox.values.where((order) => !order.isSynced).toList();

      if (pendingOrders.isEmpty) {
        _showSnackBar('No pending orders to sync');
        return;
      }

      int successCount = 0;
      int failedCount = 0;

      for (final order in pendingOrders) {
        try {
          final key = offlineOrdersBox.keys.firstWhere(
            (k) {
              final storedOrder = offlineOrdersBox.get(k);
              return storedOrder != null &&
                  storedOrder.dealershipId == order.dealershipId &&
                  storedOrder.createdAt == order.createdAt;
            },
            orElse: () => -1,
          );

          if (key == -1) continue;

          setState(() {
            isSendingOrder = true; // Show progress when sending each order
          });

          final success = await _submitOrderToServer(order);
          if (success) {
            await offlineOrdersBox.put(key, order.copyWith(isSynced: true));
            successCount++;
          } else {
            failedCount++;
          }
        } catch (e) {
          print('Error syncing order ${order.dealershipId}: $e');
          failedCount++;
          continue;
        } finally {
          if (mounted) {
            setState(() {
              isSendingOrder = false; // Hide progress after each order
            });
          }
        }
      }

      _showSnackBar('Synced $successCount orders (${failedCount} failed)');
    } catch (e) {
      _showSnackBar('Error syncing orders: ${e.toString()}');
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isSyncing = false;
          isSendingOrder = false;
        });
      }
    }
  }

  Future<String?> _compressAndConvertImage(String base64Image) async {
    try {
      // Decode the base64 string to bytes
      String cleanBase64 = base64Image;
      if (base64Image.startsWith('data:')) {
        cleanBase64 = base64Image.split(',').last;
      }

      Uint8List imageBytes = base64Decode(cleanBase64);

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print('Failed to decode image');
        return null;
      }

      // Resize the image (max width 800px, maintain aspect ratio)
      if (image.width > 800) {
        image = img.copyResize(image, width: 800);
      }

      // Compress the image (quality 70%)
      List<int> compressedBytes = img.encodeJpg(image, quality: 70);

      // Convert back to base6
      String compressedBase64 = base64Encode(compressedBytes);

      print(
          'Image compressed from ${imageBytes.length} bytes to ${compressedBytes.length} bytes');

      return compressedBase64;
    } catch (e) {
      print('Error compressing image: $e'); 
      return null;
    }
  }

  Future<bool> _submitOrderToServer(OfflineOrder order) async {
    try {
      // Validate required fields
      if (order.dealershipId == null) {
        throw Exception('Dealership ID is required');
      }
      if (order.userId == null) {
        throw Exception('User ID is required');
      }
      if (order.products.isEmpty) {
        throw Exception('Order must contain products');
      }

      // Validate products
      final List<Map<String, dynamic>> validProducts = [];
      for (final product in order.products) {
        if (product.productId == null) {
          throw Exception('Product ID is required');
        }
        if (product.distributorPrice == null) {
          throw Exception('Distributor price is required');
        }
        if (product.orderQuantity == null || product.orderQuantity <= 0) {
          throw Exception('Invalid quantity for product ${product.productId}');
        }

        validProducts.add({
          "productId": product.productId,
          "DistributorPrice": product.distributorPrice,
          "orderQuantity": product.orderQuantity,
        });
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      // Handle image compression and base64 conversion
      String? compressedImageData = null;

      if (order.imageBase64 != null && order.imageBase64!.isNotEmpty) {
        try {
          compressedImageData =
              await _compressAndConvertImage(order.imageBase64!);
          if (compressedImageData == null) {
            print('Failed to compress image, using original');
            compressedImageData = order.imageBase64!;
          }
        } catch (e) {
          print('Error processing image: $e');
          compressedImageData = order.imageBase64!;
        }
      }

      // Prepare request body
      final requestBody = {
        "dealershipId": order.dealershipId,
        "address": order.address ?? '',
        "userId": order.userId,
        "appDateTime": order.appDateTime ?? getCurrentDateTime(),
        "ImageFileSource": compressedImageData ?? '',
        "OrderItemCommandList": validProducts,
      };

      print('Submitting order to dealership ${order.dealershipId}');
      print('Image data length: ${compressedImageData?.length ?? 0}');
      print('Request body: ${jsonEncode(requestBody)}');

      // Make API request
      final response = await http
          .post(
            Uri.parse("${Constants.BASE_URL}/api/App/SaveDealershipOrder"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': '6XesrAM2Nu',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 200) {
            print('Order submitted successfully');
            return true;
          } else {
            final errorMessage = responseData['Message'] ??
                responseData['message'] ??
                'Order submission failed';
            throw Exception(errorMessage);
          }
        } catch (e) {
          throw Exception('Failed to parse server response: $e');
        }
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['Message'] ??
              errorResponse['message'] ??
              errorResponse['Exception']?['Message'] ??
              'Order submission failed with status ${response.statusCode}';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception(
              'Failed to submit order: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error submitting order: $e');
      _showSnackBar(
          'Failed to sync order: ${e.toString().replaceAll('Exception: ', '')}');
      return false;
    }
  }

  Future<void> _deleteOrder(dynamic key) async {
    try {
      await offlineOrdersBox.delete(key);
      if (mounted) setState(() {});
      _showSnackBar('Order deleted');
    } catch (e) {
      _showSnackBar('Error deleting order: $e');
    }
  }

  void _showSnackBar(String message) {
    if (_isDisposed || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  String getCurrentDateTime() {
    return DateTime.now().toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Orders'),
          actions: [
            if (offlineOrdersBox.values.any((order) => !order.isSynced))
              IconButton(
                icon: isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                onPressed: isSyncing ? null : _syncOrders,
                tooltip: 'Sync Orders',
              ),
          ],
        ),
        body: Stack(
          children: [
            _buildOrderList(),
            if (isSendingOrder)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sending order...',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!Hive.isBoxOpen('offlineOrdersBox') || offlineOrdersBox.isEmpty) {
      return const Center(child: Text('No offline orders found'));
    }

    final unsyncedOrders =
        offlineOrdersBox.values.where((o) => !o.isSynced).toList();
    final syncedOrders =
        offlineOrdersBox.values.where((o) => o.isSynced).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _initHive();
        if (mounted) setState(() {});
      },
      child: ListView(
        children: [
          if (unsyncedOrders.isNotEmpty) ...[
            _buildSectionHeader('Pending Sync (${unsyncedOrders.length})'),
            ...offlineOrdersBox
                .toMap()
                .entries
                .where((e) => !e.value.isSynced)
                .map((e) => _buildOrderCard(e.key, e.value)),
          ],
          if (syncedOrders.isNotEmpty) ...[
            _buildSectionHeader('Synced Orders (${syncedOrders.length})'),
            ...offlineOrdersBox
                .toMap()
                .entries
                .where((e) => e.value.isSynced)
                .map((e) => _buildOrderCard(e.key, e.value)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
  Widget _buildOrderCard(dynamic key, OfflineOrder order) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final totalAmount = order.products.fold(
      0.0,
      (sum, product) =>
          sum + (product.orderQuantity * (product.distributorPrice ?? 0)),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.dealershipName ?? 'Unknown Dealership',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    order.isSynced ? 'Synced' : 'Pending',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor:
                      order.isSynced ? Colors.green[100] : Colors.orange[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(order.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (order.address?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address:', style: TextStyle(color: Colors.grey[700])),
                  Text(
                    order.address!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            const Text('Products:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.products.map((product) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${product.productName ?? 'Unknown'} (${product.productVolume ?? 0}ml)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${product.orderQuantity} × ${product.distributorPrice?.toStringAsFixed(2) ?? '0.00'}',
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs.${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (!order.isSynced)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteConfirmation(key),
                  ),
              ],
            ),
            if (order.imageBase64?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Payment Receipt:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showFullImage(order.imageBase64!),
                    child: Center(
                      child: Image.memory(
                        _getImageBytes(order.imageBase64!),
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.receipt, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Uint8List _getImageBytes(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:')) {
        cleanBase64 = base64String.split(',').last;
      }
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Error decoding image: $e');
      return base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
    }   
  }

  void _showFullImage(String base64Image) {
    showDialog(
      context: context, 
      builder: (context) => Dialog( 
        child: InteractiveViewer(
          child: Image.memory(
            _getImageBytes(base64Image),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,  
                child: const Center(
                  child: Text('Unable to display image'),
                ),
              );
            },
          ),
        ),
      ), 
    );
  }

  void _showDeleteConfirmation(dynamic key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(key);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
