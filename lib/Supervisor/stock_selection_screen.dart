import 'package:KhilafatCola/Supervisor/distributor_stock_screen.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


import '../widgets/const.dart';

class StockSelectionScreen extends StatefulWidget {
  const StockSelectionScreen({super.key});

  @override
  State<StockSelectionScreen> createState() =>
      _DistributorSelectionScreenState();
}

class _DistributorSelectionScreenState extends State<StockSelectionScreen> {
  bool isLoading = false;
  final Dio _dio = Dio();
Future<void> _fetchCategories() async {
  setState(() {
    isLoading = true;
  });

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

    // Print the entire response
    print('API Response: ${response.data}');

    // Print the status code
    print('Status Code: ${response.statusCode}');

    // Print headers (optional)
    print('Headers: ${response.headers}');

    setState(() {
      _categories = response.data['Data'];
      isLoading = false;
    });

    // Print the fetched categories
    print('Fetched Categories: $_categories');
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    // Print the error if the request fails
    print('Failed to fetch categories: $e');

    // Print the stack trace for more detailed debugging

  }
}

  int? _selectedCategory;
  String? _selectedCategoryName;
  List<dynamic> _categories = [];

  @override
  void initState() {
    _fetchCategories();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.redAccent,
        title: const Text('Select Distributor',  style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        
        ),
      
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<int>(
              iconEnabledColor: Colors.red,
              decoration: const InputDecoration(
                hintText: 'Select Distributor',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red), // Red underline when not focused
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red), // Red underline when focused
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
                            value: (category['DealershipId'] as int),
                            child: Text(category['DealershipName'] as String),
                          ))
                      .toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedCategory = value;
                  _selectedCategoryName = _categories.firstWhere((category) =>
                      category['DealershipId'] == value)['DealershipName'];
                });

                if (value != null) {
                  // await the fetch
                  // setState(() async {});
                  setState(() {});
                  // rebuild after fetch is complete
                }
              },
              value: _selectedCategory,
              validator: (value) =>
                  value == null ? 'Please select a distributor' : null,
              dropdownColor: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (_selectedCategory == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(child: Text("Validation Alert")),
                          content:
                              const Text('Please Select distributor first.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Close the application
                                Navigator.pop(context);
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    print('SelectedID$_selectedCategory');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DistributorStockScreen(
                          distributorID: _selectedCategory,
                          distributorName: _selectedCategoryName,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Get Stock'))
          ],
        ),
      ),
    );
  }
}
