import 'package:KhilafatCola/order_confirmation/Order_Confirmation_screen.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Map<String, int> itemQuantities = {
    'Cola Flavoured Drink 300ml': 1,
    'Lime Flavoured Drink 300ml': 1,
    'Orange Flavoured Drink 330ml': 1,
    'Cola Flavoured Drink 1.5L': 1,
    'Lime Flavoured Drink 1.5L': 1,
    'Orange Flavoured Drink 1.5L': 1,
    'Cola Flavoured Drink 1L': 1,
    'Lime Flavoured Drink 1L': 1,
    'Orange Flavoured Drink 1L': 1,
  };

  void _incrementQuantity(String itemName) {
    setState(() {
      itemQuantities[itemName] = itemQuantities[itemName]! + 1;
    });
  }

  // Function to decrement item quantity
  void _decrementQuantity(String itemName) {
    setState(() {
      if (itemQuantities[itemName]! > 1) {
        itemQuantities[itemName] = itemQuantities[itemName]! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Text('My Cart'),
      //   actions: [
      //     TextButton(onPressed: (){}, child: Text('Shop Close',style: TextStyle(color: Colors.white),)),
      //     TextButton(onPressed: (){
      //       Navigator.push(context, MaterialPageRoute(builder: (context)=>StopDetailScreen()));
      //
      //     }, child: Text('Order Confirm',style: TextStyle(color: Colors.white),))
      //
      //   ],
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB71234), // A richer Coca-Cola Red
                          Color(0xFFF02A2A), // A slightly darker red
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyCartScreen()));
                          },
                          child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: Center(
                                  child: Text(
                                'Shop Close',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ))),
                        ),
                        // TextButton(onPressed: (){}, child: Text('Shop Close',style: TextStyle(color: Colors.white),)),

                        InkWell(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>StopDetailScreen()));
                          },
                          child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: Center(
                                  child: Text(
                                'Order Confirm',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ))),
                        ),
                      ],
                    ),
                  ),
                  ...itemQuantities.keys.map((itemName) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8.0),
                            Image.asset(
                              'assets/images/Colacan.png',
                              height: 100.0,
                              width: 100.0,
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Quantity: ${itemQuantities[itemName]}'),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Text('Rs. 150',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.remove_circle),
                                        onPressed: () {
                                          _decrementQuantity(itemName);
                                        },
                                      ),
                                      Text('${itemQuantities[itemName]}'),
                                      IconButton(
                                        icon: Icon(Icons.add_circle),
                                        onPressed: () {
                                          _incrementQuantity(itemName);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            thickness: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
