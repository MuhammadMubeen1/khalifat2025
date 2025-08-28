import 'package:KhilafatCola/Supervisor/sup_dashboard.dart';
import 'package:KhilafatCola/utils/widgets.dart';
import 'package:KhilafatCola/widgets/Splash.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;


import 'widgets/const.dart';

class AttendanceSheet extends StatelessWidget {
  const AttendanceSheet({super.key});

  Future<bool> _onWillPop() async {
    // Re-fetch data before the user navigates back
    return false; // Allow the back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Mark Attendance'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuperviserDashboard(),
                ),
              );
              // Custom back button functionality
              // bool shouldNavigateBack = await _onWillPop(); // Call your custom function
              // if (shouldNavigateBack) {
              //   Navigator.pop(context); // Navigate back if allowed
              // }
            },
          ),
        ),
        body: _AttendanceSheetContent(),
      ),
    );
  }
}

class _AttendanceSheetContent extends StatefulWidget {
  @override
  _AttendanceSheetContentState createState() => _AttendanceSheetContentState();
}

class _AttendanceSheetContentState extends State<_AttendanceSheetContent> {
  bool? mark;
  bool isAbsentSelected = false;
  bool isLoading = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> MarkAttendance(bool? marks, String? reason) async {
    setState(() {
      isLoading = true;
    });

    // API URL
    String url = '${Constants.BASE_URL}/api/App/MarkAttendance';

    // Request headers
    Map<String, String> headers = {
      'Authorization': '6XesrAM2Nu',
      'Content-Type': 'application/json'
    };

    // Request body
    Map<String, dynamic> body = {
      "UserId": userid,
      "IsPresent": marks,
      "Reason": reason,
      "lat": currentlat,
      "lng": currentlng,
      'appDateTime': getCurrentDateTime(),
    };

    try {
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['Status'];
        final message = data['Message'];

        setState(() {
          isLoading = false;
        });

        if (message == 'Attendance Mark Successfully') {
          // Navigate to the home screen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SuperviserDashboard(),
          //   ),
          // );
        } else if (message == 'Attendance Already Mark') {
          // Show error if attendance is already marked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else if (message == "Today is your weekly Off!") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error during login: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Mark Attendance',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPresentButton(),
              const SizedBox(width: 20),
              _buildLeaveButton(),
            ],
          ),
          if (isAbsentSelected) _buildLeaveReasonSection(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Attendance History',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentButton() {
    return InkWell(
      onTap: () async {
        if (IsDistCompForAtten == true) {
          if (dealershipInformation.isNotEmpty) {
            if (distanceInMeters <= 50) {
              await MarkAttendance(true, '');
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Location Alert"),
                    content: const Text(
                        "You Must be within 50 meters in the distributor area."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Alert"),
                  content: const Text("No Distributor has been assigned."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          await MarkAttendance(true, '');
        }
      },
      child: Container(
        height: 60,
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(0, 66, 37, 1),
              Color.fromRGBO(0, 66, 61, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/present.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Present',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveButton() {
    return InkWell(
      onTap: () => setState(() => isAbsentSelected = !isAbsentSelected),
      child: _buildButton(
          'Leave', null, [const Color(0xFFB71234), const Color(0xFFF02A2A)],
          icon: Icons.close),
    );
  }

  Widget _buildButton(String text, String? imagePath, List<Color> colors,
      {IconData? icon}) {
    return Container(
      height: 60,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
            )
          else if (icon != null)
            Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveReasonSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason for Leave:',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              final comment = _commentController.text;
              if (comment.isEmpty) {
                _showValidationDialog();
              } else {
                showConfirmationDialog();
              }
            },
            child: Center(
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB71234),
                      Color(0xFFF02A2A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Center(
                  child: Text(
                    'Send',
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Validation Error"),
          content: const Text("Comment must not be empty."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    setState(() {
      isLoading = true;
    });
    try {
      await MarkAttendance(false, _commentController.text);

      mark = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to confirm order. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify'),
          content: const Text('Are you sure you want to mark your absent'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _confirmOrder();
              },
            ),
          ],
        );
      },
    );
  }
}
