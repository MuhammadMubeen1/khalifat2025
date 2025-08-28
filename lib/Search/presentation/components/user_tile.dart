import 'package:KhilafatCola/Search/data/data_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';


class UserTile extends StatelessWidget {
  final User user;

  UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // ListView.builder(
          //   itemCount: shopList.length,
          //   itemBuilder: (context, index) {
          //     var shop = shopList[index];
          //     int shopID = shop['ShopId'];
          //     String shopName = shop['ShopName'] ?? 'No Shop Name';
          //     String OpeningTime = shop['OpeningTime'] ?? 'No Owner Name';
          //     String ClosingTime = shop['ClosingTime'] ?? 'No Owner Name';
          //     double shoplat = shop['ShopLat'] ?? 'No Owner Name';
          //     double shoplag = shop['ShopLng'] ?? 'No Owner Name';
          //     String shopAddress = shop['ShopAddress'] ?? 'No Owner Name';
          //     String Phone = shop['PhoneNo'] ?? 'No Phone No';
          //     String Distance = shop["FormattedDistance"] ?? "No Distance";
          //     int totalOrder = shop['TotalOrder'];
          //     String DistanceKm =
          //         shop["FormattedDistanceUnit"] ?? "No Distance";
          //     int distanceValue = int.tryParse(Distance) ?? 0;
          //     // String isVisited = shop['IsVisited'];
          //     String isOrder = shop['IsOrder'];
          //     // final shopIds = shop['ShopId'];
          //     // final VisitId = shop['VisitId'];
          //     // final orderId = shop['OrderId'];
          //     bool canClickButton = distanceValue < 400 && DistanceKm == 'm';
          //     return isOrder == "No"
          //         ? Padding(
          //       padding: const EdgeInsets.only(
          //           top: 10, bottom: 10, right: 5, left: 5),
          //       child: FadeInUp(
          //         duration: Duration(milliseconds: 1500),
          //         child: Container(
          //           height: 100,
          //           width: MediaQuery.of(context).size.width,
          //           decoration: BoxDecoration(
          //             boxShadow: [
          //               isOrder == 'Yes'
          //                   ? BoxShadow(
          //                 color: Colors.green.shade600,
          //                 blurRadius: 10,
          //                 offset: Offset(0, 3), // Shadow position
          //               )
          //                   : BoxShadow(
          //                 color: Colors.red.shade200,
          //                 blurRadius: 10,
          //                 offset: Offset(0, 3), // Shadow position
          //               ),
          //             ],
          //             borderRadius: BorderRadius.circular(12),
          //             border: isOrder == 'Yes'
          //                 ? Border.all(color: Colors.white, width: 5)
          //                 : Border.all(color: Colors.grey, width: 5),
          //             color: Colors.white,
          //           ),
          //           child: Center(
          //             child: Padding(
          //               padding: const EdgeInsets.only(left: 5, right: 5),
          //               child: Row(
          //                 mainAxisAlignment:
          //                 MainAxisAlignment.spaceEvenly,
          //                 children: [
          //                   Expanded(
          //                     child: ListTile(
          //                       // leading: Icon(
          //                       //   Icons
          //                       //       .arrow_circle_right_rounded,
          //                       //   color: Colors
          //                       //       .black,
          //                       // ),
          //                       title: totalOrder > 0
          //                           ? Text(
          //                         'Total Orders: $totalOrder',
          //                         style: TextStyle(
          //                             fontWeight: FontWeight.bold),
          //                       )
          //                           : SizedBox(),
          //                       subtitle: Column(
          //                         crossAxisAlignment:
          //                         CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             shopName,
          //                             style: GoogleFonts.lato(
          //                                 color: Colors.black,
          //                                 fontSize: 14,
          //                                 fontWeight: FontWeight.w700),
          //                           ),
          //                           Text.rich(
          //                             TextSpan(
          //                               children: [
          //                                 TextSpan(
          //                                   text: shopAddress,
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w500),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           Text.rich(
          //                             TextSpan(
          //                               children: [
          //                                 TextSpan(
          //                                   text: convertTo12HourFormatt(
          //                                       OpeningTime),
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w500),
          //                                 ),
          //                                 TextSpan(
          //                                   text: ' To ',
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 16,
          //                                       fontWeight:
          //                                       FontWeight.w800),
          //                                 ),
          //                                 TextSpan(
          //                                   text: convertTo12HourFormatt(
          //                                       ClosingTime),
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w500),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           Text.rich(
          //                             TextSpan(
          //                               children: [
          //                                 TextSpan(
          //                                   text: Phone,
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w500),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           Text.rich(
          //                             TextSpan(
          //                               children: [
          //                                 TextSpan(
          //                                   text: Distance,
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w500),
          //                                 ),
          //                                 TextSpan(
          //                                   text: DistanceKm,
          //                                   style: GoogleFonts.lato(
          //                                       color: Colors.black,
          //                                       fontSize: 14,
          //                                       fontWeight:
          //                                       FontWeight.w800),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                   Visibility(
          //                     visible: totalOrder > 0,
          //                     child: InkWell(
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) =>
          //                                 OrderProcessScreen(
          //                                   shopID: shopID.toString(),
          //                                 ),
          //                           ),
          //                         );
          //                       },
          //                       child: Container(
          //                         height: 30,
          //                         width: 50,
          //                         decoration: BoxDecoration(
          //                             borderRadius:
          //                             BorderRadius.circular(10),
          //                             gradient:
          //                             // isOrder == 'Yes' ?
          //                             LinearGradient(
          //                               colors: [
          //                                 Color(0xFFB71234),
          //                                 // A richer Coca-Cola Red
          //                                 Color(0xFFF02A2A),
          //                                 // A slightly darker red
          //                               ],
          //                               begin: Alignment.topLeft,
          //                               end: Alignment.bottomRight,
          //                             )),
          //                         child: Center(
          //                           child: Text(
          //                             totalOrder > 0
          //                                 ? 'View Details'
          //                                 : 'Order',
          //                             style: TextStyle(
          //                                 fontSize: 10,
          //                                 color: Colors.white),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                   InkWell(
          //                     onTap: () {
          //                       Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) => ShopScreen2(
          //                               shopid: shopID,
          //                             ),
          //                           ));
          //                     },
          //                     child: Container(
          //                       height: 30,
          //                       width: 50,
          //                       decoration: BoxDecoration(
          //                           borderRadius:
          //                           BorderRadius.circular(10),
          //                           gradient:
          //                           // isOrder == 'Yes' ?
          //                           LinearGradient(
          //                             colors: [
          //                               Color(0xFFB71234),
          //                               // A richer Coca-Cola Red
          //                               Color(0xFFF02A2A),
          //                               // A slightly darker red
          //                             ],
          //                             begin: Alignment.topLeft,
          //                             end: Alignment.bottomRight,
          //                           )
          //                         // : LinearGradient(
          //                         //     colors: [
          //                         //       Colors.grey,
          //                         //       Colors.grey
          //                         //           .shade300 // A slightly darker red
          //                         //     ],
          //                         //     begin: Alignment.topLeft,
          //                         //     end: Alignment.bottomRight,
          //                         //   ),
          //                       ),
          //                       child: Center(
          //                         child: Text(
          //                           isOrder == "Yes"
          //                               ? 'View Details'
          //                               : 'Order',
          //                           style: TextStyle(
          //                               fontSize: 10,
          //                               color: Colors.white),
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                   InkWell(
          //                     onTap: () {
          //                       Navigator.push(
          //                         context,
          //                         MaterialPageRoute(
          //                           builder: (context) => MyMap(
          //                             latshop: shoplat,
          //                             lngshop: shoplag,
          //                           ),
          //                         ),
          //                       );
          //                     },
          //                     child: Container(
          //                       height: 30,
          //                       width: 30,
          //                       decoration: BoxDecoration(
          //                           borderRadius:
          //                           BorderRadius.circular(90),
          //                           gradient:
          //                           // isOrder == 'Yes' ?
          //                           LinearGradient(
          //                             colors: [
          //                               Color(0xFFB71234),
          //                               // A richer Coca-Cola Red
          //                               Color(0xFFF02A2A),
          //                               // A slightly darker red
          //                             ],
          //                             begin: Alignment.topLeft,
          //                             end: Alignment.bottomRight,
          //                           )
          //                         // : LinearGradient(
          //                         //     colors: [
          //                         //       Colors.grey,
          //                         //       Colors.grey
          //                         //           .shade300 // A slightly darker red
          //                         //     ],
          //                         //     begin: Alignment.topLeft,
          //                         //     end: Alignment.bottomRight,
          //                         //   ),
          //                       ),
          //                       child: Icon(
          //                         Icons.pin_drop,
          //                         color: Colors.white,
          //                         size: 20,
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     )
          //         : Text('');
          //   },
          // ),
          // ListTile(
          //   leading: Hero(
          //     tag: user.shopName,
          //     child: Text(user.shopName),
          //   ),
          //   title: Text('${user.phoneNo} ${user.totalOrder}'),
          //   onTap: () {},
          // ),
          // Divider(
          //   thickness: 2.0,
          // ),
        ],
      ),
    );
  }
}
