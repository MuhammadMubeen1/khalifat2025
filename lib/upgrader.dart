import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppUpdateChecker {
  // You would host a JSON file on your server containing version info
  static const String UPDATE_URL = 'https://your-server.com/app_version.json';

  // Store your app's Google Play Store URL
  static const String PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.khilafat.cola';

  // Check if update is required
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // For demo purposes, we'll use hardcoded values
      // In production, you would fetch this from your server
      String currentVersion = "1.0.1"; // Your app's current version

      // Uncomment below code to get actual app version once package_info_plus is properly set up
      // PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // String currentVersion = packageInfo.version;

      String requiredVersion = "1.0.0"; // Minimum required version

      print(
          "Current version: $currentVersion, Required version: $requiredVersion");

      // Compare versions
      if (isUpdateRequired(currentVersion, requiredVersion)) {
        // Make sure context is still valid before showing dialog
        if (context.mounted) {
          _showUpdateDialog(context);
        }
      }
    } catch (e) {
      print("Error checking for updates: $e");
      // Don't crash app if update check fails
    }
  }

  // Helper method to compare version strings (e.g., "1.0.7" vs "1.0.8")
  static bool isUpdateRequired(String currentVersion, String requiredVersion) {
    try {
      List<int> current =
          currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> required =
          requiredVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      // Ensure both lists have same length
      while (current.length < required.length) current.add(0);
      while (required.length < current.length) required.add(0);

      // Compare version segments
      for (int i = 0; i < required.length; i++) {
        if (current[i] < required[i]) return true;
        if (current[i] > required[i]) return false;
      }

      return false; // Versions are equal
    } catch (e) {
      print("Error comparing versions: $e");
      return false; // If comparison fails, don't require update
    }
  }

  // Show forced update dialog
  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
              'A new version of the app is available. You must update to continue using the app.'),
          actions: [
            TextButton(
              child: const Text('Update Now'),
              onPressed: () {
                _launchAppStore();
              },
            ),
            TextButton(
              child: const Text('Close App'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Launch the app store
  static Future<void> _launchAppStore() async {
    try {
      final Uri url = Uri.parse(PLAY_STORE_URL);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print("Error launching app store: $e");
    }
  }

  // For production use: fetch version info from server
  static Future<Map<String, dynamic>> _fetchVersionInfo() async {
    try {
      final response = await http.get(Uri.parse(UPDATE_URL));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching version info: $e');
    }
    return {'currentRequiredVersion': '1.0.0'};
  }
}
