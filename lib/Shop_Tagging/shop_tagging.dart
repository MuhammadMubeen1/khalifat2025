import 'dart:convert';
import 'dart:io';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_history.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // For Uint8List
import 'package:path_provider/path_provider.dart'; // For getTemporaryDirectory
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ShopTagging extends StatefulWidget {
  final int shopId;
  final Map<String, dynamic>? shopData; // Add this parameter

  ShopTagging({super.key, required this.shopId, this.shopData});

  @override
  State<ShopTagging> createState() => _ShopTaggingState();
}

class _ShopTaggingState extends State<ShopTagging> {
  bool isLoading = false;
  bool isSuccess = false;
  String coordinates = '';
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _isLoading = false;
  double _internetSpeed = 0.0;

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

  // Location and image
  String lat = '';
  String log = '';
  File? _imageFile;
  String base64Image = '';
  bool _isImageLoading = false;
  bool _hasNewImage = false; // Track if user captured a new image

  // Categories
  List<dynamic> _categories = [];
  int? _selectedCategory;
  List<dynamic> _categoriesdist = [];
  int? _selecteddistCategory;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectionChanges();

    if (_isConnected) {
      _checkInternetSpeed().then((_) {
        if (_internetSpeed > 0.5) {
          _fetchCategories();
          _fetchDistributorsCategories();
        }
      });
    }

