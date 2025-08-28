// import 'package:KhilafatCola/utils/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../widgets/const.dart';

// class DistributorStockScreen extends StatefulWidget {
//   final distributorID;
//   final distributorName;

//   const DistributorStockScreen(
//       {super.key, this.distributorID, this.distributorName});
//   @override
//   _DistributorStockScreenState createState() => _DistributorStockScreenState();
// }

// class _DistributorStockScreenState extends State<DistributorStockScreen> {
//   List<dynamic> stockData = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchStockData(widget.distributorID.toString());
//   }

//   Future<void> fetchStockData(String id) async {
//     final url = Uri.parse(
//         "${Constants.BASE_URL}/api/App/GetDistStockByDistId?DistributorId=$id&appDateTime=${getCurrentDateTime()}");

//     final response = await http.get(url, headers: {
//       "Authorization": "6XesrAM2Nu",
//       "Content-Type": "application/json"
//     });

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         stockData = data["Data"];
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception("Failed to load data");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red[50],
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: Center(
//           child: Text(
//             widget.distributorName ?? "Distributor Stock",
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         backgroundColor: Colors.red,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : stockData.isEmpty
//               ? const Center(child: Text("No data available"))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(10),
//                   itemCount: stockData.length,
//                   itemBuilder: (context, index) {
//                     final item = stockData[index];
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       elevation: 4,
//                       margin: const EdgeInsets.symmetric(vertical: 10),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(10),
//                         leading: Image.network(
//                           item != null && item["ProductImagePath"] != null
//                               ? "${Constants.IMAGE_URL}/" +
//                                   item["ProductImagePath"]
//                               : "https://example.com/default-image.png", // URL to your default image
//                           width: 60,
//                           height: 60,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.image_not_supported, size: 50),
//                         ),
//                         title: Text(
//                           item["Name"] ?? "Unknown",
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(
//                           "Type: ${item["Type"]}",

//                           //  Volume: ${item["VolumeInMl"]}ml\n",

//                           //  "Retail Price: ${item["RetailPrice"]} | Trade Price: ${item["TradePrice"]}\n"
//                           //     "Distributor Price: ${item["DistributorPrice"]}",

//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         trailing: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text(
//                               "In Stock:",
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red),
//                             ),
//                             Text(
//                               "${item["LeftQuantity"]}",
//                               style: const TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/const.dart';

class DistributorStockScreen extends StatefulWidget {
  final dynamic distributorID;
  final String? distributorName;

  const DistributorStockScreen(
      {super.key, this.distributorID, this.distributorName});

  @override
  _DistributorStockScreenState createState() => _DistributorStockScreenState();
}

class _DistributorStockScreenState extends State<DistributorStockScreen>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> stockData = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true; // Keeps the list alive when scrolling

  @override
  void initState() {
    super.initState();
    fetchStockData(widget.distributorID.toString());
  }

  Future<void> fetchStockData(String id) async {
    final url = Uri.parse(
        "${Constants.BASE_URL}/api/App/GetDistStockByDistId?DistributorId=$id&appDateTime=${getCurrentDateTime()}");

    try {
      final response = await http.get(url, headers: {
        "Authorization": "6XesrAM2Nu",
        "Content-Type": "application/json"
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stockData = data["Data"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching stock data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keeping state alive

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            widget.distributorName ?? "Distributor Stock",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stockData.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  key: const PageStorageKey(
                      'DistributorStockList'), // Keeps scroll position
                  padding: const EdgeInsets.all(10),
                  itemCount: stockData.length,
                  itemBuilder: (context, index) {
                    return StockItemCard(item: stockData[index]);
                  },
                ),
    );
  }
}

class StockItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const StockItemCard({super.key, required this.item});

  @override
  _StockItemCardState createState() => _StockItemCardState();
}

class _StockItemCardState extends State<StockItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      true; // Prevents widget from being rebuilt when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final item = widget.item;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: item != null &&
                item["ProductImagePath"] != null &&
                item["ProductImagePath"].isNotEmpty
            ? (item["ProductImagePath"].startsWith('data:image')
                ? Image.memory(
                    base64Decode(item["ProductImagePath"].split(',').last),
                    width: 60,
                    height: 60,
                    // fit: BoxFit.cover,
                  )
                : Image.network(
                    "${item["ProductImagePath"]}",
                    width: 60,
                    height: 60,
                    // fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 50),
                  ))
            : const Icon(
                Icons.image_not_supported,
                size: 50,
              ),

        title: Text(
          item["Name"] ?? "Unknown",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Type: ${item["Type"]}",
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "In Stock:",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(
              "${item["LeftQuantity"]}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
