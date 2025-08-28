import 'package:KhilafatCola/tracking/tracking.dart';
import 'package:flutter/material.dart';


import '../googlemaps/google_maps.dart';

class TrackingScreen extends StatefulWidget {
  final String location;
  final VoidCallback onTaskCompleted;

  const TrackingScreen(
      {Key? key, required this.location, required this.onTaskCompleted})
      : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Track the completion of stops
  Map<String, bool> stopsCompletionStatus = {
    'Stop 1': false,
    'Stop 2': false,
    'Stop 3': false,
    'Stop 4': false
  };

  void _navigateToMapSample(BuildContext context, String stopName,
      String latitude, String longitude) {}

  void _navigateToStopDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopDetailScreen(

            // stopName: stopName,
            // onStopCompleted: () {
            //   setState(() {
            //     stopsCompletionStatus[stopName] = true;
            //     // Check if all stops are completed
            //     if (stopsCompletionStatus.values.every((completed) => completed)) {
            //       widget.onTaskCompleted();
            //     }
            //   });
            // },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking - ${widget.location}'),
        backgroundColor: Color(0xFFFB4646),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 25.0)),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToMapSample(
                                  context, 'Stop 1', '31.4510192', '74.28988'),
                              child: _buildStopDot('Stop 1', 'UMT',
                                  stopsCompletionStatus['Stop 1']!),
                            ),
                            const SizedBox(height: 10),
                            _buildDateTimeInfo(
                                'Visit Date & Time', 'Submitted Date & Time'),
                            const SizedBox(height: 20),
                            _showButton(),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToMapSample(context,
                                    'Stop 2', '31.4796554', '74.2754984'),
                                child: _buildStopDot(
                                    'Stop 2',
                                    'Doctors Hospital',
                                    stopsCompletionStatus['Stop 2']!),
                              ),
                              const SizedBox(height: 10),
                              _buildDateTimeInfo(
                                  'Visit Date & Time', 'Submitted Date & Time'),
                              const SizedBox(height: 20),
                              _showButton(),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToMapSample(
                                  context, 'Stop 3', '41.40338', '2.17403'),
                              child: _buildStopDot(
                                  'Stop 3',
                                  '41.40338, 2.17403',
                                  stopsCompletionStatus['Stop 3']!),
                            ),
                            const SizedBox(height: 10),
                            _buildDateTimeInfo(
                                'Visit Date & Time', 'Submitted Date & Time'),
                            const SizedBox(height: 20),
                            _showButton(),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToMapSample(
                                  context, 'Stop 4', '41.40338', '2.17403'),
                              child: _buildStopDot(
                                  'Stop 4',
                                  '41.40338, 2.17403',
                                  stopsCompletionStatus['Stop 4']!),
                            ),
                            const SizedBox(height: 10),
                            _buildDateTimeInfo(
                                'Visit Date & Time', 'Submitted Date & Time'),
                            const SizedBox(height: 15),
                            _showButton(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFFB4646)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: const BorderSide(
                                      color: Colors.white, width: 2.0),
                                ),
                              ),
                              shadowColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              elevation: MaterialStateProperty.all<double>(5),
                            ),
                            child: const Text(
                              'All Task Completed',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopDot(String stopName, String location, bool isCompleted) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.red : Color(0xFFFB4646),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 5),
            Text(stopName),
          ],
        ),
        const SizedBox(width: 10),
        Text(
          location,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo(String visitDateTime, String submittedDateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$visitDateTime',
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$submittedDateTime',
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: () {
              _navigateToMapSample(context, 'Stop 3', '41.40338', '2.17403');
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFFFB4646)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
              shadowColor: MaterialStateProperty.all<Color>(Colors.black),
              elevation: MaterialStateProperty.all<double>(5),
            ),
            child: Text('Show on Maps')),
        ElevatedButton(
            onPressed: () {
              _navigateToStopDetailScreen(context);
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFFFB4646)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
              shadowColor: MaterialStateProperty.all<Color>(Colors.black),
              elevation: MaterialStateProperty.all<double>(5),
            ),
            child: Text('Shop Checkout'))
      ],
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 2.0,
      height: 100.0,
      color: Color(0xFFFB4646),
    );
  }
}
