import 'package:flutter/material.dart';

class MyApp5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Henry Kunjumon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Sales Manager'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard(
                color: Colors.blue,
                title: 'Today\'s Lead',
                icon: Icons.add_shopping_cart,
                pending: 482,
                completed: 82,
                progress: 30,
              ),
              _buildCard(
                color: Colors.yellow,
                title: 'Today\'s Meeting',
                icon: Icons.people,
                pending: 482,
                completed: 82,
                progress: 0,
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard(
                color: Colors.red,
                title: 'Today\'s Visit',
                icon: Icons.location_pin,
                pending: 482,
                completed: 82,
                progress: 0,
              ),
              _buildCard(
                color: Colors.cyan,
                title: 'New Lead',
                icon: Icons.add_shopping_cart,
                pending: 482,
                completed: 82,
                progress: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required String title,
    required IconData icon,
    required int pending,
    required int completed,
    required int progress,
  }) {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon),
                  Icon(Icons.arrow_upward_outlined),
                ],
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$pending',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending'),
                  Text('Completed'),
                ],
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress'),
                  Text('$progress%'),
                ],
              ),
            ],
          ),
        ),
        color: color,
      ),
    );
  }
}