    // Pre-fill form if we're editing an existing shop
    if (widget.shopData != null) {
      _prefillFormData();
    }
  }

  void _prefillFormData() {
    final data = widget.shopData!;

    // Set form values from the shop data
    _shopname.text = data['ShopName'] ?? '';
    _phoneno.text = data['PhoneNo'] ?? '';
    _ownername.text = data['OwnerName'] ?? '';
    _address.text = data['Address'] ?? '';
    _openingtime.text = data['OpeningTime'] ?? '';
    _closetime.text = data['ClosingTime'] ?? '';
    _landmark.text = data['Landmark'] ?? '';
    _secondaryPhone.text = data['SecondaryPhoneNo'] ?? '';

    // Set fridge counts if available
    _pepsiController.text = data['PepsiFridge']?.toString() ?? '0';
    _cokeController.text = data['CokeFridge']?.toString() ?? '0';
    _nestleController.text = data['NestleFridge']?.toString() ?? '0';
    _nesfrutaController.text = data['NesfrutaFridge']?.toString() ?? '0';
    _otherController.text = data['OthersFridge']?.toString() ?? '0';

    // Set category and distributor if available
    if (data['ShopTypeId'] != null) {
      _selectedCategory = data['ShopTypeId'] as int;
    }

    if (data['TerritoryId'] != null) {
      _selecteddistCategory = data['TerritoryId'] as int;
    }

    // Set location if available
    if (data['PinLocation'] != null) {
      try {
        // Check if PinLocation is already a parsed map or a JSON string
        Map<String, dynamic> locationMap;
        if (data['PinLocation'] is String) {
          locationMap = json.decode(data['PinLocation']);
        } else {
          locationMap = Map<String, dynamic>.from(data['PinLocation']);
        }

        lat = locationMap['lat'].toString();
        log = locationMap['lng'].toString();
        isSuccess = true;
        coordinates = "Latitude: $lat, Longitude: $log";
      } catch (e) {
        print('Error parsing location: $e');
        // Try alternative parsing if the first method fails
        try {
          String locationString = data['PinLocation'].toString();
          if (locationString.contains('{') && locationString.contains('}')) {
            final regex = RegExp(r'"lat":([\d.]+).*?"lng":([\d.]+)');
            final match = regex.firstMatch(locationString);
            if (match != null) {
              lat = match.group(1)!;
              log = match.group(2)!;
              isSuccess = true;
              coordinates = "Latitude: $lat, Longitude: $log";
            }
          }
        } catch (e2) {
          print('Alternative parsing also failed: $e2');
        }
      }
    }

    // Load image if available
    if (data['ImageName'] != null) {
      _loadImageFromUrl(data['ImageName']);
    } else if (data['ImageNamea'] != null) {
      // Try alternative image field if main one is not available
      _loadImageFromUrl(data['ImageNamea']);
    }
  }

  Future<void> _loadImageFromUrl(String imageUrl) async {
    setState(() {
      _isImageLoading = true;
    });

    try {
      // Clear any existing image data first
      setState(() {
        _imageFile = null;
        base64Image = '';
        _hasNewImage = false;
      });

      if (imageUrl.startsWith('data:image')) {
        // Handle base64 encoded image
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          final base64String = imageUrl.substring(commaIndex + 1);
          final bytes = base64Decode(base64String);
          base64Image = base64String; // Store the base64 string

          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/loaded_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await tempFile.writeAsBytes(bytes);

          setState(() {
            _imageFile = tempFile;
          });
        }
      } else {
        // Handle regular URL
        final fullUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${Constants.BASE_URL}$imageUrl';

        final response = await http.get(Uri.parse(fullUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          base64Image = base64Encode(bytes); // Convert to base64 and store

          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/loaded_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await tempFile.writeAsBytes(bytes);

          setState(() {
            _imageFile = tempFile;
          });
        }
      }
    } catch (e) {
      print('Error loading image: $e');
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _checkInternetSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('https://www.google.com'));
      stopwatch.stop();

      if (response.statusCode == 200) {
        // Calculate speed in KB/s
        final speed = (response.contentLength! / 1024) /
            (stopwatch.elapsedMilliseconds / 1000);
        setState(() {
          _internetSpeed = speed;
        });
        print('Internet speed: ${_internetSpeed.toStringAsFixed(2)} KB/s');
      } else {
        setState(() {
          _internetSpeed = 0;
        });
      }
    } catch (e) {
      print('Error checking internet speed: $e');
      setState(() {
        _internetSpeed = 0;
      });
    }
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

  Future<void> _getLocation() async {
    setState(() {
      isLoading = true;
      isSuccess = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      coordinates =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      lat = position.latitude.toString();
      log = position.longitude.toString();

      setState(() {
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
        SnackBar(content: Text('Location error: $e')),
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
        _isConnected = false;
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

  Future<void> captureImage() async {
    setState(() {
      _isImageLoading = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduced quality
        maxWidth: 800, // Reduced size
        maxHeight: 800,
      );

      if (image != null) {
        File imageFile = File(image.path);

        // Read file as bytes
        List<int> imageBytes = await imageFile.readAsBytes();

        // Convert to base64
        String base64String = base64Encode(imageBytes);

        setState(() {
          _imageFile = imageFile;
          base64Image = base64String;
          _hasNewImage = true;
        });

        print('Image captured: ${base64String.length} chars');
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }
  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  Future<void> _shopTaggingOnline() async {
    try {
      String url = '${Constants.BASE_URL}/api/App/SaveShopTaggingByTerritoryId';

      Map<String, String> headers = {
        'Authorization': '6XesrAM2Nu',
        'Content-Type': 'application/json'
      };

      // Determine which image to use
      List<String> imageFileSourceList = [];

      if (_hasNewImage && base64Image.isNotEmpty) {
        // Use the newly captured image
        imageFileSourceList = [base64Image];
      } else if (widget.shopData != null && base64Image.isNotEmpty) {
        // For existing shops, send the existing image data if available
        imageFileSourceList = [base64Image];
      } else if (widget.shopData != null &&
          (widget.shopData!['ImageName'] != null ||
              widget.shopData!['ImageNamea'] != null)) {
        // If we have an existing shop with an image but no base64 data loaded,
        // we need to load the image from the URL and convert to base64
        try {
          String imageUrl =
              widget.shopData!['ImageName'] ?? widget.shopData!['ImageNamea'];
          if (imageUrl.startsWith('data:image')) {
            // Handle base64 encoded image
            final commaIndex = imageUrl.indexOf(',');
            if (commaIndex != -1) {
              final base64String = imageUrl.substring(commaIndex + 1);
              imageFileSourceList = [base64String];
            }
          } else {
            // Handle regular URL
            final fullUrl = imageUrl.startsWith('http')
                ? imageUrl
                : '${Constants.BASE_URL}$imageUrl';

            final response = await http.get(Uri.parse(fullUrl));
            if (response.statusCode == 200) {
              final bytes = response.bodyBytes;
              imageFileSourceList = [base64Encode(bytes)];
            }
          }
        } catch (e) {
          print('Error loading existing image: $e');
          throw Exception('Could not load existing image');
        }
      } else {
        // For new shops without image, send empty array
        imageFileSourceList = [];
      }

      // Validate base64 string if we're sending an image
      if (imageFileSourceList.isNotEmpty) {
        try {
          base64Decode(imageFileSourceList.first);
        } catch (e) {
          print('Invalid base64 image data: $e');
          imageFileSourceList = []; // Fallback to empty array
        }
      }

      // Create the request body
      Map<String, dynamic> body = {
        "command": "SaveShopTagging",
        "id": widget.shopId.toString(),
        "userId": userid ?? '',
        "TerritoryId": _selecteddistCategory ?? '',
        "shopName": _shopname.text,
        "phoneNo": _phoneno.text,
        "ownerName": _ownername.text,
        "address": _address.text,
        "openingTime": _openingtime.text,
        "closingTime": _closetime.text,
        "lat": lat.isNotEmpty ? double.parse(lat) : 0.0,
        "lng": log.isNotEmpty ? double.parse(log) : 0.0,
        "shopTypeId": _selectedCategory,
        "pepsiFridge": _pepsiController.text.isEmpty
            ? 0
            : int.parse(_pepsiController.text),
        "cokeFridge":
            _cokeController.text.isEmpty ? 0 : int.parse(_cokeController.text),
        "nestleFridge": _nestleController.text.isEmpty
            ? 0
            : int.parse(_nestleController.text),
        "nesfrutaFridge": _nesfrutaController.text.isEmpty
            ? 0
            : int.parse(_nesfrutaController.text),
        "othersFridge": _otherController.text.isEmpty
            ? 0
            : int.parse(_otherController.text),
        "appDateTime": getCurrentDateTime(),
        "landmark": _landmark.text,
        "secondaryPhoneNo": _secondaryPhone.text,
        "imageExtension": ".jpg",
        "imageFileSource": imageFileSourceList,
      };

      // Remove null values but NEVER remove imageFileSource
      body.removeWhere(
          (key, value) => value == null && key != 'imageFileSource');

      // PRINT ALL DATA TO CONSOLE
      print('=== REQUEST DATA ===');
      print('URL: $url');
      print('Headers: ${json.encode(headers)}');

      Map<String, dynamic> logBody = Map.from(body);
      if (logBody.containsKey('imageFileSource')) {
        logBody['imageFileSource'] =
            'List with ${body['imageFileSource']?.length} items';
      }

      print('Body: ${json.encode(logBody)}');
      print('Image decision:');
      print('  - Has new image: $_hasNewImage');
      print('  - Base64 image length: ${base64Image.length}');
      print('  - Image to send: List with ${imageFileSourceList.length} items');
      print('  - Shop data exists: ${widget.shopData != null}');
      if (widget.shopData != null) {
        print('  - Existing image name: ${widget.shopData!['ImageName']}');
        print('  - Existing image namea: ${widget.shopData!['ImageNamea']}');
      }
      print('====================');

      // Use Dio for better error handling
      try {
        final response = await _dio.post(
          url,
          data: body,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );

        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.statusCode == 200) {
          final data = response.data;
          if (data is Map && data['Message'] != null) {
            if (data['Message'] != 'Shop Tagged Successfully!' &&
                data['Message'] != 'Shop Updated Successfully!') {
              throw Exception(data['Message'] ?? 'Unknown error from server');
            }
          } else {
            throw Exception('Invalid response format from server');
          }
        } else {
          throw Exception(
              'HTTP ${response.statusCode}: ${response.statusMessage}');
        }
      } on DioException catch (dioError) {
        print('Dio error: ${dioError.message}');
        if (dioError.response != null) {
          print('Response data: ${dioError.response?.data}');
          print('Response headers: ${dioError.response?.headers}');
        }
        rethrow;
      }
    } catch (e) {
      print('Online save error: $e');
      rethrow;
    }
  }
  void _showSlowInternetPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Slow Internet Connection"),
          content: const Text(
              "Your internet connection is too slow. Please try again with a better connection."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showNoInternetPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Internet Connection"),
          content: const Text(
              "Your device is not connected to the internet. Please connect to the internet and try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> shopTagging() async {
    // Check if we have a valid image - different logic for new vs existing shops
    final bool hasValidImage;

  

    if (widget.shopData != null) {
      
      // For editing: either new image OR existing image is acceptable
      hasValidImage = (_hasNewImage && base64Image.isNotEmpty) ||
          (widget.shopData!['ImageName'] != null ||
              widget.shopData!['ImageNamea'] != null);
    } else {
      // For new shops: must have a new captured image
      hasValidImage = _hasNewImage && base64Image.isNotEmpty;
    }
    if (_formKey.currentState!.validate() &&
        hasValidImage &&
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

      try {
        // Check internet connection and speed
        await _checkInternetSpeed();

        if (!_isConnected) {
          _showNoInternetPopup();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        if (_internetSpeed < 0.5) {
          _showSlowInternetPopup();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Proceed with online submission
        await _shopTaggingOnline();

        // Clear form fields after successful submission
        _clearFormFields();

        // Navigate to history if online save succeeds
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Tagging_History()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.shopData != null
                ? 'Shop updated successfully!'
                : 'Shop tagged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (onlineError) {
        print('Online submission failed: $onlineError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${onlineError.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      String errorMessage = 'Please fill all required fields';

      if (!isSuccess) {
        errorMessage += ', capture location';
      }

      if (widget.shopData == null && !_hasNewImage) {
        errorMessage += ', and capture image';
      } else if (widget.shopData != null &&
          !_hasNewImage &&
          widget.shopData!['ImageName'] == null &&
          widget.shopData!['ImageNamea'] == null) {
        errorMessage += ', and capture image';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
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
          Icons.explore_outlined, // or any of the alternatives below
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
              DropdownMenuItem<int>(
                value: null,
                child: Text(
                  _isConnected ? 'No Territory available' : 'No Territory data',
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
      validator: (value) => value == null ? 'Please Select a Territory' : null,
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
              DropdownMenuItem<int>(
                value: null,
                child: Text(
                  _isConnected ? 'No shop type available' : 'No shop type data',
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
                        widget.shopData != null
                            ? 'Edit Shop Tagging'
                            : 'Shop Tagging',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(width: 60), // Placeholder for balance
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
                            hintText: 'Secondary Phone No',
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
                              child: Center(
                                child: _isImageLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            _imageFile != null
                                ? Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red),
                                    ),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Upload Image of the shop',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                            if (_imageFile != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                      base64Image = '';
                                      _hasNewImage = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Submit Button
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.red,
                          )
                        : FadeInUp(
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
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

  void _clearFormFields() {
    _formKey.currentState?.reset(); // Reset the form
    _shopname.clear();
    _phoneno.clear();
    _shopaddress.clear();
    _ownername.clear();
    _address.clear();
    _openingtime.clear();
    _closetime.clear();
    _landmark.clear();
    _secondaryPhone.clear();
    _pepsiController.clear();
    _cokeController.clear();
    _nestleController.clear();
    _otherController.clear();
    _nesfrutaController.clear();

    setState(() {
      _selectedCategory = null;
      _selecteddistCategory = null;
      _imageFile = null;
      base64Image = '';
      isSuccess = false;
      coordinates = '';
      lat = '';
      log = '';
    });
  }
}
