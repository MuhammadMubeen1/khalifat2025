import 'package:KhilafatCola/Route/sup_routelist.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../Supervisor/sup_teamscreen.dart';
import '../drawer/drawer.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  double achievedTarget = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/coke.png'),
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.menu, size: 30, color: Colors.redAccent),
                      onPressed: _openDrawer,
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInUp(
                                duration: Duration(milliseconds: 1000),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Dashboard',
                                          style: GoogleFonts.lato(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB71234), // A richer Coca-Cola Red
                            Color(0xFFF02A2A), // A slightly darker red
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // White background container
                                    Column(
                                      children: [
                                        Text(
                                          'XYZ',
                                          style: GoogleFonts.lato(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(top: 20.0)),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // White background
                                            borderRadius: BorderRadius.circular(
                                                20), // Rounded corners
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 3,
                                                blurRadius: 8,
                                                offset: Offset(
                                                    0, 3), // Shadow position
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Route Button with Icon and Text
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RouteListScreen()));
                                                    },
                                                    child: Icon(
                                                      Icons.route,
                                                      color: Colors
                                                          .redAccent, // Icon color
                                                      size: 50, // Icon size
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          8), // Space between icon and text
                                                  Text(
                                                    'My Routes',
                                                    style: TextStyle(
                                                      fontSize: 16, // Font size
                                                      fontWeight: FontWeight
                                                          .bold, // Font weight
                                                      color: Colors
                                                          .black87, // Text color
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(
                                                  width:
                                                      20), // Space between buttons

                                              // Teams Button with Icon and Text
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyTeamScreen()));
                                                    },
                                                    child: Icon(
                                                      Icons.group,
                                                      color: Colors
                                                          .greenAccent, // Icon color
                                                      size: 50, // Icon size
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          8), // Space between icon and text
                                                  Text(
                                                    'My Teams',
                                                    style: TextStyle(
                                                      fontSize: 16, // Font size
                                                      fontWeight: FontWeight
                                                          .bold, // Font weight
                                                      color: Colors
                                                          .black87, // Text color
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Center(
                              child: Text(
                                'My Target',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20.0)),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: _buildProgressWithText(
                                achievedTarget,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20.0)),
                            Center(
                              child: Text(
                                'My Orders',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20.0)),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(
                                    16.0), // Add padding for spacing
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Set the background color to white
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Optional: Rounded corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2), // Shadow position
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Orders: 10',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8.0), // Space between text items
                                    Text(
                                      'Total Shops: 50',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8.0), // Space between text items
                                    Text(
                                      'Total Price: 25000',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20.0)),
                            Center(
                              child: Text(
                                'My Sales',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 20.0)),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(
                                    16.0), // Add padding for spacing
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Set the background color to white
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Optional: Rounded corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2), // Shadow position
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Orders: 10',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8.0), // Space between text items
                                    Text(
                                      'Total Shops: 50',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8.0), // Space between text items
                                    Text(
                                      'Total Price: 25000',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
