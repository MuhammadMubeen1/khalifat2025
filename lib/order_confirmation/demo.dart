import 'dart:convert';
import 'dart:io';
import 'package:KhilafatCola/Hive/offline_order_model.dart';
import 'package:KhilafatCola/order_confirmation/OfflineOrdersScreen.dart';
import 'package:KhilafatCola/order_confirmation/sup_Order_Comfirm.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Products {
  final int productId;
  final String name;
  final String type;
  final double distributorPrice;
  final int quantityInPack;
  final String imageName;
  final int volumeInMl;
  int orderQuantity;

  Products({
    required this.productId,
    required this.name,
    required this.type,
    required this.distributorPrice,
    required this.quantityInPack,
    required this.imageName,
    required this.volumeInMl,
    this.orderQuantity = 0,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productId: json['ProductId']?.toInt() ?? 0,
      name: json['Name'] ?? '',
      type: json['Type'] ?? '',
      distributorPrice: json['DistributorPrice']?.toDouble() ?? 0.0,
      quantityInPack: json['QuantityInPack']?.toInt() ?? 0,
      imageName: json['ImageName'] ?? '',
      volumeInMl: json['VolumeInMl']?.toInt() ?? 0,
      orderQuantity: (json['OrderQuantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ProductId': productId,
        'Name': name,
        'Type': type,
        'DistributorPrice': distributorPrice,
        'QuantityInPack': quantityInPack,
        'ImageName': imageName,
        'VolumeInMl': volumeInMl,
        'OrderQuantity': orderQuantity,
      };
}

class Dealership {
  final int dealershipId;
  final String dealershipName;
  final String phoneNo;
  final String address;
  final String pinLocation;
  final List<Products> products;

  Dealership({
    required this.dealershipId,
    required this.dealershipName,
    required this.phoneNo,
    required this.address,
    required this.pinLocation,
    required this.products,
  });

  factory Dealership.fromJson(Map<String, dynamic> json) {
    var productList = json['Products'] as List? ?? [];
    List<Products> products = productList
        .map((i) => Products.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return Dealership(
      dealershipId: json['DealershipId']?.toInt() ?? 0,
      dealershipName: json['DealershipName'] ?? '',
      phoneNo: json['PhoneNo'] ?? '',
      address: json['Address'] ?? '',
      pinLocation: json['PinLocation'] ?? '',
      products: products,
    );
  }

  Map<String, dynamic> toJson() => {
        'DealershipId': dealershipId,
        'DealershipName': dealershipName,
        'PhoneNo': phoneNo,
        'Address': address,
        'PinLocation': pinLocation,
        'Products': products.map((p) => p.toJson()).toList(),
      };
}

class SelectedProduct {
  final int productId;
  final double distributorPrice;
  int orderQuantity;
  String productImage;
  String productName;
  int productVolumne;

  SelectedProduct({
    required this.productId,
    required this.distributorPrice,
    required this.orderQuantity,
    required this.productImage,
    required this.productVolumne,
    required this.productName,
  });
}

class DealershipScreen2 extends StatefulWidget {
  final int distributorID;
  final String? distributorName;
  final String? distributorAddress;
  final bool isOnline;

  const DealershipScreen2({
    super.key,
    required this.distributorID,
    this.distributorName,
    this.distributorAddress,
    this.isOnline = true,
  });

  @override
  _DealershipScreenState createState() => _DealershipScreenState();
}

class _DealershipScreenState extends State<DealershipScreen2> {
  Dealership? dealership;
  List<SelectedProduct> selectedProducts = [];
  bool isLoading = true;
  bool isOnline = true;
  final Connectivity _connectivity = Connectivity();
  late Box<OfflineOrder> offlineOrdersBox;
  late Box productsCacheBox;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    isOnline = widget.isOnline;
    _initHive().then((_) {
      _initConnectivity();
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen('offlineOrdersBox')) {
        offlineOrdersBox = await Hive.openBox<OfflineOrder>('offlineOrdersBox');
      } else {
        offlineOrdersBox = Hive.box<OfflineOrder>('offlineOrdersBox');
      }

      if (!Hive.isBoxOpen('products_cache')) {
        productsCacheBox = await Hive.openBox('products_cache');
      } else {
        productsCacheBox = Hive.box('products_cache');
      }
    } catch (e) {
      print('Error initializing Hive: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing local storage: $e')),
        );
      }
    }
  }

  Future<void> _initConnectivity() async {
    try {
      _connectivity.onConnectivityChanged.listen((result) {
        if (_isDisposed) return;
        setState(() {
          isOnline = result != ConnectivityResult.none;
        });
        if (isOnline) {
          _syncPendingOrders();
        }
      });
    } catch (e) {
      print('Error initializing connectivity: $e');
    }
  }

  Future<void> _syncPendingOrders() async {
    try {
      final pendingOrders =
          offlineOrdersBox.values.where((order) => !order.isSynced).toList();

      if (pendingOrders.isEmpty) return;

      for (final order in pendingOrders) {
        final key = offlineOrdersBox
            .keyAt(offlineOrdersBox.values.toList().indexOf(order));
        try {
          await _submitOrderToServer(order);
          await offlineOrdersBox.put(key, order.copyWith(isSynced: true));
        } catch (e) {
          print('Error syncing order ${order.dealershipId}: $e');
          continue;
        }
      }

      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${pendingOrders.length} orders synced successfully')),
        );
      }
    } catch (e) {
      print('Error syncing orders: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error syncing orders: $e')),
        );
      }
    }
  }

  Future<void> _submitOrderToServer(OfflineOrder order) async {
    final response = await http.post(
      Uri.parse("${Constants.BASE_URL}/api/App/SaveDealershipOrder"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '6XesrAM2Nu',
      },
      body: jsonEncode({
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
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit order: ${response.body}');
    }
  }

  Future<void> _loadProducts() async {
    if (_isDisposed) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isOnline) {
        try {
          dealership = await fetchDealership(widget.distributorID.toString());
          if (dealership != null) {
            await _cacheProducts(dealership!);
            print('Products loaded from network and cached');
          } else {
            throw Exception('Failed to fetch dealership data');
          }
        } catch (e) {
          print('Network fetch failed, trying cache: $e');
          dealership = await _loadCachedProducts(widget.distributorID);
          if (dealership == null) {
            throw Exception('No cached data available');
          }
        }
      } else {
        dealership = await _loadCachedProducts(widget.distributorID);
        if (dealership == null) {
          if (!_isDisposed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'No cached data available for this distributor. Please go online to fetch data first.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('Products loaded from cache');
        }
      }
    } catch (e) {
      print('Error loading products: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _cacheProducts(Dealership dealership) async {
    try {
      final cacheKey = 'products_${dealership.dealershipId}';
      final jsonData = dealership.toJson();

      await productsCacheBox.put(cacheKey, jsonData);
      print(
          'Products cached successfully for distributor ${dealership.dealershipId}');
    } catch (e) {
      print('Error caching products: $e');
      throw Exception('Failed to cache products: $e');
    }
  }

  Future<Dealership?> _loadCachedProducts(int distributorId) async {
    try {
      final cacheKey = 'products_$distributorId';
      final cachedData = productsCacheBox.get(cacheKey);

      if (cachedData != null) {
        print('Cached data found for distributor $distributorId');
        return Dealership.fromJson(Map<String, dynamic>.from(cachedData));
      } else {
        print('No cached data found for distributor $distributorId');
        return null;
      }
    } catch (e) {
      print('Error loading cached products: $e');
      return null;
    }
  }

  Future<Dealership> fetchDealership(String dealershipID) async {
    final url = Uri.parse(
      '${Constants.BASE_URL}/api/App/GetProductForDOByDistId?dealershipId=$dealershipID&appDateTime=${getCurrentDateTime()}',
    );

    print('Making request to: $url'); // Print the URL being called

    final response = await http.get(
      headers: {
        'Authorization': '6XesrAM2Nu',
      },
      url,
    );

    print('Response status code: ${response.statusCode}'); // Print status code
    print('Response body: ${response.body}'); // Print raw response body

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Parsed response data: $responseData'); // Print parsed data

      if (responseData['Data'] != null) {
        return Dealership.fromJson(
            Map<String, dynamic>.from(responseData['Data']));
      } else {
        throw Exception('No data found in response');
      }
    } else if (response.statusCode == 410) {
      final responseData = jsonDecode(response.body);
      print('Parsed response data (410): $responseData'); // Print parsed data

      if (responseData['Data'] != null &&
          responseData['Data']['Message'] != null) {
        return Dealership.fromJson(
            Map<String, dynamic>.from(responseData['Data']['Message']));
      }
      throw Exception('Failed to load dealership data');
    } else {
      throw Exception('Failed to load dealership data');
    }
  }

  void _showManualQuantityDialog(Products product) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter quantity",
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  int? newQuantity = int.tryParse(quantityController.text);
                  if (newQuantity != null && newQuantity >= 0) {
                    product.orderQuantity = newQuantity;

                    if (!selectedProducts
                        .any((p) => p.productId == product.productId)) {
                      selectedProducts.add(SelectedProduct(
                        productId: product.productId,
                        distributorPrice: product.distributorPrice,
                        orderQuantity: product.orderQuantity,
                        productImage: product.imageName,
                        productVolumne: product.volumeInMl,
                        productName: product.name,
                      ));
                    } else {
                      selectedProducts
                          .firstWhere((p) => p.productId == product.productId)
                          .orderQuantity = product.orderQuantity;
                    }
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _increaseQuantity(Products product) {
    setState(() {
      product.orderQuantity++;
      if (!selectedProducts.any((p) => p.productId == product.productId)) {
        selectedProducts.add(SelectedProduct(
            productId: product.productId,
            distributorPrice: product.distributorPrice,
            orderQuantity: product.orderQuantity,
            productImage: product.imageName,
            productVolumne: product.volumeInMl,
            productName: product.name));
      } else {
        selectedProducts
            .firstWhere((p) => p.productId == product.productId)
            .orderQuantity = product.orderQuantity;
      }
    });
  }

  void _decreaseQuantity(Products product) {
    setState(() {
      if (product.orderQuantity > 0) {
        product.orderQuantity--;
        if (product.orderQuantity == 0) {
          selectedProducts.removeWhere((p) => p.productId == product.productId);
        } else {
          selectedProducts
              .firstWhere((p) => p.productId == product.productId)
              .orderQuantity = product.orderQuantity;
        }
      }
    });
  }

  void _navigateToSelectedProducts() {
    print('Selected Products : $selectedProducts');

    if (selectedProducts.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Empty Cart'),
            content: const Text('Your cart is empty. Please add some items.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedProductsScreen(
            selectedProducts: selectedProducts,
            dealershipID: widget.distributorID,
            distributorName: widget.distributorName ??
                dealership?.dealershipName ??
                'Unknown',
            distributorAddress:
                widget.distributorAddress ?? dealership?.address ?? 'Unknown',
            isOnline: isOnline,
          ),
        ),
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
        title: const Text(
          'Primary Sale Products',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.offline_pin),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OfflineOrdersScreen()),
              );
            },
            tooltip: 'View Offline Orders',
          ),
          TextButton(
            onPressed: _navigateToSelectedProducts,
            child: const Text(
              'Checkout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber,
              child: const Text(
                'OFFLINE MODE - Working with cached data',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  )
                : dealership == null
                    ? const Center(
                        child: Text(
                            'No active Distributor Price Groups found for the Selected Distributor'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.all(constraints.maxWidth * 0.04),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: Colors.redAccent, width: 2),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          constraints.maxWidth * 0.04),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Distributor: ${dealership!.dealershipName}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Phone: ${dealership!.phoneNo}",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Address: ${dealership!.address}",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: dealership!.products.length,
                                  itemBuilder: (context, index) {
                                    final product = dealership!.products[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal:
                                              constraints.maxWidth * 0.04),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            constraints.maxWidth * 0.04),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 30,
                                              child: product
                                                      .imageName.isNotEmpty
                                                  ? (product.imageName
                                                          .startsWith(
                                                              'data:image')
                                                      ? Image.memory(
                                                          base64Decode(product
                                                              .imageName
                                                              .split(',')
                                                              .last),
                                                        )
                                                      : Image.network(
                                                          '${Constants.BASE_URL}/${product.imageName}',
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              'assets/default_image.png',
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ))
                                                  : Image.asset(
                                                      'assets/default_image.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${product.name} (${product.volumeInMl} ml ${product.type} )",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Distributor Price: ${product.distributorPrice}\nQuantity in Pack: ${product.quantityInPack}',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 13),
                                                  ),
                                                  const SizedBox(height: 4),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
                                                      onPressed: () =>
                                                          _decreaseQuantity(
                                                              product),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _showManualQuantityDialog(
                                                              product),
                                                      child: Text(
                                                        '${product.orderQuantity}',
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
                                                      onPressed: () =>
                                                          _increaseQuantity(
                                                              product),
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class SelectedProductsScreen extends StatefulWidget {
  final List<SelectedProduct> selectedProducts;
  final int dealershipID;
  final String distributorName;
  final String distributorAddress;
  final bool isOnline;

  const SelectedProductsScreen({
    super.key,
    required this.selectedProducts,
    required this.dealershipID,
    required this.distributorName,
    required this.distributorAddress,
    required this.isOnline,
  });

  @override
  State<SelectedProductsScreen> createState() => _SelectedProductsScreenState();
}

class _SelectedProductsScreenState extends State<SelectedProductsScreen> {
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _base64Image;
  late Box<OfflineOrder> offlineOrdersBox;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen('offlineOrdersBox')) {
        offlineOrdersBox = await Hive.openBox<OfflineOrder>('offlineOrdersBox');
      } else {
        offlineOrdersBox = Hive.box<OfflineOrder>('offlineOrdersBox');
      }
    } catch (e) {
      print('Error initializing Hive: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing local storage: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        await _convertImageToBase64(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
        await _convertImageToBase64(pickedFile.path);
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _convertImageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      if (!_isDisposed) {
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      print('Error converting image to base64: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  Future<void> saveDealershipOrder() async {
    if (!widget.isOnline) {
      await _saveOrderOffline();
      return;
    }

    if (_isDisposed) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> orderItemCommandList =
          widget.selectedProducts.map((product) {
        return {
          "productId": product.productId,
          "DistributorPrice": product.distributorPrice,
          "orderQuantity": product.orderQuantity,
        };
      }).toList();

      final Map<String, dynamic> bodyData = {
        "dealershipId": widget.dealershipID,
        "address": widget.distributorAddress,
        "userId": userid,
        "appDateTime": getCurrentDateTime(),
        "ImageFileSource": _base64Image,
        "OrderItemCommandList": orderItemCommandList,
      };

      final response = await http.post(
        Uri.parse("${Constants.BASE_URL}/api/App/SaveDealershipOrder"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order Created')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SupervisorOrderHistoryScreen(),
            ),
          );
        }
      } else {
        throw Exception('Failed to save order: ${response.body}');
      }
    } catch (e) {
      print('Error saving order: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveOrderOffline() async {
    if (_image == null) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please attach payment invoice')),
        );
      }
      return;
    }

    try {
      final offlineOrder = OfflineOrder(
        dealershipId: widget.dealershipID,
        dealershipName: widget.distributorName,
        address: widget.distributorAddress,
        userId: userid,
        appDateTime: getCurrentDateTime(),
        imageBase64: _base64Image,
        products: widget.selectedProducts
            .map((p) => OfflineOrderSelectedProduct(
                  productId: p.productId,
                  distributorPrice: p.distributorPrice,
                  orderQuantity: p.orderQuantity,
                  productName: p.productName,
                  productVolume: p.productVolumne,
                ))
            .toList(),
        isSynced: false,
        createdAt: DateTime.now(),
      );

      await offlineOrdersBox.add(offlineOrder);

      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order saved offline. Will sync when online')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SupervisorOrderHistoryScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error saving offline order: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving offline order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalQuantity = widget.selectedProducts
        .fold(0, (sum, product) => sum + product.orderQuantity);
    double totalAmount = widget.selectedProducts.fold(
        0.0,
        (sum, product) =>
            sum + (product.orderQuantity * product.distributorPrice));

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Selected Products',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!widget.isOnline)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.amber,
                  child: const Text(
                    'OFFLINE MODE - Order will be saved locally',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = widget.selectedProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: product.productImage.isNotEmpty
                                  ? (product.productImage
                                          .startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(product.productImage
                                              .split(',')
                                              .last),
                                          width: 70,
                                          height: 70,
                                        )
                                      : Image.network(
                                          '${Constants.BASE_URL}/${product.productImage}',
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/default_image.png',
                                              width: 70,
                                              height: 70,
                                            );
                                          },
                                        ))
                                  : Image.asset(
                                      'assets/default_image.png',
                                      width: 70,
                                      height: 70,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        'Name: ${product.productName}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Volume in ML: ${product.productVolumne} ml',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Distributor Price: ${(product.distributorPrice).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'QTY:',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${product.orderQuantity}',
                                        style: const TextStyle(
                                            fontSize: 28,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Total Quantity: $totalQuantity',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Amount: Rs.$totalAmount',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Attach Payment Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              _image != null
                  ? Image.file(
                      File(_image!.path),
                      width: 100,
                      height: 100,
                    )
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () async {
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please Attach Payment Invoice')),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(child: Text("Confirm Order")),
                            content: const Text(
                                'Are you sure you want to save this order?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await saveDealershipOrder();
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Order',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
