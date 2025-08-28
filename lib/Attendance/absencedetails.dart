import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsenceDetailScreen extends StatefulWidget {
  final String personName;

  AbsenceDetailScreen({required this.personName});

  @override
  _AbsenceDetailScreenState createState() => _AbsenceDetailScreenState();
}

class _AbsenceDetailScreenState extends State<AbsenceDetailScreen> {
  String severity = 'Moderate'; // Default severity
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absence Details', style: GoogleFonts.roboto(fontSize: 22)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person's Name
            Text(
              'Why is ${widget.personName} absent?',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Severity of absence label
            Text(
              'Severity of Absence',
              style: GoogleFonts.roboto(fontSize: 18),
            ),
           const SizedBox(height: 10),

            // Radio buttons for Severity
            // Row(
            //   children: [
            //     _buildSeverityOption('Leave'),
            //     // _buildSeverityOption('Moderate'),
            //     _buildSeverityOption('Low'),
            //   ],
            // ),
            // _buildSeverityOption('Moderate'),

            const SizedBox(height: 20),

            // Textfield for Additional Description
            // Text(
            //   'Additional Description',
            //   style: GoogleFonts.roboto(fontSize: 18),
            // ),
            // SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe reason for absence',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
           const  SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // You can handle form submission here
                  String description = descriptionController.text;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const  Text('Absence Details Submitted'),
                      content: Text(
                          'Severity: $severity\nDescription: $description'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for building severity option
  Widget _buildSeverityOption(String value) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: severity,
        onChanged: (String? newValue) {
          setState(() {
            severity = newValue!;
          });
        },
        title: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
