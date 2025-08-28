// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:khilafat_cola/widgets/Splash.dart';
//
// class SalesmanTasksScreen extends StatefulWidget {
//   @override
//   _SalesmanTasksScreenState createState() => _SalesmanTasksScreenState();
// }
//
// class _SalesmanTasksScreenState extends State<SalesmanTasksScreen> {
//   List<dynamic> tasks = [];
//   bool isLoading = true;
//
//   // Function to fetch data from the API
//   Future<void> fetchSalesmanTasks() async {
//     final url = Uri.parse(
//         '${Constants.BASE_URL}/api/App/GetSalesmanTasksByDate?salesmanId=2&appDateTime=2024-09-10');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': '6XesrAM2Nu', // Add authorization header if needed
//     };
//
//     try {
//       final response = await http.get(url, headers: headers);
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//
//         // Check if the "Data" field is an array
//         if (responseData['Data'] != null && responseData['Data'] is List) {
//           setState(() {
//             tasks = responseData['Data']; // Set tasks from the "Data" field
//             isLoading = false;
//           });
//         } else {
//           // Handle case where "Data" is not an array
//           setState(() {
//             isLoading = false;
//             tasks = []; // Empty the list if no tasks found
//           });
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Exception occurred: $e')),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSalesmanTasks(); // Call the function when the widget is initialized
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Salesman Tasks'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : tasks.isEmpty
//               ? Center(child: Text('No tasks found'))
//               : ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     print('ssss${tasks.length}');
//                     final task = tasks[index];
//                     return ListTile(
//                       title: Text(task['SalesmenName'] ??
//                           'No Task Name'), // Adjust according to your actual field names
//                       subtitle:
//                           Text(task['SalesmenPhoneNo'] ?? 'No Description'),
//                     );
//                   },
//                 ),
//     );
//   }
// }
