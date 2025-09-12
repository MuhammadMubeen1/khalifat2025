import 'dart:convert';
import 'dart:io';
import 'package:KhilafatCola/Shop_Tagging/offline_shop_tagging_screen.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_history.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

class ShopTaggingOffline extends StatefulWidget {
  const ShopTaggingOffline({super.key});

  @override
  State<ShopTaggingOffline> createState() => _ShopTaggingState();
}

class _ShopTaggingState extends State<ShopTaggingOffline> {
  bool isLoading = false;
  bool isSuccess = false;
  String coordinates = '';
  bool _isLoading = false;
  late Box<ShopTaggingModel> _shopTaggingBox;
  late Box _appDataBox;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopname = TextEditingController();
  final TextEditingController _phoneno = TextEditingController();
  final TextEditingController _shopaddress = TextEditingController();
  final TextEditingController _ownername = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _openingtime = TextEditingController();
  final TextEditingController _closetime = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _secondaryPhone = TextEditingController();
  final TextEditingController _pepsiController = TextEditingController();
  final TextEditingController _cokeController = TextEditingController();
  final TextEditingController _nestleController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _nesfrutaController = TextEditingController();

  // Location and images
  String lat = '';
  String log = '';
  List<File> _imageFiles = [];
  List<String> base64Images = [];

