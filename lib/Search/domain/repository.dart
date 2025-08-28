import 'dart:convert';
import 'package:KhilafatCola/widgets/Splash.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


import '../../utils/widgets.dart';
import '../../widgets/const.dart';
import '../data/data_model.dart';

final String url =
    "${Constants.BASE_URL}/api/App/GetAllTerritoryShopByUserId?userId=$userid&lat=$currentlat&lng=$currentlng&appDateTime=${getCurrentDateTime()}";

// Parsing the 'Data' part of the response
List<User> parseUser(String responseBody) {
  var parsed = json.decode(responseBody);

  // Check if 'Data' exists and is not null, otherwise return an empty list
  if (parsed['Data'] != null && parsed['Data'] is List) {
    var list = parsed['Data'] as List<dynamic>;
    return list.map((e) => User.fromJson(e)).toList();
  } else {
    return []; // Return an empty list if 'Data' is null
  }
}

Future<List<User>> fetchUsers() async {
  final http.Response response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': '6XesrAM2Nu', // Adding Authorization header
      'Content-Type': 'application/json', // Add Content-Type if needed
    },
  );

  if (response.statusCode == 200) {
    print('B:${response.body}'); // Debugging the response body
    return compute(parseUser, response.body);
  } else {
    throw Exception(
        'Failed to load users. Status code: ${response.statusCode}');
  }
}
