import 'package:flutter/material.dart';

class FoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('Food Ordering App'),
          leading: Icon(Icons.menu),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart),
            ),
          ],
        ),
        body: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _CategoryCard(
                        title: 'Pizza',
                        itemCount: 25,
                        icon: Image.asset('assets/pizza.png'),
                      ),
                      _CategoryCard(
                        title: 'Salads',
                        itemCount: 30,
                        icon: Image.asset('assets/salad.png'),
                      ),
                      _CategoryCard(
                        title: 'Desserts',
                        itemCount: 30,
                        icon: Image.asset('assets/dessert.png'),
                      ),
                      _CategoryCard(
                        title: 'Pasta',
                        itemCount: 44,
                        icon: Image.asset('assets/pasta.png'),
                      ),
                      _CategoryCard(
                        title: 'Beverages',
                        itemCount: 30,
                        icon: Image.asset('assets/beverage.png'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final Image icon;

  _CategoryCard({required this.title, required this.itemCount, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '$itemCount items',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}