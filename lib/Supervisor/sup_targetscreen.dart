import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

double achievedTarget = 50;

class _TargetScreenState extends State<TargetScreen> {
  Widget _buildProgressWithText(double achievedTarget) {
    return Container(
      padding: EdgeInsets.all(16), // Add padding around the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the progress bar container
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 8,
            offset: Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: achievedTarget / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.redAccent,
                  ),
                ),
              ),
              // Text in the center of the CircularProgressIndicator
              Text(
                '${achievedTarget.toStringAsFixed(0)}%', // Display achieved target as a percentage
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Text color
                ),
              ),
            ],
          ),

          // Spacer between CircularProgressIndicator and text
          SizedBox(width: 20),

          // Text next to the progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achieved Target',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8), // Space between the two texts
              Text(
                '${(100 - achievedTarget).toStringAsFixed(0)}% Remaining',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent, // Lighter color for remaining text
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('This Month Target'),
        ),
        body: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(
              'Total Target',
              style: TextStyle(fontSize: 20.0),
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            FadeInUp(
              duration: Duration(milliseconds: 1500),
              child: _buildProgressWithText(
                achievedTarget,
              ),
            ),
          ],
        ));
  }
}