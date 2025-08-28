import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/widgets.dart';

class ShopOrderDetailScreen extends StatefulWidget {
  final List<dynamic> products;
  final shopName;
  final shopAddress;
  final Number;
  final Status;
  final date;
  final vehicalname;
  final drivername;
  final kcnumber;
  final driverPhone;
  const ShopOrderDetailScreen(
      {super.key,
      required this.products,
      this.shopName,
      this.shopAddress,
      this.Number,
      this.Status,
      this.date,
      this.vehicalname,
      this.drivername,
      this.kcnumber,
      this.driverPhone});

  @override
  State<ShopOrderDetailScreen> createState() => _ShopOrderDetailScreenState();
}

class _ShopOrderDetailScreenState extends State<ShopOrderDetailScreen> {
  Map<String, dynamic> calculateTotals() {
    int totalQuantity = 0; // Change to int
    double totalPrice = 0;

    for (var product in widget.products) {
      // Ensure ItemQuantity is treated as an integer
      totalQuantity = product['ItemQuantity'].toInt() +
          totalQuantity; // Using toInt() here to ensure no decimal values
      totalPrice += product['TradePrice'] * product['ItemQuantity'];
    }

    return {
      'totalQuantity': totalQuantity, // Keep as int
      'totalPrice': totalPrice,
    };
  }

  @override
  void initState() {
    print('KC Challan ${widget.kcnumber}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals();
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
          backgroundColor: Colors.red, title: const Text("Products Details")),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: [
            widget.vehicalname == null
                ? Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\u2022  ${widget.Status}  \u2022',
                                    style: GoogleFonts.cinzel(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Shop Name : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.shopName,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Shop Address : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.shopAddress,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Phone No : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.Number,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Order Date : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: convertTo12HourFormat(widget.date),
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          spreadRadius: 4,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\u2022  ${widget.Status}  \u2022',
                                    style: GoogleFonts.cinzel(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Shop Name : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.shopName,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Shop Address : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.shopAddress,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Phone No : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.Number,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Order Date : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: convertTo12HourFormat(widget.date),
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Driver Name : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.drivername,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Driver Phone No : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.driverPhone,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Vehicle Name : ',
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: widget.vehicalname,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Challan Code : ',
                                      style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    TextSpan(
                                      text: widget.kcnumber,
                                      style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                          ClipboardData(text: widget.kcnumber))
                                      .then((_) {
                                    // Optionally, show a snackbar or toast notification
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Challan Code copied to clipboard!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  size: 15,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Order Details',
              style:
                  GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(
              thickness: 1,
              color: Colors.black,
              indent: 110,
              endIndent: 110,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  double totalPrice = (widget.products[index]['TradePrice'] *
                      widget.products[index]['ItemQuantity']);
                  // int totalQuantity = products[index].fold(0, (sum, item) => sum + item['ItemQuantity']);
                  return Column(
                    children: [
                      ListTile(
                        leading: Image.network(
                          'http://kcapiqa.fscscampus.com/${widget.products[index]['ImageName']}',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          '${widget.products[index]['ProductName']} (${widget.products[index]['VolumeInMl']} ml ${widget.products[index]['ProductType']})',
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trade Price: ${widget.products[index]['TradePrice']}',
                              style: GoogleFonts.lato(
                                  color: Colors.black, fontSize: 14),
                            ),
                            Text(
                              'Quantity in Pack: ${widget.products[index]['QuantityInPack']}',
                              style: GoogleFonts.lato(
                                  color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'QTY',
                              style: GoogleFonts.lato(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.products[index]['ItemQuantity']}',
                              style: GoogleFonts.lato(
                                  color: Colors.black, fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        endIndent: 10,
                        indent: 10,
                        color: Colors.black,
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Quantity: ${totals['totalQuantity']}',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Total Price: ${totals['totalPrice']?.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
