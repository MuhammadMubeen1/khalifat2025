// import 'package:flutter/material.dart';

// class ConnectionAwareWidget extends StatelessWidget {
//   final bool isConnected;
//   final Widget child;

//   const ConnectionAwareWidget({
//     Key? key,
//     required this.isConnected,
//     required this.child,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         child, // Main content
//         if (!isConnected)
//           Container(
//             color: Colors.black.withOpacity(0.7),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.wifi_off, size: 50, color: Colors.white),
//                   SizedBox(height: 10),
//                   Text(
//                     'No Internet Connection',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
