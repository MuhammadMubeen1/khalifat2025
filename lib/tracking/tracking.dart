import 'dart:convert';
import 'dart:io';

import 'package:KhilafatCola/Home/home.dart';
import 'package:KhilafatCola/order_confirmation/dsf_cart_details.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


import '../widgets/const.dart';

class StopDetailScreen extends StatefulWidget {
  final shopid;
  final orderId;

  const StopDetailScreen({
    Key? key,
    this.shopid,
    this.orderId,
  }) : super(key: key);

  @override
  _StopDetailScreenState createState() => _StopDetailScreenState();
}

class _StopDetailScreenState extends State<StopDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final bool _shopOpen = false; // Track if shop is open

  // Focus node for the comments TextField
  final FocusNode _commentsFocusNode = FocusNode();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String base64Image = '';

  Future<void> captureImage() async {
    final ImagePicker picker = ImagePicker();

    // Capture an image from the camera or pick from the gallery
    final XFile? image = await picker.pickImage(
        source: ImageSource.camera); // or ImageSource.gallery

    if (image != null) {
      // _imageFile = File(image.path);
      // Convert the image file to a Base64 string
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
      setState(() {
        _imageFile = File(image.path);
      });
      // Print or use the Base64 string
      print("Base64 Encoded Image: $base64Image");
    } else {
      print("No image selected");
    }
  }

  Future<void> markShopVisit(bool isOpen) async {
    const String apiUrl = "${Constants.BASE_URL}/api/App/MarkShopVisit";
    final url = Uri.parse(apiUrl);

    final body = jsonEncode({
      "userId": userid,
      "shopId": widget.shopid,
      "isOpen": isOpen,
      "comments": _commentsController.text,
      "imageSource": base64Image
    });

    // Send the POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '6XesrAM2Nu',
      },
      body: body,
    );
    print('Body: $body');
    print('Image$base64Image');
    if (response.statusCode == 200) {
      // If the server returns a success response, navigate to the HomeScreen
      print('Shop visit marked successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop visit marked successfully')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShopScreen2(
                    shopid: widget.shopid,
                    orderId: widget.orderId,
                  )));
    } else {
      // If the server returns an error, handle it
      print('Failed to mark shop visit: ${response.statusCode}');
    }
  }

  Future<void> markShopVisitClose(bool isOpen) async {
    final String apiUrl = "$baseurl/api/App/MarkShopVisit";
    final url = Uri.parse(apiUrl);

    final body = jsonEncode({
      "userId": userid,
      "shopId": widget.shopid,
      "isOpen": isOpen,
      "comments": _commentsController.text,
      "imageSource": base64Image
    });

    // Send the POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '6XesrAM2Nu',
      },
      body: body,
    );
    print('Body: $body');
    if (response.statusCode == 200) {
      // If the server returns a success response, navigate to the HomeScreen
      print('Shop visit marked successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop visit marked successfully')),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      // If the server returns an error, handle it
      print('Failed to mark shop visit: ${response.statusCode}');
    }
  }

  // Future<void> markShopVisitOpen(bool isOpen) async {
  //   final String apiUrl = "$baseurl/api/App/MarkShopVisit";
  //   final url = Uri.parse(apiUrl);
  //
  //   final body = jsonEncode({
  //     "userId": userid,
  //     "shopId": shopId,
  //     "isOpen": isOpen,
  //     "comments": _commentsController.text,
  //     "imageSource": base64Image
  //   });
  //
  //   // Send the POST request
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': '6XesrAM2Nu',
  //     },
  //     body: body,
  //   );
  //   print('Body: $body');
  //   if (response.statusCode == 200) {
  //     // If the server returns a success response, navigate to the HomeScreen
  //     print('Shop visit marked successfully');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Shop visit marked successfully')),
  //     );
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => HomeScreen(),
  //       ),
  //     );
  //   } else {
  //     // If the server returns an error, handle it
  //     print('Failed to mark shop visit: ${response.statusCode}');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    print('Orderrr ID: ${widget.orderId}');
    print('Shop Id ${widget.shopid}');
    // fetchSalesmanTasks(); // Call the function when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        shape: const RoundedRectangleBorder(
          // Add rounded corners
          borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(50)), // Round bottom corners only
        ), // Coca-Cola red
        title: const Text(
          'Visited Mark Complete',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.red[50],
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Please complete the following actions to proceed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            height: 200,
                            width: 200,
                            // fit: BoxFit.cover,
                          )
                        : InkWell(
                            onTap: captureImage,
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 4,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextField(
                    focusNode: _commentsFocusNode,
                    // Assign focus node
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    controller: _commentsController,
                    decoration: const InputDecoration(
                      hintText: 'Enter comments here',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 30),

                // Shop Close/Open Buttons
                // Using Visibility to show/hide Shop Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shop Close Button
                    //  Visibility(
                    //         visible: false,
                    //         child: ElevatedButton(
                    //           onPressed: () {
                    //             if (_imageFile == null ||
                    //                 _commentsController.text.isEmpty) {
                    //               // Show alert if image is null or comments are empty
                    //               _showAlert(context);
                    //             } else {
                    //               _showDialog(context);
                    //             }
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.red,
                    //             padding: EdgeInsets.symmetric(
                    //                 horizontal: 30, vertical: 15),
                    //             textStyle: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //           child: Text('Shop Close'),
                    //         ),
                    //       )
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: Visibility(
                        visible: true,
                        child: ElevatedButton.icon(
                          label: const Text('Close Shop'),
                          icon: const Icon(Icons.close, size: 15),
                          onPressed: () {
                            if (_imageFile == null ||
                                _commentsController.text.isEmpty) {
                              // Show alert if image is null or comments are empty
                              _showAlert(context);
                            } else {
                              _showDialog(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Shop Open Button
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.open_in_browser,
                        size: 15,
                      ),
                      label: const Text(
                        'Shop Open',
                      ),
                      onPressed: () {
                        setState(() {
                          if (_imageFile != null) {
                            _showCompletedDialog(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please Capture an Image ')),
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                // Show Take Order and Completed buttons only when _shopOpen is true
                if (_shopOpen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Take Order Button
                      //  Visibility(
                      //         visible: false,
                      //         child: ElevatedButton(
                      //           onPressed: () {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) => ShopScreen2()));
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: Colors.red,
                      //             padding: EdgeInsets.symmetric(
                      //                 horizontal: 30, vertical: 15),
                      //             textStyle: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //           child: Text('Take Order'),
                      //         ),
                      //       )
                      Visibility(
                        visible: true,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Take Order'),
                        ),
                      ),
                      // Completed Button
                      ElevatedButton(
                        onPressed: () async {
                          // Check if image is not taken or comments are empty
                          if (_imageFile == null ||
                              _commentsController.text.isEmpty) {
                            // Show alert if image is null or comments are empty
                            _showAlert(context);
                          } else {
                            // If everything is filled, show confirmation dialog
                            _showCompletedDialog(context);
                            // You might want to call markShopVisit here after user confirms the dialog
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Completed'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Shop is Closed'),
          content: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Are You Sure The Shop Is Close.'),
                Image.asset(
                  'assets/images/shopclose.png',
                  height: 200,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomeScreen(),
                //   ),
                // ); // Close the dialog
                await markShopVisitClose(false);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Shop is Open'),
          content: SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Are You Sure You Want to Complete.'),
                // Image.asset(
                //   'assets/images/open.png',
                //   height: 200,
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomeScreen(),
                //   ),
                // ); // Close the dialog
                await markShopVisit(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incomplete Actions'),
          content: const Text(
              'Please capture a shop image and provide comments before marking the shop as closed.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _commentsFocusNode.dispose();
    super.dispose();
  }
}
