import 'package:KhilafatCola/drawer/drawer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }
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

              decoration: BoxDecoration(
                image: DecorationImage(

                  image: AssetImage('assets/images/coke.png'),
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,),
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
                    // color: Colors.blue.shade400,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(image: AssetImage('assets/schoolbackground.jpg'),fit: BoxFit.cover),
                    //     gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    //       Colors.white,
                    //       Colors.green.shade400
                    //     ])),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,

                                            child: Text('Details',style: GoogleFonts.aclonica(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),)),
                                        // Align(
                                        //     alignment: Alignment.topLeft,
                                        //
                                        //
                                        //     child:greetings() ),
                                        SizedBox(height: 40,),

                                      ],
                                    ),
                                  )),

                            ],
                          ),

                        ],
                      ),
                    ),
                  ),


                  Expanded(
                    child: Container(

                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB71234), // A richer Coca-Cola Red
                              Color(0xFFF02A2A), // A slightly darker red
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          // image: DecorationImage(image: AssetImage('assets/backgrounds.jpg'),fit: BoxFit.cover),

                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60))),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Your Monthly Details',style: GoogleFonts.actor(color: Colors.white,fontSize: 22),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child:  Container(
                                height: 80,
                                width:  MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                  color: Colors.white,

                                ),
                                child: Center(
                                  child: ListTile(
                                    leading: Icon(Icons.arrow_circle_right_rounded,color: Colors.black,),
                                    title: Text('Canal Road',style: GoogleFonts.roboto(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400),),
                                    subtitle: Text('12-09-2024',style: GoogleFonts.roboto(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w700),),
                                    trailing: InkWell(
                                      onTap: () {
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB71234), // A richer Coca-Cola Red
                                              Color(0xFFF02A2A), // A slightly darker red
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Center(child: Text('Start',style: TextStyle(color: Colors.white),)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),),

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
}
