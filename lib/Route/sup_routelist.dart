import 'dart:async';
import 'dart:convert';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/const.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  _RouteListScreenState createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true; // Initially true to show the loader
  List<Map<String, dynamic>> visitedRoutes = [];
  List<Map<String, dynamic>> unvisitedRoutes = [];
  List<Map<String, dynamic>> allRoutes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAllRoutes();
    fetchVisitedRoutes();
    fetchUnvisitedRoutes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data when this screen is shown
    refreshData();
  }

  void refreshData() {
    fetchAllRoutes();
    fetchVisitedRoutes();
    fetchUnvisitedRoutes();
    setState(() {
      // This will call the FutureBuilders to re-fetch data
    });
  }

  Future<void> fetchAllRoutes() async {
    setState(() {
      isLoading = true;
    });
    final String url =
        '${Constants.BASE_URL}/api/App/GetTodayRouteAllShopCountBySupervisorId?userId=$userid&appDateTime=${getCurrentDateTime()}';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            allRoutes = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVisitedRoutes() async {
    final String url =
        '${Constants.BASE_URL}/api/App/GetTodayRouteVisitedShopCountBySupervisorId?userId=$userid&appDateTime=${getCurrentDateTime()}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            visitedRoutes = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchUnvisitedRoutes() async {
    final String url =
        '${Constants.BASE_URL}/api/App/GetTodayRouteNotVisitedShopCountBySupervisorId?userId=$userid&appDateTime=${getCurrentDateTime()}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '6XesrAM2Nu',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Data'] != null) {
          List<dynamic> requests = jsonResponse['Data'];
          setState(() {
            unvisitedRoutes = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Today Route Visited',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(color: Colors.grey.shade200),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Visited'),
            Tab(text: 'Unvisited'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loader when loading
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListView(allRoutes, false, false),
                _buildListView(visitedRoutes, true, false),
                _buildListView(unvisitedRoutes, false, true),
              ],
            ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> routes, bool isVisitedTab,
      bool isUnvisitedTab) {
    return routes.isNotEmpty
        ? ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueGrey,
                          backgroundImage: route['UserImage'] != null &&
                                  route['UserImage'].isNotEmpty
                              ? (route['UserImage'].startsWith('data:image')
                                  ? MemoryImage(
                                      base64Decode(
                                          route['UserImage'].split(',').last),
                                    )
                                  : NetworkImage(
                                      '${route['UserImage']}',
                                    )) as ImageProvider
                              : null,
                          child: (route['UserImage'] == null ||
                                  route['UserImage'].isEmpty)
                              ? Text(
                                  route['DSFName']?.substring(0, 1) ?? "A",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Route: ${route['RouteName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'DSF: ${route['DSFName']}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              Text(
                                isVisitedTab
                                    ? 'Number of Shops: ${route['VisitedShop']}'
                                    : isUnvisitedTab
                                        ? 'Number of Shops: ${route['NotVisitedShop']}'
                                        : 'Number of Shops: ${route['NoOfShop']}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              Text(
                                '${route['RoleName']}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : FutureBuilder(
            future: Future.delayed(const Duration(seconds: 5)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text(
                    "No Route List Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
            },
          );
  }
}