  // Categories
  List<dynamic> _categories = [];
  int? _selectedCategory;
  List<dynamic> _categoriesdist = [];
  int? _selecteddistCategory;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initHive().then((_) {
      _loadCachedData();
      _fetchCategories();
      _fetchDistributorsCategories();
      _checkAndRequestLocationPermission();
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission permanently denied. Please enable it in settings.'),
        ),
      );
      await Geolocator.openAppSettings();
      return;
    }

    await _getLocation();
  }

  Future<void> _initHive() async {
    _shopTaggingBox = await Hive.openBox<ShopTaggingModel>('shopTaggingBox');
    _appDataBox = await Hive.openBox('appData');
  }

  Future<void> _loadCachedData() async {
    final cachedDistributors = _appDataBox.get('cachedDistributors');
    final cachedShopTypes = _appDataBox.get('cachedShopTypes');

    if (cachedDistributors != null) {
      setState(() {
        _categoriesdist = cachedDistributors;
      });
    }

    if (cachedShopTypes != null) {
      setState(() {
        _categories = cachedShopTypes;
      });
    }
  }

  Future<void> _cacheData() async {
    await _appDataBox.put('cachedDistributors', _categoriesdist);
    await _appDataBox.put('cachedShopTypes', _categories);
  }

  Future<void> _getLocation() async {
    setState(() {
      isLoading = true;
      isSuccess = false;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optionally prompt user to enable location services
        bool enabled = await Geolocator.openLocationSettings();
        if (!enabled) {
          throw 'Location services are required but disabled.';
        }
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are required but denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Direct user to app settings
        await Geolocator.openAppSettings();
        throw 'Location permissions are permanently denied. Please enable them in app settings.';
      }

      // Get current position with fallbacks
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      ).onError((error, stackTrace) async {
        // Fallback to lower accuracy if high accuracy fails
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 10),
        );
      });

      // Update state with position data
      setState(() {
        coordinates =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
        lat = position.latitude.toString();
        log = position.longitude.toString();
        isLoading = false;
        isSuccess = true;
      });
    } catch (e) {
      print('Location error: $e');
      setState(() {
        isLoading = false;
        isSuccess = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get(
        '${Constants.BASE_URL}/api/App/GetShopType?appDateTime=${getCurrentDateTime()}',
        options: Options(
          headers: {
            'Authorization': '6XesrAM2Nu',
          },
        ),
      );
      setState(() {
        _categories = response.data['Data'];
        _appDataBox.put('cachedShopTypes', _categories);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchDistributorsCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _dio.get(
        '${Constants.BASE_URL}/api/App/GetTerritoryByUserId?userId=$userid&appDateTime=${getCurrentDateTime()}',
        options: Options(
          headers: {
            'Authorization': '6XesrAM2Nu',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data != null && response.data['Data'] != null) {
        setState(() {
          _categoriesdist = response.data['Data'];
          _appDataBox.put('cachedDistributors', _categoriesdist);
          isLoading = false;
        });
      } else {
        print('Data not found in the response');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to fetch categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      String formattedTime = DateFormat('hh:mm a').format(
        DateTime(2021, 1, 1, picked.hour, picked.minute),
      );
      controller.text = formattedTime;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'\.(jpg|jpeg|png)'));
      final extension = filePath.substring(lastIndex);
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_compressed$extension";

      // Get original file size
      final originalSize = await file.length();
      print('Original image size: ${originalSize / 1024} KB');

      // Start with higher quality and reduce until we reach target size
      int quality = 70;
      File? result;
      int maxAttempts = 10; // Prevent infinite loop

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          outPath,
          quality: quality,
          minWidth: 800, // Reduced from 1024
          minHeight: 800, // Reduced from 1024
        );

        if (result == null) break;

        // Check compressed file size
        final compressedSize = await result.length();
        final sizeInKB = compressedSize / 1024;
        print(
            'Compression attempt $attempt: Quality $quality, Size: ${sizeInKB.toStringAsFixed(2)} KB');

        // If under 50KB or quality is too low, stop
        if (sizeInKB <= 50 || quality <= 10) {
          print('Final compressed size: ${sizeInKB.toStringAsFixed(2)} KB');
          return result;
        }

        // Reduce quality for next attempt
        quality = (quality * 0.7).round().clamp(10, 100);

        // If quality reduction is too small, do more aggressive reduction
        if (compressedSize > 100 * 1024) {
          // If still over 100KB
          quality = (quality * 0.5).round().clamp(10, 100);
        }
      }

      return result;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> captureImage() async {
    if (_imageFiles.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You can only upload a maximum of 1 image.')),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduced from default
        maxWidth: 1200, // Added max width
        maxHeight: 1200, // Added max height
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        File originalImageFile = File(image.path);
        File? compressedImage = await _compressImage(originalImageFile);

        if (compressedImage != null) {
          List<int> imageBytes = await compressedImage.readAsBytes();
          final compressedSize = imageBytes.length / 1024;
          print(
              'Final image size after compression: ${compressedSize.toStringAsFixed(2)} KB');

          setState(() {
            _imageFiles.add(compressedImage);
            base64Images.add(base64Encode(imageBytes));
            _isLoading = false;
          });
        } else {
          // Fallback to original image if compression fails
          List<int> imageBytes = await originalImageFile.readAsBytes();
          final originalSize = imageBytes.length / 1024;
          print(
              'Using original image, size: ${originalSize.toStringAsFixed(2)} KB');

          setState(() {
            _imageFiles.add(originalImageFile);
            base64Images.add(base64Encode(imageBytes));
            _isLoading = false;
          });
        }
      } else {
        print("No image selected");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      base64Images.removeAt(index);
    });
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  // Check if shop with same phone number already exists in local storage
  bool _isShopAlreadyExists(String phoneNo) {
    final allShops = _shopTaggingBox.values.toList();
    return allShops.any((shop) => shop.phoneNo == phoneNo);
  }

  Future<void> _saveShopTagging() async {
    // Check if shop with same phone number already exists
    if (_isShopAlreadyExists(_phoneno.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Duplicate Phone Number"),
            content: const Text(
              "A shop with this phone number already exists in offline storage.",
            ),
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
      return;
    }

    final shopTagging = ShopTaggingModel(
      id: 0,
      userId: userid ?? '',
      TerritoryId: _selecteddistCategory,
      shopName: _shopname.text,
      phoneNo: _phoneno.text,
      ownerName: _ownername.text,
      address: _address.text,
      openingTime: _openingtime.text,
      closingTime: _closetime.text,
      imageExtension: ".jpg",
      lat: lat.isNotEmpty ? double.parse(lat) : 0.0,
      lng: log.isNotEmpty ? double.parse(log) : 0.0,
      imageFileSource: base64Images.join('|||'),
      shopTypeId: _selectedCategory,
      pepsiFridge: _pepsiController.text.isEmpty ? '0' : _pepsiController.text,
      cokeFridge: _cokeController.text.isEmpty ? '0' : _cokeController.text,
      nestleFridge:
          _nestleController.text.isEmpty ? '0' : _nestleController.text,
      nesfrutaFridge:
          _nesfrutaController.text.isEmpty ? '0' : _nesfrutaController.text,
      othersFridge: _otherController.text.isEmpty ? '0' : _otherController.text,
      appDateTime: DateTime(2020, 1, 1).toIso8601String(),
      landmark: _landmark.text.isEmpty ? '' : _landmark.text,
      secondaryPhoneNo:
          _secondaryPhone.text.isEmpty ? '' : _secondaryPhone.text,
      isSynced: false,
      createdAt: DateTime.now(), // Use current date instead of placeholder
    );

    // Print all data to console
    print('=== SHOP TAGGING DATA BEING SAVED ===');
    print('id: ${shopTagging.id}');
    print('userId: ${shopTagging.userId}');
    print('TerritoryId: ${shopTagging.TerritoryId}');
    print('shopName: ${shopTagging.shopName}');
    print('phoneNo: ${shopTagging.phoneNo}');
    print('ownerName: ${shopTagging.ownerName}');
    print('address: ${shopTagging.address}');
    print('openingTime: ${shopTagging.openingTime}');
    print('closingTime: ${shopTagging.closingTime}');
    print('imageExtension: ${shopTagging.imageExtension}');
    print('lat: ${shopTagging.lat}');
    print('lng: ${shopTagging.lng}');
    print(
        'imageFileSource length: ${shopTagging.imageFileSource.length} characters');
    print('shopTypeId: ${shopTagging.shopTypeId}');
    print('pepsiFridge: ${shopTagging.pepsiFridge}');
    print('cokeFridge: ${shopTagging.cokeFridge}');
    print('nestleFridge: ${shopTagging.nestleFridge}');
    print('nesfrutaFridge: ${shopTagging.nesfrutaFridge}');
    print('othersFridge: ${shopTagging.othersFridge}');
    print('appDateTime: ${shopTagging.appDateTime}');
    print('landmark: ${shopTagging.landmark}');
    print('secondaryPhoneNo: ${shopTagging.secondaryPhoneNo}');
    print('isSynced: ${shopTagging.isSynced}');
    print('createdAt: ${shopTagging.createdAt}');
    print('Number of images: ${base64Images.length}');
    print('=====================================');

    await _shopTaggingBox.add(shopTagging);

    // Print confirmation of saving
    print('Shop tagging data saved to local storage successfully!');
    print('=====================================');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Saved Successfully"),
          content: const Text(
            "Your shop tagging has been saved offline. You can manually sync it when the internet connection is stable.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineShopTaggingScreen(),
                  ),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _shopTaggingOnline(ShopTaggingModel shopTagging) async {
    String url = '${Constants.BASE_URL}/api/App/SaveShopTaggingByTerritoryId';

    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Convert the imageFileSource string back to a list
    List<String> imageSources = shopTagging.imageFileSource.split('|||');

    Map<String, dynamic> body = {
      "command": "SaveShopTagging", // Added the required command field
      "id": 0,
      "userId": shopTagging.userId,
      "TerritoryId": shopTagging.TerritoryId,
      "shopName": shopTagging.shopName,
      "phoneNo": shopTagging.phoneNo,
      "ownerName": shopTagging.ownerName,
      "address": shopTagging.address,
      "openingTime": shopTagging.openingTime,
      "closingTime": shopTagging.closingTime,
      "imageExtension": shopTagging.imageExtension,
      "lat": shopTagging.lat,
      "lng": shopTagging.lng,
      "imageFileSource":
          imageSources, // Send as array instead of concatenated string
      "shopTypeId": shopTagging.shopTypeId,
      "pepsiFridge": shopTagging.pepsiFridge,
      "cokeFridge": shopTagging.cokeFridge,
      "nestleFridge": shopTagging.nestleFridge,
      "nesfrutaFridge": shopTagging.nesfrutaFridge,
      "othersFridge": shopTagging.othersFridge,
      "appDateTime":
      // DateTime(2020, 1, 1).toIso8601String(),
       shopTagging.appDateTime,
      "landmark": shopTagging.landmark,
      "secondaryPhoneNo": shopTagging.secondaryPhoneNo,
    };

    // Print the JSON body to console
    print('=== API REQUEST BODY ===');
    print('URL: $url');
    print('Headers: $headers');
    print('Body (JSON):');

    final jsonString = JsonEncoder.withIndent('  ').convert(body);
    print(jsonString);
    print('========================');

    // Print all function parameters
    print('=== FUNCTION PARAMETERS ===');
    print('ShopTaggingModel details:');
    print('  userId: ${shopTagging.userId}');
    print('  TerritoryId: ${shopTagging.TerritoryId}');
    print('  shopName: ${shopTagging.shopName}');
    print('  phoneNo: ${shopTagging.phoneNo}');
    print('  ownerName: ${shopTagging.ownerName}');
    print('  address: ${shopTagging.address}');
    print('  openingTime: ${shopTagging.openingTime}');
    print('  closingTime: ${shopTagging.closingTime}');
    print('  imageExtension: ${shopTagging.imageExtension}');
    print('  lat: ${shopTagging.lat}');
    print('  lng: ${shopTagging.lng}');
    print('  imageFileSource (original): ${shopTagging.imageFileSource}');
    print('  shopTypeId: ${shopTagging.shopTypeId}');
    print('  pepsiFridge: ${shopTagging.pepsiFridge}');
    print('  cokeFridge: ${shopTagging.cokeFridge}');
    print('  nestleFridge: ${shopTagging.nestleFridge}');
    print('  nesfrutaFridge: ${shopTagging.nesfrutaFridge}');
    print('  othersFridge: ${shopTagging.othersFridge}');
    print('  landmark: ${shopTagging.landmark}');
    print('  secondaryPhoneNo: ${shopTagging.secondaryPhoneNo}');
    print('===========================');

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );

      print('=== API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Headers: ${response.headers}');
      print('====================');

      return response.statusCode == 200;
    } catch (e) {
      print('=== API ERROR ===');
      print('Error: $e');
      if (e is DioError) {
        print('Dio Error Type: ${e.type}');
        print('Error Message: ${e.message}');
        print('Error Response: ${e.response}');
      }
      print('=================');
      return false;
    }
  }

  Future<void> shopTagging() async {
    if (_formKey.currentState!.validate() &&
        _imageFiles.isNotEmpty &&
        isSuccess == true) {
      if (_selecteddistCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Territory')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await _saveShopTagging();

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill all required fields and capture location/at least one image')),
      );
    }
  }

  Widget _buildDistributorDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        hintText: 'Select Territory',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 16,
        ),
        prefixIcon: const Icon(
          Icons.explore_outlined,
          color: Colors.red,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
      items: _categoriesdist.isEmpty
          ? [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(
                  'No Territory available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]
          : _categoriesdist
              .map((distributor) => DropdownMenuItem<int>(
                    value: distributor['TerritoryId'] as int,
                    child: Text(distributor['TerritoryName'] as String),
                  ))
              .toList(),
      onChanged: (value) {
        setState(() {
          _selecteddistCategory = value;
        });
      },
      value: _selecteddistCategory,
      validator: (value) => value == null ? 'Please select a Territory' : null,
    );
  }

  Widget _buildShopTypeDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        hintText: 'Select Category',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 16,
        ),
        prefixIcon: const Icon(
          Icons.category,
          color: Colors.red,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
      items: _categories.isEmpty
          ? [
              const DropdownMenuItem<int>(
                value: null,
                child: Text(
                  'No shop type available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]
          : _categories
              .map((category) => DropdownMenuItem<int>(
                    value: category['Id'] as int,
                    child: Text(category['Name'] as String),
                  ))
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      value: _selectedCategory,
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _imageFiles.length >= 1
          ? 1
          : _imageFiles.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == _imageFiles.length && _imageFiles.length < 1) {
          return GestureDetector(
            onTap: captureImage,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Icon(Icons.add_a_photo, color: Colors.red),
              ),
            ),
          );
        } else {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_imageFiles[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
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
                          ))),
                      Center(
                          child: Text(
                        'Shop Tagging Offline',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OfflineShopTaggingScreen()));
                        },
                        child: Text(
                          'Offline Data',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    // Distributor Dropdown
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: _buildDistributorDropdown(),
                      ),
                    ),

                    // Shop Name
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Shop Name';
                            }
                            return null;
                          },
                          controller: _shopname,
                          decoration: InputDecoration(
                            hintText: 'Shop Name',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Owner Name
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Owner Name';
                            }
                            return null;
                          },
                          controller: _ownername,
                          decoration: InputDecoration(
                            hintText: 'Owner Name',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Phone Number
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            MaskTextInputFormatter(
                              mask: '####-#######',
                              filter: {"#": RegExp(r'[0-9]')},
                            )
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length != 12) {
                              return 'Please Enter Phone No';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: _phoneno,
                          decoration: InputDecoration(
                            hintText: 'Phone No',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Secondary Phone
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            MaskTextInputFormatter(
                              mask: '####-#######',
                              filter: {"#": RegExp(r'[0-9]')},
                            )
                          ],
                          keyboardType: TextInputType.number,
                          controller: _secondaryPhone,
                          decoration: InputDecoration(
                            hintText: 'Secondary Phone No  - Optional',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Shop Category Dropdown
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: _buildShopTypeDropdown(),
                      ),
                    ),

                    // Shop Address
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Shop Address';
                            }
                            return null;
                          },
                          controller: _address,
                          decoration: InputDecoration(
                            hintText: 'Shop Address',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.pin_drop,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Landmark
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          controller: _landmark,
                          decoration: InputDecoration(
                            hintText: 'Landmark',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.pin_drop,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Opening Time
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          controller: _openingtime,
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Shop Opening Time';
                            }
                            return null;
                          },
                          onTap: () {
                            _selectTime(context, _openingtime);
                          },
                          keyboardType: TextInputType.none,
                          decoration: InputDecoration(
                            hintText: 'Shop Opening Time',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.watch_later,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Closing Time
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Shop Closing Time';
                            }
                            return null;
                          },
                          onTap: () {
                            _selectTime(context, _closetime);
                          },
                          keyboardType: TextInputType.number,
                          controller: _closetime,
                          inputFormatters: [
                            MaskTextInputFormatter(
                              mask: '##:##',
                              filter: {"#": RegExp(r'[0-9]')},
                            )
                          ],
                          decoration: InputDecoration(
                            hintText: 'Shop Close Time',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.watch_later,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Pepsi Fridges
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                          controller: _pepsiController,
                          decoration: InputDecoration(
                            hintText: 'Pepsi Fridges',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Coke Fridges
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                          controller: _cokeController,
                          decoration: InputDecoration(
                            hintText: 'Coke Fridges',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Nestle Fridges
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                          controller: _nestleController,
                          decoration: InputDecoration(
                            hintText: 'Nestle Fridges',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Nesfruta Fridges
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                          controller: _nesfrutaController,
                          decoration: InputDecoration(
                            hintText: 'Nesfruta Fridges',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Other Fridges
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _otherController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Other Fridges',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.shopping_bag,
                              color: Colors.red,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Location and Image Capture
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 1500),
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () {
                                    _getLocation();
                                  },
                            child: Container(
                              height: 50,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB71234),
                                    Color(0xFFF02A2A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : isSuccess
                                        ? const Icon(Icons.check,
                                            color: Colors.white)
                                        : Text(
                                            "Get Location",
                                            style: GoogleFonts.lato(
                                                color: Colors.white),
                                          ),
                              ),
                            ),
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1500),
                          child: InkWell(
                            onTap: captureImage,
                            child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB71234),
                                      Color(0xFFF02A2A),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      )),
                          ),
                        ),
                      ],
                    ),

                    // Image Grid
                    const SizedBox(height: 10),
                    _buildImageGrid(),

                    // Submit Button
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: InkWell(
                        onTap: shopTagging,
                        child: Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFB71234),
                                Color(0xFFF02A2A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Done',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shopname.dispose();
    _phoneno.dispose();
    _shopaddress.dispose();
    _ownername.dispose();
    _address.dispose();
    _openingtime.dispose();
    _closetime.dispose();
    _landmark.dispose();
    _secondaryPhone.dispose();
    _pepsiController.dispose();
    _cokeController.dispose();
    _nestleController.dispose();
    _otherController.dispose();
    _nesfrutaController.dispose();
    super.dispose();
  }
}
