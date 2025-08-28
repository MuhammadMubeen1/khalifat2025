import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red
              ),
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
