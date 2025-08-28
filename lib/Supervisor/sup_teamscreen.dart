import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../login.dart';
import '../utils/widgets.dart';
import '../widgets/Splash.dart';
import '../widgets/const.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> myteam = [];
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    fetchMyTeamData1();
    //startAutoRefresh();

    super.initState();
  }

  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      fetchMyTeamData1(); // Call the API every 5 seconds
    });
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data when this screen is shown
    refreshData();
  }

  void refreshData() {
    fetchMyTeamData1();
    setState(() {
      // This will call the FutureBuilders to re-fetch data
    });
  }

  Future<void> fetchMyTeamData1() async {
    final String url =
        '${Constants.BASE_URL}/api/App/GetTodayMyTeamStatusByUserId?userId=$userid&appDateTime=${getCurrentDateTime()}';

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
            myteam = List<Map<String, dynamic>>.from(requests);
          });
        } else {
          print('No new requests found in the API response.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.redAccent,
          title: const Center(
            child: Text(
              'My Team',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: myteam.isNotEmpty
            ? ListView.builder(
                itemCount: myteam.length,
                itemBuilder: (context, index) {
                  final teamMember = myteam[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                         Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 40,
                                backgroundImage: teamMember['ImageName'] !=
                                            null &&
                                        teamMember['ImageName'].isNotEmpty
                                    ? (teamMember['ImageName']
                                            .startsWith('data:image')
                                        ? MemoryImage(
                                            base64Decode(teamMember['ImageName']
                                                .split(',')
                                                .last),
                                          )
                                        : NetworkImage(
                                            '${teamMember['ImageName']}',
                                          )) as ImageProvider
                                    : null,
                                child: (teamMember['ImageName'] == null ||
                                        teamMember['ImageName'].isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teamMember['FullName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Mobile: ${teamMember['PhoneNumber']}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Designation: ${teamMember['RoleName']}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Present Status : ${teamMember['PresentStatus']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (teamMember['PresentStatus'] == 'Online')
                                    Text(
                                      'Attendance Date: ${convertTo12HourFormat(teamMember['AttendanceDate'])}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  else if (teamMember['PresentStatus'] ==
                                      'Absent')
                                    Text(
                                      'Reason: ${teamMember['Reason']}\nAttendence Detail: ${convertTo12HourFormat(teamMember['AttendanceDate'])}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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
                        "No Data Available",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ));
  }
}
