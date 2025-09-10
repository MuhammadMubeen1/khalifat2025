import 'dart:convert';

import 'package:KhilafatCola/DealershipScreen/dealership_screen.dart';
import 'package:KhilafatCola/Shop/Shop_Orders_Screen.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_history.dart';
import 'package:KhilafatCola/Shop_Tagging/shop_tagging_local.dart';
import 'package:KhilafatCola/Supervisor/stock_selection_screen.dart';
import 'package:KhilafatCola/main.dart';
import 'package:KhilafatCola/order_confirmation/dsf_Order_Confirm.dart';
import 'package:KhilafatCola/order_confirmation/sup_Order_Comfirm.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Supervisor/sup_shoptaggingscreen.dart';
import '../login.dart';
import '../order_confirmation/sup_dealership_order.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
 

 Future<void> markLoginLogoutState() async {
    final url = Uri.parse("${Constants.BASE_URL}/api/App/MarkLoginLogoutState");
    final body = {
      "deviceId": deviceid,
      "appDateTime": getCurrentDateTime(),
      "isLogin": false
    };
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "6XesrAM2Nu",
    };

    try {
      // Show processing message
      Fluttertoast.showToast(
        msg: "Logging out...",
        toastLength: Toast.LENGTH_SHORT,
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Clear all stored data before navigating
        await _clearAllData();

        // Close Hive boxes properly
        await Hive.close();

        // Show success message
        Fluttertoast.showToast(
          msg: "Logged out successfully",
          toastLength: Toast.LENGTH_SHORT,
        );

        // Use WidgetsBinding to ensure navigation happens after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        });
      } else {
        print("Failed: ${response.statusCode}, ${response.body}");
        Fluttertoast.showToast(
          msg: "Logout failed. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "Network error during logout",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
  Future<void> _clearAllData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear Hive boxes
      final userBox = await Hive.openBox(userBoxName);
      final dealershipBox = await Hive.openBox(dealershipBoxName);
      await userBox.clear();
      await dealershipBox.clear();
      await userBox.close();
      await dealershipBox.close();

      // Reset all global variables
      userid = '';
      name = '';
      role = '';
      userImage = '';
      userEmail = '';
      userPhone = '';
      StartShift = "";
      EndShift = "";
      IsMarkAttendance = '';
      isPresent = '';
      PresentTime = '';
      coords = '';
      IsMobileDeviceRegister = null;
      IsAvailableForMobile = null;
      IsDistCompForAtten = null;
      dealershipInformation = [];
      pinLocationss = '';
      shopid = null;
      isLoginSucess = false;
      dealershipName = '';
      dealershipLocation = '';
      dealerlat = null;
      dealerlng = null;
      DeliveryChallanCode = null;
      orderId = null;
      distanceInMeters = 0;
      IsLogedIn = null;
      isCheckOut = null;
      ImageServer = '';
      dealershipID = null;
    } catch (e) {
      print("Error clearing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(userPhone),
            currentAccountPicture: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: userImage != null && userImage.isNotEmpty
                  ? (userImage.startsWith('data:image')
                      ? MemoryImage(base64Decode(userImage.split(',').last))
                      : NetworkImage('$userImage')) as ImageProvider
                  : AssetImage('assets/default_avatar.png'),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB71234), // A richer Coca-Cola Red
                  Color(0xFFF02A2A), // A slightly darker red
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // role == 'DSF' && role == 'ASE' && role == 'ASD' ?
         Visibility(
              visible: role == "ASE" ||
                  role == "ZSM" ||
                  role == "RSM" ||
                  role == "ASD" ||
                  role == "RSM" ||
                  role == "DSF",
              child:  ListTile(
            leading: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.red,
            ),
            title: const Text(
              'Shop Tagging Online',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShopTagging(shopId: 0,)));
            },
          )),

        Visibility(
              visible: role == "ASE" ||
                  role == "ZSM" ||
                  role == "RSM" ||
                  role == "ASD" ||
                  role == "RSM" ||
                  role == "DSF",  
              child:   ListTile(
            leading: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.red,
            ),
            title: const Text(
              'Shop Tagging Offline',
              style: TextStyle(fontWeight: FontWeight.w500
              
              
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShopTaggingOffline()));
            },
          )),
          // : SizedBox.shrink(),
          // role == 'DSF' && role == 'ASE' && role == 'ASD' ?
       Visibility(
              visible: role == "ASE" ||
                  role == "ZSM" ||
                  role == "RSM" ||
                  role == "ASD" ||
                  role == "RSM" ||
                  role == "DSF",
              child:    ListTile(
            leading: const Icon(
              Icons.history,
              color: Colors.red,
            ),
            title: const Text(
              'Shop Tagging History',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Tagging_History()));
            },
          )),
          // : SizedBox.shrink(),
          Visibility(
            visible: role == "ASD",
            child: ListTile(
              leading: const Icon(
                Icons.check,
                color: Colors.red,
              ),
              title: const Text(
                'Shop Tagging Confirmation',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShopTaggingRequestScreen()));
              },
            ),
          ),
          Visibility(
            visible: role == "ASE",
            child: ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: Colors.red,
              ),
              title: const Text(
                'Shop Orders',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShopOrderScreen()));
              },
            ),
          ),
          role == 'DSF'
              ? ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Shop Order History',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DSFOrderHistoryScreen()));
                  },
                )
              : const SizedBox(),
          Visibility(
            visible: role == "ASE" || role == "ZSM",
            child: ListTile(
              leading: const Icon(
                Icons.add_shopping_cart_outlined,
                color: Colors.red,
              ),
              title: const Text(
                'Primary Sale',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SupervisorOrderHistoryScreen()));
              },
            ),
          ),
        
          Visibility(
              visible: role == "ASE" ||
                  role == "ZSM" ||
                  role == "RSM" ||
                  role == "ASD" ||
                  role == "RSM" ||
                  role == "DSF",
              child: ListTile(
            leading: const Icon(
              Icons.warehouse,
              color: Colors.red,
            ),
            title: const Text(
              'My Distributors',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DealershipDetailsScreen(
                            dealershipInformation: dealershipInformation,
                          )));
            },
              )),
          role == "ASE" || role == "ZSM"
              ? ListTile(
                  leading: const Icon(
                    Icons.inventory,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Distributor Stock',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StockSelectionScreen()));
                  },
                )
              : const SizedBox.shrink(),

          // ListTile(
          //   leading: Icon(
          //     Icons.cleaning_services_rounded,
          //     color: Colors.red,
          //   ),
          //   title: Text('Clear All Data(Demo)'),
          //   onTap: () async {
          //     var headers = {
          //       'Authorization': '6XesrAM2Nu'
          //     };qa
          //     var request = http.Request('GET', Uri.parse('${Constants.BASE_URL}/api/App/ClearLog1?appDateTime=${getCurrentDateTime()}'));
          
          //     request.headers.addAll(headers);
          
          //     http.StreamedResponse response = await request.send();
          
          //     if (response.statusCode == 200) {
          //       print(await response.stream.bytesToString());
          //       Fluttertoast.showToast(
          //               msg: 'Data Cleared ',
          //               toastLength: Toast.LENGTH_SHORT,
          //               gravity: ToastGravity.BOTTOM, // Also possible "TOP" and "CENTER"
          //               backgroundColor: Colors.white,
          //               textColor: Colors.black);
          //     }
          //     else {
          //     print(response.reasonPhrase);
          //     }
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.hail,
          //     color: Colors.red,
          //   ),
          //   title: Text('Order History'),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => OrderHistoryScreen()));
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.scale_sharp,
          //     color: Colors.red,
          //   ),
          //   title: Text('Schedule'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     // Add your navigation logic here
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.info,
          //     color: Colors.red,
          //   ),
          //   title: Text('About'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     // Add your navigation logic here
          //   },
          // ),

         ListTile(
  leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
  title: const Text(
    'Logout',
    style: TextStyle(fontWeight: FontWeight.w500),
  ),
  onTap: () async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      await markLoginLogoutState();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
      }
    }
  },
),
          //1.1.xx for liqa url
          //1.2.1.xx for qa Url xx=> updates
          //1.3.1.xx for qa Url xx=> updates

          const Spacer(),
          // const ListTile(
          //   leading: Text('App Version'),
          //   trailing: Text('V1.2.4'),
          // ),
        ],
      ),
    );
  }
}
