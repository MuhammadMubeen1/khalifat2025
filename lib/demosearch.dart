import 'dart:convert';
import 'package:KhilafatCola/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ShopSearchScreen1 extends StatefulWidget {
  const ShopSearchScreen1({super.key});

  @override
  _ShopSearchScreenState createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends State<ShopSearchScreen1> {
  List<dynamic> shopList = [];
  List<dynamic> filteredShopList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  // Fetch data from the API
  Future<void> fetchShops() async {
    const String url =
        '${Constants.BASE_URL}/api/App/GetAllTerritoryShopByUserId?userId=5a778c9c-a8c1-4e79-9911-db690f927332&lat=31.485601682172476&lng=74.28254614338144&appDateTime=2024-10-24T08:49:02.056Z';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Access the 'Data' key from the response
        final List<dynamic> data = jsonResponse['Data'];
        print('Das:$data');
        // Update the state with the data from the 'Data' object
        setState(() {
          shopList = data;
          filteredShopList = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Search method to filter the shop list
  void filterShops(String query) {
    final filtered = shopList.where((shop) {
      final shopName = shop['ShopName'].toString().toLowerCase();
      return shopName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredShopList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Search'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Shops',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      filterShops(query);
                    },
                  ),
                ),
                // List of shops
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredShopList.length,
                    itemBuilder: (context, index) {
                      final shop = filteredShopList[index];
                      return ListTile(
                        title: Text(shop['ShopName']),
                        subtitle:
                            Text(shop['Address'] ?? 'No address available'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
